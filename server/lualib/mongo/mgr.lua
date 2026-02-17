local orm = require "orm"
local schema = require "orm.schema"
local driver = require "mongo.driver"
local timer = require "timer"
local log = require "log"
local mongoConfig = require "etc.mongo"
local sys = require "extend"

local mongo_config

local g_collection_obj = {} -- 数据库链接
local g_cache_collection = {} -- 缓存数据对象
local g_default_projection = { _id = false }
local db_save_interval = 5

local M = {}

local function check_collection(dbName, dbCol)
    if not mongoConfig.isExistDB(dbName) then
        error("database not configured" .. dbName)
    end

    local coll_config = mongoConfig.getColInfo(dbCol)
    if coll_config == nil then
        error("collection not configured" .. dbName .. "." .. dbCol)
    end
end

local function get_collection_obj(dbName, dbCol)
    if not g_collection_obj[dbName] then
        g_collection_obj[dbName] = {}
    end
    local colls = g_collection_obj[dbName]
    if not colls[dbCol] then
        local colObj = driver.getCollection(dbName, dbCol)
        colls[dbCol] = colObj
        log.info("tag=new mongo collection,dbName=%s,dbCol=%s", dbName, dbCol)
    end
    return colls[dbCol]
end

local function get_cache_collection(dbName, dbCol)
    if not g_cache_collection[dbName] then
        g_cache_collection[dbName] = {}
    end
    local colls = g_cache_collection[dbName]
    if not colls[dbCol] then
        colls[dbCol] = {}
    end
    return colls[dbCol]
end

local function save_dirty(coll_obj, query, dirty_doc)
    local ok, err, ret = coll_obj:safe_update(query, dirty_doc, true)
    if not ok then
		log.error("save failed, ret=%s, err=%s",ret, err)
        return false
    end

    if ret.nModified ~= 1 then
		log.error("save failed not modified, ret=%s, err=%s",ret, err)
        return false
    end
    return true
end

local function save_doc(coll_obj, key, unique_id, doc)
    if not orm.is_dirty(doc) then
        return true
    end

    local old_version = doc._version
    doc._version = old_version + 1
    local query = {
        [key] = unique_id,
        _version = old_version,
    }
    local is_dirty, dirty_doc = orm.commit_mongo(doc)
    if not is_dirty then
        return true
    end
    local ok = save_dirty(coll_obj, query, dirty_doc)
    if not ok then
        doc._version = doc._version - 1
    end
    return true
end

-----------------------------------------------------------------------------------------------------------
function M.unload(dbName, dbCol, key, unique_id)
	check_collection(dbName, dbCol)

    local cache_collection = get_cache_collection(dbName, dbCol)
    if not cache_collection then
        return
    end
    local cache = cache_collection[unique_id]
    if not cache then
        return
    end

    if cache.loading then
        return
    end

    if cache.unloading then
        return
    end

    cache.unloading = true

    -- 先取消定时存盘
    cache.timer_obj:cancel()

    local doc = cache.doc
    if not doc then
        return
    end

    local coll_obj = get_collection_obj(dbName, dbCol)
    local ok = save_doc(coll_obj, key, unique_id, doc)
    if not ok then
		log.error("unload save failed")
    end

    cache.unloading = nil
    -- 移除 cache
    cache_collection[unique_id] = nil

end

function M.load(dbName, dbCol, key, unique_id, default)
	check_collection(dbName, dbCol)

    local cache_collection = get_cache_collection(dbName, dbCol)
    if cache_collection[unique_id] then
        return cache_collection[unique_id].doc
    end

    -- 防重入，提前占位
    cache_collection[unique_id] = {
        loading = true,
    }

    local t = default or {}
    t[key] = unique_id
    t._version = 0

    -- 从数据库加载数据
    local coll_obj = get_collection_obj(dbName, dbCol)
    local ret = coll_obj:find_and_modify({
        query = { [key] = unique_id },
        update = { ["$setOnInsert"] = t },
        fields = g_default_projection,
        upsert = true,
        new = true,
    })
    if ret.ok ~= 1 then
		log.error("load failed")
        return
    end

    -- 防止重入
    if not cache_collection[unique_id].loading then
        return cache_collection[unique_id].doc
    end

    -- 用 orm 包裹: dbCol 为 schema name
    local doc = schema[dbCol].new(ret.value)

    -- 定时器入库脏数据(随机分布)
    local timer_obj = timer.repeat_random_delayed("mongo_mgr", db_save_interval, function()
        save_doc(coll_obj, key, unique_id, doc)
    end)

    cache_collection[unique_id] = {
        doc = doc,
        timer_obj = timer_obj,
    }
    return doc
end

return M
