
local idConfig = require "etc.id"
local M = {}

function M.get_machine_id(rawid)
    local SEQUENCE_BIT = idConfig.get_seq_bit()
    local MACHINE_BIT = idConfig.get_machine_bit()
    local MAX_MACHINE_ID = (1 << MACHINE_BIT) - 1
	return (rawid >> SEQUENCE_BIT) & MAX_MACHINE_ID

end

function M.get_sequence_id(rawid)
    local SEQUENCE_BIT = idConfig.get_seq_bit()
    local MAX_SEQUENCE_ID = (1 << SEQUENCE_BIT) - 1
	return rawid & MAX_SEQUENCE_ID
end

return M
