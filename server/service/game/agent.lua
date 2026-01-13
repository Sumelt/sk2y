
require "skynet.manager"
local skynet = require "skynet"
local snax = require "skynet.snax"
local sys = require "extend"

local AgentNames = {} -- { username = { } }

function response.login(gate, uid, subid, secret, username)
	assert(AgentNames[username] == nil)
	AgentNames[username] = {
			gate = gate,
			uid = uid,
			subid = subid,
			secret = secret,
			online = true,
			username = username,
	}
	return true
end

function response.logout(username)
	local agentUser = AgentNames[username] 
	assert(agentUser)
	skynet.call(agentUser.gate, "lua", "logout", username, agentUser.uid)
	AgentNames[username] = nil
end

function response.afk(address, username)
	local agentUser = AgentNames[username]
	if agentUser and agentUser.online then
		local snaxd = snax.self()			
		snaxd.req.logout(username)
	end
end

function init()
	skynet.register_protocol {
		name = "client",
		id = skynet.PTYPE_CLIENT,
		unpack = skynet.tostring,
		dispatch = function(session, source, msg)
			skynet.ret(msg)
		end
	}
end


