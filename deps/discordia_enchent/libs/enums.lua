local enum = require('discordia').enums.enum ---@diagnostic disable-line

---@class enchent_enums
---@field public type enchent_enums_componentType
---@field public buttonStyle enchent_enums_buttonStyle
local export = {
    optionType = enum({
		subCommand = 1,
		subCommandGroup = 2,
		string = 3,
		integer = 4,
		boolean = 5,
		user = 6,
		channel = 7,
		role = 8
	}),
	applicationCommandPermissionType = enum({
		role = 1,
		user = 2,
	}),
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
        deferredUpdateMessage = 6;
        updateMessage = 7;
        applicationCommandAutocompleteResult = 8;
    });

    ---@class enchent_enums_componentType_child:number
    ---@class enchent_enums_componentType
    ---@field public actionRow enchent_enums_componentType_child 1
    ---@field public button enchent_enums_componentType_child 2
    ---@field public selectMenu enchent_enums_componentType_child 3
	componentType = enum({
        actionRow = 1;
        button = 2;
        selectMenu = 3;
    });

    ---@class enchent_enums_buttonStyle_child:number
    ---@class enchent_enums_buttonStyle
    ---@field public primary enchent_enums_buttonStyle_child blurple color. requires custom_id field
    ---@field public secondary enchent_enums_buttonStyle_child grey color. requires custom_id field
    ---@field public success enchent_enums_buttonStyle_child green color. requires custom_id field
    ---@field public danger enchent_enums_buttonStyle_child red color. requires custom_id field
    ---@field public link enchent_enums_buttonStyle_child grey color. requires url field
    buttonStyle = enum({
        primary = 1;
        secondary = 2;
        success = 3;
        danger = 4;
        link = 5;
    });
};

return export;

