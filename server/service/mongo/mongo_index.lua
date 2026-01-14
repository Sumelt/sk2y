
local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local mongoConfig = require "etc.mongo"

local CMD = {}

function CMD.create_indexes()
    local all_ok = true
	local dbCfg = mongoConfig.getDBCfg()
	local dbName = mongoConfig.getDBName()
	local colTbl = mongoConfig.getColTbl()
	local dbs = mongo.client(dbCfg)
	local db = dbs[dbName]
	for colName, _ in pairs(colTbl) do
            local collection = db[colName]
            if collection then
                for _, index in ipairs(mongoConfig.getColIndex(colName)) do
                    local ok, err = pcall(collection.createIndex, collection, index)
                    if not ok then
                        all_ok = false
                        log.error("failed to create index,dbname=%s,coll_name=%s,err=%s", dbname, coll_name, err)
                    else
                        log.info("index created successfully,dbname=%s,coll_name=%s,index=%s", dbname, coll_name, index)
                    end
                end
			else
                log.error("collection not found,dbname=%s,coll_name=%s", dbname, coll_name)
                all_ok = false
			end
	end
    return all_ok
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], string.format('mongodb unknown operation: %s', cmd))
		if cmd == "socket" then
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)
