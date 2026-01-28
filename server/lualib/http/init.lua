
local skynet = require "skynet"
local log = require "log"

local M = {}

function M.start(conf)
    local watchdog = skynet.newservice("http/watchdog")
    skynet.call(watchdog, "lua", "start", conf)
end

function M.register_router(router_name)
    local watchdog = skynet.queryservice("watchdog")
    if not watchdog then
        log.error("http_watchdog not exist, router_name=%s", router_name)
        return
    end
    skynet.call(watchdog, "lua", "register_router", router_name)
end

return M
