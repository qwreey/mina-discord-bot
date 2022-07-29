--[[
This code will injects environments into _G
]]

-- get indexs of table
local insert = table.insert;
local function indexs(t)
	local result = {};
	local index = nil
	while true do
		index = next(t,index);
		if not index then break; end
		insert(result,index);
	end
	return result;
end
_G.indexs = indexs;

-- displays --- ago
local time = os.time;
local function timeAgo(old,now)
	if not now then
		now = time();
	end
	local sub = now - old;
	if sub > 220752000 then
		return ("%d 년전"):format(sub / 220752000);
	elseif sub > 18446400 then
		return ("%d 달전"):format(sub / 18446400);
	elseif sub > 604800 then
		return ("%d 주전"):format(sub / 604800);
	elseif sub > 86400 then
		return ("%d 일전"):format(sub / 86400);
	elseif sub > 3600 then
		return ("%d 시간전"):format(sub / 3600);
	elseif sub > 60 then
		return ("%d 분전"):format(sub / 60);
	else
		return ("%d 초전"):format(sub);
	end
	return "?";
end
_G.timeAgo = timeAgo;

-- google api key,z discord token, game api key and more. this is should be protected
do
	local testing; -- check testing mode
	for _,v in pairs(args) do
		if v == "env.testing" or v == "test" or v == "testing" then
			testing = true;
			break;
		end
	end
	_G.ACCOUNTData = data.load("data/ACCOUNT.json"); ---@type table
	if testing then
		local testData = data.load("data/ACCOUNT_test.json");
		for i,v in pairs(testData) do
			ACCOUNTData[i] = v;
		end
		ACCOUNTData.testing = true;
	end
end

-- EULA text
_G.EULA = data.loadRaw("data/EULA.txt");

-- the leaderstatus data that will save on server storage
local loveLeaderstatusPath = "data/loveLeaderstatus.json";
_G.loveLeaderstatus = data.load(loveLeaderstatusPath);
_G.loveLeaderstatusPath = loveLeaderstatusPath;
_G.loveLeaderstatusMaxUsers = 10;

-- the words that means rank, this is useed on '미나 호감도 순위'
_G.leaderstatusWords = {
	["순위"] = true;
	["순위판"] = true;
	["랭크"] = true;
	["전채"] = true;
	["랭킹"] = true;
};

-- Off keywords, used on 미나 음악 켜기 and more
_G.onKeywords = {
	["켬"] = true;
	["켜기"] = true;
	["켜"] = true;
	["켜줘"] = true;
	["켜봐"] = true;
	["켜라"] = true;
	["켜줘라"] = true;
	["켜봐라"] = true;
	["켜주세요"] = true;
	["온"] = true;
	["on"] = true;
	["ON"] = true;
	["On"] = true;
	["켜보세요"] = true;
	["켜라고요"] = true;
};

-- Off keywords, used on 미나 음악 끄기 and more
_G.offKeywords = {
	["끔"] = true;
	["끄기"] = true;
	["꺼"] = true;
	["꺼줘"] = true;
	["꺼봐"] = true;
	["꺼라"] = true;
	["꺼줘라"] = true;
	["꺼봐라"] = true;
	["꺼주세요"] = true;
	["오프"] = true;
	["off"] = true;
	["OFF"] = true;
	["Off"] = true;
	["꺼보세요"] = true;
	["꺼라고요"] = true;
};

-- giveing love cooltime
_G.loveCooltime = 3600;

-- this is used on displays disabled on dm message
_G.disableDm = "이 반응은 DM 에서 사용 할 수 없어요! 서버에서 이용해 주세요";
local eulaComment = (
	"\n> %s 기능을 사용할 수 없어요!" ..
	"\n> %s 기능을 사용하려면 **`미나야 약관 동의`** 를 입력해주세요!" ..
	"\n> (약관의 세부정보를 보려면 **`미나야 약관`** 을 입력해주세요)"
);
_G.eulaComment = eulaComment;
local function makeEulaComment(feature)
	return eulaComment:format(feature,feature);
end
_G.makeEulaComment = makeEulaComment;

-- this is used on when user is not accept eula
_G.eulaComment_love = makeEulaComment("호감도");
_G.eulaComment_music = makeEulaComment("음악");

-- the admins of this bot
_G.admins = { -- 관리 명령어 권한
	["367946917197381644"] = true; -- me
	["756035861250048031"] = true; -- my sub account
	["647101613047152640"] = true; -- 눈송이
	["654245768055619584"] = true; -- 12302
};

-- the bot prefixs
_G.prefixs = {
	"미나야";
	"미나";
	"미나야.";
	"미나!";
	"미나야!";
	"미나야...";
	"미나야..",
	"미나...";
	"미나는";
	"미나의";
	"mina";
	"hey mina";
	"민아";
	"민나";
	"민나야";
	"민아야";
	"미냐";
	"미냐야";
	"미냐는";
	"미나가";
	"미냐가";
	"미냐갸";
	"미나갸";
	"ㅁㄴ";
};

-- this is used on display when user messaged only perfixs
_G.prefixReply = { -- 그냥 미나야 하면 답
	"미나는 여기 있어요!","부르셨나요?","넹?",
	"왜요 왜요 왜요?","심심해요?","네넹","미나에요",
	"Zzz... 아! 안졸았어요","네!"
};

-- this is used on when user messaged texts that bot didn't know
_G.unknownReply = { -- 반응 없을때 띄움
	"**(갸우뚱?)**","무슨 말이에요?","네?","으에?"--,"먕?",":thinking: 먀?"
};

-- bot managing functions
local ctime = os.clock;
local status = {
	function ()
		return ("미나 버전 `%s`!"):format(tostring(app.version));
	end;
	"'미나야 도움말' 을 이용해 도움말을 얻거나 '미나야 <할말>' 을 이용해 미나와 대화하세요!";
	function (client)
		local guildCount = 0;
		local memberCount = 0;
		for guild in client.guilds:iter() do
			guildCount = guildCount + 1;
			memberCount = memberCount + (guild.totalMemberCount or 1) - 1;
		end
		return ("%d 개의 서버에서 %d 명의 유저들과 소통하는중!"):format(guildCount,memberCount);
	end;
	function ()
		return ("미나 가동시간 %s!"):format(timeAgo(0,ctime()));
	end;
};
-- local status = {
-- "★☆ 해피 뉴 이어 ☆★";
-- "새해 복 많이 받으세요~";
-- }
local statusLen = #status;
_G.status = status;
_G.ping = "Unknown";
local function startBot(botToken,isTesting) -- 봇 시작시키는 함수
	local client = _G.client;

	-- 토큰주고 시작
	logger.debug("starting bot ...");
	client:run(("Bot %s"):format(botToken),{
		type = 3;
		browser = "DISCORD IOS";
	});
	if isTesting then
		_G.livereloadEnabled = true;
		local prefixs = _G.prefixs;
		for i,v in pairs(prefixs) do
			-- for testing mode, adding ! on prefixs to prevent two bot are crashing!
			prefixs[i] = "!" .. v;
		end
		logger.warn("Testing mode enabled! you should use prefix with !");
		logger.warn("Enabled live reload system for testing!");
	end

	local statusPos = 1;
	local function nextStatus()
		local this = status[statusPos];
		if type(this) == "function" then
			this = this(client);
		end
		client:setGame(this);
		if statusPos == statusLen then
			statusPos = 1;
		else
			statusPos = statusPos + 1;
		end
		timeout(10000,nextStatus);
	end
	client:once("ready",nextStatus);

	for _,v in ipairs(app.args) do
		if v == "env.httpHeartbeat" then
			logger.info("HTTP Heartbeat mode enabled");
			local function heartbeatHTTP()
				corohttp.request("GET","https://discord.com/api/v9");
				-- logger.info("Made heartbeat http on discord.com/api/v9");
				timeout(300000,heartbeatHTTP);
			end
			promise.spawn(heartbeatHTTP);
			break;
		end
	end
end
-- startBot = coroutine.wrap(startBot);
local function reloadBot() -- 봇 종료 함수
	logger.info("try restarting ...");
	client:setGame("재시작중...");
end
local luaExit = os.exit;
os.exit = coroutine.wrap(function (code)
	local function errorHandler(err)
		logger.errorf("An error occurred on killing process.\nerror message was : %s",err);
	end

	xpcall(client.emit,errorHandler,client,"stoping",code);
	xpcall(client.stop,errorHandler,client);
	xpcall(luaExit,errorHandler,code);
end);
_G.reloadBot = reloadBot;
_G.startBot = startBot;

-- timeout
-- js's timeout function that inspired by js's timeout function
-- local remove = table.remove;
-- local unpack = unpack or table.unpack;
-- local pcallWrapper = function (func,promise,...)
-- 	local result = {pcall(func,...)};
-- 	local isPassed = remove(result,1);
-- 	if isPassed then
-- 		local andThen = promise.andThen;
-- 		if andThen then
-- 			andThen(unpack(result));
-- 		end
-- 	end
-- end;
local wrap = coroutine.wrap;
local traceback = debug.traceback;
local function timeoutError(err)
	logger.errorf("[Timeout] Errored on timeout function, error message was\n%s\n%s",
		tostring(err),tostring(traceback())
	);
end
local function timeout(delay,func,...)
	return timer.setTimeout(delay,wrap(xpcall),func,timeoutError,...);
end
_G.timeout = timeout;

-- 일반적인 love 범위들
do
	local cache = {};
	_G.loveRang = function (min,max)
		local key = ("%dx%d"):format(min,max);
		local incache = cache[key];
		if incache then return incache; end
		local new = function ()
			return random(min,max);
		end;
		cache[key] = new;
		return new;
	end;
	_G.defaultLove = loveRang(6,18);
	_G.rmLove = loveRang(-2,-8);
end

--traceback 포멧터
function _G.formatTraceback(msg)
	msg = tostring(msg);
	return msg:gsub(" -%a:[/\\]Users[/\\].-[/\\][Dd]esktop[/\\].-[/\\]","")
		:gsub("[\\/]",".")
		:gsub(".lua$","")
		:gsub("	","    ");
end

-- 재보 쿨타임
_G.reportCooltime = 60*60;

-- 넓이 없는 띄어쓰기 (zwsp)
_G.zwsp = string.char(226,128,139);

-- 최대 경고수
_G.maxWarns = 100;

-- 코드블럭 이스캐이프
_G.codeblockEscape = ("`%s`%s`"):format(zwsp,zwsp);