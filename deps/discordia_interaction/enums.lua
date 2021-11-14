local enum = require('discordia').enums.enum

return {
    interactionType = enum({
        ping = 1;
        applicationCommand = 2;
        messageComponent = 3;
        applicationCommandAutocomplete = 4;
    });
    interactionResponseType = enum({
        pong = 1;
        channelMessageWithSource = 4;
        deferredChannelMessageWithSource = 5;
    });
	componentType = enum({
        actionRow = 1;
        button = 2;
        selectMenu = 3;
    });
    buttonStyle = enum({
        primary = 1;
        secondary = 2;
        success = 3;
        danger = 4;
        link = 5;
    });
};

--ENUMS
---@class component_enums
---@field public type component_enums_componentType
---@field public buttonStyle component_enums_buttonStyle
---@class component_enums_componentType_child:number
---@class component_enums_componentType
---@field public actionRow component_enums_componentType_child 1
---@field public button component_enums_componentType_child 2
---@field public selectMenu component_enums_componentType_child 3
---@class component_enums_buttonStyle_child:number
---@class component_enums_buttonStyle
---@field public primary component_enums_buttonStyle_child blurple color. requires custom_id field
---@field public secondary component_enums_buttonStyle_child grey color. requires custom_id field
---@field public success component_enums_buttonStyle_child green color. requires custom_id field
---@field public danger component_enums_buttonStyle_child red color. requires custom_id field
---@field public link component_enums_buttonStyle_child grey color. requires url field
