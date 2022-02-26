local history = readline.History.new(); -- 히스토리 홀더 만들기
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history}); _G.editor = editor;
local app = app;
local version = app and app.version;
local prettyPrint = prettyPrint or require("pretty-print");
local promise = _G.promise;
local wrap = coroutine.wrap;
local insert = table.insert;
local unpack = unpack or table.unpack;
local pack = table.pack;
local cat = require"cat";

local utf8Len = utf8.len;
local utf8Offset = utf8.offset;
local function strcut(str,targetLen)
	local esp = str:gsub("\27%[.-;",function (this)
		return "";
	end);
	if utf8Len(esp) <= targetLen then
		return str;
	end

	local ret = "";
	local len = 0;
	local last = str:gsub("((.-)(\27%[.-m))",function(all,front,color)
		if len == targetLen then
			return "";
		end
		local frontLen = utf8Len(front);
		local sumLen = len + frontLen;
		if sumLen > targetLen then
			ret = ret .. front:sub(1,utf8Offset(front,targetLen-len));
			sumLen = targetLen;
		else
			ret = ret .. front .. color;
		end
		len = sumLen;
		return "";
	end);
	if len < targetLen then
		ret = ret .. last:sub(1,utf8Offset(last,targetLen-len));
	end
	return ret .. ("\27[0m   [Cutted to %d words]"):format(targetLen);
end

local outputMaxlength = 5000;
local colors = {
	black = {30,40};
	red = {31,41};
	green = {32,42};
	yellow = {33,43};
	blue = {34,44};
	magenta = {35,45};
	cyan = {36,46};
	white = {37,47};
	gray = {90,100};
	brightRed = {91,101};
	brightGreen = {92,102};
	brightYellow = {93,103};
	brightBlue = {94,104};
	brightMagenta = {95,105};
	brightCyan = {96,106};
	brightWhite = {97,107};
};
local powerline_arrow_right = "";

local lastColor;
local function buildLine(color,text)
	local str = lastColor
		and (("\27[%d;%dm%s"):format(lastColor[1],color[2],powerline_arrow_right))
		or (("\27[%dm"):format(color[2]));
	str = str .. ("\27[30m %s "):format(text);
	lastColor = color;
	return str;
end
_G.buildLine = buildLine;

local lastLine;
local function buildPrompt()
	local str = "";

	if lastLine then
		str = "";
	else
		str = str .. buildLine(colors.blue,"APP");
		str = str .. buildLine(colors.yellow," " .. version);

		-- set end point
		str = str .. ("\27[0m\27[%dm\27[0m "):format(lastColor[1]);
		lastColor = nil;
	end
	return str;
end
_G.buildPrompt = buildPrompt;

local runEnv = { -- 명령어 실행 환경 만들기
	runSchedule = timeout;
};
local function appendMessage(msgEnv,str)
	if not msgEnv then return; end
	local mutex = msgEnv.mutex;
	local message = msgEnv.message;
	local content = msgEnv.content;
	if not content then
		content = message.content;
	end
	mutex:lock();
	str = str:gsub("```","\\`\\`\\`");
	content = ("%s%s```"):format(content:gsub("```$",""),str);
	if #content > 2000 then
		content = ("```ansi\n%s```"):format(str);
		message = message:reply(content);
		msgEnv.content = content;
		msgEnv.message = message;
	else
		message:setContent(content);
		msgEnv.content = content;
	end
	timer.sleep(20);
	mutex:unlock();
	return message;
end
local function readPipe(pipe,msgEnv)
	for str in pipe.read do
		logger.info(str:gsub("\n$",""));
		appendMessage(msgEnv,str);
	end
end
local remove = table.remove;
function runEnv.exec(command,sendf) -- process open
	local send = send or sendf;
	local split = argsParser.split(command);
	local proc = remove(split,1);
	local cproc,err = spawn(proc,{args = split,stdio = {true,true,true}});

	if not cproc then
		return "ERR : "..err;
	end

	local msg = send and send(("```ansi\n $ %s\n```"):format(command));
	local msgEnv = msg and {message = msg,mutex = mutex.new()};
	local waitter = promise.waitter();
	waitter:add(promise.new(readPipe,cproc.stdout,msgEnv));
	waitter:add(promise.new(readPipe,cproc.stderr,msgEnv));
	waitter:wait();
	local ecode,esignal = cproc.waitExit();
	if msg then
		appendMessage(msgEnv,("Exit with code %s (%s)"):format(tostring(ecode),tostring(esignal)));
		-- msgMutex:lock();
		-- msg:setContent(("%s\n%s```"):format(msg.content:gsub("```$",""),("Exit with code %s (%s)"):format(tostring(ecode),tostring(esignal))));
		-- msgMutex:unlock();
	end
	return {ignore = true};
end
function runEnv.clear() -- 화면 지우기 명령어
	os.execute(jit.os == "Windows" and "cls" or "clear");
	return "screen clear!";
end
function runEnv.exit() -- 봇 끄기
	prettyPrint.stdout:write{"\27[2K\r\27[",tostring(colors.red[1]),"m[ PROCESS STOPPED ]\27[0m\n"};
	os.exit(exitCodes.exit);
end
function runEnv.reload() -- 다시 로드
	os.execute("cls");
	os.exit(exitCodes.reload);
end
function runEnv.print(...)
	prettyPrint.stdout:write"\27[2K\r";
	for _,v in pairs({...}) do
		if type(v) == "string" then
			prettyPrint.stdout:write{v};
		else
			prettyPrint.stdout:write{prettyPrint.dump(v)};
		end
	end
	prettyPrint.stdout:write{"\n",buildPrompt()};
end
runEnv.__last = {};
function runEnv.__enable()
	local logger = _G.logger;
	runEnv.__last.logger_prefix = logger.prefix;
	logger.__lineinfo = "";
	logger.prefix = "cmd";
	logger.noLineInfo = true;
	logger.noLiner = true;
end
function runEnv.__disable()
	local logger = _G.logger;
	local last = runEnv.__last;
	logger.__lineinfo = nil;
	logger.prefix = last.logger_prefix;
	logger.noLineInfo = nil;
	logger.noLiner = nil;
	last.logger_prefix = nil;
end
_G.print = runEnv.print;
runEnv.restart = runEnv.reload;
function runEnv.help() -- 도움말
	return {
		clear = "clear screen";
		exit = "kill luvit/cmd";
		reload = "reload code";
		restart = "same with reload";
		help = "show this msg";
		loadUserData = "get user data table";
		saveUserData = "save user data table";
	};
end
function runEnv.imporcat(file)
	local compiled = cat.compile(fs.readFileSync(file));
	local func,err = loadstring(compiled)
	if func and not err then
		return func();
	end
	error(err);
end
function runEnv.loadUserData(id)
	return userData.loadData(id);
end
function runEnv.saveUserData(id)
	return userData.saveData(id);
end
function runEnv.setPremium(id,days)
	local data = userData.loadData(id);
	if data then
		data.premiumStatus = posixTime.now() + (86400*days);
		return userData.saveData(id);
	else error"Connot found user data!";
	end
end
function runEnv.setLove(id,love)
	local data = userData.loadData(id);
	if data then
		data.love = love;
		return userData.saveData(id);
	else error"Connot found user data!";
	end
end
function runEnv.getUser(id)
	return client:getUser(id);
end
function runEnv.getGuild(id)
	return client:getGuild(id);
end
function runEnv.getChannel(id)
	return client:getChannel(id);
end
function runEnv.getEmoji(id)
	return client:getEmoji(id);
end
function runEnv.getRole(id)
	return client:getRole(id);
end
function runEnv.getMember(gid,uid)
	return client:getGuild(gid):getMember(uid);
end
function runEnv.each(t,fn,mode)
	for i,v in (mode and ipairs or pairs)(t) do
		fn(v,i);
	end
end
setmetatable(runEnv,{ -- lua can use metable env... cuz lua's global is a table!!
	__index = _G;
	__newindex = _G;
});
_G.loadstringEnv = runEnv;

-- 라인 읽기 함수
return function ()
	local loaded = false;
	local function bindOnLine(func)
		if prettyPrint.stdin.set_mode then
			editor:readLine(buildPrompt(), func);
		elseif not loaded then
			process.stdin:on(function (str)
				func(nil,func);
			end);
		end
		loaded = true
	end

	local protectedOnLine;
	local function onLine(err, line, ...)
		if line then

			-- merge last line (for read multi lines)
			local oline = line;
			if lastLine then
				line = lastLine .. "\n" .. line;
			end

			-- if it is start with .; it is console command!
			local cmdMode = line:sub(1,1) == ".";
			if cmdMode then
				local lastStatus = _G.livereloadEnabled;
				_G.livereloadEnabled = false;
				local _,_,returncode = os.execute(line:sub(2,-1));
				prettyPrint.stdout:write{" → ",prettyPrint.dump(returncode),"\n"};
				uv.sleep(20);
				_G.livereloadEnabled = lastStatus;
				bindOnLine(protectedOnLine);
				editor:refreshLine();
				return;
			end

			-- first, decoding lua
			local func,err = loadstring("return " .. line);
			if not func then
				func,err = loadstring(line);
			end

			-- lua wants more line, bypass running
			if err and oline ~= "" and (err:match "'<eof>'$" or
						err:match "unexpected symbol near '%['" or
						err:match "unexpected symbol near '%]'" or
						err:match "unexpected symbol near '{'" or
						err:match "unexpected symbol near '}'" or
						err:match "unexpected symbol near '%('" or
						err:match "unexpected symbol near '%)'") then
				if not lastLine then
					prettyPrint.stdout:write{"\27[92mMulti line mode . . .\n\27[32m","",line,"\n"};
				end
				lastLine = line;
			elseif err or (not func) then
				logger.errorf("Cannot make function from console, error was\n%s",tostring(err));
				lastLine = nil;
			else lastLine = nil;
			end

			-- continue read lines
			if lastLine or err or (not func) then
				bindOnLine(protectedOnLine);
				editor:refreshLine();
				return;
			end
			wrap(function ()
				runEnv.__enable();
				promise.new(setfenv(func,runEnv))
					:andThen(function (...)
						local printing = {"\27[2K\r → \27[0m"};
						local args = pack(...);
						local len = args.n;
						for i,this in ipairs({...}) do
							insert(printing,strcut(prettyPrint.dump(this),outputMaxlength));
							if i ~= len then
								insert(printing,",\n\27[2K\r · \27[0m");
							end
						end
						if len == 0 then
							insert(printing,prettyPrint.dump(nil));
						end
						insert(printing,"\n");
						prettyPrint.stdout:write{unpack(printing)};
					end)
					:catch(function (err)
						logger.errorf("LUA | error : %s",err);
						prettyPrint.stdout:write "\27[2K\r";
					end):wait();
				runEnv.__disable();
				bindOnLine(protectedOnLine);
			end)();
		else
			process:exit();
		end
	end
	local traceback = debug.traceback;
	local function catch(err)
		logger.errorf("Error on console execution\n%s\n%s",err,traceback());
	end
	function protectedOnLine(...)
		xpcall(onLine,catch,...);
	end
	bindOnLine(protectedOnLine); -- 라인 읽기 시작
	-- 로거에 글자 리프래셔 저장
	if prettyPrint.stdin.set_mode then
		function logger.refreshLine()
			editor:refreshLine();
		end
	end
end
