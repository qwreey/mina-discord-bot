local discordia = require("discordia");
local class = discordia.class;
local classes = class.classes;
local API = classes.API;
local format = string.format;
local interactionCallbackEndpoint = "/interactions/%s/%s/callback";

function API:interactionCallback(interactionId,interactionToken)
    self:request(
        "POST",interactionCallbackEndpoint:format(interactionId,interactionToken),
        {type = 6}
    );
end
