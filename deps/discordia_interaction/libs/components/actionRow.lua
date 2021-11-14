local this = {};
local enums = require("../../enums");
local actionRow = enums.type.actionRow;

function this.new(childs)
    return {
        type = actionRow;
        components = childs;
    };
end

return this;
