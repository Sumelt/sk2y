
local skynet = require "skynet"

local config = {
	login = {
		agent = 2,
		port = 8080,
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

function M.getPort()
	local config = getNodeCfg()
	return config.port
end

function M.getAgentCnt()
	local config = getNodeCfg()
	return config.agent
end

return M
