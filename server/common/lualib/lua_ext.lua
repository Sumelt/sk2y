
table.size = function(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

table.hasElement = function (t)
    if not next(t) then 
		return false
	end
	return true
end

function isTable(t)
	if type(t) == "table" then
		return true	
	end
	return false
end
