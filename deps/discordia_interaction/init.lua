local discordia = require("discordia");
local client = discordia.Client;
local discordiaEvents = client._events;

local export = {
    ---@type Interaction
    interaction = require("interaction");
    components = {
        __scan = true;
        ---@type component_actionRow
        actionRow = require("components/actionRow");
        ---@type component_button
        button = require("components/button");
    };
};

local insert = table.insert;
local remove = table.remove;
local unpack = unpack or table.unpack;
local eventItems = {};

-- scan and make evnet list and etc...
local function scan(this)
    for _,child in pairs(this) do
        if child.__scan then
            scan(child);
        end
    end
    local events = this._events;
    if events then
        for eventName,func in pairs(events) do
            local eventItem = eventItems[eventName];
            if not eventItem then
                eventItem = {};
                eventItems[eventName] = eventItem;
            end
            insert(eventItem,func);
        end
    end
end

-- executing events
for eventName,funcs in pairs(eventItems) do
    discordiaEvents[eventName] = function (self,data,client)
        for _,func in pairs(funcs) do
            local result = {func()};
            local passed = remove(result,1);
            if passed then
                return unpack(result);
            end
        end
    end
end

return export;
