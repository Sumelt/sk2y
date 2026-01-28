
local skynet = require "skynet"
local crypt = require "skynet.crypt"
local cluster = require "skynet.cluster"
local login = require "login_gate"
local log = require "log"

local server = {
    host = "0.0.0.0",
    port = 8001,
    multilogin = false, -- multilogin
    name = "logind",
	instance = 1,
}

local user_online = {}
local server_list = {}

function server.auth_handler(token)
	-- the token is base64(user)@base64(server):base64(password)
	local user, server, password = token:match("([^@]+)@([^:]+):(.+)")
	user = crypt.base64decode(user)
	server = crypt.base64decode(server)
	password = crypt.base64decode(password)
	assert(password == "password", "Invalid password")
	return server, user
end

function server.login_handler(server, uid, secret)
	log.info("tag=login,%s@%s is login, secret is %s", uid, server, crypt.hexencode(secret))
	local gameserver = assert(server_list[server], "Unknown server")
	-- only one can login, because disallow multilogin
	local last = user_online[uid]
	if last then
		skynet.call(last.address, "lua", "kick", uid, last.subid)
	end
	if user_online[uid] then
		error(string.format("user %s is already online", uid))
	end

	local subid = tostring(skynet.call(gameserver, "lua", "login", uid, secret))
	user_online[uid] = {address = gameserver, subid = subid , server = server}
	return subid
end

local CMD = {}

function CMD.register_gate(server, address) 
	local proxy = cluster.proxy("game", address) 
	server_list[server] = proxy 
	print("register Game:", server, address)
end

function CMD.logout(uid, subid)
	local u = user_online[uid]
	if u then
		print(string.format("%s:%s@%s is logout", subid, uid, u.server))
		user_online[uid] = nil
	end
end

function server.command_handler(command, ...)
	local f = assert(CMD[command])
	return f(...)
end

login(server)
