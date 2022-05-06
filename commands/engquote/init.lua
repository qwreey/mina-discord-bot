local typingGame = require "class.typingGame";
local engquoteRequest = require "commands.engquote.request";
local engquoteEmbed = require "commands.engquote.embed";
engquoteRequest:setCoroHttp(corohttp):setJson(json);
engquoteEmbed:setUrlCode(urlCode);

---@type table<string, Command>
local export = {
	["영어명언"] = {
		alias = {"영문명언","영문 명언","영어 명언","quote","english quote","eng quote","englishquote","engquote"};
		reply = "잠시만 기달려주세요... (확인중)";
		func = function(replyMsg,message,args,Content)
			replyMsg:update {
				embed = engquoteEmbed:embed(engquoteRequest.fetch());
				content = "영어 명언을 가져왔습니다";
			};
		end;
		onSlash = commonSlashCommand {
			description = "영어 명언을 보여줍니다!";
		};
	};
	["타자연습 영문"] = {
		alias = {
			"영문 타자연습","영문타자연습","영문타자","영문 타자",
			"영어 타자","영어타자","영어 타자연습",
			"영어타자연습","타자연습 영어","타자연습영문",
			"타자영문","타자 영문","타자 영어","타자연습영문","영문 타자"
		};
		reply = "잠시만 기달려주세요 . . .";
		embed = {description = "뒤에 보이는 문구를 재빠르게 입력하세요!"};
		func = function(replyMsg,message,args,Content)
			local this = engquoteRequest.fetch();
			typingGame.new(replyMsg,message,Content,this.content,this.author);
		end;
	};
};
return export;
