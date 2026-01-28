
local log = require "log"
local skynet = require "skynet"
local http_server = require "http"
local accountConfig = require "etc.account"

skynet.start(function()
    log.info("accountd start begin")
    local port = 8080
    local agent_count = 1
    local conf = {
        port = port,
        agent_count = agent_count,
    }
    http_server.start(conf)
    http_server.register_router("router.account")
    skynet.exit()
end)
