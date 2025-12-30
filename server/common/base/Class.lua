
function Super(class)
	return class.__SuperClass
end

local function __ImlInterFaceWithCopy(self, imlClass)
	for k, v in pairs(imlClass) do
		assert(not self[k])
		if not self[k] then
			self[k]=v
		end
	end
end

local function __InheritWithCopy(base, class)
	class = class or {}
	for k, v in pairs(base) do
		assert(not class[k])
		if not class[k] then
			class[k]=v
		end
	end

	class.__SuperClass = base
	class.__SubClass = nil
	class.__IsClass = true

	if not base.__SubClass then
		base.__SubClass = {}
	end
	table.insert(base.__SubClass, class)
	return class
end

clsObject = {
	Inherit = __InheritWithCopy,
	ImplementFrom = __ImlInterFaceWithCopy,
	__IsClass = true,
}

function clsObject:New(...)
	local obj = {}
	setmetatable(obj, {__index = self})
	obj:__init__(...)
	return obj
end

function clsObject:__init__()
	print("base")
end

function clsObject:release()
end



