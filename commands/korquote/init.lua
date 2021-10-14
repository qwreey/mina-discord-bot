-- 한글 명언
local korquoteRequest = require "commands.korquote.request";
local korquoteEmbed = require "commands.korquote.embed";
korquoteRequest:setCRandom(cRandom):setJson(json);
korquoteEmbed:setUrlCode(urlCode);

return {
	["한글명언"] = {
		alias = {"한국어명언","한글 명언","한국어 명언","명언","korean quote","kor quote","koreanquote","korquote"};
		reply = "잠시만 기달려주세요... (확인중)";
		func = function(replyMsg,message,args,Content)
			replyMsg:update {
				embed = korquoteEmbed:embed(korquoteRequest.fetch());
				content = "한글 명언을 가져왔습니다";
			};
		end;
	};
};
