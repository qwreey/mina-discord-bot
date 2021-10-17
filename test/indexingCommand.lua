---@diagnostic disable
function findCommand(...)
    p(...);
end

local text = "!@#!@$#$% QWESDASD 123124 asdfsdfasdf"
do
    local this = text;
    while true do
        local command = findCommand(reacts,this);
        if command then
            return command;
        end
        this = this:match("(.+) ");
        if not this then
            break;
        end
    end
end