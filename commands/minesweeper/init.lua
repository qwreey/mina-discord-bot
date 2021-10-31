
---@type table<string, Command>
local export = {
    ["minesweeper"] = {
        alias = {"지뢰찾기","지뢰 찾기"};
        reply = "게임을 만드는중!";
        func = function (replyMsg,message,args,Content)
            replyMsg:setContent()
        end
    };
};
return export;
