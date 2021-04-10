local iLogger = require "src/lib/log";
iLogger = {
	["trace"] = iLogger.trace;
	["debug"] = iLogger.debug;
	["info"] = iLogger.info;
	["warn"] = iLogger.warn;
	["error"] = iLogger.error;
	["fatal"] = iLogger.fatal;
};
local function main()
--#region : 설명글/TODO 헤더
--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

네이버 사전 검색 봇
https://discord.com/oauth2/authorize?client_id=828894481289969665&permissions=2147871808&scope=bot

TODO: DM 에다가 명령어 쓰기 막기
TODO: 미나야 사전 <단어> 만들기
TODO: 도움말 만들기
TODO: 사전 Json 인코딩을 없에고 그냥 바로 테이블 넘기기
TODO: coro http 손절치기 (luasocket 쓰자)

TODO: EXTEND 고치기...
TODO: 지우기 명령,강퇴 명령 같은거 만들기
]]
--#endregion : 설명글/TODO
--#region : 디코 모듈 임포트
iLogger.info("Wait for discordia");
local corohttp = require "coro-http";
local json = require "json";
local discordia = require "discordia";
local enums = discordia.enums;
local client = discordia.Client();
local function StartBot(botToken)
	-- 토큰주고 시작
	iLogger.info("Starting bot ...");
	client:run(("Bot %s"):format(botToken));
	client:setGame("'미나야 도움말' 을 이용해 도움말을 얻거나 '미나야 <할말>' 을 이용해 미나와 대화하세요!");
	return;
end
local function reloadBot()
	iLogger.info("Try restarting ...");
	client:setGame("재시작중...");
	os.exit(101);
end
--#endregion : Discord Module
--#region : 나눠진 모듈 합치기
local commandHandle = require "src/lib/commandHandle"; -- 커맨드 구조 처리기
local cRandom = require "src/lib/cRandom"; -- LUA 렌덤 핸들러
local strSplit = require "src/lib/stringSplit"; -- 글자 분해기
local urlCode = require "src/lib/urlCode"; -- 한글 URL 인코더/디코더
local makeId = require "src/lib/makeId"; -- ID 만드는거

-- 네이버 사전
local naverDictEmbed = require "src/lib/naverDict/embed"; -- 네이버 사전 임배드 렌더러
local naverDictSearch = require "src/lib/naverDict/naverDictSearch"; -- 네이버 사전 API 핸들러
naverDictSearch:setCoroHttp(corohttp):setJson(json); -- 네이버 사전 셋업

-- 유튜브 검색
local youtubeEmbed = require "src/lib/youtube/embed"
local youtubeSearch = require "src/lib/youtube/youtubeSearch"; -- 유튜브 검색
youtubeSearch:setCoroHttp(corohttp):setJson(json); -- 유튜브 검색 셋업
--#endregion : 나눠진 모듈 합치기
--#region : 설정파일 불러오기
local json = require("json");
local LoadData = function (Pos)
	local File = io.open(Pos,"r");
	local Raw = File:read("a");
	File:close();
	return json.decode(Raw);
end
local SaveData = function (Pos,Data)
	local File = io.open(Pos,"w");
	File:write(json.encoding(Data));
	File:close();
	return;
end

local ACCOUNTData = LoadData("data/ACCOUNT.json");
local History = LoadData("data/history.json");
local dirtChannels = LoadData("data/dirtChannels.json");
local loveLeaderstats = LoadData("data/loveLeaderstats.json");

local EULA do -- 사용 약관
	local File = io.open("data/EULA","r");
	EULA = File:read("a");
	File:close();
end
--#endregion : load settings from data file
--#region : 반응, 프리픽스, 설정, 커맨드 등등
local Admins = { -- 관리 명령어 권한
	["367946917197381644"] = "쿼리";
	["647101613047152640"] = "눈송이";
	["415804982764371969"] = "상어";
};
local prefixs = { -- 명령어 맨앞 글자 (접두사)
	[1] = "미나야";
	[2] = "미나";
	[3] = "미나야.";
	[4] = "미나!";
	[5] = "미나야!";
	[6] = "미나야...";
	[7] = "미나야..",
	[8] = "미나..."
};
local prefixReply = { -- 그냥 미나야 하면 답
	"미나는 여기 있어요!","부르셨나요?","넹?",
	"왜요 왜요 왜요?","심심해요?","네넹","미나에요",
	"~~어쩌라고~~","Zzz... 아! 안졸았어요",
	"Zzz... 아! 안졸았어요 ~~아 나도 좀 잠좀 자자 인간아~~","네!"
};
local unknownReply = {
	"(갸우뚱?)","무슨 말이에요?","네?",":thinking:"
};
--[[
	alias = table[array]/str; -- 다른 명령어로도 똑같은 기능 내도록
	reply = table[array]/str; -- 콜백
	func  = function(replyMsg,message,args,{
		rawCommandText = string; -- 접두사를 제외한 스트링
		prefix = prefix; -- 접두사(사용된)
		rawArgs = rawArgs; -- args 스트링 (커스텀 분석용)
		rawCommandName = rawCommandName; -- 커맨드 이름 (앞에 무시된거 포함됨)
		self = Command; -- 지금 이 커맨드 개체를 반환
	}); -- 함수
	reply = func(message,args,{위에랑같음});

	변수들
	{%:UserName:%} : 유저 이름으로 대채

	...
	와
	무야호
	미나야 3개 지워
	유튜브검색
	트위터/유튜브/인스타 같은거 바로가기
	살려줘, 잠안와, 학원, 학교, 야자, ㅈ까, 바보, 공부 추가 예정
	ㅄ,ㅂㅅ,병신
	욕은 나빠요!
	ㅗ 랑 ㅋ 반복 추가할 예정
	무계,키,성별,나이,생일 이런거
	묻는거, 스파게티,토스트 같은 음식류도
	학과별로 오지 마세요 쓰기
	스트리머마다 추가
	L 하면 L (+ /lobby, /leave)
	lol 도
	젤다 드립
	삼성.LG 기업들 말하면 피드백
	ㄱㄷ
	착해, 이뻐, 귀여워 같은 칭찬단어 만들고 그거 호감도 늘리는거 만들기
	맛있지 먹었다
	ㅇ0ㅇ
	oOo
	ㅇOㅇ
	알파카 : 옆에서 커피마신넘 학원간넘
	깔끔하네
	시끄러
	대통령마다 반응
	롤, 게임
	사람 크시는 사람이 아니지만요...
	살려줘 무, 무슨 일 있어요?!
	힘들어 언젠가 이 힘든 날조차 잊히는 행복이 진성트수님께 오리라고 믿어 의심치 않을 게요! 파이팅! 
	영상편집
	에펙 (에이펙스 ㄹㅈㄷ)
	검열
	구글,네이버,유튜브,위키피디아,나무위키 검색명령어
	안녕 하면 시간까지 말한다
]]
local function loadCommandFiles()
	
end

local commands,commandsLen;
commands,commandsLen = commandHandle.encodeCommands({
	-- 특수기능
	["제작진"] = {
		alias = {"만든이들","크래딧","크레딧","누가만듬?","작자","제작자"};
		reply = "**총괄**/코드 : 쿼리\n프로필/아이디어 : **상아리**,별이(블스상)\n작명 : 눈송이\n\n테스팅/아이디어 : 팥죽";
	};
	["나이"] = {
		func = function (_,message)
			local Year = tostring(math.floor((10000*(os.time() - ACCOUNTData.BirthdayDay) / 31536000))/10000);
			message:reply(("미나는 %s 살이에요"):format(tostring(Year)));
		end;
	};
	["유튜브"] = {
		alias = {"유튜브검색","유튜브찾기","유튜브탐색","유튭찾기","유튭","유튭검색"};
		reply = "잠시만 기다려주세요... (검색중)";
		func = function(replyMsg,message,args,Content)
			local Body,KeywordURL = youtubeSearch.searchFromYoutube(Content.rawArgs);
			
		end;
	};
	["사전"] = {
		reply = "잠시만 기다려주세요... (검색중)";
		alias = {
			"dict","Dict","Dictionary","영어찾기",
			"단어검색","단어찾기","영어검색",
			"영단어검색","영단어찾기","dictionary",
			"단어찾아","영단어찾아","단어찾아줘",
			"영단어찾아줘","영단어","사전찾기",
			"사전검색","사전찾기"
		};
		func = function(replyMsg,message,args,Content)
			local searchKey = Content.rawArgs;
			if (not searchKey) or (searchKey == "") or (searchKey == " ") then
				replyMsg:setContent("잘못된 명령어 사용법이에요!\n\n**올바른 사용 방법**\n> 미나야 사전 <검색할 단어>");
			end

			local body,url = naverDictSearch.searchFromNaverDirt(Content.rawArgs,ACCOUNTData);
			local embed = json.decode(naverDictEmbed:Embed(Content.rawArgs,url,body));
			replyMsg:setEmbed(embed.embed);
			replyMsg:setContent(embed.content);
			return;
		end;
	};
	["지워"] = {
		alias = {"지우개","지워봐","지워라","지우기"};
		func = function(replyMsg,message,args,Content)
			local RemoveNum = tonumber(Content.rawArgs);
			if (not RemoveNum) or type(RemoveNum) ~= "number" then
				message:reply("잘못된 명령어 사용법이에요!\n\n**올바른 사용 방법**\n> 미나야 지워 <지울 수>\n지울수 : 2 에서 100 까지의 숫자 (정수)");
				return;
			elseif (RemoveNum > 100) or (RemoveNum < 2) then -- 
				message:reply("잘못된 명령어 사용법이에요!\n\n<지울 수>는 2에서 100까지의 숫자이어야 합니다");
				return;
			elseif (RemoveNum % 1) ~= 0 then -- 정수인지 유리수(또는 실수) 인지 확인
				message:reply("잘못된 명령어 사용법이에요!\n\n<지울 수> 는 정수이어야 합니다 (소숫점 X)");
				return;
			end

			message.channel:bulkDelete(message.channel:getMessagesBefore(message.id,RemoveNum));
			message:reply(("최근 메시지 %s개를 지웠어요!"):format(RemoveNum));
			message:delete();
			return;
		end;
	};
	["몸무계"] = {
		alias = {"무계","얼마나무거워"};
		reply = "95.2KB";
	};
	["미나"] = {
		alias = {"미나야","미나!","미나...","미나야...","미나..","미나야..","미나.","미나야.","미나야!"};
		reply = prefixReply;
	};
	["반응"] = {
		alias = {"반응수","반응 수","반응 갯수"};
		reply = "새어보고 있어요...";
		func = function (replyMsg)
			replyMsg:setContent(("미나가 아는 반응은 %d개 이에요!"):format(commandsLen));
		end;
	};
	--["노래좀"] = {
	--	alias = {"노래추천좀","노래추천"};
	--	reply = {};
	--};
});
--#endregion : 반응, 프리픽스, 설정
--#region : 메인 파트
local dirtChannels = dirtChannels.channels;
client:on('messageCreate', function(message)
	local User = message.author;
	local Text = message.content;
	local Channel = message.channel;

	-- 유저가 봇인경우
	if User.bot --[[or (channel.type ~= enums.channelType.text)]] then
		return;
	end
	-- 하드코딩된 관리 명령어)
	if Admins[User.id] then
		if (Text == "!!!restart" or Text == "!!!reload" or Text == "미나야 리로드") then
			--다시시작
			iLogger.info("Restarting ...");
			message:reply('> 재시작중 . . . (2초 내로 완료됩니다)');
			reloadBot();
		elseif (Text == "!!!pull" or Text == "!!!download" or Text == "미나야 변경적용") then
			-- PULL (github 로 부터 코드를 다운받아옴)
			local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 받는중 . . .');
			--os.execute("git fetch"); -- git 에서 변동사항 가져오기
			os.execute("git -C src pull"); -- git 에서 변동사항 가져와 적용하기
			os.execute("timeout /t 3"); -- 너무 갑자기 활동이 일어나는걸 막기 위해 쉬어줌
			msg:setContent('> 적용중 . . . (2초 내로 완료됩니다)');
			reloadBot(); -- 리스타팅
		elseif (Text == "!!!push" or Text == "!!!upload" or Text == "미나야 깃헙업로드") then
			local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 코드를 업로드중 . . .');
			os.execute("git -C src add .");
			os.execute("git -C src commit -m 'update'");
			os.execute("git -C src push");
			msg:setContent('> 완료!');
			return;
		elseif (Text == "!!!stop" or Text == "!!!kill" or Text == "미나야 코드셧다운") then
			message:reply('> 프로그램 죽이는중 . . .');
			os.exit(100);
		end
	end
	-- 사전
	if dirtChannels[Channel.id] and string.sub(Text,1,1) == "!" then
		Text = string.sub(Text,2,-1);
		local newMsg = message:reply('> 찾는중 . . .');
		local body,url = naverDictSearch.searchFromNaverDirt(Text,ACCOUNTData);
		local data = json.decode(naverDictEmbed:Embed(Text,url,body));
		newMsg:update(data);
	end

	-- 명령어

	-- prefix : 접두사
	-- rawCommandText : 접두사 뺀 커맨드 전채
	-- splitCommandText : rawCommandText 를 \32 로 분해한 array
	-- rawCommandText : 커맨드 이름 (앞부분 다 자르고)
	-- CommandName : 커맨드 이름
	-- | 찾은 후 (for 루프 뒤)
	-- Command : 커맨드 개체 (찾은경우)

	-- 모든 접두사로 작동하도록 루프
	for _,prefix in pairs(prefixs) do
		-- 만약 접두사와 글자가 일치하는경우 반응 달기
		if prefix == Text then
			message:reply(prefixReply[cRandom(1,#prefixReply)]);
			break;
		end
		local prefix = prefix .. "\32"; -- 맨 앞 실행 접두사

		-- 커맨드 분석
		if string.sub(Text,1,#prefix) == prefix then -- 접두사가 일치함을 확인함

			-- 알고리즘 작성
			-- 커맨드 찾기
			-- 단어 분해 후 COMMAND DICT 에 색인시도
			-- 못찾으면 다시 넘겨서 뒷단어로 넘김
			-- 찾으면 넘겨서 COMMAND RUN 에 TRY 던짐

			local rawCommandText = string.sub(Text,#prefix+1,-1); -- 접두사 뺀 글자
			local splitCommandText = strSplit(rawCommandText,"\32");
			local CommandName,Command,rawCommandName;

			-- (커맨드 색인 1 차시도) 띄어쓰기를 포함한 명령어를 검사할 수 있도록 for 루프 실행
			-- 찾기 찾기 찾기
			-- 찾기 찾기
			-- 찾기
			-- 이런식으로 계단식 찾기를 수행
			for Len = #splitCommandText,1,-1 do
				local Text = "";
				for Index = 1,Len do
					Text = Text .. splitCommandText[Index];
				end
				local TempCommand = commandHandle.findCommandFrom(commands,Text);
				if TempCommand then
					CommandName = Text;
					rawCommandName = Text;
					Command = TempCommand;
					break;
				end
			end

			-- (커맨드 색인 2 차시도) 커맨드 못찾으면 단어별로 나눠서 찾기 시도
			-- 찾기 찾기 찾기
			-- 부분부분 다 나눠서 찾기
			if not Command then
				for FindPos,Text in pairs(splitCommandText) do
					Command = commandHandle.findCommandFrom(commands,Text);
					if Command then
						CommandName = "";
						rawCommandName = Text;
						for Index = 1,FindPos do
							CommandName = CommandName .. splitCommandText[Index];
						end
						break;
					end
				end
			end

			--local CommandName = string.match(rawCommandText,"(.-)\32") or rawCommandText; -- 커맨드 이름
			--local Command = commandHandle.findCommandFrom(commands,CommandName); -- 커맨드 검색

			if Command == nil then
				-- 커맨드 찾지 못함
				message:reply(unknownReply[cRandom(1,#unknownReply)]);
				-- 반응 없는거 기록하기
				local noneRespText = io.open("src/log/noneRespTexts.txt","a");
				noneRespText:write("\n" .. Text);
				noneRespText:close();
			else
				-- 커맨드 찾음 (실행)
				local func = Command.func; -- 커맨드 함수 가져오기
				local replyText = Command.reply; -- 커맨드 리플(답변) 가져오기
				local rawArgs,args; -- 인수 (str,띄어쓰기 단위로 나눔 array)
				replyText = (
					(type(replyText) == "table") -- 커맨드 답변이 여러개면 하나 뽑기
					and (replyText[cRandom(1,#replyText)])
					or replyText
				);
				-- 만약 답변글이 함수면 (지금은 %s 시에요 처럼 쓸 수 있도록) 실행후 결과 가져오기
				if type(replyText) == "function" then
					rawArgs = string.sub(rawCommandText,#CommandName+2,-1);
					args = strSplit(rawArgs,"\32");
					replyText = replyText(
						message,args,{
							rawCommandText = rawCommandText; -- 접두사를 지운 커맨드 스트링
							prefix = prefix; -- 접두사(확인된)
							rawArgs = rawArgs; -- args 를 str 로 받기 (직접 분석용)
							rawCommandName = rawCommandName;
							self = Command;
						}
					);
				end
				--replyText = (
				--	type(replyText) == "function" and
				--	replyText(message,args,{
				--	}) or replyText
				--);
				local replyMsg; -- 답변 오브잭트를 담을 변수
				if replyText then -- 만약 답변글이 있으면
					-- 답변 주기
					replyMsg = message:reply(commandHandle.formatReply(replyText,{
						Msg = message;
						User = User;
						Channel = Channel;
					}));
				end
				-- func (replyMsg,message,args,EXTENDTable);
				if func then -- 만약 커맨드 함수가 있으면
					-- 커맨드 함수 실행
					rawArgs = rawArgs or string.sub(rawCommandText,#CommandName+2,-1);
					args = strSplit(rawArgs,"\32");
					func(replyMsg,message,args,{
						rawCommandText = rawCommandText; -- 접두사를 지운 커맨드 스트링
						prefix = prefix; -- 접두사(확인된)
						rawArgs = rawArgs; -- args 를 str 로 받기 (직접 분석용)
						rawCommandName = rawCommandName;
						self = Command;
					});
				end
			end
			break;
		end
	end
end);
-- Start bot
StartBot(ACCOUNTData.botToken);
--#endregion : 메인 파트
end

-- 버그 핸들링 (충돌시 발생하므로 이 내부에서는 discordia 가 응답하지 않을 수 있음)
xpcall(main,function (err)
	iLogger.fatal(err);
	local err = (tostring(err) .. "\n");
	local dat = os.date("*t"); 
	local fnm = ("src/log/err/%dY_%dM_%dD"):format(dat.year,dat.month,dat.day);

	iLogger.debug(("Error log was saved in err folder (%s)"):format(fnm));
	local fil = io.open(fnm,"a");
	fil:write(err);
	fil:close();
end);
