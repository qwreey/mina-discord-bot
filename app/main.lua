--[[
	작성 : qwreey
	2021y 04m 06d
	7:07 (PM)

	MINA Discord bot
	https://github.com/qwreey75/MINA_DiscordBot/blob/faf29242b29302341d631513617810d9fe102587/bot.lua

	TODO: 도움말 만들기
	TODO: 지우기 명령,강퇴,채널잠금,밴 같은거 만들기
	TODO: 다 못찾으면 !., 같은 기호 지우고 찾기
	TODO: 그리고도 못찾으면 조사 다 지우고 찾기
]]

-- set title of terminal
local version do
	local file = io.popen("git log -1 --format=%cd");
	version = file:read("*a");
	file:close();
	local commitCountFile = io.popen("git rev-list --count HEAD");
	local commitCount = commitCountFile:read("*a"):gsub("\n","");
	commitCountFile:close();
	local month,day,times,year,gmt = version:match("[^ ]+ +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+)");
	version = ("%s %s %s Build %s"):format(month,day,tostring(times:match("%d+:%d+")),tostring(commitCount));
end
_G.app = {
	name = "DiscordBot";
	fullname = "discord_mina_bot";
	version = version;
};
os.execute("title " .. _G.app.name);

-- set utf-8 terminal
do
	local chcpStatus do
		local file = io.popen("chcp");
		chcpStatus = file:read("*a");
		file:close();
		chcpStatus = tonumber((chcpStatus or ""):match(": (%d+)")) or 0;
	end
	if not chcpStatus == 65001 then
		os.execute("chcp 65001>NUL");
		-- os.execute("chcp 65001>/dev/null")
	end
end

--#region : Luvit 모듈 / 주요 모듈 임포트
-- setup require system
process.env.PATH = process.env.PATH .. ";.\\bin"; -- add bin libs path
package.path = require("app.path")(package.path); -- set require path
_G.require = require; -- set global require function

-- load modules
local insert = table.insert;
local sort = table.sort;
local remove = table.remove;
local utf8 = utf8 or require "utf8"; _G.utf8 = utf8; -- unicode 8 library
local uv = require "uv"; _G.uv = uv; -- load uv library
local prettyPrint = require "pretty-print"; _G.prettyPrint = prettyPrint; -- print many typed object on terminal
local readline = require "readline"; _G.readline = readline; -- reading terminal lines
local json = require "json"; _G.json = json; -- json library
local corohttp = require "coro-http"; _G.corohttp = corohttp; -- luvit's http library
local timer = require "timer"; _G.timer = timer; -- luvit's timer library that include timeout, sleep, ...
local thread = require "thread"; _G.thread = thread; -- luvit's thread library
local fs = require "fs"; _G.fs = fs; -- luvit's fils system library
local ffi = require "ffi"; _G.ffi = ffi; -- luajit's ffi library
local utils = require "utils"; _G.utils = utils; -- luvit's utils library
local adapt = utils.adapt; _G.adapt = adapt; -- adapt function alias
local spawn = require "coro-spawn"; _G.spawn = spawn; -- spawn process (child process wrapper)
local split = require "coro-split"; _G.split = split; -- run splitted coroutines
local sha1 = require "sha1"; _G.sha1 = sha1; -- sha1
local osTime = os.time; _G.osTime = osTime; -- time
local logger = require "log"; _G.logger = logger; -- log library
local dumpTable = require "libs.dumpTable"; -- table dump library, this is auto injecting dump function on global 'table'
local exitCodes = require("app.exitCodes"); _G.exitCodes = exitCodes; -- get exit codes
local qDebug = require "app.debug"; _G.qDebug = qDebug; -- my debug system
local term = require "app.term"; -- setuping REPL terminal
local commandHandler = require "commandHandler"; _G.commandHandler = commandHandler; -- command decoding-caching-indexing system
local cRandom = require "cRandom"; _G.cRandom = cRandom; -- LUA random handler
local strSplit = require "stringSplit"; _G.strSplit = strSplit; -- string split library
local urlCode = require "urlCode"; _G.urlCode = urlCode; -- url encoder/decoder library
local makeId = require "makeId"; _G.makeId = makeId; -- making id with cRandom library
local makeSeed = require "libs.makeSeed"; _G.makeSeed = makeSeed; -- making seed library, this is used on cRandom llibrary
local myXMl = require "myXML"; _G.myXMl = myXMl; -- myXML library
local userLearn = require "commands.learning.learn"; -- user learning library
local data = require "data"; data:setJson(json); _G.data = data; -- Data system
local userData = require "class.userData"; userData:setJson(json):setlogger(logger):setMakeId(makeId); _G.userData = userData; -- Userdata system
local serverData = require "class.serverData"; serverData:setJson(json):setlogger(logger):setMakeId(makeId); _G.serverData = serverData; -- Serverdata system
local posixTime = require "libs.posixTime"; _G.posixTime = posixTime; -- get posixTime library
local inject = require "app.inject";
--#endregion : Luvit 모듈 / 주요 모듈 임포트
--#region : Discordia Module
logger.info("------------------------ [CLEAN  UP] ------------------------");
logger.info("wait for discordia ...");

-- inject modified objects
inject("discordia/libs/voice/VoiceConnection","voice/VoiceConnection"); -- inject modified voice connection
inject("discordia/libs/voice/streams/FFmpegProcess","voice/streams/FFmpegProcess"); -- inject modified stream manager
-- inject("discordia/libs/containers/Message","containers/Message"); -- inject button system
-- inject("discordia/libs/containers/abstract/TextChannel","containers/abstract/TextChannel"); -- inject button system
-- inject("discordia/libs/client/EventHandler","client/EventHandler"); -- inject button system
local require = _G.require;

local discordia = require "discordia"; _G.discordia = discordia; -- 디스코드 lua 봇 모듈 불러오기
local discordia_class = require "discordia/libs/class"; _G.discordia_class = discordia_class; -- 디스코드 클레스 가져오기
local discordia_Logger = discordia_class.classes.Logger; -- 로거부분 가져오기 (통합을 위해 수정)
local enums = discordia.enums; _G.enums = enums; -- 디스코드 enums 가져오기
local client = discordia.Client(); _G.client = client; -- 디스코드 클라이언트 만들기
local Date = discordia.Date; _G.Date = Date;
function discordia_Logger:log(level, msg, ...) -- 디스코드 모듈 로거부분 편집
	if self._level < level then return end
	msg = string.format(msg, ...);
	local logFn =
		(level == 3 and logger.debug) or
		(level == 2 and logger.info) or
		(level == 1 and logger.warn) or
		(level == 0 and logger.error);
	logFn(msg);
	return msg;
end
--#endregion : Discordia Module
--#region : 반응, 프리픽스, 설정, 커맨드 등등
logger.info("---------------------- [LOAD SETTINGS] ----------------------");

-- load environments
logger.info("load environments ...");
require("app.env"); -- inject environments
local adminCmd = require("app.admin"); -- load admin commands\
local hook = require("class.hook");
local registeLeaderstatus = require("class.registeLeaderstatus");

-- load commands
logger.info(" |- load commands from commands folder");
local otherCommands = {} -- commands 폴더에서 커맨드 불러오기
for dir in fs.scandirSync("commands") do -- read commands from commands folder
	dir = string.gsub(dir,"%.lua$","");
	logger.info(" |  |- load command dict from : commands." .. dir);
	otherCommands[#otherCommands+1] = require("commands." .. dir);
end



-- 커맨드 색인파일 만들기
local reacts,commands,commandsLen;
reacts,commands,commandsLen = commandHandler.encodeCommands({
	-- 특수기능
	["약관동의"] = {
		alias = {"EULA동의","약관 동의","사용계약 동의"};
		reply = function (message,args,c)
			local this = c.getUserData(); -- 내 호감도 불러오기
			if this then -- 약관 동의하지 않았으면 리턴
				return "**{#:UserName:#}** 님은 이미 약관을 동의하셨어요!";
			end
			local userId = tostring(message.author.id);
			fs.writeFileSync(("data/userData/%s.json"):format(userId),
				("{" ..
					('"latestName":"%s",'):format(message.author.name) ..
					'"love":0,' ..
					('"lastName":["%s"],'):format(message.author.name) ..
					'"lastCommand":{}' ..
				"}")
			);
			return "안녕하세요 {#:UserName:#} 님!\n사용 약관에 동의해주셔서 감사합니다!\n사용 약관을 동의하였기 때문에 다음 기능을 사용 할 수 있게 되었습니다!\n\n> 미나야 배워 (미출시 기능)\n";
		end;
	};
	["미나"] = {
		alias = {"미나야","미나!","미나...","미나야...","미나..","미나야..","미나.","미나야.","미나야!"};
		reply = prefixReply;
	};
	["반응"] = {
		alias = {"반응수","반응 수","반응 갯수"};
		reply = "새어보고 있어요...";
		func = function (replyMsg,message,args,Content)
			replyMsg:setContent(("미나가 아는 반응은 %d개 이에요!"):format(commandsLen));
		end;
	};
},unpack(otherCommands));
_G.reacts = reacts;
logger.info(" |- command indexing end!");

--#endregion : 반응, 프리픽스, 설정
--#region : 메인 파트
logger.info("----------------------- [SET UP BOT ] -----------------------");
local findCommandFrom = commandHandler.findCommandFrom;
local afterHook = hook.afterHook;
local beforeHook = hook.beforeHook;
client:on('messageCreate', function(message) -- 메시지 생성됨

	-- get base information from message object
	local user = message.author;
	local text = message.content;
	local channel = message.channel;
	local isDm = channel.type == enums.channelType.private;

	-- check user that is bot; if it is bot, then return (ignore call)
	if user.bot then
		return;
	end

	-- run admin command if exist
	if admins[user.id] then
		adminCmd(text,message);
	end

	-- run before hook
	for _,thisHook in pairs(beforeHook) do
		local isPassed,result = pcall(thisHook.func,thisHook,{
			text = text;
			user = user;
			channel = channel;
			isDm = isDm;
			message = message;
		});
		if isPassed and result then
			return;
		end
	end

	-- LOCAL VARIABLES
	-- Text : 들어온 텍스트 (lower cased)
	-- prefix : 접두사
	-- rawCommandText : 접두사 뺀 커맨드 전채
	-- splitCommandText : rawCommandText 를 \32 로 분해한 array
	-- rawCommandText : 커맨드 이름 (앞부분 다 자르고)
	-- CommandName : 커맨드 이름
	-- | 찾은 후 (for 루프 뒤)
	-- Command : 커맨드 개체 (찾은경우)

	-- 접두사 구문 분석하기
	local prefix;
	local TextLower = string.lower(text); -- make sure text is lower case
	for _,nprefix in pairs(prefixs) do
		if nprefix == TextLower then -- 만약 접두사와 글자가 일치하는경우 반응 달기
			message:reply {
				content = prefixReply[cRandom(1,#prefixReply)];
				reference = {message = message, mention = false};
			};
			return;
		end
		nprefix = nprefix .. "\32"; -- 맨 앞 실행 접두사
		if TextLower:sub(1,#nprefix) == nprefix then -- 만약에 접두가사 일치하면
			prefix = nprefix;
			break;
		end
	end
	if (not prefix) and (not isDm) then
		return;
	end
	prefix = prefix or "";

	-- 알고리즘 작성
	-- 커맨드 찾기
	-- 단어 분해 후 COMMAND DICT 에 색인시도
	-- 못찾으면 다시 넘겨서 뒷단어로 넘김
	-- 찾으면 넘겨서 COMMAND RUN 에 TRY 던짐
	local rawCommandText = text:sub(#prefix+1,-1); -- 접두사 뺀 글자
	local splited = strSplit(rawCommandText:lower(),"\32");
	local Command,CommandName,rawCommandName = findCommandFrom(reacts,rawCommandText,splited);
	if not Command then
		-- Solve user learn commands
		local userReact = findCommandFrom(userLearn.get,rawCommandText,splited);
		if userReact then
			message:reply {
				content = userLearn.format(userReact);
				reference = {message = message, mention = false};
			};
			return;
		end
	end

	-- 커맨드 찾지 못함
	if not Command then
		message:reply(unknownReply[cRandom(1,#unknownReply)]);
		-- 반응 없는거 기록하기
		fs.appendFile("log/unknownTexts/raw.txt","\n" .. text);
		return;
	elseif isDm and Command.disableDm then
		message:reply(disableDm);
		return;
	end

	-- 커맨드 찾음 (실행)
	local love = Command.love; -- 호감도
	love = tonumber((type(love) == "function") and love() or love);
	local loveText = (love ~= 0 and love) and ( -- love 가 0 이 아님을 확인
		(love > 0 and ("\n` ❤ + %d `"):format(love)) or -- 만약 love 가 + 면
		(love < 0 and ("\n` 💔 - %d `"):format(math.abs(love))) -- 만약 love 가 - 면
	) or "";
	local func = Command.func; -- 커맨드 함수 가져오기
	local replyText = Command.reply; -- 커맨드 리플(답변) 가져오기
	local rawArgs,args; -- 인수 (str,띄어쓰기 단위로 나눔 array)
	replyText = ( -- reply 하나 가져오기
		(type(replyText) == "table") -- 커맨드 답변이 여러개면 하나 뽑기
		and (replyText[cRandom(1,#replyText)])
		or replyText
	);

	-- 만약 호감도가 있으면 올려주기
	if love then
		local userId = user.id
		local thisUserDat = userData:loadData(userId);

		if thisUserDat then
			local username = user.name;
			thisUserDat.latestName = username;
			local lastNames = thisUserDat.lastName;
			if lastNames[#lastNames] ~= username then
				insert(lastNames,username);
			end
			local CommandID = Command.id;
			-- get last command used status
			local lastCommand = thisUserDat.lastCommand;
			if not lastCommand then
				lastCommand = {};
				thisUserDat.lastCommand = lastCommand;
			end
			local lastTime = lastCommand[CommandID];
			if lastTime and (lastTime+loveCooltime > osTime()) then -- need more sleep . . .
				loveText = "";
			else
				thisUserDat.love = thisUserDat.love + love;
				lastCommand[CommandID] = osTime();
				userData:saveData(user.id);
				registeLeaderstatus(userId,thisUserDat);
			end
		else
			loveText = eulaComment_love;
		end
	end

	-- 함수 실행을 위한 콘탠츠 만들기
	local contents = {
		user = user;
		channel = channel;
		isDm = isDm;
		rawCommandText = rawCommandText; -- 접두사를 지운 커맨드 스트링
		prefix = prefix; -- 접두사(확인된)
		rawArgs = rawArgs; -- args 를 str 로 받기 (직접 분석용)
		rawCommandName = rawCommandName;
		self = Command;
		commandName = CommandName;
		saveUserData = function ()
			return userData:saveData(user.id);
		end;
		getUserData = function ()
			return userData:loadData(user.id);
		end;
		loveText = loveText;
		isPremium = function ()
			local uData = userData:loadData(user.id);
			if not uData then
				return;
			end
			local premiumStatus = uData.premiumStatus;
			if premiumStatus and (premiumStatus > posixTime.now()) then
				return true;
			end
			return false;
		end;
	};

	-- 만약 답변글이 함수면 (지금은 %s 시에요 처럼 쓸 수 있도록) 실행후 결과 가져오기
	if type(replyText) == "function" then
		rawArgs = rawCommandText:sub(#CommandName+2,-1);
		args = strSplit(rawArgs,"\32");
		contents.rawArgs = rawArgs;
		local passed;
		passed,replyText = pcall(replyText,message,args,contents);
		if not passed then
			message:reply(("커맨드 반응 생성중 오류가 발생했습니다!\n```\n%s\n```"):format(tostring(replyText)));
		end
	end

	local replyMsg; -- 답변 오브잭트를 담을 변수
	if replyText then -- 만약 답변글이 있으면 답변 주기
		local replyTextType = type(replyText);
		local embed = Command.embed;
		if replyTextType == "string" then
			replyText = replyText .. loveText;
		elseif replyTextType == "table" and replyText.content then
			embed = replyText.embed or embed;
			replyText.content = replyText.content .. loveText;
		end
		replyMsg = message:reply{
			embed = embed;
			content = commandHandler.formatReply(replyText,{
				Msg = message;
				user = user;
				channel = channel;
			});
			reference = {message = message, mention = false};
		};
	end

	-- 명령어에 담긴 함수를 실행합니다
	-- func (replyMsg,message,args,EXTENDTable);
	if func then -- 만약 커맨드 함수가 있으면
		-- 커맨드 함수 실행
		rawArgs = rawArgs or rawCommandText:sub(#CommandName+2,-1);
		contents.rawArgs = rawArgs;
		args = strSplit(rawArgs,"\32");
		local passed,ret = pcall(func,replyMsg,message,args,contents);
		if not passed then
			logger.error("an error occurred on running function");
			logger.errorf(" | original message : %s",tostring(text));
			logger.error(" | error traceback was");
			logger.error(tostring(ret));
			logger.error(" | more information was saved on log/debug.log");
			qDebug {
				title = "an error occurred on running command function";
				traceback = tostring(ret);
				originalMsg = tostring(text);
				command = Command;
			};
			replyMsg:setContent(("명령어 처리중에 오류가 발생하였습니다\n```%s```")
				:format(tostring(ret))
			);
		end
	end

	-- run after hook
	for _,thisHook in pairs(afterHook) do
		pcall(thisHook.func,thisHook,contents);
	end
end);

term(); -- load repl terminal system
_G.livereloadEnabled = false; -- enable live reload
require("app.livereload"); -- loads livereload system; it will make uv event and take file changed signal
startBot(ACCOUNTData.botToken,ACCOUNTData.testing); -- init bot (init discordia)
--#endregion : 메인 파트
