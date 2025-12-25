
local skynet = require "skynet"
local cluster = require "skynet.cluster"

skynet.start(function()
		cluster.reload({
				login = "127.0.0.1:7101",  
				game = "127.0.0.1:7102",  
		})
        skynet.uniqueservice(true, "Logind")
		cluster.open(skynet.getenv("node"))
		cluster.register("Logind")
        skynet.exit()
    end
)
