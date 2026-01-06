
local skynet = require "skynet"
local sharedata = require "skynet.sharedata"
local driver = require "MongoDriver"

clsEntity = clsObject:Inherit()

function clsEntity:__init__()
    self.key = ""
    self.tbname = "" 
    self.recordset = {}
	self.updateflag = {}
end

function clsEntity:loadData()

end

function clsEntity:unloadData()

end

local mode = {}
local entities = {}

function mode.get(name)
    if entities[name] then
        return entities[name]
    end
    local ent = require(name)
    entities[name] = ent
    return ent
end

return mode
