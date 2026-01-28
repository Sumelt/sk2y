
local log = require "log"
local skynet = require "skynet"
local http_server = require "http"
local accountConfig = require "etc.account"

--[[
local gameOnlineTbl = {}

function response.init()
	snax.enablecluster()
	cluster.register(SERVICE_NAME)
end

function response.authIGGID(iggid, accessToken, platform, language, clientaddr, selectGameNode)
	if ( not accessToken or accessToken == "" ) then
		log.warn("tag=authIGGID,%s,accessToken fail", iggid)
		return nil, nil, nil, true
	end
end

function accept.registerGameOnline(gameNode, openTime)
	table.insert(gameOnlineTbl, {
		gameNode = gameNode,
		openTime = openTime,
	})
	table.sort(gameOnlineTbl, function(a, b)
		return a.openTime > b.openTime
	end)
end

]]

skynet.start(function()
    log.info("accountd start begin")
    local port = accConfig.getPort()
    local agent_count = accountConfig.getAgentCnt()
    local conf = {
        port = port,
        agent_count = agent_count,
    }
    http_server.start(conf)
    http_server.register_router("router.account")
    skynet.exit()
end)


