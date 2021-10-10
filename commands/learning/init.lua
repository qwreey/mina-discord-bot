
local module = {};

--[[

가르치기 명령어
구현채 부분임

]]

local insert = table.insert;

return {
    ["배워"] = {
        alias = {"기억해","배워라","배워봐"};
        reply = "외우고 있어요 . . .";
        func = function(replyMsg,message,args,Content)
            local rawArgs = Content.rawArgs;

            local what,result = rawArgs:match(".+=.+");
            what = what:match(" -.- -");
            result = result:match(" -.- -");

            local userData = Content.getUserData();
            
            local learned = userData.learned;
            if not learned then
                learned = {};
                userData.learned = learned;
            end

            insert(learned,{});

            Content.saveUserData();

            -- DO SOMETHING

            replyMsg:setContent(("'%s' 는 '%s'! 다 외웠어요!"));
        end;
    };
    ["잊어"] = {
        alias = {"까먹어","잊어버려","잊어라","잊어줘"};
        reply = "에ㅔㅔㅔㅔㅔㅔㅔㅔㅔ";
        func = function(replyMsg,message,args,Content)
            local rawArgs = Content.rawArgs;
            rawArgs = rawArgs:match(" -.- -");

            -- DO SOMETHING

            replyMsg:setContent(("'%s'? 그게 뭐였죠? 기억나지가 않아요"):format(rawArgs));
        end;
    }
};