
local skynet = require "skynet"

local config = {
	login = {
		snowflake_start_date = "2025-01-01",
		snowflake_machine_id = 2,
		time_bit = 32,
		machine_bit = 14,
		sequence_bit = 17,
    },
}

local M = {}

local function get_node()
	return skynet.getenv("node")
end

local function get_cfg()
	local node = get_node()
	return config[node]
end

function M.get_start_date()
	local config = get_cfg()
	return config.snowflake_start_date
end

function M.get_machine_id()
	local config = get_cfg()
	return config.snowflake_machine_id
end

function M.get_time_bit()
	local config = get_cfg()
	return config.time_bit
end

function M.get_machine_bit()
	local config = get_cfg()
	return config.machine_bit
end

function M.get_seq_bit()
	local config = get_cfg()
	return config.sequence_bit
end

return M
