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
		--self.handler:playFFmpeg(thing.audio);
		self.handler:playFFmpeg("https://r1---sn-ab02a0nfpgxapox-u5xl.googlevideo.com/videoplayback?expire=1632663403&ei=CyNQYcOrJJLU2roP5oGFmA4&ip=115.138.195.111&id=o-AHD3cSrYNIcrrVbYS3Px_XoLr-2JUP-UqgLct29siyuF&itag=249&source=youtube&requiressl=yes&mh=T8&mm=31%2C29&mn=sn-ab02a0nfpgxapox-u5xl%2Csn-ab02a0nfpgxapox-bh2sd&ms=au%2Crdu&mv=m&mvi=1&pl=24&initcwndbps=2118750&vprv=1&mime=audio%2Fwebm&ns=pkbzpSIuZEsdLFC_o6-sppsG&gir=yes&clen=1421624&dur=221.801&lmt=1632576947873438&mt=1632641573&fvip=1&keepalive=yes&fexp=24001373%2C24007246&c=WEB&txp=5531432&n=1g2FPUvBkvLY01_&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cns%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgdLP-YY9xlqt4rizhjYDZs_uLwd6UaW6HUQGhIAcoZBMCIQDQKDx4ooTLkfP7f4njNU9R-hUpYhCyeF97K5Lxf5FaXA%3D%3D&sig=AOq0QJ8wRQIhALC3fLqnYcJlIz4KKaQQtklyc63VVy0cngKR4gjyjPATAiAduQ5mYzjq98Ax9lX0rdtSKd7AIoCPtJNQU8fodLjfBA==");
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
	self.handler:resumeStream();
end
function this:pause()
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
	local audio = ytDown.download(thing.url)
	if not audio then
		return nil;
	end
	thing.audio = audio
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
			value = ("[%s](%s)"):format(song.name:gsub("\"","\\\""),song.url);
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
