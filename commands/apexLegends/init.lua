-- 에이펙수
local apexLegendsRequest = require "commands.apexLegends.request";
local apexLegendsEmbed = require "commands.apexLegends.embed";
apexLegendsRequest:setCoroHttp(corohttp):setJson(json):setUrlCode(urlCode);

---@type table<string, Command>
local export = {
	["에이펙스 스텟"] = {
		alias = {"apex legends 스텟","apex legends stats","apex stats","apex 스텟","에이펙스 레전드 스텟","에펙 스텟"};
		reply = "잠시만 기달려주세요... (확인중)";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
			message:delete();
			replyMsg:update {
				embed = apexLegendsEmbed:embed(apexLegendsRequest.fetch(rawArgs,ACCOUNTData));
				content = "Apex Legends Api 로 부터 가져온 결과입니다 (사용자 아이디는 개인정보 보호를 위해 제거되었습니다)";
			};
		end;
	};
};
return export;
