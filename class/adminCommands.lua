--[[
Admin command
]]

local cat = require"cat";
local prettyPrint = prettyPrint or require("pretty-print");
local remove = table.remove;
local concat = table.concat;
local ologger = logger;
local customLogger = setmetatable({__last = ""},{
	__index = function (self,index)
		local object = ologger[index];
		local objectType = type(object);
		if objectType == "function" then
			local function this(...)
				local output = object(...);
				if output == nil then return end
				remove(output,1);
				local str = concat(output);
				self.__last = self.__last .. str;
				return str;
			end
			self[index] = this;
			return this;
		end
		return object;
	end;
});

local function executeMessage(message,args,mode)
	if mode == "lua" then
	else args = cat.compile(args);
	end

	-- load string to function
	local func,err = loadstring("return " .. args);
	if not func then
		func,err = loadstring(args);
	end
	if err or (not func) then
		message:reply("[ERROR] Error occured on loadstring! traceback : " .. tostring(err));
		return;
	end

	-- get env
	loadstringEnv.__enable();
	logger.noStdout = true;
	rawset(loadstringEnv,"logger",customLogger);
	rawset(loadstringEnv,"log",customLogger);
	rawset(loadstringEnv,"send",function (str)
		message:reply(str);
	end);
	rawset(loadstringEnv,"message",message);
	rawset(loadstringEnv,"guild",message.guild);
	rawset(loadstringEnv,"member",message.member);
	rawset(loadstringEnv,"user",message.author);
	rawset(loadstringEnv,"channel",message.channel);
	customLogger.__last = "";

	-- execute
	promise.new(setfenv(func,loadstringEnv))
		:andThen(function (value)
			local loggerStringRaw = customLogger.__last;
			local valueType = type(value);
			local loggerString = ((loggerStringRaw ~= "" and valueType ~= "nil") and "\n---logger---\n" or "") .. loggerStringRaw;
			if value == loggerStringRaw then
				value = loggerStringRaw;
				loggerString = "";
			end
			local output = (valueType == "nil" and loggerString ~= "" and "")
				or (valueType == "string" and value)
				or ("\27[32m"..tostring(prettyPrint.dump(value,nil,true)).."\27[0m") .. loggerString;
			if #output > 2000 then
				message:reply{
					content = "​";
					file = {"output.log",output:gsub("\27[.-m","")};
				};
			else
				message:reply("```ansi\n" .. output .. "\n```");
			end
		end)
		:catch(function (err)
			message:reply(("Error!```ansi\n%s\n```"):format(tostring(err)));
		end):wait();

	-- unload env
	rawset(loadstringEnv,"logger",nil);
	rawset(loadstringEnv,"log",nil);
	rawset(loadstringEnv,"send",nil);
	rawset(loadstringEnv,"message",nil);
	rawset(loadstringEnv,"guild",nil);
	rawset(loadstringEnv,"member",nil);
	rawset(loadstringEnv,"user",nil);
	rawset(loadstringEnv,"channel",nil);
	loadstringEnv.__disable();
	logger.noStdout = false;
	return true;
end

---@param Text string
---@param message Message
local function adminCmd(Text,message) -- 봇 관리 커맨드 실행 함수
	local cmd = Text:match("^[^ \n]+");
	if not cmd then return; end
	local args = Text:sub(#cmd+2,-1);
	if (cmd == "!!!stop" or cmd == "!!!kill") then
		message:reply('> 프로그램 죽이는중 . . .');
		os.exit(exitCodes.exit); -- 프로그램 킬
		return true;
	elseif (cmd == "!!!restart" or cmd == "!!!reload") then
		logger.info("Restarting ...");
		message:reply('> 재시작중 . . . (2초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 프로그램 다시시작
		return true;
	elseif (cmd == "!!!pull" or cmd == "!!!download") then
		logger.info("Download codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 받는중 . . .');
		_G.livereloadEnabled = false;
		os.execute("git pull"); -- git 에서 변동사항 가져와 적용하기
		_G.livereloadEnabled = true;
		msg:setContent('> 적용중 . . . (3초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 다운로드 (리로드)\
		return true;
	elseif (cmd == "!!!push" or cmd == "!!!upload") then
		logger.info("Upload codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 코드를 업로드중 . . .');
		_G.livereloadEnabled = false;
		os.execute("git add .&&git commit -m 'MINA : Upload in main code (bot.lua)'&&git push");
		_G.livereloadEnabled = true;
		msg:setContent('> 완료!');
		return true; -- 업로드
	elseif (cmd == "!!!sync") then
		logger.info("Sync codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 동기화중 . . . (8초 내로 완료됩니다)');
		_G.livereloadEnabled = false;
		os.execute('git add .&&git commit -m "MINA : Sync in main code (Bot.lua)"&&git pull&&git push');
		_G.livereloadEnabled = true;
		msg:setContent('> 적용중 . . . (3초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 동기화 (리로드)
		return true;
	elseif (cmd == "!!!help" or cmd == "!!!cmds") then
		message:reply(
			'!!!help 또는 !!!cmds : 이 창을 띄웁니다\n' ..
			'!!!stop 또는 !!!kill : 봇을 멈춥니다\n' ..
			'!!!restart 또는 !!!reload : 봇을 다시로드 시킵니다\n' ..
			'!!!pull 또는 !!!download : 클라우드로부터 코드를 내려받고 다시 시작합니다\n' ..
			'!!!push 또는 !!!upload : 클라우드로 코드를 올립니다\n' ..
			'!!!sync : 클라우드와 코드를 동기화 시킵니다 (차이 비교후 병합)\n'
		);
		return true;
	elseif (cmd == "!!!exe" or cmd == "!!!exec" or cmd == "!!!execute" or cmd == "!!!loadstring" or cmd =="!!!e") then
		executeMessage(message,args:gsub("^lua ?",""),
			args:match("^lua") and "lua"
		)
	end
end

return adminCmd;
