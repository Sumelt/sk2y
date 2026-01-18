
local skynet = require "skynet"
local driver = require "mongo_driver"
local dbMgr = require "mongo_mgr"
local sys = require "extend"

skynet.start(function()
		driver.getCollection("sk2y-login", "role")
		local addr = skynet.newservice("mongo_index")
		local ok = skynet.call(addr, "lua", "create_indexes")
		if ok then
			print("ok")	
		else
			print("no")
		end
		local doc = dbMgr.load("sk2y-login", "role", "rid", 123)
		doc._version = 6
end)
