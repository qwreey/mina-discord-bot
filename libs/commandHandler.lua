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

local function indexingCommand(IndexTable,CommandName,CommandInfo)
	local alias = CommandInfo.alias;
	local len = 1;

	CommandInfo.name = CommandName;
	IndexTable[CommandName] = CommandInfo;
	if type(alias) == "table" then
		for _,Name in pairs(alias) do
			IndexTable[Name] = CommandInfo;
			len = len + 1;
		end
	elseif type(alias) == "string" then
		IndexTable[alias] = CommandInfo;
		len = len + 1;
	end

	return len;
end

function module.encodeCommands(...)
	local this = {};
	local len = 0;

	for _,commandPackage in pairs({...}) do
		for commandName,commandInfo in pairs(commandPackage) do
			len = len + indexingCommand(this,commandName,commandInfo);
		end
	end

	return this,len;
end

function module.findCommandFrom(encodedTable,commandName)
	return encodedTable[commandName];
end

local function formatRreplyText(Text,Data)
	local Text = Text or "";
	Text = string.gsub(Text,"{#:UserName:#}",Data.User.name);
	Text = string.gsub(Text,"{#:U%+(%x%x%x%x):#}",function (hex)
		local pass,text = pcall(function ()
			return utf8.char(tonumber(hex,16));
		end);
		return pass and text or "?";
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