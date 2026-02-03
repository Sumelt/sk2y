
local skynet = require "skynet"

local M = {}

function M.cmd(CMD)
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], string.format('unknown operation: %s', cmd))
		skynet.ret(skynet.pack(f(...)))
	end)
end

function M.socket(CMD)
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		local f = assert(CMD[subcmd], string.format('unknown operation socket: %s', subcmd))
		f(...)
	end)
end

return M
