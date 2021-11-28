local discordia = require("discordia");
local classes = discordia.class.classes;
local API = classes.API;
local uv = require("uv");
local hrtime = uv.hrtime;
local msOffset = 1e6;

local json = require('json')
local null = json.null

local remove = table.remove
local max = math.max
local f, gsub, byte = string.format, string.gsub, string.byte
local random = math.random
local encode = json.encode
local decode = json.decode
local insert, concat = table.insert, table.concat
local running = coroutine.running

local BASE_URL = "https://discord.com/api/v9"

local JSON = 'application/json'
local PRECISION = 'millisecond'
local MULTIPART = 'multipart/form-data;boundary='
local USER_AGENT = 'DiscordBot'

local majorRoutes = {guilds = true, channels = true, webhooks = true}
local payloadRequired = {PUT = true, PATCH = true, POST = true}

local function parseErrors(ret, errors, key)
	for k, v in pairs(errors) do
		if k == '_errors' then
			for _, err in ipairs(v) do
				insert(ret, f('%s in %s : %s', err.code, key or 'payload', err.message))
			end
		else
			if key then
				parseErrors(ret, v, f(k:find("^[%a_][%a%d_]*$") and '%s.%s' or tonumber(k) and '%s[%d]' or '%s[%q]', key, k))
			else
				parseErrors(ret, v, k)
			end
		end
	end
	return concat(ret, '\n\t')
end

local function sub(path)
	return not majorRoutes[path] and path .. '/:id'
end

local function route(method, endpoint)

	-- special case for reactions
	if endpoint:find('reactions') then
		endpoint = endpoint:match('.*/reactions')
	end

	-- remove the ID from minor routes
	endpoint = endpoint:gsub('(%a+)/%d+', sub)

	-- special case for message deletions
	if method == 'DELETE' then
		local i, j = endpoint:find('/channels/%d+/messages')
		if i == 1 and j == #endpoint then
			endpoint = method .. endpoint
		end
	end

	return endpoint

end

local function generateBoundary(files, boundary)
	boundary = boundary or tostring(random(0, 9))
	for _, v in ipairs(files) do
		if v[2]:find(boundary, 1, true) then
			return generateBoundary(files, boundary .. random(0, 9))
		end
	end
	return boundary
end

local function attachFiles(payload, files)
	local boundary = generateBoundary(files)
	local ret = {
		'--' .. boundary,
		'Content-Disposition:form-data;name="payload_json"',
		'Content-Type:application/json\r\n',
		payload,
	}
	for i, v in ipairs(files) do
		insert(ret, '--' .. boundary)
		insert(ret, f('Content-Disposition:form-data;name="file%i";filename=%q', i, v[1]))
		insert(ret, 'Content-Type:application/octet-stream\r\n')
		insert(ret, v[2])
	end
	insert(ret, '--' .. boundary .. '--')
	return concat(ret, '\r\n'), boundary
end

local function tohex(char)
	return f('%%%02X', byte(char))
end

local function urlencode(obj)
	return (gsub(tostring(obj), '%W', tohex))
end

function API:request(method, endpoint, payload, query, files)

	local _, main = running()
	if main then
		return error('Cannot make HTTP request outside of a coroutine', 2)
	end

	local url = BASE_URL .. endpoint

	if query and next(query) then
		url = {url}
		for k, v in pairs(query) do
			insert(url, #url == 1 and '?' or '&')
			insert(url, urlencode(k))
			insert(url, '=')
			insert(url, urlencode(v))
		end
		url = concat(url)
	end

	local req = {
		{'User-Agent', USER_AGENT},
		{'X-RateLimit-Precision', PRECISION},
		{'Authorization', self._token},
	}

	if payloadRequired[method] then
		payload = payload and encode(payload) or '{}'
		if files and next(files) then
			local boundary
			payload, boundary = attachFiles(payload, files)
			insert(req, {'Content-Type', MULTIPART .. boundary})
		else
			insert(req, {'Content-Type', JSON})
		end
		insert(req, {'Content-Length', #payload})
	end

	local mutex = self._mutexes[route(method, endpoint)]

	mutex:lock()
	local data, err, delay = self:commit(method, url, req, payload, 0)
	mutex:unlockAfter(delay)

	if data then
		return data
	else
		return nil, err
	end

end

local timer = require('timer')
local sleep = timer.sleep
local http = require('coro-http')
local request = http.request

function API:commit(method, url, req, payload, retries)

	local client = self._client
	local options = client._options
	local delay = options.routeDelay

	local startAt = hrtime()
	local success, res, msg = pcall(request, method, url, req, payload)
	local thisLatency = (hrtime()-startAt)/msOffset
	local latency = self._latency
	if not latency then
		latency = {}
		self._latency = latency
	end
	insert(latency,1,thisLatency);
	if #latency > 10 then
		remove(latency)
	end

	if not success then
		return nil, res, delay
	end

	for i, v in ipairs(res) do
		res[v[1]:lower()] = v[2]
		res[i] = nil
	end

	if res['x-ratelimit-remaining'] == '0' then
		delay = max(1000 * res['x-ratelimit-reset-after'], delay)
	end

	local data = res['content-type'] == JSON and decode(msg, 1, null) or msg

	if res.code < 300 then

		client:debug('%i - %s : %s %s', res.code, res.reason, method, url)
		return data, nil, delay

	else

		if type(data) == 'table' then

			local retry
			if res.code == 429 then -- TODO: global ratelimiting
				delay = data.retry_after
				retry = retries < options.maxRetries
			elseif res.code == 502 then
				delay = delay + random(2000)
				retry = retries < options.maxRetries
			end

			if retry then
				client:warning('%i - %s : retrying after %i ms : %s %s', res.code, res.reason, delay, method, url)
				sleep(delay)
				return self:commit(method, url, req, payload, retries + 1)
			end

			if data.code and data.message then
				msg = f('HTTP Error %i : %s', data.code, data.message)
			else
				msg = 'HTTP Error'
			end
			if data.errors then
				msg = parseErrors({msg}, data.errors)
			end

		end

		client:error('%i - %s : %s %s\n%s', res.code, res.reason, method, url,tostring(msg))
		return nil, msg, delay

	end

end

