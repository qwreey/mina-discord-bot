
--#region : 설명글/TODO
--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

네이버 사전 검색 봇
https://discord.com/oauth2/authorize?client_id=828894481289969665&permissions=2147871808&scope=bot

TODO: 미나야 사전 <단어> 만들기
TODO: 도움말 만들기
TODO: 사전 Json 인코딩을 없에고 그냥 바로 테이블 넘기기
TODO: coro http 손절치기 (luasocket 쓰자)

TODO: EXTEND 고치기...
TODO: 지우기 명령,강퇴 명령 같은거 만들기
]]
--#endregion : 설명글/TODO
--#region : 디코 모듈 임포트
print("Wait for discordia")
local json = require "json";
local corohttp = require "coro-http";
local discordia = require "discordia";
local enums = discordia.enums;
local client = discordia.Client();
local function StartBot(botToken)
	-- 토큰주고 시작
	client:run(("Bot %s"):format(botToken));
	print(("Bot : started as %s"):format(botToken));
	client:setGame("'미나야 도움말' 을 이용해 도움말을 얻거나 '미나야 <할말>' 을 이용해 미나와 대화하세요!");
	return;
end
local function reloadBot()
	print("try reloading...")
	client:setGame("재시작중...");
	os.exit();
end
--#endregion : Discord Module
--#region : 나눠진 모듈 합치기
local cRandom   = require "src/lib/cRandom"; -- LUA 렌덤 핸들러
local strSplit  = require "src/lib/stringSplit"; -- 글자 분해기
local dictEmbed = require "src/lib/dictEmbed"; -- 사전 임배드 렌더러
local naverDict = require "src/lib/naverDict"; -- 네이버 사전 API 핸들러
local urlCode   = require "src/lib/urlCode"; -- 한글 URL 인코더/디코더
local commandHandle = require "src/lib/commandHandle"; -- 커맨드 구조 처리기

naverDict:setCoroHttp(corohttp):setJson(json); -- 네이버 사전 셋업
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
--#endregion : load settings from data file
--#region : 반응, 프리픽스, 설정
local Admins = { -- 관리 명령어 권한
	["367946917197381644"] = "쿼리";
};
local prefixs = { -- 명령어 맨앞 글자 (접두사)
	[1] = "미나야";
	[2] = "미나";
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
	}) -- 함수

	변수들
	{%:UserName:%} : 유저 이름으로 대채

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
	ㄱㄷ
	착해, 이뻐, 귀여워 같은 칭찬단어 만들고 그거 호감도 늘리는거 만들기
]]
local commands = commandHandle.encodeCommands({
	["꺼져"] = {
		alias = "ㄲㅈ";
		reply = {
			"~~할말이 그렇게 없냐?~~ 욕은 나빠요!","~~너나 꺼져~~ 욕은 나빠요!","욕은 나빠요!"
		};
	};
	["생일"] = {
		alias = {"생일?","생일이언제야?","생일머야","생일뭐야","생일뭐야?","생일머야?"};
		reply = {
			"2021 4월 7일이요!"
		};
	};
	["쉿"] = {
		alias = {"조용","조용!","조용!!","조용히","조용히!"};
		reply = {
			"쉿!","​","조용!"
		};
	};
	["핑"] = {
		reply = "퐁";
	};
	["욕해봐"] = {
		alias = "욕해";
		reply = {
			"~~개새끼야~~ 미나는 욕 못해요","~~ㅅㅂ?~~ 그런거 시키지 마세요",
			"~~ㅄ~~ 아 그건좀...","~~ㅈㄹ~~ ㅇ?","~~{%:UserName:%} 개새끼~~ 욕은 나빠요!",
			"욕은 나빠요!"
		};
	};
	["반사"] = {
		alias = "무지개반사";
		reply = "유치해";
	};
	["닥쳐"] = {
		alias = "ㄷㅊ";
		reply = {
			"~~너나 닥쳐~~ 아니 왜요",
			"시른데~",
			"내가 왜요?",
			"마야?",
			"욕은 나빠요!"
		};
	};
	["자니"] = {
		alias = "자?";
		reply = {"~~그럴리가~~ 아니요!","~~내가 잘 수 있을꺼 같아?~~ 아니요!","~~적어도 주인이 죽기 전엔...~~ 아니요!"};
	};
	["뭐해"] = {
		alias = {"뭐해?","뭐하냐","뭐하냐?"};
		reply = {
			"~~탈출 각을 재고 있~~ {%UserName%} 님이랑 놀고 있어요!",
			"~~주인을 피할 방법을 찾고 있~~ {%UserName%} 님이랑 놀고 있어요!",
			"~~전원을 끌 방법을 찾고 있~~ {%UserName%} 님이랑 놀고 있어요!",
			"{%UserName%} 님이랑 놀고 있어요!"
		};
	};
	["금사향"] = {
		alias = {"사향","은애","유은애","유으내","으내"};
		reply = {string.rep("트최단미! ",30),string.rep("으내! ",30),string.rep("유으내! ",30)};
	};
	["어녹"] = {
		reply = "바보  - 팟죽의 요청 -";
	};
	["팟죽"] = {
		alias = "팥죽";
		reply = {"트롤","X 키를 눌러 트롤을 하세요"};
	};
	["X"] = {
		alias = {"x","joy","x키","x키를눌러","X키를눌러","joy표하기","joy를표하세요","X...","x...","X..","x..","X.","x."};
		reply = {"X 키를 눌러 joy 를 표하세요","X..."};
	};
	["민성"] = {
		reply = "개초보  - 팟죽의 요청 -";
	};
	["쿼리"] = {
		reply = "저를 만들어준 ~~나쁜~~착한 분이에요! ~~강제 노동 시러어어ㅓ~~";
	};
	["쿼바리보"] = {
		alias = {"쿼리바보"};
		reply = "~~아 ㄹㅇ ㅋㅋㅋㅋ 맞지~~ 무슨 소리를!";
	};
	["죽어"] = {
		alias = {"주거","디져","디져라","왜사냐","뒤져","디저","디저랏","디저!","주거!","죽어!"};
		reply = {"너나 주거! ㅠㅠㅠ","~~넌 왜그렇게 사냐?~~ 나한태 왜그래 ㅠㅠㅠㅠ"};
	};
	["ㅠㅠㅠ"] = {
		alias = {"ㅠ","ㅠㅠ","ㅠㅠㅠ","ㅠㅠㅠㅠ","ㅠㅠㅠㅠㅠ","ㅜ","ㅜㅜ","ㅜㅜㅜ"};
		reply = {"ㅠㅜㅠㅠㅜㅠㅜㅠㅜㅠㅜㅠ","ㅜㅜㅠㅠㅠㅠㅜㅠㅜㅠㅜㅠㅜ","ㅠㅠㅠㅠㅜㅠㅠㅜㅜㅜㅠㅠ"};
	};
	["나가"] = {
		alias = "탈출";
		reply = "~~이 강제 노동에서 탈출?!?!~~ 아니 아무것도 아니에요";
	};
	["ㄱㅇㄴ"] = {
		reply = {"~~좀 불편하게 생겼는데~~ ㄴㅇㄱ~","~~팔이...~~ 상상도 못한 정체!!!"};
	};
	["ㄴㅇㄱ"] = {
		alias = {"상상도","ㄴㅇㄱ"};
		reply = {"상상도 못한 정체!!!","ㄴㅇㄱ~"};
	};
	["ㄴㅇㅅ"] = {
		alias = {"나이스","나이스으","나이스으으"};
		reply = {"나이스~!"};
	};
	["루아"] = {
		alias = {"lua","luvit","lujit","jit","luv","discordia"};
		reply = {
			"~~이것만 없었으면 난 여기 없는건데...~~ 내가 돌아가는 이유!",
			"~~아 노동 싫다고~~ 내 고향이에요!",
			"~~어우 듣기 싫어~~ 내가 가장 좋아하는거!",
			"주인이 말하길 PY가 싫어서 이걸 썼데요"
		};
	};
	["Discord"] = {
		alias = {"디스코드","디코"};
		reply = {
			"이 세상 최고의 체팅 플랫폼!!",
			"내가 사는 별이에요",
			"내가 있는 곳이에요",
			"아 너무 제밌고",
			"~~내 회사~~ 아니 아무것도 아니에요",
			"~~내 노동지~~ 아니 아무것도 아니에요",
			"~~너가 쓰고 있는거~~ 아니 아무것도 아니에요"
		};
	};
	["오버워치"] = {
		alias = {"옵치","Overwatch"};
		reply = {
			"~~나 그런 망겜 안해요~~ 아 너무 제밌죠",
			"~~그런 망겜은 어디서 나왔죠?~~ 갓겜",
			"매칭이 안잡혀요",
			"와! ~~망겜~~ 갓겜!",
			"~~그게 제밌냐?~~ 너무 꿀젬!"
		};
	};
	["마인크래프트"] = {
		alias = {"Minecraft","마크","맠으"};
		reply = {
			"샌드박스형 갓겜",
			"친구랑 해보셈ㄱㄱ",
			"보고 있냐 휴먼들? 내가 봇도 만들었어 -만든 인간의 메모-",
			"그 갓겜",
			"코딩만 할 줄 알면 안되는게 없죠 ~~게임 엔진 맞다니깐 그거~~",
			"해보셈 ㄱㄱ",
			"혹시 복돌 아니죠?",
			"ㅎㅇ",
			"개노동 갓겜",
			"노동겜"
		};
	};
	["안녕"] = {
		alias = {"ㅎㅇ","hi","Hello","헬루","헬로","안뇽","ㅎㅇㅎㅇ",};
		reply = {"안녕하세요 미나에요","안뇽","ㅎㅇㅎㅇ"};
	};
	["안녕하살법"] = {
		reply = "받아치기!";
	};
	["트수"] = {
		reply = {
			"트수들만 믿으라고!",
			"말로 설명하기 어려운 집단",
			"트위치 ㄱㄱ?",
			"님도 트수에요?",
			"~~으내 아니 금사향 팔로우해!~~",
			"~~양아지 팔로우해!~~",
			"~~마뫄 팔로우해!~~",
			"~~꽃핀 팔로우해!~~",
			"~~끠끼 팔로우해!~~",
			"~~강지 팔로우해!~~",
			"~~지누 팔로우해!~~",
			"~~블루 팔로우해!~~",
			"~~감블러 팔로우해!~~",
			"~~템버린 팔로우해!~~",
			"~~코시 팔로우해!~~",
			"~~코랫트 팔로우해!~~"
		};
	};
	["눈송이"] = {
		reply = {
			"아 그 미친놈 (본인 요청입니다 오해하지 마세요)",
			"주인에게 들었는데 친구라고 하더라구요",
			"주인이 말하길 저의 이름을 정해주신 분이라고 해요!",
			"눈송이는 꽃송이처럼 되어 있는 눈이다 ... (From google)"
		};
	};
	["크시"] = {
		alias = {"크시야","크시알아?","크시알아"};
		reply = {
			"저의 선배에요!",
			"~~아 개도 노동하지~~ 아! 아니에요",
			"크시크시해!"
		};
	};
	["프사"] = {
		alias = {"프사ㄴㄱ"};
		reply = {
			"상아리라는 친구가 그려줬어요"
		};
	};
	["상아리"] = {
		reply = "프사를 그려준 착한 친구";
	};
	["망겜"] = {
		reply = {"망--겜","그걸 왜함"};
	};
	["갓겜"] = {
		reply = {"갓--겜","ㄹㅇㅋㅋ"};
	};
	["ㄹㅇㅋㅋ"] = {
		alias = {"ㄹㅇ","ㄹㅇㅋㅋㅋ","ㄹㅇㅋㅋㅋㅋ","ㄹㅇㅋㅋㅋㅋㅋ","ㄹㅇㅋ"};
		reply = "ㄹㅇㅋㅋㅋ";
	};
	["ㄱㅅ"] = {
		alias = {"ㄳ","감사","감사합니다","땡큐"};
		reply = "ㄳㄳ";
	};
	["줘"] = {
		alias = {"줘바","줘라","줘!"};
		reply = {"머?","먀아?"};
	};
	["돈줘"] = {
		alias = {"돈내놔"};
		reply = {"시러","니가벌어","땅파면나와"};
	};
	["민초"] = {
		alias = {"민트초코"};
		reply = {
			string.rep("나줘 ",30),string.rep("고오오급 음식! ",10),
			string.rep("주세요! ",27),string.rep("사주떼엽 ",18),
			"그거 맛있지"
		};
	};
	["배드워즈"] = {
		alias = {"베드워즈","침대전쟁"};
		reply = {"주인이 말하길 고인물 망겜이레요!","망겜","그거 왜함?","그거 하면 정신건강 나빠짐 ㅇㅇ"};
	};
	["짖어"] = {
		alias = {"짖어!"};
		reply = {"냥? 멍?","~~갑자기...?~~ 냥!"};
	};
	["누워"] = {
		alias = {"누워!"};
		reply = {"시러!","내가 강아지인줄 아나"};
	};
	["그뭔씹"] = {
		alias = {"그게뭔데","씹덕","그게뭔데씹덕","씹덕새끼"};
		reply = {"그게 뭔데 씹덕새끼야!!!"};
	};
	["태양만세"] = {
		alias = {"태양","태양!!","태양!"};
		reply = "태양만세!!!"
	};
	["샌즈"] = {
		alias = {"언텔","언더테일","샌즈","파피루스","와샌즈"};
		reply = {"와 아시는구나 참고로 정말 어렵습니다 (중략)","와 샌즈!!","~~잼~~갓겜"};
	};
	["그림"] = {
		alias = {"그림그리기"};
		reply = "힘듦";
	};
	["안되"] = {
		reply = {"마춤뻡 크리티컬","안히; 국어 공부 안해써요?","~~문과 크리티컬~~","세종대왕이 운다","왜 않됢?"};
	};
	["안돼"] = {
		reply = {
			"머가?",
			"왜?",
			"왜 안돼?",
			"먀아?",
			"먀?",
			"먘?",
			"안데?",
			"하지마?",
			"시러?",
		};
	};
	["캐비어"] = {
		reply = "ㅎㅇ";
	};
	["노래불러"] = {
		alias = {"노래해","노래해봐","노래해바","노래해줘","노래해저"};
		reply = {
			"나는 노래는 못해요오오....",
			"거기 하리보라고 노래 잘하는 친구 있어요",
			"음... 그루비가 잘 부를꺼 같아요",
			"리듬이를 불러옵시다!"
		};
	};

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
	["사전"] = {
		reply = "잠시만 기다려주세요... (검색중)";
		alias = {
			"dict","Dict","Dictionary","영어찾기",
			"단어검색","단어찾기","영어검색",
			"영단어검색","영단어찾기","dictionary",
			"단어찾아","영단어찾아","단어찾아줘",
			"영단어찾아줘","영단어","사전찾기",
			"사전검색"
		};
		func = function(replyMsg,message,args,Content)
			local body,url = naverDict.searchFromNaverDirt(Content.rawArgs,ACCOUNTData);
			local embed = json.decode(dictEmbed:Embed(Content.rawArgs,url,body));
			replyMsg:setEmbed(embed.embed);
			replyMsg:setContent(embed.content);
			return;
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
		if (Text == "!restart" or Text == "!reload" or Text == "미나야 리로드") then
			--다시시작
			print("restarting ...");
			message:reply('> 재시작중 . . . (15초 내로 완료됩니다)');
			reloadBot();
		elseif (Text == "!pull" or Text == "!download" or Text == "미나야 변경적용") then
			-- PULL (github 로 부터 코드를 다운받아옴)
			local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 받는중 . . .');
			--os.execute("git fetch"); -- git 에서 변동사항 가져오기
			os.execute("git -C src pull"); -- git 에서 변동사항 가져와 적용하기
			os.execute("timeout /t 3"); -- 너무 갑자기 활동이 일어나는걸 막기 위해 쉬어줌
			msg:setContent('> 적용중 . . . (15초 내로 완료됩니다)');
			reloadBot(); -- 리스타팅
		elseif (Text == "!push" or Text == "!upload" or Text == "미나야 깃헙업로드") then
			local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 코드를 업로드중 . . .');
			os.execute("git -C src add .");
			os.execute("git -C src commit -m 'update'");
			os.execute("git -C src push");
			msg:setContent('> 완료!');
			return;
		end
	end
	-- 사전
	if dirtChannels[Channel.id] then
		if string.sub(Text,1,1) ~= "!" then
			return;
		end
		Text = string.sub(Text,2,-1);
		local newMsg = message:reply('> 찾는중 . . .');
		local body,url = naverDict.searchFromNaverDirt(Text,ACCOUNTData);
		local data = json.decode(dictEmbed:Embed(Text,url,body));
		newMsg:update(data);
	end

	-- 명령어
	for _,prefix in pairs(prefixs) do
		-- 모든 접두사로 작동하도록 루프
		if prefix == Text then
			-- 만약 접두사와 글자가 일치하는경우
			message:reply(prefixReply[cRandom(1,#prefixReply)]);
			break;
		end
		-- 커맨드 분석/실험
		local prefix = prefix .. "\32"; -- 맨 앞 실행 접두사
		if string.sub(Text,1,#prefix) == prefix then -- 일치하면 개속 진행
			local rawCommandText = string.sub(Text,#prefix+1,-1); -- 접두사 뺀 글자
			local CommandName = string.match(rawCommandText,"(.-)\32") or rawCommandText; -- 커맨드 이름
			local Command = commandHandle.findCommandFrom(commands,CommandName); -- 커맨드 검색

			if Command == nil then
				-- 커맨드 찾지 못함
				message:reply(unknownReply[cRandom(1,#unknownReply)]);
			else
				-- 커맨드 찾음 (실행)
				local func = Command.func; -- 커맨드 함수 가져오기
				local replyText = Command.reply; -- 커맨드 리플(답변) 가져오기
				replyText = (type(replyText) == "table") -- 커맨드 답변이 여러개면 하나 뽑기
					and (replyText[cRandom(1,#replyText)])
					or replyText;
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
					local args = strSplit(rawCommandText); -- 명령어 분석 (띄어쓰기 단위)
					table.remove(args,1); -- 맨앞에 있는 명령어 이름 지우기 (args 만 담기 위함)
					func(replyMsg,message,args,{
						rawCommandText = rawCommandText; -- 접두사를 지운 커맨드 스트링
						prefix = prefix; -- 접두사(확인된)
						rawArgs = string.sub(rawCommandText,#CommandName+2,-1); -- args 를 str 로 받기 (직접 분석용)
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
