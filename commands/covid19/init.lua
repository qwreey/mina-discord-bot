-- 코로나 현황
local covid19Request = require "commands.covid19.request";
local covid19Embed = require "commands.covid19.embed";
covid19Request:setCoroHttp(corohttp):setMyXML(myXMl);

return {
    ["코로나 현황"] = {
        alias = {"코로나 상황","코로나 확진자","코로나 통계","오늘자 코로나","코로나 정보"};
        reply = "잠시만 기달려주세요... (확인중)";
        func = function(replyMsg,message,args,Content)
            local body = covid19Request.get(ACCOUNTData)[2];
            local dat = body:getFirstChildByTag("body"):getFirstChildByTag("items");
            local today = dat[1];
            local yesterday = dat[2];
            replyMsg:setContent("오늘 기준의 코로나 현황입니다");
            replyMsg:setEmbed(covid19Embed:embed(today,yesterday))
        end;
    };
};
