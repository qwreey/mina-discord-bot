local playerForChannels = {}; _G.playerForChannels = playerForChannels;
local playerClass = require "class.music.playerClass";
local formatTime = playerClass.formatTime;
local time = os.time;
local timer = _G.timer;
local eulaComment_music = _G.eulaComment_music or makeEulaComment("음악");

-- 섞기 움직이기(이동)

local help = [[
'**음악**'에 대한 도움말입니다

> 미나 **음악도움말**
이 메시지를 표시합니다

> 미나 **곡`(음악/노래)`추가 <음악URL 또는 검색어> [번째]**
음악을 리스트에 추가합니다, 음성 채팅방에 있어야 사용할 수 있는 명령어입니다
번째 란을 비워두면 자동으로 가장 뒤에 추가합니다
, 을 이용해 여러곡을 한꺼번에 추가할 수도 있습니다
예 : 미나 곡추가 wgcXvLdwkHg,vYw6-1znJ8o,325B1jWAPN8

> 미나 **곡`(음악/노래)`빼기 [번째 또는 이름 또는 a~b 와 같은 범위 또는 공백]**
음악을 리스트에서 뺍니다. 아무런 목표를 주지 않으면 가장 마지막에 추가한 곡을 제거합니다
, 를 이용해 여러곡을 한꺼번에 제거할 수 있습니다
예 : 미나 곡 제거 1~5,전하지 못한 진심,8

> 미나 **곡`(음악/노래)`리스트 [공백 또는 페이지]**
지금 서버의 음악 리스트를 보여줍니다, 아무런 목표를 주지 않으면 가장 첫 페이지를 보여줍니다

> 미나 **곡`(음악/노래)`스킵 [공백 또는 넘어갈 음악 수]**
넘어갈 음악 수 만큼 넘어갑니다. 비워두면 지금 듣고 있는 곡 하나만 넘어갑니다

> 미나 **곡`(음악/노래)`반복 [공백 또는 끄기/켜기 등등]**
곡 반복을 끄거나 켭니다. 공백으로 두면 상태를 반전 (꺼진 경우 켜기, 켜진 경우 끄기) 합니다

> 미나 **현재곡`(음악/노래)`**
현재 재생중인 곡의 정보를 표시합니다. 재생 위치, 조회수, 좋아요, 업로더(채널), 영상링크 등이 표시됩니다

> 미나 **곡`(음악/노래)`정보 <번째>**
해당 번째에 있는 곡의 정보를 표시합니다

> 미나 **곡`(음악/노래)`멈춰**
노래를 잠시 멈춰놓습니다.
재개 명령어를 사용하면 다시 노래를 재생할 수 있습니다

> 미나 **곡`(음악/노래)`재개**
노래를 다시 재생합니다. (멈춘 부분에서 바로 시작합니다)

> 미나 **곡`(음악/노래)`저장**
지금 플레이리스트를 나중에 다시 불러올 수 있게 저장합니다

> 미나 **곡`(음악/노래)`끄기**
음악봇을 완전히 종료합니다

> [💎 프리미엄 전용] 미나 **곡`(음악/노래)`24 [공백 또는 끄기/켜기 등등]**
24 시간 모드를 끄거나 켭니다. 켜는데에는 프리미엄이 필요합니다
이 모드를 활성화 하면 봇이 사람이 없더라도 나가지 않습니다
]];
local killTimer = 60 * 5 * 1000;

--이외에도, 곡을 음악/노래 등으로 바꾸는것 처럼 비슷한 말로 명령어를 사용할 수도 있습니다

-- make auto leave for none-using channels
local function voiceChannelJoin(member,channel)
	local channelId = channel:__hash();
	local player = playerForChannels[channelId];
	if player then
		local timeout = player.timeout;
		if timeout then
			logger.infof("Someone joined voice channel, stop killing player [channel:%s]",channelId);
			pcall(timer.clearTimer,timeout);
		end
	end
end
client:on("voiceChannelJoin",function (...)
	local passed,result = pcall(voiceChannelJoin,...);
	if not passed then
		logger.errorf("An error occurred while trying adding killing music player queue [channel:%s]",
			(select(2,...) or {__hash = function () return "unknown"; end}):__hash()
		);
		logger.errorf("Error message was : %s",result);
	end
end);

local function voiceChannelLeave(member,channel)
	local channelId = channel:__hash();
	local player = playerForChannels[channelId];
	local guild = channel.guild;
	if player and guild.connection then
		if player.mode24 then
			return;
		end
		local tryKill = true;
		for _,user in pairs(channel.connectedMembers or {}) do
			if not user.bot then
				tryKill = false;
			end
		end
		if tryKill then
			logger.infof("All users left voice channel, queued player to kill list [channel:%s]",channelId);
			player.timeout = timeout(killTimer,function ()
				logger.infof("voice channel timeouted! killing player now [channel:%s]",channelId);
				local connection = guild.connection;
				if connection then
					pcall(player.destroy,player);
					pcall(connection.close,connection);
					playerForChannels[channelId] = nil;
				end
			end);
		end
	elseif player then
		playerForChannels[channelId] = nil;
	end
end
client:on("voiceChannelLeave",function (...)
	local passed,result = pcall(voiceChannelLeave,...);
	if not passed then
		logger.errorf("An error occurred while trying adding killing music player queue [channel:%s]",
			(select(2,...) or {__hash = function () return "unknown"; end}):__hash()
		);
		logger.errorf("Error message was : %s",result);
	end
end);

local function playerDestroy(self)
	playerForChannels[self.voiceChannelID] = nil;
	self.destroyed = true;
end

local function removeSong(rawArgs,player,replyMsg)
	do -- remove by number of rawArgs
		local this = tonumber(rawArgs);
		if this then
			local pop = player:remove(this);
			if not pop then
				replyMsg:setContent(("%d 번째 곡이 존재하지 않습니다!"):format(this));
				return true;
			end
			local info = pop.info;
			replyMsg:setContent(("%d 번째 곡 '%s' 를 삭제하였습니다"):format(this,info and info.title or "알 수 없음"));
			return true;
		end
	end
	do -- a~b
		local atEnd,atStart;
		atStart,atEnd = rawArgs:match("(%d+) -~ -(%d+)");
		atStart,atEnd = tonumber(atStart),tonumber(atEnd);
		if atEnd and atStart then
			local min,max = math.min(atStart,atEnd),math.max(atStart,atEnd);
			player:remove(
				min,max
			);
			replyMsg:setContent(("성공적으로 %d 번째 곡부터 %d 번째 곡 까지 삭제했습니다!"):format(min,max));
			return true;
		end
	end
	do -- index by name
		for index = #player,1,-1 do -- TODO: check this is working?
			local song = player[index];
			local info = song.info;
			if info then
				local title = info.title;
				if title then
					if title:lower():gsub(" ",""):find(rawArgs:lower():gsub(" ",""),1,true) then
						player:remove(index);
						replyMsg:setContent(("%d 번째 곡 '%s' 를 삭제하였습니다"):format(index,info and info.title or "알 수 없음"));
						return true;
					end
				end
			end
		end
	end
end

---@type table<string, Command>
local export = {
	["add music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"add","p","play"};
		alias = {
			"노래틀어","노래틀어줘","노래추가해","노래추가해줘","노래추가하기","노래추가해봐","노래추가해라","노래추가","노래재생","노래실행",
			"노래 틀어","노래 틀어줘","노래 추가해","노래 추가해줘","노래 추가하기","노래 추가해봐","노래 추가해라","노래 추가","노래 재생","노래 실행",
			"음악틀어","음악틀어줘","음악추가해","음악추가해줘","음악추가하기","음악추가해봐","음악추가해라","음악추가","음악재생","음악실행",
			"음악 틀어","음악 틀어줘","음악 추가해","음악 추가해줘","음악 추가하기","음악 추가해봐","음악 추가해라","음악 추가","음악 재생","음악 실행",
			"곡틀어","곡틀어줘","곡추가해","곡추가해줘","곡추가하기","곡추가해봐","곡추가해라","곡추가","곡재생","곡실행",
			"곡 틀어","곡 틀어줘","곡 추가해","곡 추가해줘","곡 추가하기","곡 추가해봐","곡 추가해라","곡 추가","곡 재생","곡 실행",
			"음악 add","music add","music 추가",
			"음악 insert","music insert",
			"음악 play","music play","mucis 재생",
			"song add","song 추가","song play","song 재생",
			"add 음악","add 곡","add 노래"
		};
		reply = "처리중입니다";
		func = function(replyMsg,message,args,Content)
			local nth,rawArgs; do
				local contentRaw = Content.rawArgs;
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
			local guild = message.guild;
			local guildConnection = guild.connection;
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
				guild.me:deafen(); -- deafen it selfs
				player = playerClass.new {
					voiceChannel = voiceChannel;
					voiceChannelID = voiceChannelID;
					handler = handler;
					destroy = playerDestroy;
				};
				playerForChannels[voiceChannelID] = player;
			end

			-- if nth is bigger then playerlist len, just adding song on end of list
			if nth and (nth > #player) then
				nth = nil;
			end

			if not rawArgs:match(",") then -- once
				local member = message.member;
				local nickname = member and member.nickname;
				local authorName = message.author.name:gsub("`","\\`");
				local username = nickname and (nickname:gsub("`","\\`") .. (" (%s)"):format(authorName)) or authorName;
				local this = {
					message = message;
					url = rawArgs;
					whenAdded = time();
					username = username;
				};
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
				local info = this.info;
				if info then
					replyMsg:setContent(("성공적으로 곡 '%s' 을(를)%s 추가하였습니다! `(%s)`")
						:format(info.title,nth and ((" %d 번째에"):format(nth)) or "",formatTime(info.duration))
					);
				else
					replyMsg:setContent("성공적으로 곡 'NULL' 을(를) 추가하였습니다! `(0:0)`");
				end
			else -- batch add
				local list = {};
				for item in rawArgs:gmatch("[^,]+") do
					table.insert(list,item);
				end
				local ok = 0;
				local whenAdded = time();
				local member = message.member;
				local nickname = member and member.nickname;
				local authorName = message.author.name:gsub("`","\\`");
				local username = nickname and (nickname:gsub("`","\\`") .. (" (%s)"):format(authorName)) or authorName;
				local duration = 0;
				for _,item in ipairs(list) do
					if not guild.connection then -- if it killed by user
						return;
					end
					local this = {
						message = message;
						url = item;
						whenAdded = whenAdded;
						username = username;
					};
					local passed,back = pcall(player.add,player,this,nth);
					if not passed then
						message:reply(("곡 '%s' 를 추가하는데 실패하였습니다\n```%s```"):format(tostring(item),tostring(back)));
					else
						ok = ok + 1;
						local info = this.info;
						if info then
							duration = duration + (info.duration or 0);
						end
					end
				end
				replyMsg:setContent(("성공적으로 곡 %d 개를 추가하였습니다! `(%s)`")
					:format(ok,formatTime(duration))
				);
			end
		end;
	};
	["join music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"add","p","play"};
		alias = {
			"보이스채팅참여","보이스채팅참여해","보이스채팅참가","보이스채팅참가해","보이스채팅참가하기","보이스채팅참가해라","보이스채팅참가해봐","보이스채팅참가하자",
			"보이스채팅 참여","보이스채팅 참여해","보이스채팅 참가","보이스채팅 참가해","보이스채팅 참가하기","보이스채팅 참가해라","보이스채팅 참가해봐","보이스채팅 참가하자",
			"보이스 채팅참여","보이스 채팅참여해","보이스 채팅참가","보이스 채팅참가해","보이스 채팅참가하기","보이스 채팅참가해라","보이스 채팅참가해봐","보이스 채팅참가하자",
			"보이스 채팅 참여","보이스 채팅 참여해","보이스 채팅 참가","보이스 채팅 참가해","보이스 채팅 참가하기","보이스 채팅 참가해라","보이스 채팅 참가해봐","보이스 채팅 참가하자",
			"voice참여","voice참여해","voice참가","voice참가해","voice참가하기","voice참가해라","voice참가해봐","voice참가하자",
			"voice 참여","voice 참여해","voice 참가","voice 참가해","voice 참가하기","voice 참가해라","voice 참가해봐","voice 참가하자",
			"보이스참여","보이스참여해","보이스참가","보이스참가해","보이스참가하기","보이스참가해라","보이스참가해봐","보이스참가하자",
			"보이스 참여","보이스 참여해","보이스 참가","보이스 참가해","보이스 참가하기","보이스 참가해라","보이스 참가해봐","보이스 참가하자",
			"보이스챗참여","보이스챗참여해","보이스챗참가","보이스챗참가해","보이스챗참가하기","보이스챗참가해라","보이스챗참가해봐","보이스챗참가하자",
			"보이스챗 참여","보이스챗 참여해","보이스챗 참가","보이스챗 참가해","보이스챗 참가하기","보이스챗 참가해라","보이스챗 참가해봐","보이스챗 참가하자",
			"음성 채팅참여","음성 채팅참여해","음성 채팅참가","음성 채팅참가해","음성 채팅참가하기","음성 채팅참가해라","음성 채팅참가해봐","음성 채팅참가하자",
			"음성 채팅 참여","음성 채팅 참여해","음성 채팅 참가","음성 채팅 참가해","음성 채팅 참가하기","음성 채팅 참가해라","음성 채팅 참가해봐","음성 채팅 참가하자",
			"음챗참여","음챗참여해","음챗참가","음챗참가해","음챗참가하기","음챗참가해라","음챗참가해봐","음챗참가하자",
			"음챗 참여","음챗 참여해","음챗 참가","음챗 참가해","음챗 참가하기","음챗 참가해라","음챗 참가해봐","음챗 참가하자",
			"음성채팅참여","음성채팅참여해","음성채팅참가","음성채팅참가해","음성채팅참가하기","음성채팅참가해라","음성채팅참가해봐","음성채팅참가하자",
			"음성채팅 참여","음성채팅 참여해","음성채팅 참가","음성채팅 참가해","음성채팅 참가하기","음성채팅 참가해라","음성채팅 참가해봐","음성채팅 참가하자",
			"vc참여","vc참여해","vc참가","vc참가해","vc참가하기","vc참가해라","vc참가해봐","vc참가하자",
			"vc 참여","vc 참여해","vc 참가","vc 참가해","vc 참가하기","vc 참가해라","vc 참가해봐","vc 참가하자",
			"노래참여","노래참여해","노래참가","노래참가해","노래참가하기","노래참가해라","노래참가해봐","노래참가하자",
			"노래 참여","노래 참여해","노래 참가","노래 참가해","노래 참가하기","노래 참가해라","노래 참가해봐","노래 참가하자",
			"음악참여","음악참여해","음악참가","음악참가해","음악참가하기","음악참가해라","음악참가해봐","음악참가하자",
			"음악 참여","음악 참여해","음악 참가","음악 참가해","음악 참가하기","음악 참가해라","음악 참가해봐","음악 참가하자",
			"곡참여","곡참여해","곡참가","곡참가해","곡참가하기","곡참가해라","곡참가해봐","곡참가하자",
			"곡 참여","곡 참여해","곡 참가","곡 참가해","곡 참가하기","곡 참가해라","곡 참가해봐","곡 참가하자",			
			"음악 join","music join","music 참가","join vc","vc join","join voice","voice join"
		};
		reply = "처리중입니다";
		func = function(replyMsg,message,args,Content)
			-- check users voice channel
			local voiceChannel = message.member.voiceChannel;
			if not voiceChannel then
				replyMsg:setContent("음성 채팅방에 있지 않습니다! 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.");
				return;
			end

			-- get already exist connection
			local guild = message.guild;
			local guildConnection = guild.connection;
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
				guild.me:deafen(); -- deafen it selfs
				player = playerClass.new {
					voiceChannel = voiceChannel;
					voiceChannelID = voiceChannelID;
					handler = handler;
					destroy = playerDestroy;
				};
				playerForChannels[voiceChannelID] = player;
				replyMsg:setContent("성공적으로 음성채팅에 참가했습니다!");
				return;
			end
			replyMsg:setContent("이미 음성채팅에 참가했습니다!");
		end;
	};
	["list music"] = {
		disableDm = true;
		command = {"l","ls","list","q","queue"};
		alias = {
			"노래페이지","노래대기열","노래리스트","노래순번","노래페이지",
			"노래 페이지","노래 대기열","노래 리스트","노래 순번","노래 페이지",
			"곡페이지","곡대기열","곡리스트","곡순번","곡페이지",
			"곡 페이지","곡 대기열","곡 리스트","곡 순번","곡 페이지",
			"음악페이지","음악대기열","음악리스트","음악순번","음악페이지",
			"음악 페이지","음악 대기열","음악 리스트","음악 순번","음악 페이지",
			"재생목록","재생 목록","신청 목록","신청목록","플리",
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
			local rawArgs = Content.rawArgs;
			replyMsg:update {
				embed = player:embedfiyList(tonumber(rawArgs) or tonumber(rawArgs:match("%d+")));
				content = "현재 이 서버의 플레이리스트입니다!";
				components = {
					{
						type = 1;
						label = "Test";
						sytle = 1;
						custom_id = "test";
					};
				};
			};
		end;
	};
	["song24"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"loop","looping","lp","lop"};
		alias = {
			"song 24","music 24","music24","song 24h","song24h","music24h","music 24h",
			"노래24","노래 24","노래 24시","노래24시","노래24시간","노래 24시간",
			"음악24","음악 24","음악 24시","음악24시","음악24시간","음악 24시간",
			"곡24","곡 24","곡 24시","곡24시","곡24시간","곡 24시간"
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
			end

			-- loop!
			local rawArgs = Content.rawArgs;
			local setTo = not player.mode24;
			if onKeywords[rawArgs] then
				setTo = true;
			elseif onKeywords[rawArgs] then
				setTo = false;
			end

			if setTo then
				if Content.isPremium() then
					replyMsg:setContent("성공적으로 24 시간 모드를 활성화했습니다!");
					player.mode24 = true;
				else
					replyMsg:setContent("프리미엄에 가입하지 않아 켤 수 없습니다!");
				end
			else
				player.mode24 = nil;
				replyMsg:setContent("성공적으로 24 시간 모드를 비활성화했습니다!");
				voiceChannelLeave(Content.user,voiceChannel); -- check there is no users
			end
		end;
	};
	["loop"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"loop","looping","lp","lop"};
		alias = {
			"반복재생",
			"looping","looping toggle","toggle looping","플레이리스트반복","플레이 리스트 반복","플리 반복",
			"플리반복","플리루프","플리 루프","플리반복하기","플리 반복하기",
			"재생목록 반복하기","재생목록반복하기","재생목록반복","재생목록 반복","재생목록루프","재생목록 루프",
			"노래반복","노래루프","노래반복하기","노래 반복","노래 루프","노래 반복하기",
			"음악반복","음악루프","음악반복하기","음악 반복","음악 루프","음악 반복하기",
			"곡반복","곡루프","곡반복하기","곡 반복","곡 루프","곡 반복하기",
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)
			-- get already exist connection
			local guildConnection = message.guild.connection;
			if not guildConnection then
				replyMsg:setContent("봇이 음성채팅방에 있지 않습니다. 봇이 음성채팅방에 있을때 사용해주세요!");
				return;
			end
			local voiceChannel = guildConnection.channel;
			if not voiceChannel then
				replyMsg:setContent("채널이 발견되지 않았습니다!");
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
			local setTo = not player.isLooping;
			if onKeywords[rawArgs] then
				setTo = true;
			elseif onKeywords[rawArgs] then
				setTo = false;
			end

			if setTo then
				player:setLooping(true);
				replyMsg:setContent("성공적으로 플레이리스트 반복을 켰습니다!");
			else
				player:setLooping(false);
				replyMsg:setContent("성공적으로 플레이리스트 반복을 멈췄습니다!");
			end
		end;
	};
	["음악"] = {
		reply = "명령어를 처리하지 못했어요!\n> 음악 기능 도움이 필요하면 '미나 음악 도움말' 을 입력해주세요";
	};
	["음악 도움말"] = {
		registeredOnly = eulaComment_music;
		alias = {"음악 사용법","음악 사용법 알려줘","음악사용법","음악 도움말 보여줘","음악 help","음악도움말","music help","help music","music 도움말"};
		reply = help;
		sendToDm = "개인 메시지로 도움말이 전송되었습니다!";
	};
	["remove music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"rm","remove","r"};
		alias = {
			"곡 재거","곡재거","음악 재거","음악 재거","노래 재거","노래재거",
			"곡빼줘","곡제거","곡빼기","곡없에기","곡지우기","곡삭제","곡지워","곡빼","곡없에","곡지워줘","곡없에줘","곡날리기",
			"곡 빼줘","곡 제거","곡 빼기","곡 없에기","곡 지우기","곡 삭제","곡 지워","곡 빼","곡 없에","곡 지워줘","곡 없에줘","곡 날리기",
			"음악빼줘","음악제거","음악빼기","음악없에기","음악지우기","음악삭제","음악지워","음악빼","음악없에","음악지워줘","음악없에줘","음악날리기",
			"음악 빼줘","음악 제거","음악 빼기","음악 없에기","음악 지우기","음악 삭제","음악 지워","음악 빼","음악 없에","음악 지워줘","음악 없에줘","음악 날리기",
			"노래빼줘","노래제거","노래빼기","노래없에기","노래지우기","노래삭제","노래지워","노래빼","노래없에","노래지워줘","노래없에줘","노래날리기",
			"노래 빼줘","노래 제거","노래 빼기","노래 없에기","노래 지우기","노래 삭제","노래 지워","노래 빼","노래 없에","노래 지워줘","노래 없에줘","노래 날리기",
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
					replyMsg:setContent(("%s 번째 곡 '%s' 를 삭제하였습니다!"):format(tostring(index),info and info.title or "알 수 없음"));
					return;
				end
			end

			local removed = false;
			for songStr in rawArgs:gmatch("[^,]+") do
				removed = removed or removeSong(songStr,player,replyMsg);
			end
			if not removed then
				replyMsg:setContent("아무런 곡도 삭제하지 못했습니다!");
			end
		end;
	};
	["skip music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"sk","skip","s"};
		alias = {
			"곡 넘겨","곡건너뛰기","곡스킵","곡넘어가기","곡넘기기","곡넘겨줘","곡넘어가","곡다음","곡다음으로","곡다음곡",
			"곡넘겨","곡 건너뛰기","곡 스킵","곡 넘어가기","곡 넘기기","곡 넘겨줘","곡 넘어가","곡 다음","곡 다음으로","곡 다음곡",
			"음악넘겨","음악건너뛰기","음악스킵","음악넘어가기","음악넘기기","음악넘겨줘","음악넘어가","음악다음","음악다음으로","음악다음곡",
			"음악 넘겨","음악 건너뛰기","음악 스킵","음악 넘어가기","음악 넘기기","음악 넘겨줘","음악 넘어가","음악 다음","음악 다음으로","음악 다음곡",
			"노래넘겨","노래건너뛰기","노래스킵","노래넘어가기","노래넘기기","노래넘겨줘","노래넘어가","노래다음","노래다음으로","노래다음곡",
			"노래 넘겨","노래 건너뛰기","노래 스킵","노래 넘어가기","노래 넘기기","노래 넘겨줘","노래 넘어가","노래 다음","노래 다음으로","노래 다음곡",
			"music 스킵","music 넘어가기","music 넘기기","music 넘겨줘","music 넘어가","music 다음","music 다음으로","music 다음곡",
			"song 스킵","song 넘어가기","song 넘기기","song 넘겨줘","song 넘어가","song 다음","song 다음으로","song 다음곡",
			"song skip","skip song","skip music","music skip",
			"next skip","next song","next music","music next",
			"skip 음악","skip 곡","skip 노래",
			"곡 넘어 가기","음악 넘어 가기","노래 넘어 가기"
		};
		reply = "처리중입니다 . . .";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
			rawArgs = tonumber(rawArgs:match("%d+")) or 1;

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
			local lenPlayer = #player;
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			elseif not player.nowPlaying then -- if it is not playing then
				replyMsg:setContent("실행중인 음악이 없습니다!");
				return;
			elseif lenPlayer < rawArgs then
				replyMsg:setContent(("스킵 하려는 곡 수가 전채 곡 수 보다 많습니다!\n> 참고 : 현재 곡 수는 %d 개 입니다")
					:format(lenPlayer)
				);
				return;
			end

			-- skip!
			local lastOne,lastIndex,all = player:remove(1,rawArgs);
			local looping = player.isLooping
			if looping then
				for _,thing in ipairs(all) do
					player:add(thing);
				end
			end
			local loopMsg = (looping and "\n(루프 모드가 켜져있어 스킵된 곡은 가장 뒤에 다시 추가되었습니다)" or "");
			local new = player[1];
			new = new and player.info;
			new = new and new.title
			local nowPlaying = (new and ("다음으로 재생되는 곡은 '%s' 입니다\n"):format(new) or "");
			replyMsg:setContent( -- !!REVIEW NEEDED!!
				rawArgs == 1 and
				(("성공적으로 곡 '%s' 를 스킵하였습니다%s%s"):format(tostring(lastOne and lastOne.info and lastOne.info.title),nowPlaying,loopMsg)) or
				(("성공적으로 곡 %s 개를 스킵하였습니다!%s%s"):format(tostring(rawArgs),nowPlaying,loopMsg))
			);
		end;
	};
	["pause music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"pause"};
		alias = {
			"곡 멈추기","곡 멈춰","곡멈추기","곡멈춰",
			"음악 멈추기","음악 멈춰","음악멈추기","음악멈춰",
			"노래 멈추기","노래 멈춰","노래멈추기","노래멈춰",
			"노래 일시중단","노래 일시중단","노래일시중단","노래일시중단",
			"음악 일시중단","음악 일시중단","음악일시중단","음악일시중단",
			"노래 일시중단","노래 일시중단","노래일시중단","노래일시중단",
			"노래 일시 중단","노래 일시 중단","노래일시 중단","노래일시 중단",
			"음악 일시 중단","음악 일시 중단","음악일시 중단","음악일시 중단",
			"노래 일시 중단","노래 일시 중단","노래일시 중단","노래일시 중단",
			"노래 일시중지","노래 일시중지","노래일시중지","노래일시중지",
			"음악 일시중지","음악 일시중지","음악일시중지","음악일시중지",
			"노래 일시중지","노래 일시중지","노래일시중지","노래일시중지",
			"노래 일시 중지","노래 일시 중지","노래일시 중지","노래일시 중지",
			"음악 일시 중지","음악 일시 중지","음악일시 중지","음악일시 중지",
			"노래 일시 중지","노래 일시 중지","노래일시 중지","노래일시 중지",
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
			player:setPaused(true);
			replyMsg:setContent("성공적으로 음악을 멈췄습니다!");
		end;
	};
	["stop music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"off","stop","leave"};
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
			player:destroy();
			player:kill();
			replyMsg:setContent("성공적으로 음악을 종료하였습니다!");
		end;
	};
	["now music"] = {
		disableDm = true;
		command = {"n","np","nowplay","nowplaying","nplay","nplaying","nowp"};
		alias = {
			"현재재생","지금재생","현재 재생","지금 재생","현재 곡","현재 음악","현재 노래","지금 곡","지금 음악","지금 노래",
			"현재곡","현재음악","현재노래","지금곡","지금음악","지금노래","지금재생중",
			"지금 재생중","now playing","music now","song now","playing now","now play","nowplaying"
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
			local rawArgs = Content.rawArgs;
			replyMsg:update {
				embed = player:embedfiyNowplaying();
				content = "지금 재생중인 곡입니다!";
			};
		end;
	};
	["info music"] = {
		disableDm = true;
		command = {"i","info","nowplay","nowplaying","nplay","nplaying","nowp"};
		alias = {
			"곡정보","곡 정보","info song","song info","music info","info music","곡 자세히보기",
			"곡자세히보기","곡설명","곡 설명","song description","description song"
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
			local this = Content.rawArgs;
			this = tonumber(this) or tonumber(this:match("%d+")) or 1;
			replyMsg:update {
				embed = player:embedfiyNowplaying(this);
				content = (this == 1) and "지금 재생중인 곡입니다!" or (("%d 번째 곡입니다!"):format(this));
			};
		end;
	};
	["resume music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"resume"};
		alias = {
			"곡 다시재생","곡다시재생",
			"음악 다시재생","음악다시재생",
			"노래 다시재생","노래다시재생",
			"노래 재개","노래 재개","노래재개","노래재개",
			"음악 재개","음악 재개","음악재개","음악재개",
			"곡 재개","곡 재개","곡재개","곡재개",
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
			player:setPaused(false);
			replyMsg:setContent("성공적으로 음악을 재개했습니다!");
		end;
	};
	["export music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"export","e"};
		alias = {
			"노래리스트저장하기","노래리스트저장","노래내보내기","노래출력","노래저장","노래저장하기","노래기록","노래기록하기","노래나열하기",
			"노래 리스트 저장하기","노래 리스트 저장","노래 내보내기","노래 출력","노래 저장","노래 저장하기","노래 기록","노래 기록하기","노래 나열하기",
			"음악리스트저장하기","음악리스트저장","음악내보내기","음악출력","음악저장","음악저장하기","음악기록","음악기록하기","음악나열하기",
			"음악 리스트 저장하기","음악 리스트 저장","음악 내보내기","음악 출력","음악 저장","음악 저장하기","음악 기록","음악 기록하기","음악 나열하기",
			"곡리스트저장하기","곡리스트저장","곡내보내기","곡출력","곡저장","곡저장하기","곡기록","곡기록하기","곡나열하기",
			"곡 리스트 저장하기","곡 리스트 저장","곡 내보내기","곡 출력","곡 저장","곡 저장하기","곡 기록","곡 기록하기","곡 나열하기",
			"곡 리스트저장하기","곡 리스트저장","음악 리스트저장하기","음악 리스트저장","노래 리스트저장하기","노래 리스트저장",
			"플리내보내기","플리 내보내기","플리 저장","플리 킵","음악 리스트 킵","노래 리스트 킵","곡 리스트 킵",
			"음악 대기열 킵","음악 대기열 킵","곡 대기열 킵","export music","music export","song export","export song",
			"music 내보내기","song 내보내기","내보내기 song","내보내기 music","export 음악","음악 export","곡 export","export 곡","노래 export","export 노래"
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
			elseif #player == 0 then
				return replyMsg:setContent("리스트가 비어있습니다!");
			end
			local export = "";
			for _,item in ipairs(player) do
				export = export .. item.vid .. ",";
			end
			replyMsg:setContent(("```미나 곡추가 %s```")
				:format(export:sub(1,-2))
			);
		end;
	};
};
return export;
