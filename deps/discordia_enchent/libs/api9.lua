local discordia = require("discordia");
local classes = discordia.class.classes;
local API = classes.API;

local json = require('json')

local f, gsub, byte = string.format, string.gsub, string.byte
local random = math.random
local encode = json.encode
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