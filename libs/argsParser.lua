local strSub = string.sub;
local tableInsert = table.insert;
local module = {};

function module.decode(split,optionArgs)
    optionArgs = optionArgs or {};
    local option = {};
    local args = {};

    local lastOpt;

    for i,this in ipairs(split) do
        if i >= 1 then
            if strSub(this,1,1) == "-" then -- this = option
                option[this] = true;
                if optionArgs[this] then
                    lastOpt = this;
                else lastOpt = nil;
                end
            elseif lastOpt then -- set option
                option[lastOpt] = this;
                lastOpt = nil;
            else
                tableInsert(args,this);
            end
        end
    end

    return args,option;
end

return module;
