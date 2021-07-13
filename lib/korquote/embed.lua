local engquoteEmbed = {};
local urlCode = require "src/lib/urlCode";

-- class : engquoteEmbed
-- embed quote with api's return
-- it returns table for discordia's embed system

-- written by qwreey all right of this code had owned by qwreey;
-- 2021 / 07 / 04

function engquoteEmbed:embed(body)
    local author = body.author
    return {
        color = 16760299;
        --footer = {
        --    text = "https://github.com/lukePeavey/quotable 의 API 를 이용한 검색 결과입니다";
        --};
        author = {
            name = author;
            url = "https://www.google.co.kr/search?q=" .. urlCode.urlEncode(author);
        };
        description = body.message;
    };
end

return engquoteEmbed;