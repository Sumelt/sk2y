
require "skynet.manager"
local skynet = require "skynet"
local cluster = require "skynet.cluster"

skynet.start(function()
	cluster.reload({
		login = "127.0.0.1:7101",
		game = "127.0.0.1:7102",
	})
	local addr = skynet.uniqueservice(true, "gamed")
	skynet.call(addr, "lua", "open", {
		port = tonumber(skynet.getenv("port")) or 8888,
		maxclient = tonumber(skynet.getenv("maxclient")) or 1024,
		servername = "sample",
	})
	cluster.register("csGamed")
	cluster.open(skynet.getenv("node"))
	cluster.call("login", ".logind", "register_gate", "sample", addr)
	skynet.exit()
end
)
