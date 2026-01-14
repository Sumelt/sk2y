
local skynet = require "skynet"
local driver = require "mongo_driver"

skynet.start(function()
		driver.getCollection("sk2y-login", "role")
    end
)
