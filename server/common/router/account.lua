
local log = require "log"
local jwt = require "jwt"
local time = require "time"
local id_generator = require "id_generator"
local errcode = require "errcode"

local server2game = ""
local max_role_count = 5
local login_jwt_secret = "sk2y"

local M = {
    GET = {},
    POST = {},
}

M.GET["/roles"] = function(req, res)
end



