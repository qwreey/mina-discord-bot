-- 네이버 사전
local naverDictEmbed = require "commands.naverDict.embed"; -- 네이버 사전 임배드 렌더러
local naverDictSearch = require "commands.naverDict.request"; -- 네이버 사전 API 핸들러
naverDictSearch:setCoroHttp(corohttp):setJson(json):setUrlCode(urlCode); -- 네이버 사전 셋업

return {
    ["사전"] = {
        reply = "잠시만 기다려주세요... (검색중)";
        alias = {
            "dict","Dict","Dictionary","영어찾기",
            "단어검색","단어찾기","영어검색",
            "영단어검색","영단어찾기","dictionary",
            "단어찾아","영단어찾아","단어찾아줘",
            "영단어찾아줘","영단어","사전찾기",
            "사전검색","사전찾기"
        };
        func = function(replyMsg,message,args,Content)
            local searchKey = Content.rawArgs;
            if (not searchKey) or (searchKey == "") or (searchKey == " ") then
                replyMsg:setContent("잘못된 명령어 사용법이에요!\n\n**올바른 사용 방법**\n> 미나야 사전 <검색할 단어>");
            end

            local body,url = naverDictSearch.searchFromNaverDirt(Content.rawArgs,ACCOUNTData);
            print(naverDictEmbed:embed(Content.rawArgs,url,body))
            local embed = json.decode(naverDictEmbed:embed(Content.rawArgs,url,body));
            replyMsg:setEmbed(embed.embed);
            replyMsg:setContent(embed.content);
            return;
        end;
    };
};
