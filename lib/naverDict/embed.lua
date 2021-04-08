--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

네이버 사전에 검색하기 API 를 통해 얻은 정보를 디스코드 임베드로 변환시키는 모듈

]]

local dictEmbed = [[{"content":"네이버 어학사전 검색 결과입니다","embed":{"title":"%s","url":"https://dict.naver.com/search.dict?dicQuery=%s","description":"%s","color":65230,"footer":{"icon_url":"https://ssl.pstatic.net/dicimg/favicons/dict/v1/home/favicon.ico","text":"Powered by naver dict / ㅋㅂㄹㅂ 개발"},"fields":[%s{"name":"구글에 검색하기","value":"*[구글로 이동합니다](https://www.google.co.kr/search?q=%s&safe=active)*","inline":true},{"name":"위키피디아에 검색하기","value":"*[위키피디아로 이동합니다](https://ko.wikipedia.org/wiki/%s)*","inline":true}]}}]];
local meanEmbed = [[{"name": "%s","value": "%s"},]];
local meanItem = "%s\\n[더보기](%s)";
local module = {};

-- 전체 임베딩
function module.toDictEmbed(Keyword,UrlCode,ItemsJson,ShortDesc)
    return dictEmbed:format(
        Keyword,UrlCode,ShortDesc,ItemsJson,UrlCode,UrlCode
    );
end

local function TitleMD(Title)
    local Title = Title;
    Title = string.gsub(Title,"|","\\|");
    Title = string.gsub(Title,"<b>(.-)</b>",function(this)
        return this;
    end);
    return Title;
end
local function DecsMD(Text)
    local Text = Text;
    Text = string.gsub(Text,"|","\\|");
    Text = string.gsub(Text,"<b>(.-)</b>",function(this)
        return ("**%s**"):format(this);
    end);
    return Text;
end

-- 의미 임베딩
function module.meanEmbed(Items)
    local this = "";
    local ShortDesc = "";
    local LastTitles = {};
    local ItemArray = Items.items;
    for Index,Item in pairs(ItemArray) do
        local Title = Item.title or "";
        if Index >= 4 then
            local Link = Item.link or "";
            local Desc = string.gsub((Item.description or ""),"\n","\\n");
            this = this .. meanEmbed:format(TitleMD(Title),meanItem:format(DecsMD(Desc),Link));
        end
        if not LastTitles[Title] then
            ShortDesc = ShortDesc .. (#ShortDesc ~= 0 and "," or "") .. Title;
        end
        LastTitles[Title] = true;
    end
    -- 하나도 안나오면
    if #ItemArray == 0 then
        ShortDesc = "<b>그딴게 어디있겠냐?</b>";
    end
    return this,DecsMD(ShortDesc);
end

function module:Embed(Keyword,UrlCode,Items)
    return self.toDictEmbed(Keyword,UrlCode,self.meanEmbed(Items));
end

return module;