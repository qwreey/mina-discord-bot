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

local help = [[
> 미나 **음악도움말**
이 메시지를 표시합니다
음악도움말 대신 다음과 같이 쓸 수도 있습니다
`'음악 도움말' '음악 help' '음악' 'music help' 'help music' 'music 도움말'`
'**음악**'에 대한 도움말입니다

> 미나 **음악추가** **[음악URL 또는 검색어]**
음악을 리스트에 추가합니다, 음성 채팅방에 있어야 사용할 수 있는 명령어입니다.
음악추가 대신 다음과 같이 쓸 수도 있습니다
`'add music' '음악 추가' '음악 add' 'music add' 'music 추가' '음악 재생' '음악재생'`

> 미나 **음악리스트**
지금 서버의 음악 리스트를 보여줍니다
`'음악 리스트' '음악리스트' 'list music' 'queue music' 'music queue' '음악 queue'`
]];

return {
	["add music"] = {
		alias = {"음악추가","음악 추가","음악 add","music add","music 추가","음악 재생","음악재생"};
		reply = "처리중입니다";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
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
			local this = {url = rawArgs};
			local passed,back = pcall(player.add,player,this);

			-- when failed to adding song into playlist
			if not passed then
				iLogger.errorf("Failed to add music '%s' on player:%s",rawArgs,voiceChannelID);
				iLogger.errorf("traceback : %s",back)
				qDebug {
					title = "music adding failed";
					arg = rawArgs;
					this = player;
					voiceChannelID = voiceChannelID;
				};
				replyMsg:setContent(("오류가 발생하였습니다! 영상이 존재하지 않거나 다운로드에 실패하였을 수 있습니다, 다시 시도해주세요\n```FALLBACK :\n%s```")
					:format(tostring(back))
				);
				return;
			end

			-- when successfully adding song into playlist
			replyMsg:setContent(("성공적으로 곡 '%s' 을(를) 추가하였습니다!")
				:format(this.name)
			);
		end;
	};
	["list music"] = {
		alias = {"음악 리스트","음악리스트","list music","queue music","music queue","음악 queue"};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)
			local guildConnection = message.guild.connection;
			if not guildConnection then
				return replyMsg:setContent("현재 이 서버에서는 음악 기능을 사용하고 있지 않습니다\n> 음악 실행중이 아님");
			end
			local player = playerForChannels[guildConnection.channel:__hash()];
			if not player then
				return replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
			end
			replyMsg:setEmbed(player:embedfiy());
			replyMsg:setContent("현재 이 서버의 플레이리스트입니다");
		end;
	};
	["음악"] = {
		alias = {"음악 도움말","음악 help","음악도움말","music help","help music","music 도움말"};
		reply = help;
	}
};
