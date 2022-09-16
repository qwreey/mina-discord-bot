--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)
TODO: 나중에 더 CPU 친화적으로 방법을 바꾸자

커맨드 테이블을 핸들링함 (렘과 CPU 에 가장 적절한 방법으로 변형 후 실행/피드백까지 관여하는 모듈)


어차피 Table 은 숫자와 같은 자료형이 아니라 주소가 있는 (위치가 있는) 오브젝트이다
그렇기에 그냥 막 복 떠도 쉐도우 카피 아니면 램 안먹는다 (그냥 하나 있는것 처럼)

Index 마다 다 나눠주면 나중에 Table[Command] 치면 바로 인덱싱 가능하기에
Cpu 에 더 좋다 그래서 이렇게 나눠놓는거

이 과정을 encodeCommands 이라고 부르고 있음
]]

local module = {};

local lower = string.lower;
local concat = table.concat;
local match = string.match;
local gsub = string.gsub;
local sleep = timer.sleep;
function module.onSlash(onSlash,client,reactInfo,commandName)
	if commandHandler.slashInited then
		return onSlash(reactInfo,client);
	end
	_G.client:on("slashCommandsReady",function ()
		onSlash(reactInfo,client);
	end);
end

---Indexing commands into one table map
---@param indexTable table want to contain the commands (with name and alias)
---@param cmds table want to contain the commands (with command option)
---@param commandName string of this command
---@param reactInfo Command
---@return number
local function indexingReact(indexTable,cmds,noPrefix,commandName,reactInfo)
	local alias = reactInfo.alias;
	local aliasType = type(alias);
	local len = 1;

	reactInfo.name = commandName;
	reactInfo.id = sha1(commandName);
	indexTable[commandName] = reactInfo;

	if aliasType == "table" then
		for _,Name in pairs(alias) do
			indexTable[Name:lower()] = reactInfo;
			len = len + 1;
		end
	elseif aliasType == "string" then
		indexTable[alias:lower()] = reactInfo;
		len = len + 1;
	end

	local command = reactInfo.command;
	local commandType = type(command);
	if commandType == "table" then
		for _,index in ipairs(command) do
			cmds[index] = reactInfo;
		end
	elseif commandType == "string" then
		cmds[command] = reactInfo;
	end
	if reactInfo.noPrefix then
		noPrefix[commandName] = reactInfo;
	end

	reactInfo.alias = nil;
	reactInfo.command = nil;

	local onSlash = reactInfo.onSlash;
	if onSlash then
		reactInfo.onSlash = nil;
		module.onSlash(onSlash,client,reactInfo,commandName);
	end

	local init = reactInfo.init;
	if init then
		init(reactInfo);
	end

	return len;
end

---encoding commands into one table
---@return table reactionMap mapped reactions
---@return table commandMap mapped commands
---@return table noPrefix mapped no prefixed commands
---@return number len len of reactions (map length)
function module.encodeCommands(...)
	local this,cmds,noPrefix = {},{},{};
	local len = 0;

	for _,commandPackage in pairs({...}) do
		if type(commandPackage) ~= "table" then
			logger.errorf(("Error occurred while indexing commands from '%s'"):format(
				tostring(commandPackage)
			));
			logger.error(" |- commandPackage must be table!");
		end
		for commandName,commandInfo in pairs(commandPackage) do
			if type(commandInfo) == "table" then
				local pass,result = pcall(indexingReact,this,cmds,noPrefix,commandName,commandInfo);
				if pass then
					len = len + result;
				else
					logger.error(result);
					logger.error("Error occurred on loading command");
					logger.error(commandInfo);
				end
			end
		end
	end

	return this,cmds,noPrefix,len;
end

-- indexing command/reaction from command/reaction map
local function findReaction(reacts,text,reactsType)
	if (reactsType or type(reacts)) == "function" then
		return reacts(text);
	end
	return reacts[text];
end

---find command from reacts array/function object
---@param reacts function | table
---@param text string
---@return table | nil CommandObject Command or nil
---@return string | nil CommandName Name of command
---@return string | nil CommandRawName full of user inputed string
function module.findCommandFrom(reacts,text,splitCommandText)
	if type(text) == "table" then
		splitCommandText = text;
	else
		splitCommandText = strSplit(lower(text),"\32\n\t");
	end

	-- rawText = "find thing like this"
	-- indexing( "find thing like this" )
	-- indexing( "find thing like" )
	-- indexing( "find thing" )
	-- indexing( "find" )
	local reactsType = type(reacts);
	local maintext = text;
	while true do
		local subtext = maintext;
		while true do
			local command = findReaction(reacts,subtext,reactsType);
			command = command or findReaction(reacts,gsub(subtext," ",""),reactsType);
			if command then
				return command,subtext,maintext;
			end
			subtext = match(subtext,"(.+) +");
			if not subtext then break; end
		end
		maintext = match(maintext,"^.- +(.+)");
		if not maintext then break; end
		sleep(1);
	end

	-- do
	-- 	local spText,textn = "",""; -- 띄어쓰기가 포함되도록 검색 / 띄어쓰기 없이 검색
	-- 	local lenSplit = #splitCommandText;
	-- 	for index = lenSplit,1,-1 do
	-- 		local thisText = splitCommandText[index];
	-- 		spText = spText .. (index == lenSplit and "" or " ") .. thisText;
	-- 		textn = textn .. thisText;
	-- 		local spTempCommand = findCommand(reacts,spText);
	-- 		if spTempCommand then
	-- 			return spTempCommand,spText,spText;
	-- 		end
	-- 		local tempCommand = findCommand(reacts,spText);
	-- 		if tempCommand then
	-- 			return tempCommand,textn,textn;
	-- 		end
	-- 	end
	-- end

	-- rawText = "find thing like this"
	-- indexing( "find" )
	-- indexing( "thing" )
	-- indexing( "like" )
	-- indexing( "this" )
	for findPos,textn in ipairs(splitCommandText) do
		sleep(1);
		local command = findReaction(reacts,textn,reactsType);
		if command then
			return command,textn,concat(splitCommandText," ",1,findPos);
		end
	end
end

--[[
	UserName : 유저 이름으로 바뀜
	T+시간형식 : 해당 시간 형식으로 바뀜
		%a	abbreviated weekday name (e.g., Wed)
		%A	full weekday name (e.g., Wednesday)
		%b	abbreviated month name (e.g., Sep)
		%B	full month name (e.g., September)
		%c	date and time (e.g., 09/16/98 23:48:10)
		%d	day of the month (16) [01-31]
		%H	hour, using a 24-hour clock (23) [00-23]
		%I	hour, using a 12-hour clock (11) [01-12]
		%M	minute (48) [00-59]
		%m	month (09) [01-12]
		%p	either "am" or "pm" (pm)
		%S	second (10) [00-61]
		%w	weekday (3) [0-6 = Sunday-Saturday]
		%x	date (e.g., 09/16/98)
		%X	time (e.g., 23:48:10)
		%Y	full year (1998)
		%y	two-digit year (98) [00-99]
		%%	the character `%´
	U+유니코드 : 해당 유니코드 글자로 바뀜
]]

local unitSec = 1;
local unitMin = 60;
local unitHour = unitMin * 60;
local unitDay = unitHour * 24;
local units = {
	s = unitSec;
	m = unitMin;
	h = unitHour;
	d = unitDay;
};
local signs = {
	["+"] = 1;
	["-"] = -1;
};
local date = os.date;
local function formatReplyText(Text,Data)
	Text = Text or "";
	Text = string.gsub(Text,"{#:UserName:#}",Data.user.name);
	Text = string.gsub(Text,"{#:U%+(%x%x%x%x):#}",function (hex)
		local pass,text = pcall(function ()
			return utf8.char(tonumber(hex,16));
		end);
		return pass and text or "?";
	end);
	local now;
	Text = string.gsub(Text,"{#:T%+(.-):#}",function (format)
		now = now or posixTime.now();
		local offset = 0;
		format = format:gsub("%(o:([smhd])([%-%+])(%d+)%)",function (unit,sign,num)
			offset = offset + (tonumber(num) * units[unit] * signs[sign]);
			return "";
		end);
		return date(format,now + offset);
	end);
	return Text;
end
function module.formatReply(RawContent,Data)
	if type(RawContent) == "table" then
		RawContent.content = formatReplyText(RawContent.content,Data);
		if type(RawContent.embed) == "string" then
			RawContent.embed = formatReplyText(RawContent.embed,Data);
		end
		return RawContent;
	elseif type(RawContent) == "string" then
		return formatReplyText(RawContent,Data);
	end
end

return module;