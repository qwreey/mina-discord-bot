-- music channel player instance class for playing user's queued music
---@class playerClass
local this = {};
this.__index = this;
this.playerForChannels = {};

local isStreamMode;
local ytHandler; ---@module "class.music.youtubeStream";
for _,str in ipairs(app.args) do
	if str == "voice.useStream" then
		isStreamMode = true;
		ytHandler = require("class.music.youtubeStream");
	end
end
ytHandler = ytHandler or require("class.music.youtubeDownload");
this.ytHandler = ytHandler;
this.timeoutMessage = ytHandler.timeoutMessage;

local remove = table.remove;
local insert = table.insert;
local time = os.time;
local floor = math.floor;
local timeAgo = _G.timeAgo;
local promise = _G.promise;

local function formatTime(t)
	if not t then
		return "NULL";
	end
	local sec = floor(t % 60);
	local min = t / 60;
	local hour = floor(min / 60);
	min = floor(min%60)
	sec = tostring(sec);
	if #sec == 1 then
		sec = "0" .. sec;
	end
	return ("%s%d:%s"):format((hour ~= 0 and (tostring(hour) .. ":") or ""),min,sec);
end
this.formatTime = formatTime;

local function sendMessage(thing,msg)
	local message = thing.message;
	if type(message) == "table" then
		return message:reply {
			content = msg;
			reference = {message = message, mention = false};
		};
	else
		local channel = thing.channel;
		if type(channel) == "table" then
			return channel:send(msg);
		end
	end
end
this.sendMessage = sendMessage;

-- 이 코드는 신과 나만 읽을 수 있게 만들었습니다
-- 만약 편집을 기꺼히 원한다면... 그렇게 하도록 하세요
-- 다만 여기의 이 규칙을 따라주세요
-- local theHourOfAllOfSpentForEditingThis = 82; -- TYPE: number;hour
-- 이 코드를 편집하기 위해 사용한 시간만큼 여기의
-- 변수에 값을 추가해주세요.

--[[
voiceChannelID : 그냥 식별용으로 쓰기 위해 만든 별거 없는 아이디스페이스
nowPlaying : 지금 플레이중인 곡
new.playIndex
]]

-- make new playerClass instnace

---@return playerClass
function this.new(props)
	local new = {};
	setmetatable(new,this);
	new:__init(props);
	return new;
end

-- init player object
function this:__init(props)
	local voiceChannelID = props.voiceChannelID;
	self.voiceChannelID = voiceChannelID;
	self.nowPlaying = nil;
	self.handler = props.handler;
	self.isPaused = false;
	self.isLooping = props.isLooping;
	self.timestamp = props.timestamp;
	self.mode24 = props.mode24;
	self.playerForChannels[voiceChannelID] = self;
end

-- download music for prepare playing song
function this.download(thing)
	local audio,info,url,vid = ytHandler.download(thing.url);
	if not audio then
		return;
	end
	thing.whenDownloaded = time();
	thing.url = url or thing.url;
	thing.audio = audio;
	thing.info = info;
	thing.vid = vid;
	if isStreamMode then
		thing.exprie = tonumber(audio:match("expire=(%d+)&"));
	end
	return true;
end

--#region : Stream handling methods

-- play thing
local getPosixNow = posixTime.now;
local expireAtLast = 2 * 60;
local retryRate = 20;
local maxRetrys = 7;
function this:__play(thing,position) -- PRIVATE
	-- chack errors
	if not thing then -- if thing is nil, return
		return;
	end
	local handler = self.handler;
	do
		local voiceId = self.voiceChannelID;
		if not self.playerForChannels[voiceId] then
			logger.warnf("Ignored playing from channel '%s' (self is not cached on playerForChannels)",voiceId);
			return;
		elseif self[1] ~= thing then
			logger.warnf("Ignored playing from channel '%s' (first and thing is not matched)",voiceId);
			return;
		elseif not handler.channel.guild.connection then
			logger.warnf("Ignored playing from channel '%s' (Connection destroyed)",voiceId);
			self:kill();
			return;
		end
	end

	-- set state to playing
	position = position or self.timestamp;
	logger.infof("playing %s with %s",tostring(thing),tostring(position)); -- logging
	if self.nowPlaying then -- if already playing something, kill it
		self:__stop();
	end
	self.timestamp = nil;
	self.nowPlaying = thing; -- set playing song
	self.isPaused = false; -- set paused state to false

	-- if it needs redownload, try it nowd
	local exprie = thing.exprie;
	local info = thing.info;
	if exprie and exprie <= (getPosixNow()+(info and info.duration or 0)+expireAtLast-(position or 0)) then
		this.download(thing);
	end

	-- run asynchronously task for playing song
	-- play this song
	local ffmpegError;
	promise.new(handler.playFFmpeg,handler,thing.audio,nil,position,coroutine.wrap(function (errStr)
		ffmpegError = (ffmpegError or "") .. "\n" .. errStr; -- set error
	end)):andThen(function (result,reason)
		if self.destroyed then -- is destroyed
			return;
		elseif reason == "Connection is not ready" then -- discord connection error
			return pcall(self.kill,self);
		elseif reason and (reason ~= "stream stopped") and (reason ~= "stream exhausted or errored") then -- idk
			logger.errorf("Play failed : %s",reason);
			sendMessage(thing,("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
				tostring((thing.info or {title = "unknown"}).title),
				tostring(reason)
			));
			return;
		end

		-- TODO: hight resolution time required!
		-- when errored, replay on errored timestamp (point of stoped)
		result = result or position;
		if ffmpegError and (type(result) == "number") then -- result is elapsed
			local ffmpegErrorLow = ffmpegError:lower();
			if ffmpegErrorLow:match("access denied") or ffmpegErrorLow:match("Forbidden") then -- if expried
				logger.warnf("stream url expried, re-downloading ... (%s)",thing.url);
				self.download(thing);
			end
			local lastErrorTime = self.lastErrorTime;
			local now = posixTime.now();
			local lastErrorRetrys = self.lastErrorRetrys or 0;
			local unrated = (not lastErrorTime) or (lastErrorTime+retryRate < now);
			if unrated or (lastErrorRetrys < maxRetrys) then
				if unrated then
					lastErrorRetrys = 0;
					self.lastErrorTime = now;
				end
				self.lastErrorRetrys = lastErrorRetrys + 1;
				self.nowPlaying = nil;
				promise.spawn(self.__play,self,thing,result / 1000); -- adding coroutine on worker
				return;
			else
				sendMessage(thing,("오류가 너무 많아 이 곡을 건너뜁니다! 가장 최근 오류 :```log\n%s```"):format(ffmpegError));
			end
		end
		self.lastErrorTime = nil;
		self.lastErrorRetrys = nil;

		-- when seeking
		local seeking = self.seeking;
		if seeking then
			self.seeking = nil;
			self.nowPlaying = nil;
			logger.infof("seeking into %s",tostring(seeking));
			promise.spawn(self.__play,self,thing,seeking);
			return;
		end

		-- show next song info into channel
		local now = self[1];
		local upnext = self[2];
		if (now == thing) and upnext then
			local lastMsg = self.lastUpnextMessage;
			if lastMsg then
				local delete = lastMsg.delete;
				if delete then
					pcall(delete,lastMsg);
				end
			end
			self.lastUpnextMessage = sendMessage(thing,("지금 '%s' 를(을) 재생합니다!"):format(
				tostring((upnext.info or {title = "unknown"}).title)
			));
		end

		-- when looping is enabled, append this into playlist
		if self.isLooping and self.nowPlaying then
			insert(self,thing); -- insert this into end of queue
		end

		-- remove this song from queue and play next
		self.nowPlaying = nil; -- remove song
		if now == thing then
			-- IMPORTANT! without this, it will take this coroutine until ending of list
			-- so, it will make coroutine stacks that will take space!
			promise.spawn(self.remove,self,1);
		end
	end):catch(function (err) -- lua error on running
		self.error = err;
		logger.errorf("Play failed : %s",err);
		sendMessage(thing,("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
			tostring((thing.info or {title = "unknown"}).title),
			tostring(err)
		));
	end);
end

-- stop now playing
function this:__stop() -- PRIVATE
	if not self.nowPlaying then
		return;
	end
	self.handler:stopStream();
	self.nowPlaying = nil;
	self.isPaused = false;
	return true;
end

--#endregion : Stream handling methods

-- apply play queue
function this:apply()
	local song = self[1];
	logger.infof("aplly np : '%s' song : '%s'",tostring(self.nowPlaying),tostring(song));
	if self.nowPlaying == song then
		return;
	end
	logger.info("apply requested");
	if not song then
		return self:__stop();
	end
	self:__play(song);
	return true;
end

--- insert new song
function this:add(thing,onIndex)
	local message = thing.message;
	thing.channel = thing.channel or (message and message.channel);
	self.download(thing);
	if not thing.audio then
		error("fail to download");
	end

	-- add into play queue
	if onIndex then
		insert(self,onIndex,thing);
	else
		insert(self,thing);
	end

	-- apply this play queue
	self:apply();
	return true;
end

-- remove song and checkout
function this:remove(start,counts)
	counts = counts or 1;
	if not start then -- get last index
		start = #self;
		counts = 1; -- THIS IS MUST BE 1, other value will make errors
	end
	local popedLast,indexLast;
	local popedAll = {};
	for index = start,start+counts-1 do
		popedLast = remove(self,start);
		indexLast = index;
		insert(popedAll,popedLast);
	end
	self:apply();
	return popedLast,indexLast,popedAll;
end

-- disconnect voice connection and remove self from cache list
function this:kill()
	self:__stop();
	local handler = self.handler;
	if handler then
		handler:close();
	end
	self.destroyed = true;
	self.playerForChannels[self.voiceChannelID] = nil;
end

-- set resume, pause
function this:setPaused(paused)
	if paused then
		self.isPaused = true;
		self.handler:pauseStream();
	else
		self.isPaused = false;
		self.handler:resumeStream();
	end
end

-- set looping
function this:setLooping(looping)
	self.isLooping = looping;
end

local ceil = math.ceil;
function this:getStatusText()
	local duration = 0;
	for _,song in ipairs(self) do
		duration = duration + song.info.duration;
	end
	local len = #self;
	local handler = self.handler;
	local getElapsed = handler and rawget(handler,"getElapsed");
	local elapsed = getElapsed and (getElapsed() / 1000) or 0;
	return {
		text = ("총 곡 수 : %d | 총 페이지 수 : %d | 총 길이 : %s"):format(len,ceil(len / 10),formatTime(duration - (elapsed or 0)))
		.. (self.isLooping and "\n플레이리스트 루프중" or "")
		.. (self.mode24 and "\n24 시간 모드 켜짐" or "")
		.. (self.isPaused and "\n재생 멈춤" or "");
	};
end

local itemPerPage = 10;
-- display list of songs
function this:embedfiyList(page)
	local handler = self.handler;
	local getElapsed = handler and rawget(handler,"getElapsed");
	local elapsed = getElapsed and (getElapsed() / 1000) or 0;

	local now = time();
	page = tonumber(page) or 1;
	local atStart,atEnd = itemPerPage * (page-1) + 1,page * itemPerPage
	local fields = {};
	for index = atStart,atEnd do
		local song = self[index];
		if song then
			insert(fields,{
				name = (index == 1) and ("현재 재생중 (%s/%s)"):format(formatTime((song.info or {}).duration),formatTime(elapsed)) or (("%d 번째 곡 (%s)"):format(index,formatTime((song.info or {}).duration)));
				value = ("[%s](%s)\n`신청자 : %s (%s)`"):format(
					(song.info or {title = "NULL"}).title:gsub("\"","\\\""),
					song.url,
					song.username or "NULL",
					timeAgo(song.whenAdded,now)
				);
			});
		end
	end

	if #fields == 0 then
		if page == 1 then
			return {
				footer = self:getStatusText();
				fields = fields;
				title = "1 페이지";
				description = "재생 목록이 비어있습니다";
				color = 16040191;
			};
		end
		return {
			footer = self:getStatusText();
			fields = fields;
			title = ("%d 페이지"):format(page);
			description = "페이지가 비어있습니다";
			color = 16040191;
		};
	end

	if #self > atEnd then
		insert(fields,{
			name = "더 많은 곡이 있습니다!";
			value = ("다음 페이지를 보려면\n> 미나 곡리스트 %d\n를 입력해주세요"):format(page + 1);
		});
	end

	return {
		description = "팁 : **미나 곡정보 [번째]** 를 이용하면 해당 곡에 대한 더 자세한 정보를 얻을 수 있습니다";
		fields = fields;
		footer = self:getStatusText();
		title = ("%d 번째 페이지"):format(page);
		color = 16040191;
	}
end

-- seekbar object
local seekbarForward = "━";
local seekbarBackward = "─";
local seekbarString = "%s %s⬤%s %s\n";
local seekbarLen = 14;
local function seekbar(now,atEnd)
	local per = now / atEnd;
	local forward = math.floor(seekbarLen * per + 0.5);
	local backward = math.floor(seekbarLen - forward);
	return seekbarString:format(
		formatTime(now),
		seekbarForward:rep(forward),
		seekbarBackward:rep(backward),
		formatTime(atEnd)
	);
end
this.seekbar = seekbar;

-- display now playing
function this:embedfiyNowplaying(index)
	index = tonumber(index) or 1;
	local song = self[index];

	if not song then
		return {
			title = (index == 1) and "재생 목록이 비어있습니다" or "존재하지 않습니다!";
			color = 16040191;
		};
	end

	local info = song.info;
	if not info then
		return {
			title = "알 수 없는 곡";
			color = 16040191;
		};
	end
	local thumbnails = info.thumbnails;
	local handler = self.handler;
	local getElapsed = handler.getElapsed;
	local elapsed = getElapsed and (getElapsed() / 1000) or 0;
	local duration = info.duration;
	return {
		footer = self:getStatusText();
		title = info.title;
		description = ("%s신청자 : %s | 신청시간 : %s\n%s조회수 : %s | 좋아요 : %s\n업로더 : %s\n[영상으로 이동](%s) | [채널로 이동](%s)"):format(
			getElapsed and (index == 1) and seekbar(elapsed,duration) or "",
			song.username or "NULL",
			timeAgo(song.whenAdded),
			(not getElapsed) and ("곡 길이 : %s | "):format(formatTime(duration)) or "",
			tostring(info.view_count),
			tostring(info.like_count),
			tostring(info.uploader),
			tostring(song.url or info.webpage_url),
			tostring(info.uploader_url or info.channel_url)
		);
		thumbnail = thumbnails and {
			url = thumbnails[#thumbnails].url;
		} or nil;
		color = 16040191;
	};
end

-- seek playing position
function this:seek(timestamp)
	if not self.nowPlaying then
		error(
			("player:seek must be called on playing song (self.nowPlaying == nil)\nplayerId: %s")
				:format(self.voiceChannelID or "NULL")
		);
	else
		local timestampType = type(timestamp);
		if timestampType ~= "number" then
			error(
				("timestamp must be number value. but got %s (%s)")
					:format(timestampType,tostring(timestamp))
			);
		end
	end
	self.seeking = timestamp;
	self.handler:stopStream();
end

-- restore saved status
function this.restore(data)
	local client = _G.client;
	for _,playerData in ipairs(data) do
		local voiceChannelId = playerData.channel;
		local voiceChannel = client:getChannel(voiceChannelId); ---@type GuildVoiceChannel
		local songs = playerData.songs;

		if voiceChannel and songs and (#songs ~= 0) then
			local player = this.new {
				voiceChannelID = voiceChannelId;
				handler = voiceChannel:join();
				timestamp = playerData.timestamp;
				isLooping = playerData.isLooping;
				mode24 = playerData.mode24;
			};
			for _,song in ipairs(songs) do
				song.channel = client:getChannel(song.channel);
				pcall(player.add,player,song);
			end
			if playerData.isPaused then
				player:setPaused(true);
			end
		end
	end
end

-- save status
function this.save()
	local data = {};
	for voiceChannelId,player in pairs(this.playerForChannels) do
		local playerData = {channel = voiceChannelId,isLooping = player.isLooping,isPaused = player.isPaused,mode24 = player.mode24};
		local songs = {};
		playerData.songs = songs;
		local handler = player.handler;
		local getElapsed = handler and rawget(handler,"getElapsed");
		local timestamp = getElapsed and (getElapsed() / 1000);
		playerData.timestamp = timestamp;
		for _,song in ipairs(player) do
			insert(songs,{
				channel = song.channel.id;
				whenAdded = song.whenAdded;
				username = song.username;
				url = song.url;
			});
		end
		insert(data,playerData);
	end
	return data;
end

return this;
