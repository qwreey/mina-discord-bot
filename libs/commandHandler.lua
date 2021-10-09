--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

커맨드 테이블을 핸들링함 (렘과 CPU 에 가장 적절한 방법으로 변형 후 실행/피드백까지 관여하는 모듈)

TODO: 나중에 더 CPU 친화적으로 방법을 바꾸자

어차피 Table 은 숫자와 같은 자료형이 아니라 주소가 있는 (위치가 있는) 오브젝트이다
그렇기에 그냥 막 복 떠도 쉐도우 카피 아니면 램 안먹는다 (그냥 하나 있는것 처럼)

Index 마다 다 나눠주면 나중에 Table[Command] 치면 바로 인덱싱 가능하기에
Cpu 에 더 좋다 그래서 이렇게 나눠놓는거

이 과정을 encodeCommands 이라고 부르고 있음
]]

local module = {};

local function indexingReact(indexTable,cmds,commandName,reactInfo)
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
	local commandType = type(aliasType)
	if commandType == "table" then
		for _,index in ipairs(command) do
			cmds[index] = reactInfo;
		end
	elseif commandType == "string" then
		cmds[command] = reactInfo;
	end

	return len;
end

function module.encodeCommands(...)
	local this,cmds = {},{};
	local len = 0;

	for _,commandPackage in pairs({...}) do
		for commandName,commandInfo in pairs(commandPackage) do
			len = len + indexingReact(this,cmds,commandName,commandInfo);
		end
	end

	return this,cmds,len;
end

function module.findCommandFrom(encodedTable,commandName)
	return encodedTable[commandName];
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

local function formatRreplyText(Text,Data)
	local Text = Text or "";
	Text = string.gsub(Text,"{#:UserName:#}",Data.User.name);
	Text = string.gsub(Text,"{#:U%+(%x%x%x%x):#}",function (hex)
		local pass,text = pcall(function ()
			return utf8.char(tonumber(hex,16));
		end);
		return pass and text or "?";
	end);
	Text = string.gsub(Text,"{#:T%+(.-):#}",function (format)
		return os.date(format);
	end);
	return Text;
end
function module.formatReply(RawContent,Data)
	if type(RawContent) == "table" then
		RawContent.content = formatRreplyText(RawContent.content,Data);
		if type(RawContent.embed) == "string" then
			RawContent.embed = formatRreplyText(RawContent.embed,Data);
		end
		return RawContent;
	elseif type(RawContent) == "string" then
		return formatRreplyText(RawContent,Data);
	end
end

return module;