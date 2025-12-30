
local log = require "Log"
local skynet = require "skynet"
local mongo = require "skynet.db.mongo"

local mode = {}
local connetList = {}

function mode:getMongoClinet()
	return math.random(1, table.size(connetList))
end

function mode:connetMongo()
	for i = 1, skynet.getenv("db_pool_size") do
		local client = mongo.client({
			host = skynet.getenv("db_host"),
			port = skynet.getenv("db_port"),
			username = skynet.getenv("db_username"),
			password = skynet.getenv("db_password"),
			authdb = skynet.getenv("db_auth"),
		})
		table.insert(connetList, client)
	end
	log.info("tag=mongodb,connect success,poolSize:%s", table.size(connetList))
end

return mode
