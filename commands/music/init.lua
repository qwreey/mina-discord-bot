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

> 미나 **곡추가 <음악URL 또는 검색어> [번째]**
음악을 리스트에 추가합니다, 음성 채팅방에 있어야 사용할 수 있는 명령어입니다.
번째 란을 비워두면 자동으로 가장 뒤에 추가합니다
, 을 이용해 여러곡을 한꺼번에 추가할 수도 있습니다

> 미나 **곡빼기 [번째 또는 이름 또는 공백, a~b 와 같은 범위선택자]**
음악을 리스트에서 뺍니다, 아무런 목표를 주지 않으면 가장 마지막에 추가한 곡을 제거합니다

> 미나 **곡리스트 [공백 또는 페이지]**
지금 서버의 음악 리스트를 보여줍니다

> 미나 **곡스킵 [공백 또는 넘어갈 음악 수]**
넘어갈 음악 수 만큼 넘어갑니다, 비워두면 지금 듣고 있는 곡 하나만 넘어갑니다

> 미나 **곡정보**

이외에도, 곡을 음악/노래 등으로 바꾸는것 처럼 비슷한 말로 불러도 학습되어 있기 때문에 작동합니다
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

현재 재생, 정보, 지금재생, 지금, 현재, 실행중, 실행곡, ...
]]

return {
	["add music"] = {
		alias = {
			"노래추가","노래재생","노래실행",
			"노래 추가","노래 재생","노래 실행",
			"음악추가","음악재생","음악실행",
			"음악 추가","음악 재생","음악 실행",
			"곡추가","곡실행","음악재생",
			"곡 추가","곡 실행","음악 재생",
			"음악 add","music add","music 추가",
			"음악 insert","music insert",
			"음악 play","music play","mucis 재생",
			"song add","song 추가","song play","song 재생",
			"add 음악","add 곡","add 노래"
		};
		reply = "처리중입니다";
		func = function(replyMsg,message,args,Content)
			local nth,rawArgs; do
				local contentRaw = Content.rawArgs
				rawArgs = contentRaw;
				rawArgs,nth = rawArgs:match("(.-) (%d-)$");
				nth = tonumber(nth);
				rawArgs = rawArgs or contentRaw;
			end

			-- check users voice channel
			local voiceChannel = message.member.voiceChannel;
			if not voiceChannel then
				replyMsg:setContent("음성 채팅방에 있지 않습니다! 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.");
				return;
			end

			-- get already exist connection
			local guildConnection = message.guild.connection;
			if guildConnection and (guildConnection.channel ~= voiceChannel) then
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 각 서버당 한 채널만 이용할 수 있습니다!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not guildConnection then -- if connections is not exist, create new one
				local handler = voiceChannel:join();
				if not handler then
					replyMsg:setContent("채널에 참가할 수 없습니다, 봇이 유효한 권한을 가지고 있는지 확인해주세요!");
					return;
				end
				player = playerClass.new {
					voiceChannel = voiceChannel;
					voiceChannelID = voiceChannelID;
					handler = handler;
				};
				playerForChannels[voiceChannelID] = player;
			end

			if not rawArgs:match(",") then -- once
				local this = {url = rawArgs};
				local passed,back = pcall(player.add,player,this,nth);

				-- when failed to adding song into playlist
				if (not passed) or (not this.info) then
					replyMsg:setContent(("오류가 발생하였습니다! 영상이 존재하지 않거나 다운로드에 실패하였을 수 있습니다, 다시 시도해주세요\n```FALLBACK :\n%s```")
						:format(tostring(back))
					);
					-- debug
					logger.errorf("Failed to add music '%s' on player:%s",rawArgs,voiceChannelID);
					logger.errorf("traceback : %s",back)
					qDebug {
						title = "music adding failed";
						arg = rawArgs;
						voiceChannelID = voiceChannelID;
					};
					return;
				end

				-- when successfully adding song into playlist
				replyMsg:setContent(("성공적으로 곡 '%s' 을(를) 추가하였습니다!")
					:format(this.info.title)
				);
			else -- batch add
				local list = {};
				for item in rawArgs:gmatch("[^,]+") do
					table.insert(list,item);
				end
				local ok = 0;
				for _,item in ipairs(list) do
					local this = {url = item};
					local passed,back = pcall(player.add,player,this,nth);
					if not passed then
						message:reply(("곡 '%s' 를 추가하는데 실패하였습니다\n```%s```"):format(tostring(item),tostring(back)));
					else
						ok = ok + 1;
					end
				end
				replyMsg:setContent(("성공적으로 곡 %d 개를 추가하였습니다!")
					:format(ok)
				);
			end
		end;
	};
	["list music"] = {
		alias = {
			"노래대기열","노래리스트","노래순번","노래페이지",
			"노래 대기열","노래 리스트","노래 순번","노래 페이지",
			"곡대기열","곡리스트","곡순번","곡페이지",
			"곡 대기열","곡 리스트","곡 순번","곡 페이지",
			"음악대기열","음악리스트","음악순번","음악페이지",
			"음악 대기열","음악 리스트","음악 순번","음악 페이지",
			"플레이리스트","플레이 리스트",
			"list music","queue music","music queue","music list",
			"list song","queue song","song queue","song list",
			"song 리스트","music 리스트","song 대기열","song 리스트",
			"list 곡","list 음악","list 노래"
		};
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
			"곡제거","곡빼기","곡없에기","곡지우기","곡삭제","곡지워","곡빼","곡없에","곡지워줘","곡없에줘","곡날리기",
			"곡 제거","곡 빼기","곡 없에기","곡 지우기","곡 삭제","곡 지워","곡 빼","곡 없에","곡 지워줘","곡 없에줘","곡 날리기",
			"음악제거","음악빼기","음악없에기","음악지우기","음악삭제","음악지워","음악빼","음악없에","음악지워줘","음악없에줘","음악날리기",
			"음악 제거","음악 빼기","음악 없에기","음악 지우기","음악 삭제","음악 지워","음악 빼","음악 없에","음악 지워줘","음악 없에줘","음악 날리기",
			"노래제거","노래빼기","노래없에기","노래지우기","노래삭제","노래지워","노래빼","노래없에","노래지워줘","노래없에줘","노래날리기",
			"노래 제거","노래 빼기","노래 없에기","노래 지우기","노래 삭제","노래 지워","노래 빼","노래 없에","노래 지워줘","노래 없에줘","노래 날리기",
			"music 빼기","music 없에기","music 지우기","music 삭제","music 지워","music 빼","music 없에","music 지워줘","music 없에줘","music 날리기",
			"song 빼기","song 없에기","song 지우기","song 삭제","song 지워","song 빼","song 없에","song 지워줘","song 없에줘","song 날리기",
			"song remove","remove song","remove music","music remove",
			"remove 음악","remove 곡","remove 노래"
		};
		reply = "처리중입니다 . . .";
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
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 봇이 있는 음성 채팅방에서 사용해주세요!");
				return;
			elseif not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다, 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			end

			local rawArgs = Content.rawArgs;
			do  -- remove last one
				if rawArgs == "" then
					local pop,index = player:remove();
					if not pop then
						replyMsg:setContent("마지막 곡이 없습니다!");
						return;
					end
					local info = pop.info;
					replyMsg:setContent(("%s 번째 곡 '%s' 를 삭제하였습니다"):format(tostring(index),info and info.title or "알 수 없음"));
					return;
				end
			end
			do -- remove by number of rawArgs
				local this = tonumber(rawArgs);
				if this then
					local pop = player:remove(this);
					if not pop then
						replyMsg:setContent(("%d 번째 곡이 존재하지 않습니다!"):format(this));
						return;
					end
					local info = pop.info;
					replyMsg:setContent(("%d 번째 곡 '%s' 를 삭제하였습니다"):format(this,info and info.title or "알 수 없음"));
					return;
				end
			end
			do -- a~b
				local atEnd,atStart;
				atStart,atEnd = rawArgs:match("(%d+) -~ -(%d+)");
				atStart,atEnd = tonumber(atStart),tonumber(atEnd);
				if atEnd and atStart then
					local min = math.min(atStart,atEnd);
					local max = math.max(atStart,atEnd);
					for _ = 1,max-min+1 do
						player:remove(min);
					end
					replyMsg:setContent(("성공적으로 %d 번째 곡부터 %d 번째 곡 까지 삭제했습니다!"):format(min,max));
					return;
				end
			end
			do -- index by name
				for i,v in ipairs(player) do
					local info = v.info;
					if info then
						local title = info.title;
						if title then
							if title:match(rawArgs) then
								player:remove(i);
								replyMsg:setContent(("%d 번째 곡 '%s' 를 삭제하였습니다"):format(i,info and info.title or "알 수 없음"));
								return;
							end
						end
					end
				end
			end
			replyMsg:setContent("아무런 곡도 삭제하지 못했습니다");
		end;
	};
	["skip music"] = {
		alias = {
			"곡스킵","곡넘어가기","곡넘기기","곡넘겨줘","곡넘어가","곡다음","곡다음으로","곡다음곡",
			"곡 스킵","곡 넘어가기","곡 넘기기","곡 넘겨줘","곡 넘어가","곡 다음","곡 다음으로","곡 다음곡",
			"음악스킵","음악넘어가기","음악넘기기","음악넘겨줘","음악넘어가","음악다음","음악다음으로","음악다음곡",
			"음악 스킵","음악 넘어가기","음악 넘기기","음악 넘겨줘","음악 넘어가","음악 다음","음악 다음으로","음악 다음곡",
			"노래스킵","노래넘어가기","노래넘기기","노래넘겨줘","노래넘어가","노래다음","노래다음으로","노래다음곡",
			"노래 스킵","노래 넘어가기","노래 넘기기","노래 넘겨줘","노래 넘어가","노래 다음","노래 다음으로","노래 다음곡",
			"music 스킵","music 넘어가기","music 넘기기","music 넘겨줘","music 넘어가","music 다음","music 다음으로","music 다음곡",
			"song 스킵","song 넘어가기","song 넘기기","song 넘겨줘","song 넘어가","song 다음","song 다음으로","song 다음곡",
			"song skip","skip song","skip music","music skip",
			"next skip","next song","next music","music next",
			"skip 음악","skip 곡","skip 노래"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
			rawArgs = tonumber(rawArgs:match("%d+") or 1);

			-- check users voice channel
			local voiceChannel = message.member.voiceChannel;
			if not voiceChannel then
				replyMsg:setContent("음성 채팅방에 있지 않습니다! 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.");
				return;
			end

			-- get already exist connection
			local guildConnection = message.guild.connection;
			if guildConnection and (guildConnection.channel ~= voiceChannel) then
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 봇이 있는 음성 채팅방에서 사용해주세요!");
				return;
			elseif not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다, 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			elseif not player.nowPlaying then -- if it is not playing then
				replyMsg:setContent("실행중인 음악이 없습니다!");
				return;
			end

			-- skip!
			for _ = 1,rawArgs do
				player:remove(1);
			end
			replyMsg:setContent("성공적으로 곡 %d 개를 스킵하였습니다!");
		end;
	};
	["pause music"] = {
		alias = {
			"곡 멈추기","곡 멈춰","곡멈추기","곡멈춰",
			"음악 멈추기","음악 멈춰","음악멈추기","음악멈춰",
			"노래 멈추기","노래 멈춰","노래멈추기","노래멈춰",
			"노래 일시중단","노래 일시중단","노래일시중단","노래일시중단",
			"음악 일시중단","음악 일시중단","음악일시중단","음악일시중단",
			"노래 일시중단","노래 일시중단","노래일시중단","노래일시중단",
			"music 멈추기","music 멈춰","song 멈추기","song 멈춰",
			"song pause","pause song","pause music","music pause",
			"pause 곡","pause 음악","pause 노래"
		};
		reply = "처리중입니다 . . .";
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
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 봇이 있는 음성 채팅방에서 사용해주세요!");
				return;
			elseif not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다, 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			elseif not player.nowPlaying then -- if it is not playing then
				replyMsg:setContent("실행중인 음악이 없습니다!");
				return;
			elseif player.isPaused then -- paused alreadly
				replyMsg:setContent("이미 음악이 멈춰있습니다!");
				return;
			end

			-- pause!
			player:pause();
			replyMsg:setContent("성공적으로 음악을 멈췄습니다!");
		end;
	};
	["stop music"] = {
		alias = {
			"곡 끄기","곡 꺼","곡끄기","곡꺼",
			"음악 끄기","음악 꺼","음악끄기","음악꺼",
			"노래 끄기","노래 꺼","노래끄기","노래꺼",
			"곡 나가","곡 나가기","곡나가","곡나가기",
			"음악 나가","음악 나가기","음악나가","음악나가기",
			"노래 나가","노래 나가기","노래나가","노래나가기",
			"곡 종료","곡 종료해","곡종료","곡종료해",
			"음악 종료","음악 종료해","음악종료","음악종료해",
			"노래 종료","노래 종료해","노래종료","노래종료해",
			"music 끄기","music 꺼","song 끄기","song 꺼",
			"song stop","stop song","stop music","music stop",
			"stop 음악","stop 곡","stop 노래"
		};
		reply = "처리중입니다 . . .";
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
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 봇이 있는 음성 채팅방에서 사용해주세요!");
				return;
			elseif not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다, 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			end

			-- pause!
			player:kill();
			replyMsg:setContent("성공적으로 음악을 종료하였습니다!");
		end;
	};
	["resume music"] = {
		alias = {
			"곡 다시재생","곡다시재생",
			"음악 다시재생","음악다시재생",
			"노래 다시재생","노래다시재생",
			"노래 재개","노래 재개","노래재개","노래재개",
			"음악 재개","음악 재개","음악재개","음악재개",
			"노래 재개","노래 재개","노래재개","노래재개",
			"music 다시재생","music다시재생","song 재개","song재개",
			"song resume","resume song","resume music","music resume",
			"resume 곡","resume 노래","resume 음악"
		};
		reply = "처리중입니다 . . .";
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
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중입니다, 봇이 있는 음성 채팅방에서 사용해주세요!");
				return;
			elseif not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다, 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			elseif not player.nowPlaying then -- if it is not playing then
				replyMsg:setContent("실행중인 음악이 없습니다!");
				return;
			elseif not player.isPaused then -- paused alreadly
				replyMsg:setContent("이미 음악이 재생중입니다!");
				return;
			end

			-- pause!
			player:resume();
			replyMsg:setContent("성공적으로 음악을 재개했습니다!");
		end;
	};
};
