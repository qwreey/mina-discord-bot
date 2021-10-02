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
'**음악**'에 대한 도움말입니다

> 미나 **음악도움말**
이 메시지를 표시합니다

> 미나 **곡추가** **[음악URL 또는 검색어]**
음악을 리스트에 추가합니다, 음성 채팅방에 있어야 사용할 수 있는 명령어입니다.

> 미나 **곡빼기** **[공백 또는 번째]**
음악을 리스트에서 뺍니다, 아무런 목표를 주지 않으면 가장 마지막에 추가한 곡을 제거합니다

> 미나 **음악리스트**
지금 서버의 음악 리스트를 보여줍니다
]];

--[[
음악도움말 대신 다음과 같이 쓸 수도 있습니다
`'음악' '음악 도움말' '음악 help' '음악' 'music help' 'help music' 'music 도움말'`

음악추가 대신 다음과 같이 쓸 수도 있습니다
`'곡 추가' '곡추가' 'add music' '음악 추가' '음악 add' 'music add' 'music 추가' '음악 재생' '음악재생'`

이 명령어는 또한 다음과 같이 쓸 수도 있습니다
`"곡 빼기","곡 없에기","곡 지우기","곡 삭제","곡 지워","곡 빼","곡 없에","곡 지워줘","곡 없에줘","곡 날리기" 등등등`

이 명령어는 또한 다음과 같이 쓸 수도 있습니다
`'곡 리스트' '곡리스트' '음악 리스트' '음악리스트' 'list music' 'queue music' 'music queue' '음악 queue'`
]]

return {
	["add music"] = {
		alias = {"곡 추가","곡추가","음악추가","음악 추가","음악 add","music add","music 추가","음악 재생","음악재생"};
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
				:format(this.info.title)
			);
		end;
	};
	["list music"] = {
		alias = {"곡 리스트","곡리스트","음악 리스트","음악리스트","list music","queue music","music queue","음악 queue"};
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
	["music"] = {
		alias = {"음악","음악 도움말","음악 help","음악도움말","music help","help music","music 도움말"};
		reply = help;
	};
	["remove music"] = {
		alias = {
			"곡빼기","곡없에기","곡지우기","곡삭제","곡지워","곡빼","곡없에","곡지워줘","곡없에줘","곡날리기",
			"곡 빼기","곡 없에기","곡 지우기","곡 삭제","곡 지워","곡 빼","곡 없에","곡 지워줘","곡 없에줘","곡 날리기",
			"음악빼기","음악없에기","음악지우기","음악삭제","음악지워","음악빼","음악없에","음악지워줘","음악없에줘","음악날리기",
			"음악 빼기","음악 없에기","음악 지우기","음악 삭제","음악 지워","음악 빼","음악 없에","음악 지워줘","음악 없에줘","음악 날리기",
			"music 빼기","music 없에기","music 지우기","music 삭제","music 지워","music 빼","music 없에","music 지워줘","music 없에줘","music 날리기",
			"song 빼기","song 없에기","song 지우기","song 삭제","song 지워","song 빼","song 없에","song 지워줘","song 없에줘","song 날리기",
			"song remove","remove song","remove music","music remove"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)

		end;
	};
	["skip music"] = {
		alias = {
			"곡스킵","곡넘어가기","곡넘기기","곡넘겨줘","곡넘어가","곡다음","곡다음으로","곡다음곡",
			"곡 스킵","곡 넘어가기","곡 넘기기","곡 넘겨줘","곡 넘어가","곡 다음","곡 다음으로","곡 다음곡",
			"음악스킵","음악넘어가기","음악넘기기","음악넘겨줘","음악넘어가","음악다음","음악다음으로","음악다음곡",
			"음악 스킵","음악 넘어가기","음악 넘기기","음악 넘겨줘","음악 넘어가","음악 다음","음악 다음으로","음악 다음곡",
			"music 스킵","music 넘어가기","music 넘기기","music 넘겨줘","music 넘어가","music 다음","music 다음으로","music 다음곡",
			"song 스킵","song 넘어가기","song 넘기기","song 넘겨줘","song 넘어가","song 다음","song 다음으로","song 다음곡",
			"song skip","skip song","skip music","music skip",
			"next skip","next song","next music","music next"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)

		end;
	};
	["pause music"] = {
		alias = {
			"곡 멈추기","곡 멈춰","곡멈추기","곡멈춰",
			"음악 멈추기","음악 멈춰","음악멈추기","음악멈춰",
			"music 멈추기","music 멈춰","song 멈추기","song 멈춰",
			"song pause","pause song","pause music","music pause"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)

		end;
	};
	["stop music"] = {
		alias = {
			"곡 끄기","곡 꺼","곡끄기","곡꺼",
			"음악 끄기","음악 꺼","음악끄기","음악꺼",
			"music 끄기","music 꺼","song 끄기","song 꺼",
			"song stop","stop song","stop music","music stop"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)

		end;
	};
	["resume music"] = {
		alias = {
			"곡 멈추기","곡 멈춰","곡멈추기","곡멈춰",
			"음악 멈추기","음악 멈춰","음악멈추기","음악멈춰",
			"music 멈추기","music 멈춰","song 멈추기","song 멈춰",
			"song pause","pause song","pause music","pause music"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)

		end;
	};
};
