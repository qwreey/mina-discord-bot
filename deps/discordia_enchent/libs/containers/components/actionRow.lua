---Handler for actionRow component
---@class component_actionRow
local this = {};
local enums = require("../../enums");
local actionRow = enums.componentType.actionRow;

---Create new action row containing childs components
---@return table actionRow table that containing childs components
function this.new(childs)
    return {
        type = actionRow;
        components = childs;
    };
end

return this;
