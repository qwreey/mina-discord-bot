-- 영문 명언

local engquoteRequest = require "commands.engquote.request";
local engquoteEmbed = require "commands.engquote.embed";
engquoteRequest:setCoroHttp(corohttp):setJson(json);
engquoteEmbed:setUrlCode(urlCode);

return {
	["영어명언"] = {
		alias = {"영문명언","영문 명언","영어 명언","quote","english quote","eng quote","englishquote","engquote"};
		reply = "잠시만 기달려주세요... (확인중)";
		func = function(replyMsg,message,args,Content)
			replyMsg:setEmbed(engquoteEmbed:embed(engquoteRequest.fetch()));
			replyMsg:setContent("영어 명언을 가져왔습니다");
		end;
	};
};
