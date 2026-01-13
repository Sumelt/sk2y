
local M = {}

local httpc = require "http.httpc"
local cjson = require "cjson.safe"
local verifyUrl = ""
local verifyReq = ""

function M:verifyAccessToken(iggid, accessToken, platform, language, clientAddr)
	return true
end

return M
