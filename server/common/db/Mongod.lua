
require "skynet.manager"
local skynet = require "skynet"
local driver = require "MongoDriver"

skynet.start(function()
	skynet.register(".mongo")
	driver.connetMongo()
end)
