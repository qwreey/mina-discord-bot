local this = {};

local interaction = require("../interaction");
local enums = require("../../enums");
local button = enums.componentType.button;
local messageComponent = enums.interactionType.messageComponent;
function this.new(props)
    -- local func = props.func;
    -- props.func = nil;
    props.type = button;
    return props;
end

local evnetHandler = require("../evnetHandler");
evnetHandler.make("INTERACTION_CREATE",function (data, client)
    if data.type == messageComponent then -- button


        -- make acts
        client._api:interactionCallback(
            tostring(interactionId),
            tostring(interactionToken)
        );

        return true,client:emit('buttonPressed', buttonId, object);
    end
    return false;
end);

return this;
