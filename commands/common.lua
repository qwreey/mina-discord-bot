local uv = uv or require("uv");
local time = uv.hrtime;
local offset = (10^6);
return {
    ["핑"] = {
        alias = {"ping","지연시간","응답시간"};
        reply = function (msg)
            local send = time();
            local new = msg:reply("🏓 봇 지연시간\n전송중 . . .");
            local ping = tostring((time()-send)/offset);
            local before = time();
            timeout(0,function ()
                local clock = tostring((time()-before)/offset);
                new:setContent(("🏓 봇 지연시간\n> 서버 응답시간 : %s`ms`\n> 내부 클럭 속도 : %s`ms`"):format(ping,clock));
            end);
        end;
    };
    ["버전"] = {
        alias = "version";
        reply = ("미나의 현재버전은 `%s` 이에요 (From last git commit time)"):format(app.version);
        love = defaultLove;
    };
};
