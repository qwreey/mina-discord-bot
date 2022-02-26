local discordia = require("discordia")
local classes = discordia.class.classes
local FFmpegProcess = classes.FFmpegProcess

local floor = math.floor
local insert = table.insert
local uv = require('uv')
local yield, resume, running = coroutine.yield, coroutine.resume, coroutine.running
local function onExit() end
local moreArgs = {}
rawset(FFmpegProcess,"args",moreArgs)
function FFmpegProcess:__init(path, rate, channels, position, errorHandler)
	position = tonumber(position)

	local stdout = uv.new_pipe(false)
	local stderr = uv.new_pipe(false)

	local args = {
		'-fflags', '+discardcorrupt',
		'-i', path,
		'-ar', rate,
		'-ac', channels,
		'-reconnect', '1',
		'-reconnect_at_eof', '1',
		'-reconnect_streamed', '1',
		'-reconnect_delay_max', '5',
		-- ss flag
		'-vn', '-dn', '-sn', '-f', 's16le', 'pipe:1',
		'-loglevel', 'warning', '-ignore_unknown', '-copy_unknown'
	}
	for i,v in ipairs(moreArgs) do
		insert(args,i+4,v);
	end
	if position then
		-- logger.infof("seeked %s",tostring(position));
		insert(args,1,'-ss')
		insert(args,2,tostring( floor(position)))
	end

	self._child = assert(uv.spawn('ffmpeg', {
		args = args,
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
			logger.infof("calling error function with %s",tostring(errorHandler));
			local passed,result = pcall(errorHandler,str);
			if not passed then
				logger.errorf("ErrorCallbackFunction was errored on called. traceback was :\n",tostring(result));
			end
		end
	end)

	self._buffer = buffer or ''
	self._stdout = stdout

	yield()

end
_G.FFmpegProcess = FFmpegProcess;
