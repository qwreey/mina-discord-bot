---@class component_button
local this = {};

local allBindings = {};
local interaction = require("../interaction");
local enums = require("../../enums");
local button = enums.componentType.button;
local messageComponent = enums.interactionType.messageComponent;

---@class enchent_button_props:table
---@field public custom_id string a developer-defined identifier for the component, max 100 characters
---@field public disabled boolean whether the component is disabled, default false
---@field public style enchent_enums_buttonStyle_child one of button styles
---@field public url string a url for link-style buttons
---@field public emoji Emoji name, id, and animated
---@field public label string text that appears on the button, max 80 characters
---@field public func function Making response

---Create new button object
---@param props enchent_button_props struct of button object
---@return table
function this.new(props)
    props.type = button;

    local func = props.func;
    if func then
        allBindings[props.custom_id] = func;
        props.func = nil;
    end
    return props;
end

local function runBindings(id,interaction)
    local binding = allBindings[id];
    if binding then
        binding(interaction);
    end
end
local warp = coroutine.wrap;

local evnetHandler = require("../../eventHandler");
evnetHandler.make("INTERACTION_CREATE",function (data, client)
    if data.type == messageComponent then -- button
        local new = interaction(data,client);
        local buttonId = new.buttonId;
        warp(runBindings)(buttonId,new);
        return true,client:emit('buttonPressed',buttonId,new);
    end
    return false;
end);

return this;
