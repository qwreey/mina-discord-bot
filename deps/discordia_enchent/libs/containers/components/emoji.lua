---Handler for actionRow component
---@class component_emoji
local this = {};
local enums = require("../../enums");
local actionRow = enums.componentType.actionRow;

---@class enchent_button_props:table
---@field public id Snowflake|nil emoji id
---@field public name string|nil (can be null only in reaction emoji objects) emoji name

-- roles?	array of role object ids	roles allowed to use this emoji
-- user?	user object	user that created this emoji
-- require_colons?	boolean	whether this emoji must be wrapped in colons
-- managed?	boolean	whether this emoji is managed
-- animated?	boolean	whether this emoji is animated
-- available?	boolean	whether this emoji can be used, may be false due to loss of Server Boosts

---Create new emoji object
---@param emojiObject enchent_button_props table that containing emoji data
---@return component_emoji
function this.new(emojiObject)
    if type(emojiObject) == "string" then
        return {name = emojiObject};
    end
    return {
        id = emojiObject.id;
        name = emojiObject.name;
    };
end

return this;
