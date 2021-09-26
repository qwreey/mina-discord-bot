-- client.voice:loadOpus('libopus-x86');
-- client.voice:loadSodium('libsodium-x86');

-- local spawn = require('coro-spawn');
-- local split = require('coro-split');
-- local parse = require('url').parse;
-- local http = require('http');

-- local connection;
-- local msg = '';
-- local channel;
-- local playingURL = '';
-- local playingTrack = 0;

local playerForChannels = {};
local playerClass = require "commands.music.playerClass";

return {
    ["add music"] = {
        alias = {"음악추가","음악 추가","음악 add","music add","music 추가","음악 재생","음악재생"};
        reply = "처리중입니다";
        func = function(replyMsg,message,args,Content)
            -- check users voice channel
            local voiceChannel = message.member.voiceChannel;
            if not voiceChannel then
                replyMsg:setContent("음성 채팅방에 있지 않습니다! 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.");
                return;
            end

            -- get already exist connection
            local guildConnection = message.guild.connection;
            if guildConnection and (guildConnection.channel ~= voiceChannel) then
                replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 각 서버당 한 채널만 이용할 수 있습니다.");
                return;
            end

            -- get player object from playerClass
            local voiceChannelID = voiceChannel:__hash();
            local player = playerForChannels[voiceChannelID];
            if not guildConnection then
                player = playerClass.new {
                    voiceChannel = voiceChannel;
                    voiceChannelID = voiceChannelID;
                    handler = voiceChannel:join();
                };
            end
            playerForChannels[voiceChannelID] = player;
            player:add({
                url = Content.rawArgs;
            });
        end;
    };
};
