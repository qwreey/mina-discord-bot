-- TODO: 가사 찾기 구현하기
-- * API 찾아봅시다

-- TODO: 애코 효과 같은 필터 구현하기
-- * ?

-- TODO: 볼륨 조정 구현하기
-- * ffmpeg 이용

-- TODO: 버튼 기능 추가
-- * 스킵이나 멈춤, 배속 이런거?

-- TODO: 챗 자동 정리
-- * 어캐해 미친

-- TODO: 더 자세한 '지금 재생합니다' 메시지
-- * 썸넬, 설명 몇글자, ... 주의할껀 이거 utf offset 써야됨 절대 string.sub 홀로 쓰기 금지!! (byte 짤림)

-- TODO: 갠디를 통한 도움말 구현하기
-- * 귀찮..아

-- TODO: 유튜브 링크만 던지면 자동으로 곡추가 구현하기
-- * 채널 명에 '미나' 적혀 있으면 수행 하는걸로

-- TODO: 프리미엄 기능 배포하기
-- * 아니 페이팔 계정을 어캐 만드냐고
-- * 19 세 이상 아니면 사업자 용으로 못만들던데?

-- TODO: 사운드 클라우드, 스포티파이 지원
-- * 글쌔,, 사운드 클라우드는 괜찮은데 스포티파이는 폐쇠적임

-- TODO: 서버 음악 기록판
-- * 데이터 스토리지가 그렇게 많은 편은 아니라서 300 곡을 최대로 잡자

-- TODO: 듣는 중에 호감도 주는 기능
-- * 남용될꺼 같음..

-- TODO: Button 으로 Playlist 추가 멈추기

local youtubePlaylist = require "class.music.youtubePlaylist";
local playerClass = require "class.music.playerClass";
local youtubeVideoList = require "class.music.youtubeVideoList";
local playerForChannels = playerClass.playerForChannels;
local formatTime = playerClass.formatTime;
local time = os.time;
-- local timer = _G.timer;
local eulaComment_music = _G.eulaComment_music or makeEulaComment("음악");
local hourInSecond = 60*60;
local minuteInSecond = 60;
-- local client = _G.client;
local help = [[
**음악 기능에 대한 도움말입니다**
> 주의! 이 기능은 아직 불완전합니다. 오류로 인해 몇몇 곡이 스킵 될 수도 있습니다!

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

-- 섞기 움직이기(이동)
--이외에도, 곡을 음악/노래 등으로 바꾸는것 처럼 비슷한 말로 명령어를 사용할 수도 있습니다

-- remove songs wrapping
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
		for index = #player,1,-1 do
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
	-- ["load music"] = {
	-- 	commands = {"load","로드","불러오기","가져오기"};
	-- 	alias = {
	-- 		"곡 가져오기","곡 불러오기","곡가져오기","곡불러오기",
	-- 		"노래 가져오기","노래 불러오기","노래가져오기","노래불러오기",
	-- 		"음악 가져오기","음악 불러오기","음악가져오기","음악불러오기",
	-- 		"music load","song load","music laod"
	-- 	};
	-- 	reply = "로딩중 ⏳";
	-- 	disableDm = true;
	-- 	registeredOnly = true;
	-- 	func = function (replyMsg,message,args,Content)

	-- 	end;
	-- 	onSlash = commonSlashCommand {
	-- 		description = "저장해둔 곡들을 불러옵니다";
	-- 		name = "곡불러오기";
	-- 		optionDescription = "불러올 플레이리스트 이름을 입력하세요";
	-- 		optionRequired = true;
	-- 		optionType = discordia_enchant.enums.optionType.string;
	-- 	};
	-- };
	-- ["save music"] = {
	-- 	commands = {"save","저장","저장하기"};
	-- 	alias = {
	-- 		"곡 가져오기","곡 불러오기","곡가져오기","곡불러오기",
	-- 		"노래 가져오기","노래 불러오기","노래가져오기","노래불러오기",
	-- 		"음악 가져오기","음악 불러오기","음악가져오기","음악불러오기",
	-- 		"music load","song load","music laod"
	-- 	};
	-- 	reply = "로딩중 ⏳";
	-- 	disableDm = true;
	-- 	registeredOnly = true;
	-- 	func = function (replyMsg,message,args,Content)

	-- 	end;
	-- 	onSlash = commonSlashCommand {
	-- 		description = "저장해둔 곡들을 불러옵니다";
	-- 		name = "곡불러오기";
	-- 		optionDescription = "불러올 플레이리스트 이름을 입력하세요";
	-- 		optionRequired = true;
	-- 		optionType = discordia_enchant.enums.optionType.string;
	-- 	};
	-- };
	["search music"] = {
		command = {"search","검색","찾기","find"};
		alias = {
			"music search","search music",
			"song search","search song",
			"music find","find music",
			"song find","find song",
			"곡검색","곡 검색","곡찾기","곡 찾기",
			"음악검색","음악 검색","음악찾기","음악 찾기",
			"노래검색","노래 검색","노래찾기","노래 찾기"
		};
		disableDm = true;
		registeredOnly = eulaComment_music;
		reply = "로딩중 ⏳";
		---@param replyMsg Message
		---@param Content commandContent
		func = function(replyMsg,message,args,Content)
			replyMsg:update(youtubeVideoList.display(Content.rawArgs,Content.user.id));
		end;
		onSlash = commonSlashCommand {
			description = "곡을 검색하고 추가할 곡을 선택합니다!";
			name = "곡검색";
			optionDescription = "검색할 키워드를 입력합니다";
			optionsType = discordia_enchant.enums.optionType.string;
			optionRequired = true;
		};
	};
	["add music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"add","p","play","추가","재생","곡추가"};
		alias = {
			"추가",
			"곡 신청","노래 신청","음악 신청","곡신청","노래신청","음악신청",
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
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content)
			local nth,rawArgs; do
				local contentRaw = Content.rawArgs;
				rawArgs = contentRaw;
				rawArgs,nth = rawArgs:match("(.-) (%d-)$");
				nth = tonumber(nth);
				rawArgs = rawArgs or contentRaw;
			end

			if rawArgs == "" then
				replyMsg:setContent("키워드 또는 url 을 입력해주세요!");
				return;
			end

			-- check users voice channel
			local voiceChannel = message.member.voiceChannel;
			if not voiceChannel then
				replyMsg:setContent("음성 채팅방에 있지 않아요!\n> 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다.");
				return;
			end

			-- get already exist connection
			local guild = message.guild;
			local guildConnection = guild.connection;
			if guildConnection and (guildConnection.channel ~= voiceChannel) then
				replyMsg:setContent("다른 음성채팅방에서 봇을 사용중이에요!\n> 각 서버당 한 채널만 이용할 수 있습니다!");
				return;
			end

			-- get player object from playerClass
			-- ! 여기에는 해결되지 않은 미지의 오류가 있음
			-- ? 아마도 클라이언트가 voiceChannelConnection 을 똑바로 수거하지 못하는듯 함
			-- todo: 이거 고쳐야됨
			local voiceChannelID = voiceChannel:__hash();
			local player = playerForChannels[voiceChannelID];
			if not guildConnection then -- if connections is not exist, create new one
				local handler,err = voiceChannel:join(); --* 여기서 음챗에 들어감
				--* 음챗 연결이 성공적으로 나오면 handler 라는게 비어있으면 안됨
				if not handler then --? 근데 연결이 없다? ㅇㅅㅇ?????? 그대로 끝내버림
					replyMsg:setContent(("채널에 참가할 수 없습니다, 봇이 유효한 권한을 가지고 있는지 확인해주세요!\n```\n%s\n```"):format(err));
					return; --? 다시 시도 같은 구현이 하나도 없어서 그냥 나감
				end
				guild.me:deafen(); -- deafen it selfs
				player = playerClass.new {
					voiceChannel = voiceChannel;
					voiceChannelID = voiceChannelID;
					handler = handler;
				};
			end

			-- if nth is bigger then playerlist len, just adding song on end of list
			if nth and (nth > #player) then
				nth = nil;
			end

			local member = message.member;
			local nickname = member and member.nickname;
			local authorName = message.author.name:gsub("`","\\`");
			local username = nickname and (nickname:gsub("`","\\`") .. (" (%s)"):format(authorName)) or authorName;
			local playlist = youtubePlaylist.getPID(rawArgs);
			if not (rawArgs:match(",") or playlist) then -- once
				local this = {
					message = message;
					url = rawArgs;
					whenAdded = time();
					username = username;
				};
				local passed,err = pcall(player.add,player,this,nth);

				-- when failed to adding song into playlist
				if (not passed) or (not this.info) then
					replyMsg:setContent(err:match(": (.+)") or err);
					-- debug
					logger.errorf("Failed to add music '%s' on player:%s",rawArgs,voiceChannelID);
					logger.errorf("traceback : %s",err)
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
					replyMsg:setContent(("곡 '%s' 을(를)%s 추가했어요! `(%s)`")
						:format(info.title,nth and ((" %d 번째에"):format(nth)) or "",formatTime(info.duration))
					);
				else
					replyMsg:setContent("곡 'NULL' 을(를) 추가했어요! `(0:0)`");
				end
			else -- batch add
				local list;
				local listLen;
				if playlist then
					list = youtubePlaylist.getPlaylist(playlist);
					listLen = list and #list;
					if (not list) or listLen == 0 then
						return replyMsg:setContent("유튜브 플레이 리스트를 가져오는데 실패했어요!");
					end
				else
					list = {};
					for item in rawArgs:gmatch("[^,]+") do
						table.insert(list,item);
					end
					listLen = #list
				end
				local ok = 0;
				local whenAdded = time();
				local duration = 0;
				for index,item in ipairs(list) do
					if not guild.connection then -- if it killed user
						return replyMsg:setConetnt("추가 도중 취소되었어요!");
					end
					--TODO: 도중 취소 기능 (버튼으로) 구현하기
					local this = {
						message = message;
						url = item;
						whenAdded = whenAdded;
						username = username;
					};
					promise.new(player.add,player,this,nth)
						:andThen(function ()
							ok = ok + 1;
							local info = this.info;
							if info then
								duration = duration + (info.duration or 0);
							end
							replyMsg:setContent(youtubePlaylist.display(listLen,index,info.title));
						end)
						:catch(function (err)
							message:reply(("곡 '%s' 를 추가하는데 실패하였습니다\n> %s"):format(tostring(item),err:match(": (.+)")));
						end)
						:wait();
				end
				replyMsg:setContent(("성공적으로 곡 %d 개를 추가하였습니다! `(%s)`")
					:format(ok,formatTime(duration))
				);
			end
		end;
		onSlash = function(self,client)
			local name = self.name;
			client:slashCommand({ --@diagnostic disable-line
				name = "곡추가";
				description = "곡을 추가합니다!";
				options = {
					{
						name = "곡";
						description = "유튜브에 검색될 키워드 또는 URL 을 입력하세요! (',' 을 이용해 곡을 여러개 추가할 수 있습니다)";
						type = discordia_enchant.enums.optionType.string;
						required = true;
					};
					{
						name = "위치";
						description = "곡이 추가될 위치입니다! (비워두면 자동으로 리스트의 맨뒤에 추가됩니다)";
						type = discordia_enchant.enums.optionType.integer;
						required = false;
					};
				};
				callback = function(interaction, params, cmd)
					local pos = params["위치"];
					processCommand(userInteractWarpper(
						("%s %s%s"):format(name,
							params["곡"],
							(pos and pos ~= "") and (", " .. tostring(pos)) or ("")
					),interaction,true));
				end;
			});
		end;
	};
	["join music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"참가","조인","j","join","참여","참가"};
		alias = {
			"참여","참가","조인",
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
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content,self)
			-- check users voice channel
			local voiceChannel = message.member.voiceChannel;
			if not voiceChannel then
				return replyMsg:update(self.joinFailNoChannel);
			end

			-- get already exist connection
			local guild = message.guild;
			local guildConnection = guild.connection;
			if guildConnection then
				if guildConnection.channel ~= voiceChannel then
					return replyMsg:update(self.joinFailOtherChannel);
				end
				return replyMsg:update(self.joinedAlready);
			end

			-- get player object from playerClass
			local voiceChannelID = voiceChannel:__hash();
			local handler = voiceChannel:join();
			if not handler then
				replyMsg:update(self.joinFail);
				return;
			end
			guild.me:deafen(); -- deafen it selfs
			playerClass.new {
				voiceChannel = voiceChannel;
				voiceChannelID = voiceChannelID;
				handler = handler;
			};
			return replyMsg:update(self.joinSuccess);
		end;
		onSlash = commonSlashCommand {
			description = "음성 채팅방에 참가합니다 (/곡추가 명령어를 사용하면 이 명령어가 자동으로 사용됩니다)";
			name = "곡참가";
			noOption = true;
		};
		joinFailNoChannel = buttons.action_remove "음성 채팅방에 있지 않습니다! 이 명령어를 사용하려면 음성 채팅방에 있어야 합니다!";
		joinFailOtherChannel = buttons.action_remove "다른 음성채팅방에서 봇을 사용중입니다, 각 서버당 한 채널만 이용할 수 있습니다!";
		joinedAlready = buttons.action_remove "이미 음성채팅에 참가했습니다!";
		joinSuccess = buttons.action_remove "성공적으로 음성채팅에 참가했습니다!";
		joinFail = buttons.action_remove "채널에 참가할 수 없습니다, 봇이 유효한 권한을 가지고 있는지 확인해주세요!"
	};
	["list music"] = {
		disableDm = true;
		command = {"l","ls","list","q","queue","플리","리스트","큐","목록"};
		alias = {
			"리스트",
			"노래목록","노래페이지","노래대기열","노래리스트","노래순번","노래페이지",
			"노래 목록","노래 페이지","노래 대기열","노래 리스트","노래 순번","노래 페이지",
			"곡목록","곡페이지","곡대기열","곡리스트","곡순번","곡페이지",
			"곡 목록","곡 페이지","곡 대기열","곡 리스트","곡 순번","곡 페이지",
			"음악목록","음악페이지","음악대기열","음악리스트","음악순번","음악페이지",
			"음악 목록","음악 페이지","음악 대기열","음악 리스트","음악 순번","음악 페이지",
			"재생목록","재생 목록","신청 목록","신청목록","플리",
			"플레이리스트","플레이 리스트",
			"list music","queue music","music queue","music list",
			"list song","queue song","song queue","song list",
			"song 리스트","music 리스트","song 대기열","song 리스트",
			"list 곡","list 음악","list 노래"
		};
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;
			local page = tonumber(rawArgs) or tonumber(rawArgs:match("%d+")) or 1;
			replyMsg:update(playerClass.showList(Content.guild,page))
		end;
		onSlash = commonSlashCommand {
			description = "곡 리스트를 봅니다!";
			name = "곡리스트";
			optionDescription = "리스트의 페이지를 입력하세요! (비워두면 1 페이지를 보여줍니다)";
			optionsType = discordia_enchant.enums.optionType.integer;
			optionRequired = false;
		};
	};
	["song24"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"24","24h"};
		alias = {
			"song 24","music 24","music24","song 24h","song24h","music24h","music 24h",
			"노래24","노래 24","노래 24시","노래24시","노래24시간","노래 24시간",
			"음악24","음악 24","음악 24시","음악24시","음악24시간","음악 24시간",
			"곡24","곡 24","곡 24시","곡24시","곡24시간","곡 24시간"
		};
		reply = "로딩중 ⏳";
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
				playerClass.voiceChannelLeave(Content.user,voiceChannel); -- check there is no users
			end
		end;
		onSlash = commonSlashCommand {
			description = "24 시간 음악 기능을 켭니다! (이 모드가 켜지면 봇이 자동으로 음성채팅을 나가지 않습니다)";
			name = "곡24";
			optionDescription = "24 시간 모드를 켤지 끌지 결정해주세요!";
			optionRequired = false;
			optionChoices = {
				{
					name = "24 시간 모드를 켭니다!";
					value = "켜기";
				};
				{
					name = "24 시간 모드를 끕니다!";
					value = "끄기";
				};
			};
		};
	};
	["loop"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"루프","loop","looping","lp","lop"};
		alias = {
			"반복재생",
			"looping","looping toggle","toggle looping","플레이리스트반복","플레이 리스트 반복","플리 반복",
			"플리반복","플리루프","플리 루프","플리반복하기","플리 반복하기",
			"재생목록 반복하기","재생목록반복하기","재생목록반복","재생목록 반복","재생목록루프","재생목록 루프",
			"노래반복","노래루프","노래반복하기","노래 반복","노래 루프","노래 반복하기",
			"음악반복","음악루프","음악반복하기","음악 반복","음악 루프","음악 반복하기",
			"곡반복","곡루프","곡반복하기","곡 반복","곡 루프","곡 반복하기",
		};
		reply = "로딩중 ⏳";
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
		onSlash = commonSlashCommand {
			description = "플레이 리스트 루프모드를 켭니다! (이 모드가 켜지면 다 들은 곡은 뒤에 다시 추가됩니다)";
			name = "곡루프";
			optionDescription = "루프 모드를 켤지 끌지 결정해주세요!";
			optionRequired = false;
			optionChoices = {
				{
					name = "루프모드를 켭니다!";
					value = "켜기";
				};
				{
					name = "루프모드를 끕니다!";
					value = "끄기";
				};
			};
		};
	};
	["음악"] = {
		reply = "명령어를 처리하지 못했어요!\n> 음악 기능 도움이 필요하면 '미나 음악 도움말' 을 입력해주세요";
	};
	["음악 도움말"] = {
		alias = {"도움말 음악","도움말 음악봇","음악 사용법","음악 사용법 알려줘","음악사용법","음악 도움말 보여줘","음악 help","음악도움말","music help","help music","music 도움말"};
		reply = help;
		sendToDm = "개인 메시지로 도움말이 전송되었습니다!";
	};
	["remove music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"지워","지워기","없에기","없에","제거","재거","빼기","rm","remove","r"};
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
		reply = "로딩중 ⏳";
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
		onSlash = commonSlashCommand {
			description = "원하는 곡을 제거합니다!";
			name = "곡제거";
			optionDescription = "건너뛸 곡의 이름의 일부 또는 번째를 입력하세요 (여러 곡을 삭제하는 경우 ',' 을 이용하세요)";
		};
	};
	["skip music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"넘겨","넘기기","건너뛰기","스킵","sk","skip","s"};
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
		reply = "로딩중 ⏳";
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
			new = new and new.info;
			new = new and new.title
			local nowPlaying = (new and ("다음으로 재생되는 곡은 '%s' 입니다\n"):format(new) or "");
			replyMsg:setContent( -- !!REVIEW NEEDED!!
				rawArgs == 1 and
				(("성공적으로 곡 '%s' 를 스킵하였습니다 %s%s"):format(tostring(lastOne and lastOne.info and lastOne.info.title),nowPlaying,loopMsg)) or
				(("성공적으로 곡 %s 개를 스킵하였습니다! %s%s"):format(tostring(rawArgs),nowPlaying,loopMsg))
			);
		end;
		onSlash = commonSlashCommand {
			description = "원하는 갯수만큼의 곡을 스킵합니다! (루프모드의 경우 스킵된 곡은 다시 뒤에 추가됩니다, 없에야 하는 경우 /곡제거 를 이용하세요)";
			name = "곡스킵";
			optionDescription = "건너뛸 곡의 갯수를 입력하세요! (비워두면 한개의 곡만 스킵합니다)";
			optionsType = discordia_enchant.enums.optionType.integer;
			optionRequired = false;
		};
	};
	["pause music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"멈춰","멈처","멈춤","pause","멈쳐"};
		alias = {
			"일시정지","일시 정지","정지","멈춰","멈쳐","멈처",
			"음악 일시정지","음악 일시 정지",
			"노래 일시정지","음악 일시 정지",
			"곡 일시정지","곡 일시 정지",
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
		reply = "로딩중 ⏳";
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
		onSlash = commonSlashCommand {
			description = "곡을 잠시 멈춥니다! (/곡재개 를 이용해 다시 재개할 수 있어요)";
			name = "곡멈춤";
			noOption = true;
		};
	};
	["stop music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"그만","종료","나가","끄기","off","stop","leave","kill"};
		alias = {
			"나가",
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
		reply = "로딩중 ⏳";
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
		onSlash = commonSlashCommand {
			description = "모든 음악을 종료하고 통화방에서 나갑니다!";
			name = "곡종료";
			noOption = true;
		};
	};
	["now music"] = {
		disableDm = true;
		command = {"현재","재생중","지금곡","지금노래","n","np","nowplay","nowplaying","nplay","nplaying","nowp"};
		alias = {
			"현재재생","지금재생","현재 재생","지금 재생","현재 곡","현재 음악","현재 노래","지금 곡","지금 음악","지금 노래",
			"현재곡","현재음악","현재노래","지금곡","지금음악","지금노래","지금재생중",
			"지금 재생중","now playing","music now","song now","playing now","now play","nowplaying"
		};
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content)
			replyMsg:update(playerClass.showSong(Content.guild));
		end;
		onSlash = commonSlashCommand {
			description = "현재 재생중인 곡의 정보를 봅니다!";
			name = "현재재생";
			noOption = true;
		};
	};
	["info music"] = {
		disableDm = true;
		command = {"정보","i","info","nowplay","nowplaying","nplay","nplaying","nowp"};
		alias = {
			"곡정보","곡 정보","info song","song info","music info","info music","곡 자세히보기",
			"곡자세히보기","곡설명","곡 설명","song description","description song"
		};
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content)
			local this = Content.rawArgs;
			this = tonumber(this) or tonumber(this:match("%d+")) or 1;
			replyMsg:update(playerClass.showSong(Content.guild,this));
		end;
		onSlash = commonSlashCommand {
			description = "해당 번째의 곡 정보를 봅니다!";
			name = "곡정보";
			optionDescription = "곡 번째를 입력하세요";
			optionsType = discordia_enchant.enums.optionType.integer;
		};
	};
	["resume music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"재개","resume"};
		alias = {
			"다시재생","일시정지 해재","일시정지 끄기",
			"다시 재생","재개","일시 정지 해재",
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
		reply = "로딩중 ⏳";
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

			-- unpause!
			player:setPaused(false);
			replyMsg:setContent("성공적으로 음악을 재개했습니다!");
		end;
		onSlash = commonSlashCommand {
			description = "멈춘 곡을 다시 재개합니다!";
			name = "곡재개";
			noOption = true;
		};
	};
	["seek music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"time","jump","t","jp","위치","시간","seek","timestamp"};
		alias = {
			"timestamp music","music timestamp","music seek",
			"song music","song timestamp","song seek","seek song",
			"곡위치","곡 위치","곡 시간","곡시간","곡 시간 이동","곡 시간이동","곡시간 이동","곡시간이동","곡 시간 조정","곡 시간조정","곡시간 조정","곡시간조정",
			"곡타임스템프","곡 타임스템프","곡 타임스템프 조정","곡 타임스템프조정","곡타임스템프 조정","곡타임스템프조정","곡 타임스템프 이동","곡 타임스템프이동","곡타임스템프 이동","곡타임스템프이동",
			"음악위치","음악 위치","음악 시간","음악시간","음악 시간 이동","음악 시간이동","음악시간 이동","음악시간이동","음악 시간 조정","음악 시간조정","음악시간 조정","음악시간조정",
			"음악타임스템프","음악 타임스템프","음악 타임스템프 조정","음악 타임스템프조정","음악타임스템프 조정","음악타임스템프조정","음악 타임스템프 이동","음악 타임스템프이동","음악타임스템프 이동","음악타임스템프이동",
			"노래위치","노래 위치","노래 시간","노래시간","노래 시간 이동","노래 시간이동","노래시간 이동","노래시간이동","노래 시간 조정","노래 시간조정","노래시간 조정","노래시간조정",
			"노래타임스템프","노래 타임스템프","노래 타임스템프 조정","노래 타임스템프조정","노래타임스템프 조정","노래타임스템프조정","노래 타임스템프 이동","노래 타임스템프이동","노래타임스템프 이동","노래타임스템프이동"
		};
		reply = "로딩중 ⏳";
		func = function(replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs or "";

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
			local nowPlaying = player and player.nowPlaying;
			if not player then
				replyMsg:setContent("오류가 발생하였습니다\n> 캐싱된 플레이어 오브젝트를 찾을 수 없음");
				return;
			elseif not nowPlaying then -- if it is not playing then
				replyMsg:setContent("실행중인 음악이 없습니다!");
				return;
			end

			-- get time mode and timestamp with to move
			local handler = player.handler;
			local getElapsed = handler and handler.getElapsed;
			local elapsed = tonumber(getElapsed and getElapsed());
			elapsed = elapsed and (elapsed / 1000);
			local mode, hours, minutes, seconds;
			local timestamp; do
				do
					mode, hours, minutes, seconds = rawArgs:match("([%+%-]?) -(%d+) -: -(%d+) -: -(%d+)");
					hours = tonumber(hours);
					minutes = tonumber(minutes);
					seconds = tonumber(seconds);
					if hours and minutes and seconds then
						timestamp = (hours * hourInSecond) + (minutes * minuteInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, minutes, seconds = rawArgs:match("([%+%-]?) -(%d+) -: -(%d+)");
					minutes = tonumber(minutes);
					seconds = tonumber(seconds);
					if minutes and seconds then
						timestamp = (minutes * minuteInSecond) + seconds;
					end
				end
				if not timestamp then
					mode, hours, minutes, seconds = rawArgs:match("([%+%-]?) -(%d+) -시간 -(%d+) -분 -(%d+) -초");
					hours = tonumber(hours);
					minutes = tonumber(minutes);
					seconds = tonumber(seconds);
					if hours and minutes and seconds then
						timestamp = (hours * hourInSecond) + (minutes * minuteInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, hours, minutes, seconds = rawArgs:match("([%+%-]?) -(%d+) -시 -(%d+) -분 -(%d+) -초");
					hours = tonumber(hours);
					minutes = tonumber(minutes);
					seconds = tonumber(seconds);
					if hours and minutes and seconds then
						timestamp = (hours * hourInSecond) + (minutes * minuteInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, minutes, seconds = rawArgs:match("([%+%-]?) -(%d+) -분 -(%d+) -초");
					minutes = tonumber(minutes);
					seconds = tonumber(seconds);
					if minutes and seconds then
						timestamp = (minutes * minuteInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, hours, seconds = rawArgs:match("([%+%-]?) -(%d+) -시간 -(%d+) -초");
					seconds = tonumber(seconds);
					hours = tonumber(hours);
					if hours and seconds then
						timestamp = (hours * hourInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, hours, seconds = rawArgs:match("([%+%-]?) -(%d+) -시 -(%d+) -초");
					seconds = tonumber(seconds);
					hours = tonumber(hours);
					if hours and seconds then
						timestamp = (hours * hourInSecond) + (seconds);
					end
				end
				if not timestamp then
					mode, hours, minutes = rawArgs:match("([%+%-]?) -(%d+) -시간 -(%d+) -분");
					minutes = tonumber(minutes);
					hours = tonumber(hours);
					if minutes and hours then
						timestamp = (hours * hourInSecond) + (minutes * minuteInSecond);
					end
				end
				if not timestamp then
					mode, hours, minutes = rawArgs:match("([%+%-]?) -(%d+) -시 -(%d+) -분");
					minutes = tonumber(minutes);
					hours = tonumber(hours);
					if minutes and hours then
						timestamp = (hours * hourInSecond) + (minutes * minuteInSecond);
					end
				end
				if not timestamp then
					mode, minutes = rawArgs:match("([%+%-]?) -(%d+) -분");
					minutes = tonumber(minutes);
					if minutes then
						timestamp = (minutes * minuteInSecond);
					end
				end
				if not timestamp then
					mode, hours = rawArgs:match("([%+%-]?) -(%d+) -시간");
					hours = tonumber(hours);
					if hours then
						timestamp = (hours * hourInSecond);
					end
				end
				if not timestamp then
					mode, hours = rawArgs:match("([%+%-]?) -(%d+) -시");
					hours = tonumber(hours);
					if hours then
						timestamp = (hours * hourInSecond);
					end
				end
				if not timestamp then
					mode, seconds = rawArgs:match("([%+%-]?) -(%d+) -초");
					seconds = tonumber(seconds);
					if seconds then
						timestamp = (seconds * minuteInSecond);
					end
				end
				if not timestamp then
					local multiple;
					mode,timestamp,multiple = rawArgs:match("([%+%-]?) -(%d+) -([hHsSmM]?)");
					timestamp = tonumber(timestamp);
					if timestamp then
						if multiple == "h" or multiple == "H" then
							timestamp = timestamp * hourInSecond;
						elseif multiple == "m" or multiple == "M" then
							timestamp = timestamp * minuteInSecond;
						end
					end
				end
			end
			if mode and elapsed then
				if mode == "+" then
					timestamp = elapsed + timestamp;
				elseif mode == "-" then
					timestamp = elapsed - timestamp;
				end
			end

			-- checking time
			local duration;
			if not timestamp then
				replyMsg:setContent("원하는 시간을 입력해주세요!");
				return;
			elseif timestamp < 0 then
				replyMsg:setContent("시간은 0 보다 작을 수 없습니다!");
				return;
			else
				local info = nowPlaying.info;
				duration = tonumber(info.duration);
				if duration and (duration < timestamp) then
					replyMsg:setContent(
						("곡의 길이보다 더 앞으로 갈 수 없습니다\n> 곡 길이는 %s 입니다!")
							:format(player.formatTime(duration))
					);
					return;
				end
			end

			-- seek!
			player:seek(timestamp);
			replyMsg:update {
				embed = {
					title = "재생 위치를 이동했습니다!";
					description = duration and player.seekbar(timestamp,duration);
					footer = player:getStatusText();
				};
				content = ("%s 로 이동!"):format(player.formatTime(timestamp));
			};
		end;
		onSlash = commonSlashCommand {
			description = "재생 위치를 변경합니다!";
			name = "곡시간";
			optionDescription = "더하려면 +, 빼려면 - 를 붇이고 다음과 같이 시간을 입력합니다 시간:분:초 (예 +1:10 -1:10 1:10 ...)";
		};
	};
	["export music"] = {
		registeredOnly = eulaComment_music;
		disableDm = true;
		command = {"저장","export","e"};
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
		reply = "로딩중 ⏳";
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
		onSlash = commonSlashCommand {
			description = "곡을 저장합니다!";
			name = "곡저장";
			noOption = true;
		};
	};
};
return export;
