local bson = require "bson"
local orm = require "orm"

local to_lightuserdata = bson.to_lightuserdata
local _bson_encode = bson.encode
local _with_bson_encode_context = orm.with_bson_encode_context
local function bson_encode(doc)
    return _with_bson_encode_context(_bson_encode, doc)
end

local saveKeyTbl = {
	["_name"] = function()
		return nil
	end,
}

local clsCol = clsObject:Inherit()

function clsCol:__init__(oci)
	Super(clsCol).__init__(self)
	for k, func in pairs(saveKeyTbl) do
		if oci[k] == nil then
			self[k] = func()
		else
			self[k] = oci[k]
		end
	end
end

function clsCol:setDBObj(dbObj)
	self._dbObj = dbObj
end

function clsCol:find_and_modify(doc)
    return self._dbObj:call("find_and_modify", self._name, doc)
end

function clsCol:find(doc, projection)
    return self._dbObj:call("find", self._name, doc, projection)
end

function clsCol:find_one(doc, projection)
    return self._dbObj:call("find_one", self._name, doc, projection)
end

function clsCol:safe_insert(doc)
    local bson_obj = bson_encode(doc)
    return self._dbObj:call("raw_safe_insert", self._name, to_lightuserdata(bson_obj))
end

function clsCol:safe_update(query, update, upsert, multi)
    local bson_obj = bson_encode({
        q = query,
        u = update,
        upsert = upsert,
        multi = multi,
    })
    return self._dbObj:call("raw_safe_update", self._name, to_lightuserdata(bson_obj))
end


return clsCol
