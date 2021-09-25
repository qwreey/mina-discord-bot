local this = {};
this.__index = this;

-- 이 코드는 신과 나만 읽을 수 있게 만들었습니다
-- 만약 편집을 기꺼히 원한다면... 그렇게 하도록 하세요
-- 다만 여기의 이 규칙을 따라주세요
-- theHourOfAllOfSpentForEditingThis = 2; -- TYPE: number;hour
-- 이 코드를 편집하기 위해 사용한 시간만큼 여기의
-- 변수에 값을 추가해주세요.

function this.new(props)
    local new = {};
    new.voiceChannelID = props.voiceChannelID;
    new.nowPlaying = nil;
    new.playIndex = 0;
    setmetatable(new,this);
    return new;
end

function this:apply()
    if self.nowPlaying == self[self.playIndex] then
        return;
    end
    self
end

local insert = table.insert;
--- insert new song
function this:add(thing)
    insert(self,thing);
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
            value = song.name;
        });
    end

    return {
        fields = fields;
        footer = {
             text = "제발 되라 버그 안나고 - 개발중 작성";
        };
        title = "재생 목록에 있는 곡들은 다음과 같습니다";
        color = 16040191;
    }
end


return this;