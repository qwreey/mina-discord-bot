local discordia = require("discordia")
local classes = discordia.class.classes
local VoiceConnection = classes.VoiceConnection
local FFmpegProcess = classes.FFmpegProcess

local uv = require('uv')
local ffi = require('ffi')
local constants = require('discordia/libs/constants') ---@diagnostic disable-line
-- local opus = require('voice/opus')
local sodium = require('discordia/libs/voice/sodium') ---@diagnostic disable-line

local CHANNELS = 2
local SAMPLE_RATE = 48000 -- Hz
local FRAME_DURATION = 20 -- ms
-- local COMPLEXITY = 5

-- local MIN_BITRATE = 8000 -- bps
-- local MAX_BITRATE = 128000 -- bps
-- local MIN_COMPLEXITY = 0
-- local MAX_COMPLEXITY = 10

local MAX_SEQUENCE = 0xFFFF
local MAX_TIMESTAMP = 0xFFFFFFFF

local HEADER_FMT = '>BBI2I4I4'
local PADDING = string.rep('\0', 12)

local MS_PER_NS = 1 / (constants.NS_PER_US * constants.US_PER_MS)
local MS_PER_S = constants.MS_PER_S

local max = math.max
local hrtime = uv.hrtime
local ffi_string = ffi.string
local pack = string.pack -- luacheck: ignore
local running, resume, yield = coroutine.running, coroutine.resume, coroutine.yield

-- timer.sleep is redefined here to avoid a memory leak in the luvit module
local new_timer = uv.new_timer;
local function sleep(delay)
	local thread = running()
	local t = new_timer()
	t:start(delay, 0, function()
		t:stop()
		t:close()
		return assert(resume(thread))
	end)
	return yield()
end

local function asyncResume(thread)
	local t = new_timer()
	t:start(0, 0, function()
		t:stop()
		t:close()
		return assert(resume(thread))
	end)
end

local pack = pack

function VoiceConnection:_play(stream, duration, position)
	position = tonumber(position);

	self:stopStream()
	self:_setSpeaking(true)

	duration = tonumber(duration) or math.huge

	local elapsed = position and (position * 1000) or 0
	local udp, ip, port = self._udp, self._ip, self._port
	local ssrc, key = self._ssrc, self._key
	local encoder = self._encoder

	local frame_size = SAMPLE_RATE * FRAME_DURATION / MS_PER_S
	local pcm_len = frame_size * CHANNELS

	local start = hrtime() - (position and position*1000000000 or 0)
	local reason

	---CUSTOM PATCH
	rawset(self,"getElapsed",function ()
		return elapsed;
	end)
	local sread = stream.read
	local encode = encoder.encode
	local encrypt = sodium.encrypt
	---CUSTOM PATCH

	while elapsed < duration do

		---CUSTOM PATCH
		local pcm = sread(stream,pcm_len)
		---CUSTOM PATCH
		if not pcm then
			reason = 'stream exhausted or errored'
			break
		end

		---CUSTOM PATCH
		local data, len = encode(encoder, pcm, pcm_len, frame_size, pcm_len * 2)
		---CUSTOM PATCH
		if not data then
			reason = 'could not encode audio data'
			break
		end

		local s, t = self._s, self._t
		local header = pack(HEADER_FMT, 0x80, 0x78, s, t, ssrc)

		s = s + 1
		t = t + frame_size

		self._s = s > MAX_SEQUENCE and 0 or s
		self._t = t > MAX_TIMESTAMP and 0 or t

		---CUSTOM PATCH
		local encrypted, encrypted_len = encrypt(data, len, header .. PADDING, key)
		---CUSTOM PATCH
		if not encrypted then
			reason = 'could not encrypt audio data'
			break
		end

		local packet = header .. ffi_string(encrypted, encrypted_len)
		udp:send(packet, ip, port)

		elapsed = elapsed + FRAME_DURATION
		local delay = elapsed - (hrtime() - start) * MS_PER_NS
		sleep(max(delay, 0))

		if self._paused then
			asyncResume(self._paused)
			self._paused = running()
			local pause = hrtime()
			yield()
			start = start + hrtime() - pause
			asyncResume(self._resumed)
			self._resumed = nil
		end

		if self._stopped then
			reason = 'stream stopped'
			break
		end

	end

	self:_setSpeaking(false)

	if self._stopped then
		asyncResume(self._stopped)
		self._stopped = nil
	end

	---CUSTOM PATCH
	rawset(self,"getElapsed",nil)
	---CUSTOM PATCH

	return elapsed, reason

end


--[=[
@m playFFmpeg
@t mem
@p path string
@op duration number
@r number
@r string
@d Plays audio over the established connection using an FFmpeg process, assuming
FFmpeg is properly configured. If a duration (in milliseconds)
is provided, the audio stream will automatically stop after that time has elapsed;
otherwise, it will play until the source is exhausted. The returned number is the
time elapsed while streaming and the returned string is a message detailing the
reason why the stream stopped. For more information about using FFmpeg,
see the [[voice]] page.
]=]
function VoiceConnection:playFFmpeg(path, duration, position, errorHandler)

	if not self._ready then
		return nil, 'Connection is not ready'
	end

	local stream = FFmpegProcess(path, SAMPLE_RATE, CHANNELS, position, errorHandler)

	local elapsed, reason = self:_play(stream, duration, position)
	stream:close()
	return elapsed, reason

end
