-- array = {
--	 "https://cdn2.thecatapi.com/images/e4g.gif";


-- }
-- 렌덤 동물

local request = require "commands.randomAnimal.request";
request:setCoroHttp(corohttp):setJson(json);

return {
	["동물"] = {
		alias = {"동물사진","동물 사진","동물 가져오기","동물 사진 가져오기","렌덤 동물","렌덤동물","동물사진가져오기","동물가져오기"};
		reply = "잠시만 기달려주세요... (불러오는중)";
		func = function(replyMsg,message,args,Content)
			replyMsg:setContent(request.fetch(Content.rawArgs) or "예기치 못한 오류가 발생하였습니다\n`(commands.randomAnimal.request.fetch() -> nil)`");
		end;
	};
};
