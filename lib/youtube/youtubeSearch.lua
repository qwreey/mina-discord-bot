--[[

작성 : qwreey
2021y 04m 08d
3:30 (PM)

유튜브 검색하기 API to LUA

]]

local module = {};
local corohttp;
local urlCode = require "src/lib/urlCode";
local json;
local searchURLTemp = "https://www.googleapis.com/youtube/v3/search?key=%s&part=snippet&maxResults=8&q=%s";

function module:setCoroHttp(NewCorohttp)
    corohttp = NewCorohttp;
    return self;
end
function module:setJson(NewJson)
    json = NewJson;
    return self;
end

function module.searchFromYoutube(Keyword,ClientData)
    local KeywordURL = urlCode.urlEncode(Keyword);
    local Header,Body = corohttp.request("GET",
        searchURLTemp:format(ClientData.GoogleAPIKey,KeywordURL)
    );
    return json.decode(Body),KeywordURL;
end

return module;