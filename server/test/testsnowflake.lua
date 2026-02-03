
local skynet = require "skynet"
local idBuilder = require "id_builder"
local idParser = require "id_parser"

skynet.start(function()
	local id = idBuilder.new_id()
	print(id)
	print(idParser.get_machine_id(id))
	print(idParser.get_sequence_id(id))
	skynet.exit()
end)
