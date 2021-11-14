local discordia = require("discordia");
local classes = discordia.class.classes;
local eventHandler = require("eventHandler");

-- enable voice fixer
require("containers/voice/FFmpegProcess")(classes.FFmpegProcess)
require("containers/voice/VoiceConnection")(
    classes.VoiceConnection,{
        FFmpegProcess = classes.FFmpegProcess;
    }
);
require("api9"); -- inject api 9
local appliactionCommand = require("containers/appliactionCommand"); -- inject appliactionCommand into client

local export = {
    ---@type enchent_enums
    enums = require("enums");
    ---@type interaction
    interaction = require("containers/interaction");
    components = {
        ---@type component_actionRow
        actionRow = require("containers/components/actionRow");
        ---@type component_button
        button = require("containers/components/button");
    };
    inject = function(client)
        eventHandler.mount(client._events);
        appliactionCommand(client);
    end;
};

return export;
