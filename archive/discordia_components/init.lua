---@diagnostic disable
---@type discordia_components
local this = {
    enums = require("./enums");
    actionRow = require("./actionRow");
    button = require("./button");
};

local discordia = require("discordia");
local client = discordia.Client;
function client:useComponents()
    require("./api");
    local objects = {
        client = self;
        discordia = discordia;
    };
    for _,module in pairs(this) do
        if type(module) == "table" then
            local __init = module.__init;
            if __init then
                __init(module,objects);
            end
        end
    end
end

return this;
