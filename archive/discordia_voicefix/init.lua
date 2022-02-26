local discordia = require("discordia");
local classes = discordia.class.classes;
require("FFmpegProcess")(classes.FFmpegProcess)
require("VoiceConnection")(
    classes.VoiceConnection,{
        FFmpegProcess = classes.FFmpegProcess;
    }
);
