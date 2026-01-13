
local sys = require "extend"
local skynet = require "skynet"
local snax = require "skynet.snax"
local gameGate = require "game_gate"
local cluster = require "skynet.cluster"
require "skynet.manager"

local SERVER_NAME = nil
local INTERNAL_ID = 0
local server = {}

local uid_agent = {}
local username_map = {}

-- login server disallow multi login, so login_handler never be reentry
-- call by login server
function server.login_handler(uid, secret)
	INTERNAL_ID = INTERNAL_ID + 1 -- don't use internal_id directly
	local subid = INTERNAL_ID
	local username = gameGate.username(uid, subid, SERVER_NAME)

	if not uid_agent[uid] then
		uid_agent[uid] = assert(snax.newservice("Agent"))
	end
	local agent = uid_agent[uid]

	-- trash subid (no used)
	agent.req.login(skynet.self(), uid, subid, secret, username)
	local u = {
		username = username,
		agent = agent,
		uid = uid,
		subid = subid,
	}
	assert(username_map[username] == nil)
	username_map[username] = u
	gameGate.login( username, secret )

	-- you should return unique subid
	return subid
end

-- call by agent
function server.logout_handler(username, uid)
	local u = username_map[username]
	if u then
		gameGate.logout(username)
		username_map[username] = nil
		uid_agent[uid] = nil
		cluster.call("login", ".Logind", "logout", uid, u.subid)
	end
end

-- call by self (when socket disconnect)
function server.disconnect_handler(username)
	local u = username_map[username]
	if u then
		u.agent.req.afk(skynet.self(), username)
	end
end

-- call by self (when recv a request from client)
function server.request_handler(username, msg)
	local u = username_map[username]
	--msg = string.pack('<d', username:len()) .. username .. msg
	return skynet.tostring(skynet.rawcall(u.agent.handle, "client", msg))
end

-- call by self (when gate open)
function server.register_handler(name)
	SERVER_NAME = name
end

-- call by web
function server.clean_handler()
	for _, agent in pairs(uid_agent) do
		agent.req.cleanAgent()
	end
end

-- call by login server
function server.kick_handler(uid, subid)
	print(uid, subid)
	local agent = uid_agent[uid]
	if agent then
		local username = gameGate.username(uid, subid, SERVER_NAME)
		agent.req.logout(username)
	end
end

skynet.register("."..SERVICE_NAME)

gameGate.start(server)
