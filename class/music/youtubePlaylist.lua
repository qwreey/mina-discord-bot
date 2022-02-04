--[[
https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&playlistId=PLRaZX25NRlZwA0Zp7aPnDKKyeNOLsBJcK&key=[YOUR_API_KEY
&pageToken=asdfasdf
nextPageToken

Items : forEach =>
  add(this.contentDetails.videoId)
]]

local base = "https://youtube.googleapis.com/youtube/v3/playlistItems?part=contentDetails&maxResults=50&playlistId=%s&key=" .. ACCOUNTData.GoogleAPIKey;
local pageFormat = "&pageToken=%s"
local module = {};
local insert = table.insert;
local corohttp = corohttp;
local json = json;

local maxPlaylistItems = 150;

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

--- return array of videoId of child of playlist
function module.getPlaylist(playlistId)
    local list = {};

    local _,body = corohttp.request("GET",base:format(playlistId));
    if not body then error("Failed to get playlist") end
    local firstPage = json.decode(body);
    if not firstPage then error("Failed to read playlist") end
    appendList(list,firstPage);

    local pageToken = firstPage.nextPageToken;
    while pageToken do
        logger.info(pageToken);
        _,body = corohttp.request("GET",
            base:format(playlistId) .. pageFormat:format(pageToken)
        );
        local page = json.decode(body);
        pageToken = page.nextPageToken; ---@diagnostic disable-line
        if not page then
            break;
        end
        if appendList(list,page) then
            break;
        end
    end

    return list;
end

---make download progress display
local floor = math.floor;
local rep = string.rep;
local progress_block = "█";
local progress_air   = "░";
local progress_len   = 23;
local playlistDisplay = "> 플레이 리스트의 음악을 추가중입니다\n"
                     .. "> \\|%s%s\\|\n"
                     .. "> 추가중인 곡 명 : %s\n"
                     .. "> (%d 개중에 %d개)";
function module.display(total,index,songName)
    local per = index/total;
    local progress_front = floor(progress_len*per);
    local progress_back = progress_len - progress_front;

    return playlistDisplay:format(
        rep(progress_block,progress_front),
        rep(progress_air,progress_back),
        songName,total,index
    )
end

return module;
