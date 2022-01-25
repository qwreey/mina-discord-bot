

---@class settingsObject
---@field public type string Type of this setting
---@field public short string Short description of this setting
---@field public description string|function Full description of this setting, if this field is set to function, it will called with self and server settings table
---@field public id string Unique identifier of this setting
---@field public formatting function|nil Function to format this setting

local musicCommandHelp =
[[```
$ 는 설정한 접두사입니다
재생     : $p/추가/재생 (곡 이름 또는 url 또는 플레이리스트 url)
리스트   : $q/리스트/목록/큐/플리 (페이지수)
스킵     : $s/스킵/넘겨/건너뛰기 (스킵할 곡 수)
지우기   : $r/지워/제거/빼기 (제거할 제목 일부 또는 번호)
현재재생 : $n/현재/지금곡
시간조정 : $seek/시간/위치 (앞으로=+1:10 뒤로=-1:10 위치=1:10)
루프모드 : $lp/루프
멈춤     : $pause/멈춰
재개     : $resume/재개
곡 정보  : $i/정보 (곡 번호)
끄기     : $off/stop/그만
참가     : $j/참여/참가
24시간   : $24
```]];

local len = utf8.len;
---@type table<string, settingsObject>
local settings = {
    ["접두사"] = {
        type = "string";
        short = "특수 명령어 접두사 설정";
        description = function (self,serverSettings)
            local prefix = (serverSettings and serverSettings[self.id]) or "$";
            return "일부 명령어(예: 음악)에 대한 특수한 접두사를 부여합니다. 다음과 같이 적용됩니다\n"
                   .. (prefix == "$" and musicCommandHelp or (musicCommandHelp:gsub("$",prefix)));
        end;
        id = "guildPrefix";
        formatting = function (value)
            local valueLen = len(value);
            if valueLen == 0 then
                return false,"값을 입력해주세요";
            elseif valueLen > 4 then
                return false,"최대 4자리 까지만 설정 가능합니다";
            end
            return true,value;
        end;
    };
};

---@type table<string, Command>
local export = {
    ["설정"] = {};
};

return export
