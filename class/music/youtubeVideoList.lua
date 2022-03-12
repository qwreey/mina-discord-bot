
local module = {};

local utfLen = utf8.len;
local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;
local songFormat = "%s%d: [%s](%s)(업로더: %s)\n";
local utils = require"class.music.utils";
local formatUrl = utils.formatUrl;
local searchVideos = utils.searchVideos;
local insert = table.insert;
local buttonPrimary = discordia_enchant_enums.buttonStyle.primary;

local function formatName(str)
    -- return tostring(str):gsub("%[","\\["):gsub("%]","\\]"):gsub("%(","\\("):gsub("%)","\\)");
    return tostring(str):gsub("%]","\\]");
end

function module.display(keyworld)
    local len = utfLen(keyworld);
    if len < 3 then
        return {content = ("검색 키워드 '%s' 는 길이가 너무 짧습니다!"):format(keyworld);};
    elseif len > 50 then
        return {content = ("검색 키워드 '%s' 는 길이가 너무 깁니다!"):format(keyworld);};
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
                custom_id = ("music_search_%s"):format(videoId);
                style = buttonPrimary;
                label = tostring(index);
            }
        );
    end

    return {
        content = "추가할 곡을 골라주세요!";
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

return module;
