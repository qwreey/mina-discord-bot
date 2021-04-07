--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

커맨드 테이블을 핸들링함 (렘과 CPU 에 가장 적절한 방법으로 변형 후 실행/피드백까지 관여하는 모듈)

TODO: 나중에 더 CPU 친화적으로 방법을 바꾸자

- 미레의 내가 읽을 글 -
어차피 Table 은 숫자와 같은 자료형이 아니라 주소가 있는 (위치가 있는) 오브젝트이다
그렇기에 그냥 막 복 떠도 쉐도우 카피 아니면 램 안먹는다 (그냥 하나 있는것 처럼)

Index 마다 다 나눠주면 나중에 Table[Command] 치면 바로 인덱싱 가능하기에
Cpu 에 더 좋다 그래서 이렇게 나눠놓는거

이 과정을 encodeCommands 이라고 부르고 있음
]]

local module = {};

function module.encodeCommands(TableOfCommand)
    local this = {};
    for Index,CommandInfo in pairs(TableOfCommand) do
        local alias = CommandInfo.alias;

        this[Index] = CommandInfo;
        if type(alias) == "table" then
            for _,Name in pairs(alias) do
                this[Name] = CommandInfo;
            end
        elseif type(alias) == "string" then
            this[alias] = CommandInfo;
        end
    end

    return this;
end

function module.findCommandFrom(encodedTable,commandName)
    return encodedTable[commandName];
end

function module.formatReply(Text,Data)
    local Text = Text or "";

    Text = string.gsub(Text,"{%:UserName:%}",Data.User.name);

    return Text;
end

return module;