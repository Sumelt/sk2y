local log = require "log"
local skynet = require "skynet"
local mc = require "skynet.multicast"
local dispatch = require "dispatch_api"

local M = {}
local g_client_channels = {}
local g_server_channel = nil

local function channel_new(service, subscribe_cmd)
    local up_channel = skynet.call(service, "lua", "GET_EVENT_CHANNEL")
    local channel = mc.new({
        channel = up_channel,
        dispatch = function(channel, source, cmd, ...)
            local func = subscribe_cmd[cmd]
            if func then
                func(...)
            else
				log.error("unknown subscribe command from channel, channel=%s, source=%s, cmd=%s", channel, source, cmd)
            end
        end,
    })
    channel.subscribe_cmd = subscribe_cmd
    channel:subscribe()
    return channel
end

function M.subscribe(service, cmd, func)
    local channel = g_client_channels[service]
    if not channel then
        local subscribe_cmd = {}
        channel = channel_new(service, subscribe_cmd)
        g_client_channels[service] = channel
    end

    channel.subscribe_cmd[cmd] = func
end

local CMD = {}
CMD.GET_EVENT_CHANNEL = function()
    return g_server_channel.channel
end

function M.publish(cmd, ...)
    g_server_channel:publish(cmd, ...)
end

function M.init()
    g_server_channel = mc.new()
	dispatch.cmd(CMD)
end

return M
