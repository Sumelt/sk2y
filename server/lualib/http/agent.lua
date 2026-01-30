
local manager = require "skynet.manager"
local log = require "log"
local skynet = require "skynet"
local socket = require "skynet.socket"
local sockethelper = require "http.sockethelper"
local httpd = require "http.httpd"
local cjson = require "cjson.safe"
local urllib = require "http.url"
local util_io = require "util.io"

local decode_json = cjson.decode
local encode_json = cjson.encode
local register = manager.register

local agent_id = ...

local CMD = {}
local SOCKET = {}

local request_body_size = (1024 * 1024)
local routers = {} -- method -> path -> handler

local function response(id, write, ...)
	local ok, err = httpd.write_response(write, ...)
	if not ok then
		log.debug("response failed, id=%s, err=%s", id, err)
	end
	log.debug("response ok, id=%s", id)
end

local function handle_request(id, interface, addr)
	log.debug("handle_request, addr=%s, id=%s", addr, id)
	local code, url, method, header, body = httpd.read_request(interface.read, request_body_size)
	if not code then
		if url == sockethelper.socket_error then
			log.info("handle_request socket closed, id=%s, addr=%s, url=%s", id, addr, url)
		else
			log.warn("handle_request read_request failed, id=%s, addr=%s, url=%s", id, addr, url)
		end
		return
	end

	if code ~= 200 then
		response(id, interface.write, code)
		log.warn("handle_request handle failed, id=%s, addr=%s, url=%s", id, addr, url)
		return
	end

	local res = {
		header = {
			["X-Powered-By"] = "skyext framework",
			["Access-Control-Allow-Origin"] = "*",
			["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
			["Access-Control-Allow-Headers"] = "Content-Type,x-token",
			["Access-Control-Allow-Credentials"] = "true",
		},
	}

	if method == "OPTIONS" then
		response(id, interface.write, 204, "", res.header)
		log.warn("handle_request method failed, id=%s, addr=%s, url=%s", id, addr, url)
		return
	end

	local method_routers = routers[method]
	if not method_routers then
		response(id, interface.write, 405)
		log.warn("handle_request method routers not found, id=%s, addr=%s, url=%s", id, addr, url)
		return
	end

	local path, query = urllib.parse(url)
	local handler = method_routers[path]
	if not handler then
		log.warn("handle_request not found, id=%s, addr=%s, method=%s, path=%s", id, addr, method, path)
		response(id, interface.write, 404)
		return
	end

	local req = {
		id = id,
		addr = addr,
		url = url,
		path = path,
		query = query,
		header = header,
		body = body,
		parse_query = function()
			return urllib.parse_query(query)
		end,
		read_json = function()
			return decode_json(body)
		end,
	}

	res.write = function(statuscode, bodyfunc, header)
		header = header or {}
		for k, v in pairs(res.header) do
			header[k] = v
		end
		response(id, interface.write, statuscode, bodyfunc, header)
	end
	res.write_json = function(data, header)
		header = header or {}
		header["content-type"] = "application/json"
		for k, v in pairs(res.header) do
			header[k] = v
		end
		response(id, interface.write, 200, encode_json(data), header)
	end
	res.write_file = function(filename, header)
		header = header or {}
		for k, v in pairs(res.header) do
			header[k] = v
		end
		-- TODO: cache file by timestamp
		local content = util_io.readfile(filename)
		response(id, interface.write, 200, content, header)
	end
	handler(req, res)
end

local function gen_interface(id)
	return {
		init = nil,
		close = nil,
		read = sockethelper.readfunc(id),
		write = sockethelper.writefunc(id),
	}
end

function SOCKET.request(id, addr)
	log.info("request, id=%s, addr=%s", id, addr)

	socket.start(id)

	local interface = gen_interface(id)
	if interface.init then
		interface.init()
	end

	local ok, err = xpcall(handle_request, debug.traceback, id, interface, addr)
	if not ok then
		log.warn("request failed, id=%s, addr=%s, err=%s", id, addr, err)
	end

	socket.close(id)
	if interface and interface.close then
		interface.close()
	end
	log.debug("request end, id=%s, addr=%s", id, addr)
end

function CMD.register_router(router_name)
	print(router_name)
	local router = require(router_name)
	for method, handlers in pairs(router) do
		for path, handler in pairs(handlers) do
			local method_routers = routers[method]
			if not method_routers then
				method_routers = {}
				routers[method] = method_routers
			end
			method_routers[path] = handler
		end
	end
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, subcmd, ...)
		if cmd == "socket" then
			local f = assert(SOCKET[subcmd], string.format('unknown operation: %s', subcmd))
			f(...)
		else
			local f = assert(CMD[cmd], string.format('unknown operation: %s', cmd))
			skynet.ret(skynet.pack(f(...)))
		end
	end)
	log.info("http agent start, agent_id=%s", agent_id)
end)

register("." .. SERVICE_NAME .. agent_id)

