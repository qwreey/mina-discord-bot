--[[
https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&playlistId=PLRaZX25NRlZwA0Zp7aPnDKKyeNOLsBJcK&key=[YOUR_API_KEY
&pageToken=asdfasdf
nextPageToken

Items : forEach =>
  add(this.contentDetails.videoId)
]]

local base = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&playlistId=%s&key=%s";
local pageFormat = "&pageToken=%s"
local module = {};
local insert = table.insert;
local empty = string.char(226,128,139);
local corohttp = corohttp;
local json = json;
local playerClass = require"class.music.playerClass";
local maxPlaylistItems = 150;
local youtubeUtils = require"class.music.utils";
local makeId = require "libs.random".makeId;
local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;

local playlist = "list=(..................................)"
---returns the playlist id of link
function module.getPID(url)
	return url:match(playlist)
end

--- return true when list is maximum
local function appendList(list,page)
	local items = page.items;
	if not items then return end
	for _,item in ipairs(items) do
		local contentDetails = item.contentDetails;
		local videoId = contentDetails and contentDetails.videoId;
		if videoId then
			insert(list,videoId);
		end
		if #list >= maxPlaylistItems then
			return true;
		end
	end
end

function module.getPlaylistWithToken(playlistId,pageToken,recurseCount)
	local header,body = corohttp.request("GET",
		base:format(playlistId,youtubeUtils.getAPIKey()) .. pageFormat:format(pageToken)
	);
	if header and header.code == 403 then
		return module.getPlaylistWithToken(playlistId,pageToken,youtubeUtils.nextAPIKey(recurseCount));
	end
	local page = json.decode(body);
	pageToken = page.nextPageToken; ---@diagnostic disable-line
	if not page then
		return;
	end
	-- if appendList(list,page) then
	-- 	return;
	-- end
	return page,pageToken
end
local getPlaylistWithToken = module.getPlaylistWithToken

--- return array of videoId of child of playlist
function module.getPlaylist(playlistId,recurseCount)
	local list = {};

	local header,body = corohttp.request("GET",base:format(playlistId,youtubeUtils.getAPIKey()));

	if header and header.code == 403 then
		return module.getPlaylist(playlistId,youtubeUtils.nextAPIKey(recurseCount))
	end

	if not body then error("Failed to get playlist") end
	local firstPage = json.decode(body);
	if not firstPage then error("Failed to read playlist") end
	appendList(list,firstPage);

	local pageToken = firstPage.nextPageToken;
	while pageToken do
		local page;
		page,pageToken = getPlaylistWithToken(playlistId,pageToken);
		if not page then break; end
		if appendList(list,page) then break; end
	end

	return list;
end

---make download progress display
local seekbar = playerClass.seekbar;
local playlistDisplay = "%s\n"
					 .. "추가중인 곡 명 : %s\n"
					 .. "(%d 개중에 %d개)";
function module.display(total,index,songName,cancelButtonId)
	return {
		content = empty;
		embed = {
			title = "플레이 리스트의 음악을 추가중입니다";
			description = playlistDisplay:format(
				seekbar(index,total,true,19),
				songName,total,index
			);
		};
		components = {
			components.actionRow.new{
				components.button.new{
					custom_id = cancelButtonId;
					style = discordia_enchant_enums.buttonStyle.danger;
					label = "취소";
					emoji = components.emoji.new"✖";
				};
			};
		};
	};
end

function module.getCancelId(memberId)
	return ("music_canceladd_%s_%s"):format(memberId,makeId());
end

local canceled = {};
module.canceled = canceled;

local notOwner = {
	content = zwsp;
	embed = {
		title = ":x: 추가를 요청한 사람만 취소할 수 있습니다";
		color = embedColors.error;
	};
}

local canceledMessage = {
	content = zwsp;
	embed = {
		title = ":clock2: 취소중 . . .";
		color = embedColors.info;
	};
	components = {
		components.actionRow.new{
			components.button.new{
				custom_id = "disabled";
				style = discordia_enchant_enums.buttonStyle.danger;
				disabled = true;
				label = "취소";
				emoji = components.emoji.new"✖";
			};
		};
	};
};

---@param object interaction
local function cancelAction(id,object)
	local all,ownerId = id:match("(music_canceladd_(%d+)_.+)");
	if ownerId then
		local member = object.member;
		local message = object.message;
		if (not member) or (not message) then
			return;
		elseif tostring(member.id) ~= ownerId then ---@diagnostic disable-line
			object:reply(notOwner,true);
			return;
		end
		canceled[all] = true;
		object:update(canceledMessage);
	end
end
client:onSync("buttonPressed",promise.async(cancelAction));

return module;
