--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

네이버 사전 검색 봇
https://discord.com/oauth2/authorize?client_id=828894481289969665&permissions=2147871808&scope=bot

]]

--#region : Discord Module
print("Wait for discordia")
local json = require "json";
local corohttp = require "coro-http";
local discordia = require "discordia";
local enums = discordia.enums;
local client = discordia.Client({
	routeDelay = 0;
	maxRetries = 3;
});
local function StartBot(botToken)
	client:run(("Bot %s"):format(botToken));
	print(("Bot : started as %s"):format(botToken));
	return;
end
--#endregion : Discord Module
--#region : 나눠진거 합치기
local dictEmbed = require "src/lib/dictEmbed";
local naverDict = require "src/lib/naverDict";
local urlCode   = require "src/lib/urlCode";
naverDict:setCoroHttp(corohttp):setJson(json);
--#endregion : 나눠진거 합치기
--#region : load settings from data file
local json = require("json");
local LoadData = function (Pos)
	local File = io.open(Pos,"r+");
	local Raw = File:read("a");
	File:close();
	return json.decode(Raw);
end
local SaveData = function (Pos,Data)
	local File = io.open(Pos,"r+");
	File:write(json.encoding(Data));
	File:close();
	return;
end

local ACCOUNTData = LoadData("data/ACCOUNT.json");
local History = LoadData("data/history.json");
local dirtChannels = LoadData("data/dirtChannels.json");
--#endregion : load settings from data file

local dirtChannels = dirtChannels.channels;
client:on('messageCreate', function(message)
	local User = message.author;
	local Text = message.content;
	local channel = message.channel;
	if User.bot or (channel.type ~= enums.channelType.text) then
		return;
	end
	if dirtChannels[message.channel.id] then
		if string.sub(Text,1,1) ~= "!" then
			return;
		end
		Text = string.sub(Text,2,-1);
		local newMsg = message:reply('> 찾는중 . . .');
		local body,url = naverDict.searchFromNaverDirt(Text,ACCOUNTData);
		local embed = json.decode(dictEmbed:Embed(Text,url,body));
		newMsg:setEmbed(embed.embed);
		newMsg:setContent(embed.content);
	end
end);

-- Start bot
StartBot(ACCOUNTData.botToken);