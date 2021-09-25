local this = {};
this.__index = this;

-- 이 코드는 신과 나만 읽을 수 있게 만들었습니다
-- 만약 편집을 기꺼히 원한다면... 그렇게 하도록 하세요
-- 다만 여기의 이 규칙을 따라주세요
-- theHourOfAllOfSpentForEditingThis = 6; -- TYPE: number;hour
-- 이 코드를 편집하기 위해 사용한 시간만큼 여기의
-- 변수에 값을 추가해주세요.

local spawn = require('coro-spawn');
local split = require('coro-split');
local parse = require('url').parse;
local function getStream(url)
    local child = spawn('youtube-dl', {
        args = {'-g', url},
        stdio = {nil, true, true}
    });
    local stream;

    local function readstdout()
        local stdout = child.stdout;
        for chunk in stdout.read do
            local mime = parse(chunk, true).query.mime;
            if mime and mime:find('audio') then
                stream = chunk;
            end
        end
        return pcall(stdout.handle.close, stdout.handle);
    end

    local function readstderr()
        local stderr = child.stderr;
        for chunk in stderr.read do
            print(chunk);
        end
        return pcall(stderr.handle.close, stderr.handle);
    end

    split(readstdout, readstderr, child.waitExit);
    return stream and stream:gsub('%c', '');
end

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
    local stream = getStream(thing.url);
    coroutine.wrap(function()
        self.handle:playFile(stream);
        self.nowPlaying = nil; -- remove song
        uv.sleep(200);
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
    self.__play(self[1]);
end

local insert = table.insert;
--- insert new song
function this:add(thing,onIndex)
    insert(self,onIndex,thing);
    if self.playIndex == 0 then
        self.playIndex = 1;
    end
    self:apply();
end

local remove = table.remove;
-- remove song and check
function this:remove(index)
    if not index then
        index = #self;
    end
    remove(self,index);
    self:apply();
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