
local snax = require "skynet.snax"
local cluster = require "skynet.cluster"
local log = require "log"

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

