
local module = {};

local utfLen = utf8.len;
local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;
local songFormat = "%s%d: [%s](%s)(업로더: %s)\n";
local utils = require"class.music.utils";
local searchVideos = utils.searchVideos;
local insert = table.insert;
local buttonPrimary = discordia_enchant_enums.buttonStyle.primary;
local playerClass = require"class.music.playerClass";
local playerForChannels = playerClass.playerForChannels;
local time = os.time;
local formatUrl = utils.formatUrl;
local empty = string.char(226,128,139);

local function formatName(str)
	-- return tostring(str):gsub("%[","\\["):gsub("%]","\\]"):gsub("%(","\\("):gsub("%)","\\)");
	return tostring(str):gsub("%]","\\]");
end

function module.display(keyworld,userId)
	userId = userId or "NULL";
	local len = utfLen(keyworld);
	if len < 2 then
		return {
			content = empty;
			embed = {
				title = ":x: 이런:<";
				description = ("검색 키워드 '%s' 는 길이가 너무 짧습니다!"):format(keyworld);
			};
		};
	elseif len > 50 then
		return {
			content = empty;
			embed = {
				title = ":x: 이런:<";
				description = ("검색 키워드 '%s' 는 길이가 너무 깁니다!"):format(keyworld);
			};
		};
	end

	local buttonsPart1,buttonsPart2,songs = {},{},"";
	local list = searchVideos(keyworld,10,true);
	for index,item in ipairs(list) do
		local videoId = item.videoId;
		songs = songFormat:format(songs,index,formatName(item.title),formatUrl(videoId),tostring(item.channelTitle));
		insert(index <= 5
			and buttonsPart1
			or buttonsPart2,
			components.button.new {
				custom_id = ("music_search_%s;%s"):format(videoId,userId);
				style = buttonPrimary;
				label = tostring(index);
			}
		);
	end

	return {
		content = ":mag: 추가할 곡을 골라주세요!";
		embed = {
			description = songs;
			color = 14799100;
			author = { name = keyworld; };
			footer = {
				icon_url = "https://lh3.googleusercontent.com/e6M5VtG7zcegiVOCtZkWEt1RB8sRo5N2iBBDyq0X8N2KofUDwPWl-Lz1LbHgVH8ZfY2XSrkKBl0ak8PBoOYC=w80-h80";
				text = "유튜브 검색 결과입니다";
			};
		};
		components = {
			#buttonsPart1 ~= 0 and components.actionRow.new(buttonsPart1) or nil;
			#buttonsPart2 ~= 0 and components.actionRow.new(buttonsPart2) or nil;
		};
	};
end

---@param id string
---@param object interaction
local function buttonPressed(id,object)
	local videoId,userId = id:match("music_search_(.-);(.+)");
	if not videoId then
		return;
	end
	logger.infof("music add button pressed (video:%s, user: %s)",videoId,userId);

	local member = object.member;
	if not member then return; end
	if (userId ~= "NULL") and (member:__hash() ~= userId) then
		return object:reply({
			content = "이 명령어를 사용한 사람만 상호작용을 이용할 수 있어요!";
		},true);
	end

	local nickname = member and member.nickname;
	local authorName = member.user.name:gsub("`","\\`");
	local username = nickname and (nickname:gsub("`","\\`") .. (" (%s)"):format(authorName)) or authorName;
	local voiceChannel = member.voiceChannel;
	if not voiceChannel then
		return object:reply({
			content = "음성 채팅방에 있지 않아요!\n> 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.";
		},true);
	end

	local guild = object.guild;
	if not guild then return; end
	local guildConnection = guild.connection;
	if guildConnection and (guildConnection.channel ~= voiceChannel) then
		return object:reply({
			content = "다른 음성채팅방에서 봇을 사용중이에요!\n> 각 서버당 한 채널만 이용할 수 있습니다!";
		},true);
	end

	local voiceChannelID = voiceChannel:__hash();
	local player = playerForChannels[voiceChannelID]; ---@type playerClass
	if not guildConnection then -- if connections is not exist, create new one
		local handler,err = voiceChannel:join();
		if not handler then
			return object:reply({
				content = ("채널에 참가할 수 없습니다, 봇이 유효한 권한을 가지고 있는지 확인해주세요!\n```\n%s\n```"):format(err);
			},true);
		end
		guild.me:deafen(); -- deafen it selfs
		player = playerClass.new {
			voiceChannel = voiceChannel;
			voiceChannelID = voiceChannelID;
			handler = handler;
		};
	end

	if not player then
		return object:reply({content = "오류가 발생했습니다. (player not cached)"},true);
	end

	object:update{
		content = "로딩중 ⏳";
		embeds = {};
		components = {};
	};

	local song = {
		message = object.message;
		url = videoId;
		whenAdded = time();
		username = username;
	};
	local passed,err = pcall(player.add,player,song);
	local info = song.info;

	if (not passed) and err and err ~= "" then
		object.channel:send{content = empty; embed = {
			title = ":x: 오류가 발생했어요!";
			description = err:match(": (.+)") or err;
		}};
		return;
	end

	object.channel:send{
		content = empty;
		embed = {
			title = (":musical_note: 곡 '%s' 을(를) 추가했어요! `(%s)`"):format(info and info.title or "NULL")
		};
	};
	promise.spawn(object.delete,object);
end
module.buttonPressed = buttonPressed;
client:on("buttonPressed",buttonPressed);

return module;
