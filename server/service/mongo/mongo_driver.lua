
local log = require "log"
local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local clsBase = require "mongo_base"

local M = {}
local dbs = {
	--[[
		[dbName] = dbObj
	--]]
}
local dbLocks = {
	--[[
		[dbName] = lock
	--]]
}

local function createDBObj(dbName)
		local oci = {
				_name = dbName,
				_collections = {},
				_conns = {},
		}
		local dbObj = clsBase:New(oci)
		dbs[dbName] = dbObj
		return dbObj
end

local function getDBObj(dbName)
	local dbObj = dbs[dbName]
	if dbObj then
		return dbObj	
	end

	local lock = dbLocks[dbName]
	if not lock then
		dbLocks[dbName] = skynet.queue()
	end
	return lock(function (dbName)
		local dbObj = dbs[dbName]
		if dbObj then
			return dbObj	
		end
		return createDBObj(dbName)
	end, dbName)
end

function M.getCollection(dbName, coll)
	local dbObj = getDBObj(dbName)	
	return dbObj:getCollection(coll)
end

return M
