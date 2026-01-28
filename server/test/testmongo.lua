
local skynet = require "skynet"
local driver = require "mongo.driver"
local dbMgr = require "mongo.mgr"
local sys = require "extend"

skynet.start(function()
		driver.getCollection("sk2y-login", "role")
		local addr = skynet.newservice("indexd")
		local ok = skynet.call(addr, "lua", "create_indexes")
		if ok then
			print("ok")	
		else
			print("no")
		end
		local doc = dbMgr.load("sk2y-login", "role", "rid", 123)
end)
