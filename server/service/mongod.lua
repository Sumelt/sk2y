
require "skynet.manager"
local skynet = require "skynet"
local mongo = require "skynet.db.mongo"
local mongoConfig = require "etc.mongo"

local db = nil
local dbName, index = ...

local CMD = {}

function CMD.find_and_modify(coll, doc)
    local colObj = db[coll]
    return colObj:findAndModify(doc)
end

function CMD.find(coll, doc, projection)
    local colObj = db[coll]
    local it = colObj:find(doc, projection)
    local all = {}
    while it:hasNext() do
        local role = it:next()
        all[#all + 1] = role
    end
    return all
end

function CMD.find_one(coll, doc, projection)
    local colObj = db[coll]
    return colObj:findOne(doc, projection)
end

function CMD.raw_safe_insert(coll, bson_str)
    local colObj = db[coll]
    return colObj:raw_safe_insert(bson_str)
end

function CMD.raw_safe_update(coll, bson_str)
    local colObj = db[coll]
    return colObj:raw_safe_update(bson_str)
end

function CMD.drop(coll)
    local colObj = db[coll]
	colObj:drop()
end

local function initMongo(dbName, index)
	local cfg = mongoConfig.getDBCfg()
	local dbs = mongo.client(cfg)
	db = dbs[dbName]
end

skynet.start(function()
	initMongo(dbName, index)
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], string.format('unknown operation: %s', cmd))
		if cmd == "socket" then
			f(...)
		else
			skynet.ret(skynet.pack(f(...)))
		end
	end)
end)

skynet.register("."..SERVICE_NAME..index)


