local skynet = require "skynet"

local config = {
	login = {
		dbName = "sk2y-login",
        connections = 2,
        cfg = {
            host = "127.0.0.1",
            port = 27017,
            username = "sk2y",
            password = "sk2y",
            authdb = "admin",
        },
        collections = {
            role = {
                indexes = {
                    { "rid", unique = true, background = true },
                    { "account", "server", background = true },
                },
            },
        },
    },
}

local M = {}

local function getNode()
	return skynet.getenv("node")
end

local function getNodeCfg()
	local node = getNode()
	return config[node]
end

function M.getConnection()
	local config = getNodeCfg()
	return config.connections
end

function M.getDBName()
	local config = getNodeCfg()
	return config.dbName
end

function M.isExistDB(dbName)
	return M.getDBName() == dbName
end

function M.getDBCfg()
	local config = getNodeCfg()
	return config.cfg
end

function M.getColTbl()
	local config = getNodeCfg()
	return config.collections
end

function M.getColInfo(colName)
	return M.getColTbl()[colName]
end

function M.getColIndex(colName)
	local info = M.getColInfo(colName)
	return info.indexes
end

return M
