local this = {};
this.__index = this;

local ytDown = require("commands.music.youtubeDownload");

-- 이 코드는 신과 나만 읽을 수 있게 만들었습니다
-- 만약 편집을 기꺼히 원한다면... 그렇게 하도록 하세요
-- 다만 여기의 이 규칙을 따라주세요
-- theHourOfAllOfSpentForEditingThis = 6; -- TYPE: number;hour
-- 이 코드를 편집하기 위해 사용한 시간만큼 여기의
-- 변수에 값을 추가해주세요.

--[[
voiceChannelID : 그냥 식별용으로 쓰기 위해 만든 별거 없는 아이디스페이스
nowPlaying : 지금 플레이중인 곡
new.playIndex
]]
function this.new(props)
	local new = {};
	new.voiceChannelID = props.voiceChannelID;
	new.nowPlaying = nil;
	new.handler = props.handler;
	new.isPaused = false;
	setmetatable(new,this);
	return new;
end

--#region : Stream handling methods

function this:__play(thing) -- PRIVATE
	if not thing then -- if thing is none - song
		return;
	end
	if self.nowPlaying then
		self:__stop();
	end
	self.nowPlaying = thing;
	coroutine.wrap(function()
		self.handler:playFFmpeg(thing.audio);
		self.nowPlaying = nil; -- remove song
		timer.sleep(20);
		self:remove(1);
	end)();
end
function this:__stop() -- PRIVATE
	if not self.nowPlaying then
		return;
	end
	self.nowPlaying = nil;
	self.handler:stopStream();
end
function this:resume()
	self.isPaused = false;
	self.handler:resumeStream();
end
function this:pause()
	self.isPaused = true;
	self.handler:pauseStream();
end
--#endregion : Stream handling methods

function this:apply()
	if self.nowPlaying == self[1] then
		return;
	end
	qDebug {
		title = "playing music";
		channelID = self.voiceChannelID;
		file = self.url;
	};
	self:__play(self[1]);
end

local insert = table.insert;
--- insert new song
function this:add(thing,onIndex,callback)
	local audio,info = ytDown.download(thing.url);
	if not audio then
		return nil;
	end
	thing.audio = audio;
	thing.info = info;
	if onIndex then
		insert(self,onIndex,thing);
	else
		insert(self,thing);
	end
	self:apply();
	return audio;
end

local remove = table.remove;
-- remove song and check
function this:remove(index)
	if not index then
		index = #self;
	end
	local poped = remove(self,index);
	self:apply();
	return poped;
end

function this:kill()
	local handler = self.handler;
	if handler then
		handler:close();
	end
end

function this:embedfiy()
	local fields = {};
	for i,song in ipairs(self) do
		insert(fields,{
			name = ("%d 번째 곡"):format(i);
			value = ("[%s](%s)"):format(song.info.title:gsub("\"","\\\""),song.url);
		});
	end

	return {
		fields = fields;
		footer = {
			 text = "제발 되라 버그 안나고 - 개발중 작성";
		};
		title = "재생 목록에 있는 곡들은 다음과 같습니다";
		color = 16040191;
	};
end

return this;
