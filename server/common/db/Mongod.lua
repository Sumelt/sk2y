
require "skynet.manager"
local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local client = nil

skynet.start(function()
	skynet.register(".mongo")
	client = mongo.client({
		host = skynet.getenv("db_host"),
		port = skynet.getenv("db_port"),
		username = skynet.getenv("db_username"),
		password = skynet.getenv("db_password"),
		authdb = skynet.getenv("db_auth"),
	})
	local db = client[skynet.getenv("db_name")]
end)
