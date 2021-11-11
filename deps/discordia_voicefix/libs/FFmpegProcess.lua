return function (FFmpegProcess)
	local uv = require('uv')
	local yield, resume, running = coroutine.yield, coroutine.resume, coroutine.running
	local function onExit() end
	function FFmpegProcess:__init(path, rate, channels, errorHandler)

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
			if err or (not chunk) then
				return;
			end
			-- stderr:read_stop();
			local str = tostring(chunk):gsub("\n$","");
			-- errstr = errstr .. str .. "\n";
			logger.errorf("[FFmpeg Error] %s",str);
			if errorHandler then
				pcall(errorHandler,str);
			end
		end)

		self._buffer = buffer or ''
		self._stdout = stdout

		yield()

	end
end
