local discordia = require("discordia");
local client = discordia.Client;
local discordiaEvents = client._events;
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
require("containers/appliactionCommand"); -- inject appliactionCommand into client

local export = {
    ---@type enchent_enums
    enums = require("enums");
    ---@type Interaction
    interaction = require("interaction");
    components = {
        ---@type component_actionRow
        actionRow = require("components/actionRow");
        ---@type component_button
        button = require("components/button");
    };
};

eventHandler.mount(discordiaEvents);
return export;
