-- music channel player instance class for playing user's queued music

local this = {};
this.__index = this;

local ytDownload = require("class.music.youtubeStream");--require("commands.music.youtubeDownload");

local remove = table.remove;
local insert = table.insert;
local time = os.time;
local floor = math.floor;
local timeAgo = _G.timeAgo;

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
function this.new(props)
	local new = {};
	setmetatable(new,this);
	new:__init(props);
	return new;
end

-- download music for prepare playing song
function this.download(thing)
	local audio,info,url,vid = ytDownload.download(thing.url);
	if not audio then
		return;
	end
	thing.whenDownloaded = time();
	thing.url = url or thing.url;
	thing.audio = audio;
	thing.info = info;
	thing.vid = vid;
	thing.exprie = tonumber(audio:match("expire=(%d+)&"));
	return true;
end

-- init player object
function this:__init(props)
	self.voiceChannelID = props.voiceChannelID;
	self.nowPlaying = nil;
	self.handler = props.handler;
	self.isPaused = false;
	self.isLooping = false;
	self.destroy = props.destroy;
end

--#region : Stream handling methods

-- play thing
local getPosixNow = posixTime.now;
local expireAtLast = 2 * 60;
function this:__play(thing,position) -- PRIVATE
	logger.infof("playing %s with %s",tostring(thing),tostring(position));
	-- if thing is nil, return
	if not thing then
		return;
	end

	-- if already playing something, kill it
	if self.nowPlaying then
		self:__stop();
	end

	-- set state to playing
	self.nowPlaying = thing; -- set playing song
	self.isPaused = false; -- set paused state to false

	-- if it needs redownload, try it now
	-- if (ytDownload.redownload) and (time() - thing.whenDownloaded > 10) then
	-- 	pcall(self.download,thing);
	-- end
	local exprie = thing.exprie;
	local info = thing.info;
	if exprie and exprie <= (getPosixNow()+(info and info.duration or 0)+expireAtLast-(position or 0)) then
		this.download();
	end

	-- run asynchronously task for playing song
	coroutine.wrap(function()
		-- play this song
		local handler = self.handler;
		local isPassed,result,reason = pcall(handler.playFFmpeg,handler,thing.audio,nil,position,coroutine.wrap(function (errStr)
			-- error on ffmpeg
			logger.info("[Music] try to sending error last message");
			local message = thing.message;
			if message then
				message:reply {
					content = ("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
						tostring((thing.info or {title = "unknown"}).title),
						tostring((errStr .. "\n"):gsub("https?://.-<[\n :]",""))
					);
					reference = {message = message, mention = false};
				};
			end
		end));

		local seeking = self.seeking;
		if seeking then
			self.seeking = nil;
			self.nowPlaying = nil;
			logger.infof("seeking into %s",tostring(seeking));
			timeout(0,self.__play,self,thing,seeking);
			return;
		end

		-- check traceback
		if self.destroyed then -- none self
			return;
		elseif not isPassed then -- errored with lua
			self.error = result;
			logger.errorf("Play failed : %s",result);
			local message = thing.message;
			if message then -- display error message
				message:reply {
					content = ("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
						tostring((thing.info or {title = "unknown"}).title),
						tostring(result)
					);
					reference = {message = message, mention = false};
				};
			end
		elseif reason == "Connection is not ready" then -- just unconnected from discord
			-- connection destroyed
			local destroy = self.destroy;
			if destroy then
				pcall(destroy,self);
			end
			return;
		elseif reason and (reason ~= "stream stopped") and (reason ~= "stream exhausted or errored") then -- steam error
			local message = thing.message;
			logger.errorf("Play failed : %s",reason);
			if message then -- display error message
				message:reply {
					content = ("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
						tostring((thing.info or {title = "unknown"}).title),
						tostring(reason)
					);
					reference = {message = message, mention = false};
				};
			end
		end

		-- show next song
		local selfThis = self[1];
		local upnext = self[2];
		if (selfThis == thing) and upnext then
			local message = upnext.message;
			if message then
				message:reply {
					content = ("지금 '%s' 를(을) 재생합니다!"):format(
						tostring((upnext.info or {title = "unknown"}).title)
					);
					reference = {message = message, mention = false};
				};
			end
		end

		-- when looping is enabled
		if self.isLooping and self.nowPlaying then
			insert(self,thing); -- insert this into end of queue
		end

		-- remove this song from queue
		self.nowPlaying = nil; -- remove song
		if selfThis == thing then
			-- IMPORTANT! without this, it will take this coroutine until ending of list
			-- so, it will make coroutine stacks that will take space!
			timeout(0,function()
				self:remove(1);
			end);
		end

		-- this coroutine will killed
	end)();
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
	if self.nowPlaying == song then
		return;
	end
	if not song then
		self:__stop();
	end
	self:__play(song);
	return true;
end

--- insert new song
function this:add(thing,onIndex)
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

-- kill bot
function this:kill()
	local handler = self.handler;
	if handler then
		handler:close();
	end
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
	return {
		text = ("총 곡 수 : %d | 총 페이지 수 : %d | 총 길이 : %s"):format(len,ceil(len / 10),formatTime(duration))
		 .. (self.isLooping and "\n플레이리스트 루프중" or "")
		 .. (self.isPaused and "\n재생 멈춤" or "");
	};
end

local itemPerPage = 10;
-- display list of songs
function this:embedfiyList(page)
	local now = time();
	page = tonumber(page) or 1;
	local atStart,atEnd = itemPerPage * (page-1) + 1,page * itemPerPage
	local fields = {};
	for index = atStart,atEnd do
		local song = self[index];
		if song then
			insert(fields,{
				name = (index == 1) and "현재 재생중" or (("%d 번째 곡 (%s)"):format(index,formatTime((song.info or {}).duration)));
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
	local elapsed = getElapsed() / 1000;
	local duration = info.duration;
	return {
		footer = self:getStatusText();
		title = info.title;
		description = ("%s신청자 : %s | 신청시간 : %s\n%s조회수 : %s | 좋아요 : %s\n업로더 : %s\n[영상으로 이동](%s) | [채널로 이동](%s)"):format(
			getElapsed and seekbar(elapsed,duration) or "",
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

return this;
