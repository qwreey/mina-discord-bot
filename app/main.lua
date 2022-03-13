--[[
	작성 : qwreey
	2021y 04m 06d
	7:07 (PM)

	MINA Discord bot
	https://github.com/qwreey75/MINA_DiscordBot/blob/faf29242b29302341d631513617810d9fe102587/bot.lua

	-- TODO: 지우기 명령,강퇴,채널잠금,밴 같은거 만들기
	-- TODO: 다 못찾으면 !., 같은 기호 지우고 찾기
	-- TODO: 그리고도 못찾으면 조사 다 지우고 찾기
]]

--#region : sys setup
-- Setup require system
require"libs/upgradeString";
local jit = _G.jit or require "jit";
process.env.PATH = process.env.PATH .. ((jit.os == "Windows" and ";.\\bin\\Windows_" or ":./bin/Linux_") .. jit.arch); -- add bin libs path
package.path = require("app.path")(package.path); -- set require path
_G.require = require; -- set global require function
local profiler = require"profiler"; _G.profiler = profiler;
local initProfiler = profiler.new"INIT";
initProfiler:start"MAIN";
_G.initProfiler = initProfiler;

-- Make app object
initProfiler:start"Setup terminal / Application";
local args,options = (require "argsParser").decode(args,{
	["--logger_prefix"] = true;
});
_G.app = {
	name = "DiscordBot";
	fullname = "discord_mina_bot";
	version = "Unknown";
	args = args;
	options = options;
	changelog = require "app.changelog";
};

-- Set title of terminal
os.execute("title " .. _G.app.name);

-- Set utf-8 terminal
if jit.os == "Windows" then
	local chcpStatus do
		local file = io.popen("chcp");
		chcpStatus = file:read("*a");
		file:close();
		chcpStatus = tonumber((chcpStatus or ""):match(": (%d+)")) or 0;
	end
	if chcpStatus ~= 65001 then
		os.execute("chcp 65001>NUL");
		-- os.execute("chcp 65001>/dev/null")
	end
end
initProfiler:stop();
--#endregion sys setup
--#region : Load modules
initProfiler:start"Load global modules";
local format = string.format;
local traceback = debug.traceback;
local insert = table.insert;
local promise = require "promise"; _G.promise = promise;
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
local logger = require "logger"; _G.logger = logger; -- log library
local dumpTable = require "libs.dumpTable"; _G.dumpTable = dumpTable; -- table dump library, this is auto injecting dump function on global 'table'
local exitCodes = require("app.exitCodes"); _G.exitCodes = exitCodes; -- get exit codes
local qDebug = require "app.debug"; _G.qDebug = qDebug; -- my debug system
local term = require "app.term"; -- setuping REPL terminal
local commandHandler = require "class.commandHandler"; _G.commandHandler = commandHandler; -- command decoding-caching-indexing system
local cRandom = require "cRandom"; _G.cRandom = cRandom; -- LUA random handler
local strSplit = require "stringSplit"; _G.strSplit = strSplit; -- string split library
local urlCode = require "urlCode"; _G.urlCode = urlCode; -- url encoder/decoder library
local makeId = require "makeId"; _G.makeId = makeId; -- making id with cRandom library
local makeSeed = require "libs.makeSeed"; _G.makeSeed = makeSeed; -- making seed library, this is used on cRandom llibrary
local myXml = require "myXml"; _G.myXml = myXml; -- myXml library
local userLearn = require "commands.learning.learn"; -- user learning library
local data = require "data"; data:setJson(json); _G.data = data; -- Data system
local userData = require "class.userData"; _G.userData = userData; -- Userdata system
local serverData = require "class.serverData"; _G.serverData = serverData; -- Serverdata system
local interactionData = require "class.interactionData"; _G.interactionData = interactionData; -- interactiondata system
local posixTime = require "libs.posixTime"; _G.posixTime = posixTime; -- get posixTime library
local mutex = require "libs.mutex"; _G.mutex = mutex;
local commonSlashCommand = require "class.commonSlashCommand"; _G.commonSlashCommand = commonSlashCommand;
local argsParser = require "libs.argsParser"; _G.argsParser = argsParser;
local IPC = require "IPC"; _G.IPC = IPC;
local unpack = require "unpack"; _G.unpack = unpack;
initProfiler:stop();
--#endregion : Load modules
--#region : Get version
-- Get version from git
initProfiler:start"Get git version";
local commitTime,commitCount = "","" do
	local errPrefix = "[GitVersion] %s";
	local errNewline = "\n"..(" "):rep(#errPrefix - 2);
	promise.new(function()
		-- git last commit time
		local gitTime = spawn("git",{
			args = {"log","-1","--format=%cd"};
			stdio = {nil,true,true};
		});
		local waitter = promise.waitter();
		waitter:add(promise.new(function()
			for str in gitTime.stdout.read do
				commitTime = commitTime .. str;
			end
		end));
		waitter:add(promise.new(function()
			for str in gitTime.stderr.read do
				logger.errorf(errPrefix,str:gsub("\n",errNewline));
			end
		end));
		waitter:wait();
		commitTime = commitTime:gsub("\n","");

		-- git commit counts
		local gitCount = spawn("git",{
			args = {"rev-list","--count","HEAD"};
			stdio = {nil,true,true};
		});
		waitter = promise.waitter();
		waitter:add(promise.new(function()
			for str in gitCount.stdout.read do
				commitCount = commitCount .. str;
			end
		end));
		waitter:add(promise.new(function()
			for str in gitCount.stderr.read do
				logger.errorf(errPrefix,str:gsub("\n",errNewline));
			end
		end));
		waitter:wait();
		commitCount = commitCount:gsub("\n","");

		-- update version
		local month,day,times,year,gmt = commitTime:match("[^ ]+ +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+)");
		local version = ("%s %s %s Build %s"):format(month,day,tostring(times:match("%d+:%d+")),tostring(commitCount));
		app.version = version;

		-- refreshLine
		editor.prompt = buildPrompt();
		editor:refreshLine();

		-- wait process exit
		gitTime.waitExit();
		gitCount.waitExit();
	end);
end
initProfiler:stop();
--#endregion : Get version
--#region : Discordia Module
initProfiler:start"Load discordia";
logger.info("------------------------ [CLEAN  UP] ------------------------");
logger.info("wait for discordia ...");

require("app.jsonErrorWrapper"); -- enable pcall wrapped json en-decoder

local discordia = require "discordia"; _G.discordia = discordia; ---@type discordia -- 디스코드 lua 봇 모듈 불러오기
local discordia_enchant = require "discordia_enchant"; _G.discordia_enchant = discordia_enchant;
local userInteractWarpper = require("class.userInteractWarpper"); _G.userInteractWarpper = userInteractWarpper;
local commonButtons = require "class.commonButtons"; _G.buttons = commonButtons;

local discordia_class = require "discordia/libs/class"; _G.discordia_class = discordia_class; ---@type class -- 디스코드 클레스 가져오기
local discordia_Logger = discordia_class.classes.Logger; ---@type Logger -- 로거부분 가져오기 (통합을 위해 수정)
local enums = discordia.enums; _G.enums = enums; ---@type enums -- 디스코드 enums 가져오기
local client = discordia.Client(require("class.clientSettings")); _G.client = client; ---@type Client -- 디스코드 클라이언트 만들기
local Date = discordia.Date; _G.Date = Date; ---@type Date

-- inject logger
function discordia_Logger:log(level, msg, ...)
	if self._level < level then return end ---@diagnostic disable-line
	msg = format(msg, ...);
	local logFn =
		(level == 3 and logger.debug) or
		(level == 2 and logger.info) or
		(level == 1 and logger.warn) or
		(level == 0 and logger.error) or logger.info;
	if level <= 1 then
		logFn(("%s\n%s"):format(msg,traceback()));
	else
		logFn(msg);
	end
	return msg;
end

---@diagnostic disable-next-line
discordia_enchant.inject(client);
initProfiler:stop();
--#endregion : Discordia Module
--#region : Load bot environments
initProfiler:start"Load bot environments";
logger.info("---------------------- [LOAD SETTINGS] ----------------------");

-- Load environments
initProfiler:start"Load environments / datas";
logger.info("load environments ...");
require("app.global"); -- inject environment
local adminCmd = require("class.adminCommands"); -- load admin commands
local hook = require("class.hook");
local registeLeaderstatus = require("class.registeLeaderstatus");
local formatTraceback = _G.formatTraceback;
local admins = _G.admins;
local testingMode = ACCOUNTData.testing;
initProfiler:stop();

-- Load commands
initProfiler:start"Load commands";
initProfiler:start"Require files";
logger.info(" |- load commands from commands folder");
local otherCommands = {} -- read commands from commands folder
for dir in fs.scandirSync("commands") do
	dir = string.gsub(dir,"%.lua$","");
	logger.info(" |  |- load from : commands." .. dir);
	otherCommands[#otherCommands+1] = require("commands." .. dir);
end
initProfiler:stop();

-- Load command indexer
initProfiler:start"Indexing commands";
local reacts,commands,noPrefix,commandsLen;
reacts,commands,noPrefix,commandsLen = commandHandler.encodeCommands({
	-- 특수기능
	["약관동의"] = {
		alias = {"EULA동의","약관 동의","사용계약 동의"};
		reply = function (message,args,content)
			local this = content.loadUserData(); -- 내 호감도 불러오기
			if this then -- 약관 동의하지 않았으면 리턴
				return "**{#:UserName:#}** 님은 이미 약관을 동의하셨어요!";
			end
			local author = message.author;
			local id = author.id;
			local name = author.name;
			userData.saveData(id,{
				latestName = name;
				lastName = {name};
				lastCommand = {};
				love = 20;
			});
			return "안녕하세요 {#:UserName:#} 님!\n사용 약관에 동의해주셔서 감사합니다!\n사용 약관을 동의하였기 때문에 다음 기능을 사용 할 수 있게 되었습니다!\n\n> 미나 배워\n> 미나 호감도\n> ...\n";
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
_G.commands = commands;
_G.noPrefix = noPrefix;
logger.info(" |- command indexing end!");
initProfiler:stop();
initProfiler:stop();
--#endregion : Load bot environments
--#region : Main logic
initProfiler:start"Setup bot client events";
logger.info("----------------------- [SET UP BOT ] -----------------------");
local findCommandFrom = commandHandler.findCommandFrom;
local afterHook = hook.afterHook;
local beforeHook = hook.beforeHook;

-- making command reader
local lower = string.lower;
local function processCommand(message)

	-- get base information from message object
	local user = message.author;
	local text = message.content;
	local channel = message.channel;
	local guild = message.guild;
	local isDm = channel.type == enums.channelType.private; ---@diagnostic disable-line
	local isSlashCommand = rawget(message,"slashCommand");

	-- check user that is bot; if it is bot, then return (ignore call)
	if user.bot then
		return;
	end

	-- run admin command if exist
	if admins[user.id] then
		local cmdText = text;
		if testingMode then
			cmdText = cmdText:sub(2,-1);
		end
		pcall(adminCmd,cmdText,message);
	end

	-- run before hook
	local hookContent;
	for _,thisHook in pairs(beforeHook) do
		hookContent = hookContent or {
			text = text;
			user = user;
			channel = channel;
			isDm = isDm;
			message = message;
		};
		local isPassed,result = pcall(thisHook.func,thisHook,hookContent);
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
	local TextLower = lower(text); -- make sure text is lower case
	for _,nprefix in pairs(prefixs) do
		if nprefix == TextLower then -- 만약 접두사와 글자가 일치하는경우 반응 달기
			channel:broadcastTyping();
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

	-- guild prefix
	local guildCommandMode;
	if guild then
		local guildData = serverData.loadData(guild.id);
		if guildData then
			local guildPrefix = guildData.guildPrefix;
			if guildPrefix then
				local lenGuildPrefix = #guildPrefix;
				if guildPrefix == text:sub(1,lenGuildPrefix) then
					guildCommandMode = true;
					prefix = guildPrefix;
				end
			end
		end
	end
	if (not prefix) and (not isDm) and (not isSlashCommand) then
		return;
	end
	prefix = prefix or "";

	channel:broadcastTyping();

	-- 커맨드 찾기
	-- 단어 분해 후 COMMAND DICT 에 색인시도
	-- 못찾으면 다시 넘겨서 뒷단어로 넘김
	-- 찾으면 넘겨서 COMMAND RUN 에 TRY 던짐
	local rawCommandText = text:sub(#prefix+1,-1); -- 접두사 뺀 글자
	local splited = strSplit(rawCommandText:lower(),"\32\n");
	local Command,CommandName,rawCommandName = findCommandFrom(guildCommandMode and commands or reacts,rawCommandText,splited);
	if not Command then
		-- is guild command mode
		if guildCommandMode then
			message:reply {
				content = ("커맨드 **'%s'** 는 존재하지 않습니다!"):format(rawCommandText);
				reference = {message = message, mention = false};
			};
			return;
		end

		-- find from none prefixed commands table
		Command,CommandName,rawCommandName = findCommandFrom(noPrefix,rawCommandText,splited);
		if not Command then
			-- Solve user learn commands
			local pass,userReact = pcall(findCommandFrom,userLearn.get,rawCommandText,splited);
			if pass and userReact then
				message:reply {
					content = userLearn.format(userReact);
					reference = {message = message, mention = false};
				};
				return;
			elseif not pass then
				logger.errorf("Error occurred on loading userLearn data! Error message was\n%s",tostring(userReact));
			end

			-- not found
			message:reply({
				content = unknownReply[cRandom(1,#unknownReply)];
				reference = {message = message, mention = false};
			});
			fs.appendFile("log/unknownTexts/raw.txt","\n" .. text); -- save
			return;
		end
	else
		-- check dm
		local cmdDisableDm = Command.disableDm;
		if isDm and cmdDisableDm then
			message:reply({
				content = (type(cmdDisableDm) == "string") and cmdDisableDm or disableDm;
				reference = {message = message, mention = false};
			});
			return;
		end
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

	-- Make love prompt
	if love then
		local userId = user.id
		local thisUserDat = userData.loadData(userId);

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
				userData.saveData(user.id);
				registeLeaderstatus(userId,thisUserDat);
			end
		else
			loveText = eulaComment_love;
		end
	end

	-- 함수 실행을 위한 콘탠츠 만들기
	---@class commandContent
	local contents = {
		guild = guild; ---@type Guild a guild that where used this command
		user = user; ---@type User a user that called this command
		channel = channel; ---@type Channel|TextChannel|GuildChannel|PrivateChannel|GuildTextChannel a channel that this command is called on
		isDm = isDm; ---@type boolean whether this channel is dm
		rawCommandText = rawCommandText; ---@type string raw command text (removed prefix)
		prefix = prefix; ---@type string used prefix
		rawArgs = rawArgs; ---@type string raw string arguments
		rawCommandName = rawCommandName; ---@type string command name, this is can be alias
		self = Command; ---@type Command this command it self
		commandName = CommandName; ---@type string this command is self's name
		---@type function Save this user's data with userData library
		---@return nil
		saveUserData = function ()
			return userData.saveData(user.id);
		end;
		---@type function Save this user's data with userData library
		---@return userDataObject userDataObject User's Data
		loadUserData = function ()
			return userData.loadData(user.id);
		end;
		loveText = loveText; ---@type string love earned text
		---@type function Get user's premium status
		---@return boolean isPremium whether user's premium exist
		isPremium = function ()
			local uData = userData.loadData(user.id);
			if not uData then
				return;
			end
			local premiumStatus = uData.premiumStatus;
			if premiumStatus and (premiumStatus > posixTime.now()) then
				return true;
			end
			return false;
		end;
		---@type boolean determine is slash command callback
		isSlashCommand = isSlashCommand;
		---@type function Get server's settings
		---@return table|nil serverData
		loadServerData = function ()
			return serverData.loadData(guild.id)
		end;
		saveServerData = function (overwrite)
			return serverData.saveData(guild.id,overwrite);
		end;
	};

	-- if reply text is function, run it and get result
	if type(replyText) == "function" then
		rawArgs = rawCommandText:sub(#rawCommandName+2,-1);
		args = strSplit(rawArgs,"\32");
		contents.rawArgs = rawArgs;
		local passed;
		passed,replyText = xpcall(replyText,function (err)
			err = tostring(err);
			local traceback = formatTraceback(debug.traceback());
			text = tostring(text);
			logger.errorf("An error occurred on running command function\n - original message : %s\n - error message was :\n%s\n - error traceback was :\n%s\n - more information was saved on log/debug.log",
				tostring(text),err,traceback
			);
			qDebug {
				title = "an error occurred on running reply function";
				errorMessage = err;
				traceback = traceback;
				originalMsg = text;
				command = Command;
			};
			coroutine.wrap(message.reply)(message,{
				content = ("커맨드 반응 생성중 오류가 발생했습니다!```log\nError message : %s\n%s```"):format(
					tostring(err),tostring(traceback)
				);
				reference = {message = message, mention = false};
			})
		end,message,args,contents,Command);
		if not passed then
			return;
		end
	end

	-- Making reply message
	local replyMsg;
	if replyText then -- if there are reply text
		local replyTextType = type(replyText);
		local embed = Command.embed;
		local components = Command.components;
		if replyTextType == "string" then -- if is string, making new message
			replyMsg = message:reply({
				components = components;
				embed = embed;
				content = commandHandler.formatReply(replyText .. loveText,{
					Msg = message;
					user = user;
					channel = channel;
				});
				reference = {message = message, mention = false};
			});
		elseif replyTextType == "table" then -- if is message (if func returned), set replyMsg to it
			replyMsg = replyText;
		end
	end

	-- 명령어에 담긴 함수를 실행합니다
	-- func (replyMsg,message,args,EXTENDTable);
	if func then -- 만약 커맨드 함수가 있으면
		-- 커맨드 함수 실행
		rawArgs = rawArgs or rawCommandText:sub(#CommandName+2,-1);
		contents.rawArgs = rawArgs;
		args = strSplit(rawArgs,"\32");
		xpcall(func,function (err)
			err = tostring(err);
			local traceback = formatTraceback(debug.traceback());
			text = tostring(text);
			logger.errorf("An error occurred on running command function\n - original message : %s\n - error message was :\n%s\n - error traceback was :\n%s\n - more information was saved on log/debug.log",
				tostring(text),err,traceback
			);
			qDebug {
				title = "an error occurred on running command function";
				errorMessage = err;
				traceback = traceback;
				originalMsg = text;
				command = Command;
			};
			coroutine.wrap(replyMsg.setContent)(replyMsg,
				("명령어 처리중에 오류가 발생하였습니다```log\nError message : %s\n%s```"):format(err,traceback)
			);
		end,replyMsg,message,args,contents,Command);
	end

	-- run after hook
	for _,thisHook in pairs(afterHook) do
		hookContent = hookContent or {
			text = text;
			user = user;
			channel = channel;
			isDm = isDm;
			message = message;
		};
		pcall(thisHook.func,thisHook,hookContent,contents);
	end
end
_G.processCommand = processCommand;

-- on message
client:on('messageCreate', processCommand);

-- making slash command
commandHandler.onSlash(function ()
	client:slashCommand({ ---@diagnostic disable-line
		name = "미나";
		description = "미나와 대화합니다!";
		options = {
			{
				name = "내용";
				description = "미나와 나눌 대화를 입력해보세요!";
				type = discordia_enchant.enums.optionType.string;
				required = true;
			};
		};
		callback = function(interaction, params, cmd)
			local pass,err = xpcall(processCommand,
			function (err)
					err = tostring(err)
					local traceback = debug.traceback();
					logger.errorf(
						"Error occurred on executing slash command\nError message : %s\nError traceback",
						err,traceback
					);
					interaction:reply(
						("애플리케이션 명령어 실행중 오류가 발생했습니다!\n```%s\n%s```"):format(
							err,traceback
						)
					);
				end,
				userInteractWarpper(
					params["내용"],
					interaction
				)
			);
		end;
	});
end,nil,nil,"MAIN");

client:on("slashCommandsCommited",function ()
	logger.info("[Slash] All slash command loaded");
end);
-- enable terminal features and live reload system
initProfiler:stop();
initProfiler:start"Init Terminal / Dev features";
do
	local terminalInputDisabled;
	local livereload = false;
	for _,v in pairs(app.args) do
		if v == "disable_terminal" then
			terminalInputDisabled = true;
		elseif v == "enable_livereload" then
			livereload = true;
		end
		if terminalInputDisabled and livereload then
			break;
		end
	end
	if not terminalInputDisabled then
		term(); -- Load repl terminal system
	end
	_G.livereloadEnabled = livereload; -- enable live reload
end
require("app.livereload")(testingMode); -- loads livereload system; it will make uv event and take file changed signal
initProfiler:stop();
initProfiler:start"Startup bot client";
startBot(ACCOUNTData.botToken,testingMode); -- init bot (init discordia)
initProfiler:stop();
initProfiler:stop(); -- stop bot setup
--#endregion : Main logic
initProfiler:stop(); -- stop main
