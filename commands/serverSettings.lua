

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
		short = "특수 명령어 접두사 설정";
		description = function (self,serverSettings)
			local prefix = (serverSettings and serverSettings[self.id]) or "$";
			return "일부 명령어(예: 음악)에 대한 특수한 접두사를 부여합니다. 다음과 같이 적용됩니다\n"
				   .. (prefix == "$" and musicCommandHelp or (musicCommandHelp:gsub("%$",prefix)));
		end;
		id = "guildPrefix";
		formatting = function (value)
			local valueLen = len(value);
			if valueLen > 4 then
				return false,"최대 4자리 까지만 설정 가능합니다";
			end
			return true,value;
		end;
	};
	["츤데레"] = {
		short = "딱...히 너를 위해 만든건 아냐!";
		description = "일부 미나 기능의 말투를 츤데레적으로 바꿉니다! 실험적인 기능이에요";
		id = "softyMode";
		formatting = function (value)
			if onKeywords[value] then
				return true,true;
			elseif offKeywords[value] then
				return true,nil;
			else
				return false,"'켜기' 또는 '끄기' 를 입력해주세요";
			end
		end;
		func = function (self,value,content)
			local guild = content.guild;
			if not guild then return end;
			local member = guild:getMember(client.user.id);
			member:setNickname(value and "츤데레 미나");
		end;
	};
};
local settingsHelpFormat = "> %s : `%s`\n"
local settingsHelp = "이 서버에서의 미나 기능을 설정합니다\n`설정 [이름] [값]` 으로 값을 설정합니다\n`설정 초기화 [이름]` 으로 설정 값을 초기화합니다\n모든 설정 리스트입니다\n";
for name,setting in pairs(settings) do
	settingsHelp = settingsHelp .. settingsHelpFormat:format(name,setting.short);
end
settingsHelp  = settingsHelp .. "설정에 대한 자세한 정보는 `설정 도움말 [설정이름]` 를 확인하세요";
local settingsNotFound = "설정 '%s' 는 존재하지 않습니다\n> 모든 설정을 보려면 `미나 설정` 을 입력하세요";
local settingHelpFormat = "**%s**\n%s%s";
local saved = "설정 '%s' 를 저장했습니다!";
local invalid = "설정 '%s' 의 값 '%s' 는 유효하지 않습니다\n> %s";
local resetNameMiss = "초기화할 설정 이름을 적어주세요!";
local resetFormat = "설정 '%s' 를 초기화했습니다!";
local nowFormat = "> 현재 값은 '%s' 입니다\n";
local notPermitted = "권한이 부족합니다!\n> 설정을 지정하려면 관리자 권한이 필요합니다";

local function reply(message,str)
	return message:reply({
		content = str;
		reference = {message = message, mention = false};
	});
end

---@type table<string, Command>
local export = {
	---@type Command
	["설정"] = {
		disableDm = true;
		-- onSlash = commonSlashCommand {
		-- 	name = "서버설정";
		-- 	description = "서버의 설정을 변경합니다";
		-- 	options = {
		-- 		{
		-- 			name = "작업";
		-- 			description = "투표 내용입니다! ',' 을 이용해 개별로 구분하세요!";
		-- 			type = discordia_enchant.enums.optionType.string;
		-- 			required = true;
		-- 		};
		-- 		{
		-- 			name = "제목";
		-- 			description = "투표의 제목을 설정합니다! (이 옵션은 비워둘 수 있습니다)";
		-- 			type = discordia_enchant.enums.optionType.string;
		-- 			required = false;
		-- 		};
		-- 	};
		-- };
		---@param message Message
		---@param args table
		---@param content commandContent
		reply = function(message, args, content)
			local rawArgs = content.rawArgs;
			local name = rawArgs:match("^(.-) ") or rawArgs;
			local value = rawArgs:sub(#name + 2,-1);
			-- logger.infof("Set setting '%s' to '%s'",name,value)

			-- load server data
			local data = content.loadServerData();
			local overwrite;
			if not data then
				data = {};
				overwrite = true;
			end

			-- send help message
			if name == "도움말" and value ~= "" then
				local setting = settings[value];
				if not setting then
					return reply(message,settingsNotFound:format(value));
				end
				local description = setting.description;
				local now = data[setting.id];
				return reply(message,settingHelpFormat:format(
					value,now and nowFormat:format(tostring(now):gsub("`","\\`")) or "",
					type(description) == "function" and description(setting,data) or description
				));
			elseif name == "초기화" then
				if not message.member:hasPermission(enums.permission.administrator) then ---@diagnostic disable-line
					return reply(message,notPermitted);
				end
				if value == "" then
					return reply(message,resetNameMiss);
				end
				local setting = settings[value]
				if setting == nil then
					return reply(message,settingsNotFound:format(value))
				end
				data[setting.id] = nil;
				content.saveServerData(overwrite and data);
				return reply(message,resetFormat:format(value));
			elseif name == "" or name == "도움말" then
				return reply(message,settingsHelp);
			end

			-- check setting object
			local setting = settings[name];
			if not setting then
				return reply(message,settingsNotFound:format(name));
			elseif value == "" then
				local description = setting.description;
				local now = data[setting.id] or "(미설정)";
				return reply(message,settingHelpFormat:format(
					name,now and nowFormat:format(tostring(now):gsub("`","\\`")) or "",
					type(description) == "function" and description(setting,data) or description
				));
			end

			-- set value
			if not message.member:hasPermission(enums.permission.administrator) then ---@diagnostic disable-line
				return reply(message,notPermitted);
			end
			local passed;
			passed,value = setting.formatting(value);
			if not passed then
				return reply(message,
					invalid:format(
						name,value:gsub("`","\\`"),
						tostring(value)
					)
				);
			end
			data[setting.id] = value;
			content.saveServerData(overwrite and data);

			-- execute hook
			local func = setting.func;
			if func then
				func(setting,value,content);
			end

			return reply(message,saved:format(name));
		end;
	};
};

return export
