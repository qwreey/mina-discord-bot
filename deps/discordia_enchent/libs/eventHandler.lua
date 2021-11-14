local events = {};
local insert = table.insert;
local remove = table.remove;

local this = {};

function this.make(name,func)
    local funcs = events[name];
    if not funcs then
        funcs = {};
        events[name] = funcs;
    end
    insert(funcs,func);
end;

function this.mount(discordiaEvents)
    for name,funcs in pairs(events) do
        discordiaEvents[name] = function (data,client)
            for _,func in pairs(funcs) do
                local result = {func(data,client)};
                local passed = remove(result,1);
                if passed then
                    return result;
                end
            end
        end;
    end
end;

return this;
