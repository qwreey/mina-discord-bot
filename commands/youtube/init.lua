-- 유튜브 검색
local youtubeEmbed = require "commands.youtube.embed";
local youtubeSearch = require "commands.youtube.request"; -- 유튜브 검색
youtubeSearch:setCoroHttp(corohttp):setJson(json):setUrlCode(urlCode); -- 유튜브 검색 셋업
youtubeEmbed:setMyXML(myXMl);

return {
	["유튜브"] = {
		alias = {"유튜브검색","유튜브찾기","유튜브탐색","유튭찾기","유튭","유튭검색","유튜브 검색","유튜브 찾기","youtube 찾기","youtube","youtube search","유튜브에서 찾기","search from youtube"};
		reply = "잠시만 기다려주세요... (검색중)";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
			if rawArgs == "" then
				replyMsg:setContent(("검색하려는 키워드가 없습니다!\n\n**올바른 사용 방법**\n> 미나야 유튜브 검색 <검색 할 키워드>\n검색 할 키워드 : 유튜브가 허용하는 검색 할 수 있는 문자"):format(rawArgs));
				return;
			end
			replyMsg:update {
				embed = youtubeEmbed:embed(
					rawArgs,
					youtubeSearch.searchFromYoutube(rawArgs,ACCOUNTData)
				);
				content = ("유튜브에서 '%s' 를 검색한 결과입니다"):format(rawArgs);
			};
		end;
	};
};
