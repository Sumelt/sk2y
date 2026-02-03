
local function snowflake_service()
    local log = require "log"
    local skynet = require "skynet"
	local idConfig = require "etc.id"
	local dispatch = require "dispatch_api"

    local function parse_date(str_date)
        local pattern = "(%d+)-(%d+)-(%d+)"
        local y, m, d = str_date:match(pattern)
        if not y or not m or not d then
            error("invalid date format")
        end
        return os.time({ year = y, month = m, day = d, hour = 0 })
    end

    -- 时间起点
    local start_date = idConfig.get_start_date()
    local BEGIN_TIMESTAMP = parse_date(start_date)

	-- 时间|机器码|序列号
    -- 每一部分占用的位数 (总共 1 + 63 = 64 位，符号位为0)
    local TIME_BIT = idConfig.get_time_bit() -- 136年
    local MACHINE_BIT = idConfig.get_machine_bit() -- 16384个进程
    local SEQUENCE_BIT = idConfig.get_seq_bit() -- 13万/秒
    -- 位数检查
    assert(TIME_BIT + MACHINE_BIT + SEQUENCE_BIT < 64, "total bits exceeds 64")

    -- 每一部分的最大值
    local MAX_SEQUENCE = (1 << SEQUENCE_BIT) - 1
    local MAX_MACHINE_ID = (1 << MACHINE_BIT) - 1
    local MAX_RELATIVE_TIME = (1 << TIME_BIT) - 1

    -- 每一部分向左的位移
    local MACHINE_LEFT = SEQUENCE_BIT
    local TIMESTAMP_LEFT = SEQUENCE_BIT + MACHINE_BIT

    local sequence = 0
    local MACHINE_ID = nil
    local last_timestamp = -1
    local is_inited = false

    -- 获取当前时间，单位 1s
    local function get_cur_timestamp()
        return math.floor(skynet.time())
    end

    local function generate_one()
        local cur_timestamp = get_cur_timestamp()
        -- 检查时钟回拨
        if cur_timestamp < last_timestamp then
            error("clock moved backwards")
        end

        if cur_timestamp == last_timestamp then
            sequence = sequence + 1
            if sequence > MAX_SEQUENCE then
                log.warn("sequence overflow, sequence=%s, cur_timestamp=%s", sequence, cur_timestamp)
                -- 等待下一个时间单位
                repeat
                    skynet.sleep(50) -- sleep 0.5s
                    cur_timestamp = get_cur_timestamp()
                until cur_timestamp > last_timestamp
                sequence = 0
            end
        else
            -- 新的时间单位，序列号重置
            sequence = 0
        end

        last_timestamp = cur_timestamp
        local relative_timestamp = cur_timestamp - BEGIN_TIMESTAMP
        -- 修复: 检查相对时间戳是否溢出
        assert(relative_timestamp <= MAX_RELATIVE_TIME, "timestamp is out of range, over 174 years")

        -- 组合 ID
        return (relative_timestamp << TIMESTAMP_LEFT) | (MACHINE_ID << MACHINE_LEFT) | sequence
    end

    local CMD = {}
    function CMD.gen_id()
        if not is_inited then
            error("snowflake service is not initialized yet")
        end
        return generate_one()
    end

    -- 返回一个顺序数组 { id1, id2, ... }
    function CMD.gen_ids(count)
        if not is_inited then
            error("snowflake service is not initialized yet")
        end

        count = tonumber(count) or 1
        if count < 1 then
            count = 1
        end
        if count > 10000 then -- 可根据业务场景修改
            error("count is too large")
        end

        local list = {}
        for i = 1, count do
            list[i] = generate_one()
        end
        return list
    end

    skynet.start(function()
        MACHINE_ID = idConfig.get_machine_id()

        -- 检查机器ID
		if not MACHINE_ID or MACHINE_ID < 0 or MACHINE_ID > MAX_MACHINE_ID then
			assert(false, "initialized machine_id")	
		end

        -- 初始化 last_timestamp，避免首次启动时钟回拨误判
        last_timestamp = get_cur_timestamp()
        is_inited = true -- 标记初始化完成

		dispatch.cmd(CMD)

		log.info("snowflake service started, node=%s, machine_id=%s, begin_timestamp=%s, last_timestamp=%s", 
			skynet.getenv("node"),MACHINE_ID, BEGIN_TIMESTAMP, last_timestamp)
    end)


end

local service = require "skynet.service"
local skynet = require "skynet"

local M = {}

local snowflake_service_addr = nil

skynet.init(function()
    snowflake_service_addr = service.new("snowflake", snowflake_service)
end)

function M.new_id()
    return skynet.call(snowflake_service_addr, "lua", "gen_id")
end

function M.new_ids(count)
    return skynet.call(snowflake_service_addr, "lua", "gen_ids", count)
end

return M
