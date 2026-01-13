local skynet = require "skynet"
local clsCol = require "mongo_col"
local mongo = require "skynet.db.mongo"

local clsBase = clsObject:Inherit()

local saveKeyTbl = {
	["_name"] = function()
		return nil
	end,
	["_collections"] = function()
		return nil
	end,
	["_conns"] = function()
		return nil
	end,
}

function clsBase:__init__(oci)
	Super(clsBase).__init__(self)
	for k, func in pairs(saveKeyTbl) do
		if oci[k] == nil then
			self[k] = func()
		else
			self[k] = oci[k]
		end
	end
	for index = 1, skynet.getenv("db_con") do
		table.insert(self._conns, { 
			index = index,
			addr = clsBase:initConnect(index),
		})
	end
end

function clsBase:initConnect(index)
	local addr = skynet.newservice("Mongod", self._name, index)
	return addr
end

function clsBase:getRoute()
    local index = math.random(1, #self._conns)
	return self._conns[index]
end

function clsBase:call(cmd, ...)
	local con = self:getRoute()
	return skynet.call(con.addr, "lua", cmd, ...)
end

function clsBase:getCollection(colName)
	local colObj = self.collections[colName]
    if not colObj then
		local oci = {
			_name = colName,
		}
		colObj = clsCol:New(oci)	
		colObj:setDBObj(self)
		self.collections[colName] = colObj
    end
    return colObj
end

return clsBase
