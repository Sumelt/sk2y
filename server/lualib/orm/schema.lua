-- Code generated from common/lualib/orm/schema_define.lua
-- DO NOT EDIT!

local orm = require "orm"
local tointeger = math.tointeger
local sformat = string.format

local number = setmetatable({
    type = "number",
}, {
    __tostring = function()
        return "schema_number"
    end,
})

local integer = setmetatable({
    type = "integer",
}, {
    __tostring = function()
        return "schema_integer"
    end,
})

local string = setmetatable({
    type = "string",
}, {
    __tostring = function()
        return "schema_string"
    end,
})

local boolean = setmetatable({
    type = "boolean",
}, {
    __tostring = function()
        return "schema_boolean"
    end,
})

local function _parse_k_tp(k, need_tp)
    if need_tp == integer then
        local nk = tointeger(k)
        if tointeger(k) == nil then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return nk
    elseif need_tp == string then
        return tostring(k)
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp), tostring(k)))
end

local function _check_k_tp(k, need_tp)
    if need_tp == integer then
        if (type(k) ~= "number") or (tointeger(k) == nil) then
            error(sformat("not equal k type. need integer, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return
    elseif need_tp == string then
        if type(k) ~= "string" then
            error(sformat("not equal k type. need string, real: %s, k: %s, need_tp: %s", type(k), tostring(k), tostring(need_tp)))
        end
        return
    end
    error(sformat("not support need_tp type: %s, k: %s", tostring(need_tp), tostring(k)))
end

local function _check_v_tp(v, need_tp)
    if need_tp == integer then
        if (type(v) ~= "number") or (tointeger(v) == nil) then
            error(sformat("not equal v type. need integer, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == number then
        if type(v) ~= "number" then
            error(sformat("not equal v type. need number, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == string then
        if type(v) ~= "string" then
            error(sformat("not equal v type. need string, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    elseif need_tp == boolean then
        if type(v) ~= "boolean" then
            error(sformat("not equal v type. need boolean, real: %s, v: %s, need_tp: %s", type(v), tostring(v), tostring(need_tp)))
        end
        return
    end
    if v ~= need_tp then
        error(sformat("not equal v type. need_tp: %s, v: %s", tostring(need_tp), tostring(v)))
    end
end

local function parse_k_func(need_tp)
    return function(self, k)
        return _parse_k_tp(k, need_tp)
    end
end

local function check_k_func(need_tp)
    return function(self, k)
        _check_k_tp(k, need_tp)
    end
end

local function check_kv_func(k_need_tp, v_need_tp)
    return function(self, k, v)
        _check_k_tp(k, k_need_tp)
        _check_v_tp(v, v_need_tp)
    end
end

local function parse_k(self, k)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end
    return k
end

local function check_k(self, k)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end
end

local function check_kv(self, k, v)
    local schema = self[k]
    if not schema then
        error(sformat("not exist key: %s", k))
    end

    _check_v_tp(v, schema)
end

local role = { type = "struct" }

setmetatable(role, {
    __tostring = function()
        return "schema_role"
    end,
})
role._version = integer
role.account = string
role.rid = integer
role.server = string
role._parse_k = parse_k
role._check_k = check_k
role._check_kv = check_kv
role.new = function(init)
    return orm.new(role, init)
end
local role_fields = {"_version","account","rid","server"}
role.fields = function()
    return role_fields
end

return {
    role = role,
}
