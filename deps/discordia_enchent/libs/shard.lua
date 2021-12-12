local discordia = require("discordia")
local classes = discordia.class.classes
local Shard = classes.Shard
local wrap = coroutine.wrap

local function merge(A,B)
	if not B then return A end
	for i,v in pairs(B) do
		A[i] = v
	end
	return A
end

local IDENTIFY = 2
function Shard:identify()

	local client = self._client
	local mutex = client._mutex
	local options = client._options

	mutex:lock()
	wrap(function()
		self:identifyWait()
		mutex:unlock()
	end)()

	self._seq = nil
	self._session_id = nil
	self._ready = false
	self._loading = {guilds = {}, chunks = {}, syncs = {}}

	return self:_send(IDENTIFY, {
		token = client._token,
		properties = merge({
			['$os'] = jit.os,
			['$browser'] = 'Discordia',
			['$device'] = 'Discordia',
			['$referrer'] = '',
			['$referring_domain'] = '',
		},options.wssProps),
		compress = options.compress,
		large_threshold = options.largeThreshold,
		shard = {self._id, client._total_shard_count},
		presence = next(client._presence) and client._presence,
	}, true)

end
