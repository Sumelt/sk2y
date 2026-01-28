
local log = require "log"
local skynet = require "skynet"
local socket = require "skynet.socket"

local CMD = {}
local agents = {}

function CMD.start(conf)
	local port = conf.port or 8080
	local agent_count = conf.agent_count or 8
	for agent_id = 1, agent_count do
		local agent = skynet.newservice("http/agent", agent_id)
		agents[agent_id] = agent
	end

	local host = conf.host or "0.0.0.0"
	local balance = 1
	local listen_id = socket.listen(host, port)
	log.info("start http, host=%s, port=%s", host, port)
	socket.start(listen_id, function(id, addr)
		skynet.send(agents[balance], "lua", "socket", "request", id, addr)
		balance = balance + 1
		if balance > #agents then
			balance = 1
		end
	end)
end

function CMD.register_router(router_name)
	for _, agent in pairs(agents) do
		skynet.send(agent, "lua", "register_router", router_name)
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], string.format('watchdog unknown operation: %s', cmd))
		if cmd == "socket" then
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)



