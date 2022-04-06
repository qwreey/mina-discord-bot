local typingGame = require "class.typingGame";
local gameForUsers = typingGame.gameForUsers;

---@type table<string, Command>
local export = {
	["타자연습 그만"] = {
		alias = {"타자그만","타자연습 그만","타자연습그만","타자연습멈춰","멈춰 타자연습","멈춰타자연습","타자연습 멈춰","그만타자연습","그만 타자연습","끄기 타자연습","타자연습 끄기"};
		reply = "잠기만 기달려주세요 . . .";
		func = function(replyMsg,message,args,Content)
			local userId = Content.user.id;
			local game = gameForUsers[userId];
			if game then
				game:detach();
				gameForUsers[userId] = nil;
				replyMsg:setContent("타자 연습을 멈췄습니다!");
			else
				replyMsg:setContent("진행중인 타자연습이 없습니다!");
			end
		end;
	};
	["타자연습"] = {
		alias = "타자";
		help = "이용 가능한 타자 연습 게임은 '영문','한글' 입니다\n> 또는 이 명령어 뒤에 원하는 글을 직접 입력할 수도 있어요";
		waitting = {
			content = "잠시만 기달려주세요 . . .";
			embed = {description = "뒤에 보이는 문구를 재빠르게 입력하세요!"};
		};
		reply = function (message,args,Content,self)
			local rawArgs = Content.rawArgs:gsub("^[\n \t]+",""):gsub("[\n \t]+$","");
			if rawArgs == "" then
				return self.help;
			end
			typingGame.new(message:reply(self.waitting),message,Content,rawArgs,"사용자 지정");
		end;
	};
}
return export;
