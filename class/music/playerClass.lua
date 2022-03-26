-- music channel player instance class for playing user's queued music
-- ---@type number
-- local theHourOfAllOfSpentForEditingThis = 122;

---@class playerClass
local this = {};
this.__index = this;
this.playerForChannels = {};

--#region --* Setup const objects *--

local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;
local isDiscordiaObject = discordia.class.isObject;
local remove = table.remove;
local insert = table.insert;
local time = os.time;
local floor = math.floor;
local timeAgo = _G.timeAgo;
local promise = _G.promise;
local killTimer = 60 * 5 * 1000;
local empty = string.char(226,128,139);

--#endregion --* setup const objects *--
--#region --* Setup ytdl *--

local isStreamMode,disableServerSidePostprocessor;
local ytHandler; ---@module "class.music.youtubeStream";
for _,str in ipairs(app.args) do
	if str == "voice.useStream" then
		isStreamMode = true;
		ytHandler = require("class.music.youtubeStream");
	elseif str == "voice.disable-server-side-postprocessor" then
		disableServerSidePostprocessor = true;
	end
end
ytHandler = ytHandler or require("class.music.youtubeDownload");
this.ytHandler = ytHandler;
this.timeoutMessage = ytHandler.timeoutMessage;

-- Insert args on ffmpeg process
if disableServerSidePostprocessor then
	local args = discordia_class.classes.FFmpegProcess.args;
	if args then
		insert(args,"-b:a");
		insert(args,"64k");
		insert(args,"-af");
		insert(args,"loudnorm");
	end
end

--#endregion --* setup ytdl *--
--#region --* Util functions *--

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
	local message = thing and thing.message;

	if not msg then
		logger.errorf("playerClass.sendMessage : arg 'msg' was invalid (msg: %s)",tostring(msg));
		return;
	end

	if type(message) == "table" then
		return message:reply {
			content = msg;
			reference = {message = message, mention = false};
		};
	else
		local channel = thing.channel;
		if type(channel) == "table" then
			return channel:send(msg);
		else
			logger.errorf("playerClass.sendMessage : cannot found message and channel from arg 'thing', ignored");
		end
	end
end
this.sendMessage = sendMessage;

-- download music for prepare playing song
local function download(thing,lastInfo)
	local audio,info,url,vid = ytHandler.download(thing.url,lastInfo);
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
this.download = download;

local function importEmoji(id,name)
	if name then return ("<:%s:%s>"):format(tostring(id),tostring(name)); end
	return ("<:a:%s>"):format(tostring(id));
end
this.importEmoji = importEmoji;

-- seekbar object
local seekbarLen = 16;
local leffHollow = importEmoji("952445243637248040","progressLeftHollow");
local leftFill = importEmoji("952445243331059793","progressLeftFill");
local midFill = importEmoji("952445243700154388","progressMidFill");
local midHalf = importEmoji("952445243666628628","progressMidHalf");
local midHollow = importEmoji("952445243805007902","progressMidHollow");
local rightHollow = importEmoji("952445243385610241","progressRightHollow");
local rightFill = importEmoji("952445243754709072","progressRightFill");
local function seekbar(now,atEnd)
	local per = now / atEnd;
	local forward = math.floor(seekbarLen * per + 0.5);

	if forward >= seekbarLen then
		return ("%s%s%s%s%s\n"):format(formatTime(now),leftFill,midFill:rep(seekbarLen-2),rightFill,formatTime(atEnd));
	elseif forward == 1 then
		return ("%s%s%s%s%s%s\n"):format(formatTime(now),leftFill,midHalf,midHollow:rep(seekbarLen-3),rightHollow,formatTime(atEnd));
	elseif forward == 0 then
		return ("%s%s%s%s%s\n"):format(formatTime(now),leffHollow,midHollow:rep(seekbarLen-2),rightHollow,formatTime(atEnd));
	end
	return ("%s%s%s%s%s%s%s\n"):format(formatTime(now),leftFill,midFill:rep(forward-1),midHalf,midHollow:rep(seekbarLen-2-forward),rightHollow,formatTime(atEnd));
end
this.seekbar = seekbar;

--#endregion --* util functions *--
--#region --* Client setups *--

--- make auto leave for none-using channels
---@param member Member
---@param channel GuildVoiceChannel
local function voiceChannelJoin(member,channel)
	if member and member.bot then ---@diagnostic disable-line
		return;
	end
	local channelId = channel:__hash();
	local player = this.playerForChannels[channelId];
	if player then
		local leaveMessage = player.leaveMessage;
		if player.isPausedByNoUser then
			player.isPausedByNoUser = nil;
			player:setPaused(false);
		end
		local timeout = player.timeout;
		if timeout then
			logger.infof("Someone joined voice channel, stop killing player [channel:%s]",channelId);
			player.timeout = nil;
			pcall(timer.clearTimer,timeout);
		end
		if leaveMessage then
			player.leaveMessage = nil;
			leaveMessage:delete();
		end
	end
end
local function voiceChannelJoinErr(channel,result)
	logger.errorf("An error occurred while trying adding killing music player queue [channel:%s]",
		(channel[1] or {__hash = function () return "unknown"; end}):__hash()
	);
	logger.errorf("Error message was : %s",result);
end
client:on("voiceChannelJoin",function (...)
	local channel = select(2,...);
	promise.new(voiceChannelJoin,...)
		:catch(voiceChannelJoinErr,channel);
end);
this.voiceChannelJoin = voiceChannelJoin;
this.voiceChannelJoinErr = voiceChannelJoinErr;

---@param member Member
---@param channel GuildVoiceChannel
---@param player playerClass
local function voiceChannelLeave(member,channel,player)
	if member and member.bot then ---@diagnostic disable-line
		return;
	end
	local channelId = channel:__hash();
	player = player or this.playerForChannels[channelId];
	local guild = channel.guild;
	local connection = guild.connection;
	if player and connection then
		local playerTimeout = player.timeout;
		if playerTimeout then
			player.timeout = nil;
			pcall(timer.clearTimer,playerTimeout);
		end
		local tryKill = true;
		for _,user in pairs(channel.connectedMembers or {}) do
			if not user.bot then
				tryKill = false;
			end
		end
		local nowPlaying = player.nowPlaying;
		if tryKill then -- pause
			if nowPlaying and (not player.isPaused) then
				player.isPausedByNoUser = true;
				player.leaveMessage = sendMessage(player[1] or player.nowPlaying,"음성채팅방에 아무도 없어 음악을 일시 중지했어요! (다시 입장시 자동으로 재개해요)");
				player:setPaused(true);
			elseif nowPlaying == nil and (not player[1]) then
				pcall(player.kill,player);
				pcall(connection.close,connection);
				this.playerForChannels[channelId] = nil;
			end
		end
		if player.mode24 then -- check mode that prevent killed
			return;
		end
		if tryKill and (not player.timeout) then -- kill
			logger.infof("All users left voice channel, queued player to kill list [channel:%s]",channelId);
			player.timeout = timeout(killTimer,function ()
				connection = guild.connection;
				local leaveMessage = player.leaveMessage;
				if connection then
					logger.infof("voice channel timeouted! killing player now [channel:%s]",channelId);
					sendMessage(player[1] or player.nowPlaying,"5분동안 사람이 없어 음성채팅방에서 나갔어요!");
					pcall(player.kill,player);
					pcall(connection.close,connection);
					this.playerForChannels[channelId] = nil;
				end
				if leaveMessage then
					leaveMessage:delete();
				end
			end);
		end
	elseif player then
		this.playerForChannels[channelId] = nil;
	end
end
local function voiceChannelLeaveErr(channel,result)
	logger.errorf("An error occurred while trying adding killing music player queue [channel:%s]",
		(channel[1] or {__hash = function () return "unknown"; end}):__hash()
	);
	logger.errorf("Error message was : %s",result);
end
client:on("voiceChannelLeave",function (...)
	local channel = select(2,...);
	promise.new(voiceChannelLeave,...)
		:catch(voiceChannelLeaveErr,channel);
end);
this.voiceChannelLeave = voiceChannelLeave;
this.voiceChannelLeaveErr = voiceChannelLeaveErr;

-- restore data
client:once("ready", function ()
	local lastData = fs.readFileSync("./data/lastMusicStatus.json")
	if lastData and lastData ~= "" then
		logger.info("found music backup data! restoring ...");
		local data = json.decode(lastData);
		if data then
			promise.new(this.restore,data):wait();
			timer.sleep(100);
			---@type playerClass
			for _,player in pairs(this.playerForChannels) do
				local handler = player and player.handler;
				local channel = handler and handler.channel;
				if channel then
					voiceChannelLeave(nil,channel,player);
				end
			end
			logger.info("Restored all song playing data!");
		end
	end
	fs.writeFileSync("./data/lastMusicStatus.json","");
end);

client:on('stoping',function ()
	fs.writeFileSync("./data/lastMusicStatus.json",json.encode(this.save()));
	logger.info("Saved all song playing data!");
end);

client:on("voiceConnectionMove",function (old,new)
	if not (old and new) then
		return;
	end

	local oldId,newId = old.id,new.id;
	if not (oldId and newId) then
		return;
	end

	logger.infof("voiceConnection move request, channel status changed to %s -> %s",oldId,newId);

	local player = this.playerForChannels[oldId];
	if not player then
		logger.errorf("voiceConnection move was requested but no player found from last connection, channel was %s -> %s",oldId,newId);
		return
	end
	this.playerForChannels[newId] = player;
	this.playerForChannels[oldId] = nil;
	player.voiceChannelID = newId;

	local newConnection = player.handler.channel.guild.connection;
	player.handler = newConnection;

	local handler = player.handler;
	local nowPlaying = player[1];
	if nowPlaying then
		player.reconnect = true;
		player:__stop();
		timer.sleep(20);
		player.reconnect = false;
		promise.spawn(this.__play,player,nowPlaying);
	end
	timer.sleep(50); -- wait for all tasks to complete
	-- player.handler
	-- logger.info(player[1] ~= nil);
	voiceChannelJoin(nil,handler.channel);
	voiceChannelLeave(nil,handler.channel,player);
end);

--#endregion --* Client setups *--
--#region --* Class initialization *--

--[[
voiceChannelID : 그냥 식별용으로 쓰기 위해 만든 별거 없는 아이디스페이스
nowPlaying : 지금 플레이중인 곡
new.playIndex
]]

--- make new playerClass instnace
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

--#endregion --* class initialization *--
--#region --* (PRIVATE) Stream handling methods *--

local getPosixNow = posixTime.now;
local expireAtLast = 2 * 60;
local retryRate = 20;
local maxRetrys = 7;
local function playEnd(args,result,reason)
	local self,thing,position = args[1],args[2],args[3];
	logger.infof("stopped with %s, %s, %s, %s, %s",tostring(self),tostring(thing),tostring(position),tostring(result),tostring(reason));
	local handler = self.handler;
	if self.destroyed then -- is destroyed
		return;
	elseif reason == "reconnecting" or handler.socket.reconnect or self.reconnect then -- reconnect and play this again
		self.reconnect = nil;
		if tonumber(result) then thing.timestamp = result / 1000; end
		return;
	elseif reason == "Connection is not ready" then -- discord connection error
		return pcall(self.kill,self);
	elseif reason and (reason ~= "stream stopped") and (reason ~= "stream exhausted or errored") then -- idk
		logger.errorf("Play failed : %s",reason);
		sendMessage(thing,("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```\n%s\n```"):format(
			tostring((thing.info or {title = "unknown"}).title),
			tostring(reason)
		));
		return;
	end

	-- TODO: hight resolution time required!
	-- when errored, replay on errored timestamp (point of stoped)
	result = result or position;
	local ffmpegError = self.ffmpegError;
	self.ffmpegError = nil;
	if ffmpegError and (type(result) == "number") then -- result is elapsed
		local ffmpegErrorLow = ffmpegError:lower();
		if ffmpegErrorLow:match("access denied") or ffmpegErrorLow:match("Forbidden") then -- if expried
			logger.warnf("stream url expried, re-downloading ... (%s)",thing.url);
			download(thing);
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
			sendMessage(thing,("오류가 너무 많아 이 곡을 건너뜁니다! 가장 최근 오류 :```\n%s```"):format(ffmpegError));
		end
	end
	self.lastErrorTime = nil;
	self.lastErrorRetrys = nil;

	-- if no connection, return
	if self.handler.channel.guild.connection ~= self.handler then
		return;
	end

	-- when seeking
	local seeking = self.seeking;
	if seeking then
		thing.timestamp,self.timestamp,self.nowPlaying,self.seeking = nil,nil,nil,nil;
		logger.infof("seeking into %s",tostring(seeking));
		promise.spawn(this.__play,self,thing,seeking);
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
		local timestamp = upnext.timestamp;
		self.lastUpnextMessage = sendMessage(thing,("'%s' 를(을) 재생합니다!%s"):format(
			tostring((upnext.info or {title = "unknown"}).title),
			timestamp and ((" (%s)"):format(formatTime(timestamp))) or ""
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
		logger.infof("try to remove songs (%s)",tostring(reason))
		promise.spawn(self.remove,self,1);
	end
end

local function playErr(args,err) -- lua error on running
	local self,thing = args[1],args[2];
	self.error = err;
	logger.errorf("Play failed : %s",err);
	sendMessage(thing,("곡 '%s' 를 재생하던 중 오류가 발생했습니다!\n```log\n%s\n```"):format(
		tostring((thing.info or {title = "unknown"}).title),
		tostring(err)
	));
end

-- play thing
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
	position = position or self.timestamp or thing.timestamp;
	logger.infof("playing %s with %s",tostring(thing),tostring(position)); -- logging
	local nowPlaying = self.nowPlaying;
	if nowPlaying then -- if already playing something, kill it
		local getElapsed = handler.getElapsed;
		if getElapsed then
			local elapsed = getElapsed() / 1000;
			nowPlaying.timestamp = elapsed;
			logger.infof("saved last playing timestamp %d",elapsed)
		end
		self:__stop();
	end
	self.timestamp = nil;
	self.nowPlaying = thing; -- set playing song
	self.isPaused = false; -- set paused state to false

	-- if it needs redownload, try it nowd
	local exprie = thing.exprie;
	local info = thing.info;
	if exprie and exprie <= (getPosixNow()+(info and info.duration or 0)+expireAtLast-(position or 0)) then
		download(thing);
	end

	-- run asynchronously task for playing song
	-- play this song
	promise.new(handler.playFFmpeg,handler,thing.audio,nil,position,coroutine.wrap(function (errStr)
		self.ffmpegError = (self.ffmpegError or "") .. "\n" .. errStr; -- set error
	end))
		:andThen(playEnd,self,thing,position)
		:catch(playErr,self,thing);
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

--#endregion --* (PRIVATE) Stream handling methods *--
--#region --* Class methods *--

-- apply play queue
function this:apply()
	local song = self[1];
	logger.infof("apply np : '%s' song : '%s'",tostring(self.nowPlaying),tostring(song));
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
	download(thing,thing.info);
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
	local handler = self.handler;
	if paused then
		self.isPaused = true;
		handler:pauseStream();
		local nowPlaying = self.nowPlaying;
		local getElapsed = rawget(handler,"getElapsed");
		if nowPlaying and getElapsed then
			nowPlaying.timestamp = getElapsed() / 1000;
		end
	else
		self.isPaused = false;
		handler:resumeStream();
	end
end

-- set looping
function this:setLooping(looping)
	self.isLooping = looping;
end

local itemPerPage = 10;
local ceil = math.ceil;
-- get total pages
function this:totalPages()
	if type(self) == "table" then
		self = #self;
	end
	return ceil(self / itemPerPage);
end

function this:getStatusText(front,back)
	local duration = 0;
	for _,song in ipairs(self) do
		local timestamp = song.timestamp or 0;
		local info = song.info;
		local songduration = info and info.duration or 0;
		duration = duration + songduration - timestamp;
	end
	local len = #self;
	local handler = self.handler;
	local getElapsed = handler and rawget(handler,"getElapsed");
	local elapsed = getElapsed and (getElapsed() / 1000) or 0;
	local text = ("총 곡 수 : %d | 총 페이지 수 : %d | 총 길이 : %s"):format(len,this.totalPages(len),formatTime(duration - (elapsed or 0)))
		.. (self.isLooping and "\n플레이리스트 루프중" or "")
		.. (self.mode24 and "\n24 시간 모드 켜짐" or "")
		.. (self.isPaused and "\n재생 멈춤" or "");
	if front then text = front .. text; end
	if back then text = text .. back; end
	return {
		text = text;
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

--#endregion --* class methods *--
--#region --* ShowSong *--

-- display song info
function this:songEmbedfiy(index)
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
	local getElapsed = index == 1 and handler.getElapsed;
	local elapsed = getElapsed and (getElapsed() / 1000) or song.timestamp;
	local duration = info.duration;
	local like = info.like_count;
	return {
		footer = self:getStatusText(("%s • %s | "):format(song.username or "NULL",timeAgo(song.whenAdded)));
		-- title = info.title;
		author = {
			name = info.title;
			url = tostring(song.url or info.webpage_url);
		};
		description = ("%s%s조회수 : %s%s | 업로더 : [%s](%s)"):format(
			elapsed and seekbar(elapsed,duration) or "",
			(not elapsed) and ("곡 길이 : %s | "):format(formatTime(duration)) or "",
			tostring(info.view_count),
			like and (" | 좋아요 : %s"):format(tostring(like)) or "",
			tostring(info.uploader),
			tostring(info.uploader_url or info.channel_url)
		);
		thumbnail = thumbnails and {
			url = thumbnails[#thumbnails].url;
		} or nil;
		color = 16040191;
	};
end

local noSong = {components.actionRow.new{
	components.button.new{
		custom_id = "music_song_1";
		style = discordia_enchant_enums.buttonStyle.success;
		label = "새로고침";
		emoji = components.emoji.new"🔄";
	};
	buttons.action_remove;
}};
function this:songIndicator(index)
	if (not index) or (not self) or (#self == 0) then
		return noSong;
	end
	return {components.actionRow.new{
		components.button.new{
			custom_id = ("music_song_%d"):format(index);
			style = discordia_enchant_enums.buttonStyle.success;
			emoji = components.emoji.new "🔄";
			label = "새로고침";
		};
		components.button.new{
			custom_id = ("music_song_%d"):format(index-1);
			style = discordia_enchant_enums.buttonStyle.primary;
			label = "이전 곡정보";
			emoji = components.emoji.new "⬅";
			disabled = index <= 1;
		};
		components.button.new{
			custom_id = ("music_song_%d"):format(index+1);
			style = discordia_enchant_enums.buttonStyle.primary;
			label = "다음 곡정보";
			emoji = components.emoji.new "➡";
			disabled = index >= #self;
		};
		buttons.action_remove;
	}};
end

---show song information, you can give arguments with guild or playerClass
---@param self playerClass the guild or player to display
---@param index number index number of song to show
---@return table contents message contents object, you can use this with message:update()
function this:showSong(index)
	index = index or 1;
	if isDiscordiaObject(self) then
		local guildConnection = self.connection;
		if not guildConnection then
			return {
				content = "틀려있는 음악이 없어요!";
				components = this.songIndicator();
				embed = {};
				embeds = {};
			};
		end
		self = this.playerForChannels[guildConnection.channel:__hash()];
		if not self then
			return {
				content = "오류가 발생했어요!\n> 플레이어를 찾을 수 없습니다 (봇을 음성채팅에서 킥한 후 다시 시도해보세요)";
				components = this.songIndicator();
				embed = {};
				embeds = {};
			};
		end
	end

	local embed = self:songEmbedfiy(index);
	return {
		embeds = {embed};
		embed = embed;
		content = index == 1 and "지금 재생중인 곡입니다!" or (("%d 번째 곡입니다!"):format(index));
		components = self:songIndicator(index);
	};
end

---@param id string
---@param object interaction
local function songIndicatorButtonPressed(id,object)
	local index = tonumber(id:match("music_song_(%d+)"));
	if not index then return; end
	-- logger.infof("index move button pressed '%d'",tostring(index));
	object:update(this.showSong(object.guild,index));
end
client:on("buttonPressed",songIndicatorButtonPressed);

--#endregion --* ShowSong *--
--#region --* ShowList *--

-- display list of songs
function this:listEmbedfiy(page)
	local handler = self.handler;
	local getElapsed = handler and rawget(handler,"getElapsed");
	local elapsed = getElapsed and (getElapsed() / 1000) or 0;

	local now = time();
	page = tonumber(page) or 1;
	local atStart,atEnd = itemPerPage * (page-1) + 1,page * itemPerPage;
	local fields = {};
	for index = atStart,atEnd do
		local song = self[index];
		if song then
			local timestamp = song.timestamp;
			insert(fields,{
				name = (index == 1) and ("현재 재생중 (%s/%s)"):format(formatTime(elapsed),formatTime((song.info or {}).duration)) or (("%d 번째 곡 (%s%s)"):format(index,timestamp and ("%s/"):format(formatTime(timestamp)) or "",formatTime((song.info or {}).duration)));
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

	return {
		description = "팁 : **미나 곡정보 [번째]** 를 이용하면 해당 곡에 대한 더 자세한 정보를 얻을 수 있습니다";
		fields = fields;
		footer = self:getStatusText();
		title = ("%d 번째 페이지"):format(page);
		color = 16040191;
	}
end

-- make next page button, previous page button, remove button components
local noPage = {components.actionRow.new{
	components.button.new{
		custom_id = "music_page_1";
		style = discordia_enchant_enums.buttonStyle.success;
		label = "새로고침";
		emoji = components.emoji.new"🔄";
	};
	buttons.action_remove;
}};
function this:pageIndicator(page)
	if (not page) or (not self) then
		return noPage;
	end
	local totalSongs = #self;
	if totalSongs == 0 then
		return noPage;
	end
	return {components.actionRow.new{
		components.button.new{
			custom_id = ("music_page_%d"):format(page);
			style = discordia_enchant_enums.buttonStyle.success;
			label = "새로고침";
			emoji = components.emoji.new "🔄";
		};
		components.button.new{
			custom_id = ("music_page_%d"):format(page-1);
			style = discordia_enchant_enums.buttonStyle.primary;
			label = "이전 페이지";
			emoji = components.emoji.new "⬅";
			disabled = page <= 1;
		};
		components.button.new{
			custom_id = ("music_page_%d"):format(page+1);
			style = discordia_enchant_enums.buttonStyle.primary;
			label = "다음 페이지";
			emoji = components.emoji.new "➡";
			disabled = page >= this.totalPages(totalSongs);
		};
		buttons.action_remove;
	}};
end

---show list page, you can give arguments with guild or playerClass
---@param self playerClass the guild or player to display
---@param page number number of page to show
---@return table contents message contents object, you can use this with message:update()
function this:showList(page)
	if isDiscordiaObject(self) then
		local guildConnection = self.connection;
		if not guildConnection then
			return {
				content = "틀려있는 음악이 없어요!";
				components = this.pageIndicator();
				embed = {};
				embeds = {};
			};
		end
		self = this.playerForChannels[guildConnection.channel:__hash()];
		if not self then
			return {
				content = "오류가 발생했어요!\n> 플레이어를 찾을 수 없습니다 (봇을 음성채팅에서 킥한 후 다시 시도해보세요)";
				components = this.pageIndicator();
				embed = {};
				embeds = {};
			};
		end
	end
	local embed = self:listEmbedfiy(page);
	return {
		embed = embed;
		embeds = {embed};
		content = "현재 이 서버의 플레이리스트입니다!";
		components = self:pageIndicator(page);
	};
end

---@param id string
---@param object interaction
local function pageIndicatorButtonPressed(id,object)
	local page = tonumber(id:match"music_page_(%d+)");
	if not page then return; end
	-- logger.infof("page move button pressed '%d'",tostring(page));
	object:update(this.showList(object.guild,page));
end
client:on("buttonPressed",pageIndicatorButtonPressed);

--#endregion ShowList
--#region --* Restore *--

-- restore saved status
function this.restore(data)
	local client = _G.client;
	local waitter = promise.waitter();
	for _,playerData in ipairs(data) do
		local voiceChannelId = playerData.channel;
		local voiceChannel = client:getChannel(voiceChannelId); ---@type GuildVoiceChannel
		local songs = playerData.songs;
		local guild = voiceChannel and voiceChannel.guild;

		if voiceChannel and songs and (#songs ~= 0) then
			waitter:add(promise.new(function ()
				local connection = voiceChannel:join();
				local player = this.new {
					voiceChannelID = voiceChannelId;
					handler = connection;
					timestamp = playerData.timestamp;
					isLooping = playerData.isLooping;
					mode24 = playerData.mode24;
				};
				local isPaused = playerData.isPaused;
				for index,song in ipairs(songs) do
					song.channel = client:getChannel(song.channel);
					pcall(player.add,player,song);
					if guild.connection ~= connection then
						return;
					end
					if index == 1 and isPaused then
						player:setPaused(true);
					end
				end
			end));
		end
	end
	waitter:wait();
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
				timestamp = song.timestamp;
				info = song.info;
			});
		end
		insert(data,playerData);
	end
	return data;
end

--#endregion --* Restore *--

return this;
