local youtubeEmbed = {};

-- class : youtubeEmbed
-- embed youtube search with youtube api's returns
-- it returns table for discordia's embed system

-- written by qwreey all right of this code had owned by qwreey;
-- 2021 / 07 / 04

local myXML;
function youtubeEmbed:setMyXML(nMyXML)
    myXML = nMyXML;
    return self;
end

function youtubeEmbed:embed(searchKeyword,body,queryStr)
    local fields = {};

    for index,thing in pairs(body.items) do
        local this = {};
        local id = thing.id;
        local snippet = thing.snippet;
        local kind = id.kind;

        local nameHeader;
        nameHeader = kind == "youtube#channel" and "채널";
        nameHeader = nameHeader or (kind == "youtube#video" and "영상");
        nameHeader = nameHeader or "알수없음";

        local url;
        url = kind == "youtube#channel" and (("https://www.youtube.com/channel/%s"):format(id.channelId));
        url = url or (kind == "youtube#video" and (("https://www.youtube.com/watch?v=%s"):format(id.videoId)));

        this.name = ("%s / %s"):format(nameHeader,myXML.toLuaStr(snippet.title));
        this.inline = true;
        this.value = ("[해당 %s으로 이동하기](%s)\n"):format(nameHeader,url) .. myXML.toLuaStr(tostring(snippet.description));

        table.insert(fields,this);

        if index >= 6 then
            break;
        end
    end

    return {
        title = ("'%s' 에 대한 검색 결과"):format(tostring(searchKeyword));
        color = 16720424;
        description = "한국 지역 유튜브에서의 검색 결과입니다";
        url = ("https://www.youtube.com/results?search_query=%s"):format(queryStr);
        footer = {
            text = "Youtube 검색 API 에 의한 결과입니다, 유튜브의 정책에 따라 검색결과가 상이해 질 수 있습니다";
        };
        author = {
            name = "Youtube";
            icon_url = "https://lh3.googleusercontent.com/e6M5VtG7zcegiVOCtZkWEt1RB8sRo5N2iBBDyq0X8N2KofUDwPWl-Lz1LbHgVH8ZfY2XSrkKBl0ak8PBoOYC=w80-h80";
        };
        fields = fields;
    };
end

return youtubeEmbed;