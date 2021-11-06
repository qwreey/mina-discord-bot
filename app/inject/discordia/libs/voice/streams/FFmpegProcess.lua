local require = _G.requires.discordia;
local uv = require('uv')

local remove = table.remove
local unpack = string.unpack -- luacheck: ignore
local rep = string.rep
local yield, resume, running = coroutine.yield, coroutine.resume, coroutine.running

local function onExit() end

local fmt = setmetatable({}, {
	__index = function(self, n)
		self[n] = '<' .. rep('i2', n)
		return self[n]
	end
})

local FFmpegProcess = require('class')('FFmpegProcess')

function FFmpegProcess:__init(path, rate, channels)

	local stdout = uv.new_pipe(false)
	local stderr = uv.new_pipe(false)

	self._child = assert(uv.spawn('ffmpeg', {
		args = {
			'-i', path,
			'-ar', rate,
			'-ac', channels,
			'-reconnect', '1',
			'-reconnect_at_eof', '1',
			'-reconnect_streamed', '1',
			'-reconnect_delay_max', '1024',
			'-dn', '-sn', '-f', 's16le', 'pipe:1',
			'-loglevel', 'warning', '-ignore_unknown', '-copy_unknown'
		},
		stdio = {0, stdout, stderr},
	}, onExit), 'ffmpeg could not be started, is it installed and on your executable path?')

	local buffer
	local thread = running()
	stdout:read_start(function(err, chunk)
		if err or not chunk then
			self:close()
		else
			buffer = chunk
		end
		stdout:read_stop()
		return assert(resume(thread))
	end)
	-- local errstr = "";
	stderr:read_start(function(err, chunk)
		if err or not chunk then
			self:close()
		end
		stderr:read_stop();
		local str = tostring(chunk):gsub("\n$","");
		-- errstr = errstr .. str .. "\n";
		logger.errorf("[FFmpeg Error] %s",str);
	end)

	self._buffer = buffer or ''
	self._stdout = stdout

	yield()

end

function FFmpegProcess:read(n)

	local buffer = self._buffer
	local stdout = self._stdout
	local bytes = n * 2

	if not self._closed and #buffer < bytes then

		local thread = running()
		stdout:read_start(function(err, chunk)
			if err or not chunk then
				self:close()
			elseif #chunk > 0 then
				buffer = buffer .. chunk
			end
			if #buffer >= bytes or self._closed then
				stdout:read_stop()
				return assert(resume(thread))
			end
		end)
		yield()

	end

	if #buffer >= bytes then
		self._buffer = buffer:sub(bytes + 1)
		local pcm = {unpack(fmt[n], buffer)}
		remove(pcm)
		return pcm
	end

end

function FFmpegProcess:close()
	self._closed = true
	self._child:kill()
	if not self._stdout:is_closing() then
		self._stdout:close()
	end
end

return FFmpegProcess
