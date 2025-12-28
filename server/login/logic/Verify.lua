
local mode = {}

local httpc = require "http.httpc"
local cjson = require "cjson.safe"
local verifyUrl = "http://cgi.igg.com"
local verifyReq = "/internal/access_token/verify"

function mode:verifyAccessToken(iggid, accessToken, platform, language, clientAddr)
	return true
end

return mode
