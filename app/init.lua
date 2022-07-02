--[[
Bot process spawner

this is will enables live reload system and auto respawn process when process have exited with errors
]]

local insert = table.insert;
local uv = require("uv");
local exitCodes = require("app.exitCodes");
local spawn = require("coro-spawn");
local prettyPrint = require("pretty-print");
local jit = require("jit");
local fs = require("fs");
args[0] = nil;
args[1] = "app/main";

-- set os flag
local osFlag = "";
for i,v in pairs(args) do
    local matching = v:match"^os%.flag=(.*)";
    if matching then
        osFlag = "_" .. matching;
        break;
    end
end

-- set bin file for each os
local binPath;
local osName = jit.os;
local archName = jit.arch;
if osName == "Windows" then
	binPath = ("./bin/Windows_%s%s"):format(archName,osFlag);
elseif osName == "Linux" then
	binPath = ("./bin/Linux_%s%s"):format(archName,osFlag);
else
	return prettyPrint.stdout:write(("\27[2K\r\27[95m[EXIT  %s]\27[0m Unsupported os '%s'\n"):format(osName));
end

---Concat paths
local function concatPath(...)
	local items = {...};
	local str;
	for _,v in ipairs(items) do
		if not str then
			str = v;
		else
			str = ("%s/%s"):format(str,v);
		end
	end
	return str;
end

-- Setup binary executables
if osName == "Linux" then -- if this os is linux, adding executing permissions to bin files
	---Change mode of file, it will only works on linux
	---@param k string the mode to change or add or remove (like chmod command)
	---@param v string the file to change
	---@return boolean passed is passed successfully
	---@return string resultsOrErrors if it was passed successfully, this value is result of command (stdout) or it was failed, this value is error of command (stderr or stdout)
	---@return number exitCode the process exit code (in number)
	local function chmod(k,v)
		local proc = io.popen(("chmod %s %s"):format(k,v));
		local results = proc:read();
		local passed,exitSig,exitCode = proc:close();
		proc = nil;
		return passed,passed and results or exitSig,exitCode;
	end

	local listOfBinFiles = {
		"lit","luvi","luvit","yt-dlp"
	};
	for _,binFile in ipairs(listOfBinFiles) do
		chmod("u+x",concatPath(binPath,binFile)); -- adding execute permissions on bin files
	end
end

-- Set utf-8 terminal if os is window
if osName == "Windows" then
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

-- spawn process function (with support adding more args)
local function spawnProcess(path,thisArgs)
	if type(thisArgs) == "function" then
		thisArgs = thisArgs();
	end
	local newArgs = {};
	for i,v in pairs(args) do
		newArgs[i] = v;
	end
	if path then
		newArgs[1] = path;
	end
	if thisArgs then
		for _,v in ipairs(thisArgs) do
			insert(newArgs,v);
		end
	end

	local newProcess = spawn(concatPath(binPath,osName == "Windows" and "luvit.exe" or "luvit"),{
		stdio = {0,1,2};
		args = newArgs;
		cwd = "./";
	});
	return newProcess.waitExit();
end

-- loop spawn process, if dead
local function loopProcess(name,path,thisArgs)
	while true do
		local exitCode = spawnProcess(path,thisArgs);
		-- prettyPrint.stdout:write(("\27[2K\r\27[95m[EXIT  %s] \27[0m----------------------------------------------------------------------------\n"):format(os.date("%H:%M")));
		prettyPrint.stdout:write(("\27[2K\r\27[95m[EXIT  %s] \27[93m(%s)\27[0m process was exited with return code : %s\n"):format(os.date("%H:%M"),name,tostring(exitCode)));

		if exitCode == exitCodes.exit then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[93m(%s)\27[0m App was passed process kill code. Killing luvit app tree ...\n"):format(os.date("%H:%M"),name));
			os.exit(0);
		elseif exitCode == exitCodes.error then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[93m(%s)\27[0m App was passed error code. Reload 5s later ...\n"):format(os.date("%H:%M"),name));
			uv.sleep(5000);
		elseif exitCode == exitCodes.reload then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[93m(%s)\27[0m App called reloading ...\n"):format(os.date("%H:%M"),name));
		else
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[93m(%s)\27[0m App was killed with some unexpected error. Reload 5s later ...\n"):format(os.date("%H:%M"),name));
			uv.sleep(5000);
		end
		prettyPrint.stdout:write(("\27[2K\r\27[93m[SETUP %s] \27[93m(%s)\27[0m Spawn new process!\n"):format(os.date("%H:%M"),name));
		-- prettyPrint.stdout:write(("\27[2K\r\27[93m[SETUP %s] \27[0m----------------------------------------------------------------------------\n"):format(os.date("%H:%M")));
	end
end
loopProcess = coroutine.wrap(loopProcess);

-- run main server
loopProcess("main","app/main",function ()
	local default = {
		"--logger_prefix","main";
		("binPath=%s"):format(binPath);
	};

	local flags = fs.readFileSync(".flags");
	if flags then
		for str in flags:gmatch("(.-);\n") do
			local replaced = str:gsub("\\n","\n");
			insert(default,replaced);
		end
		insert(default,"env.flagfile");
	end
	return default;
end);
-- loopProcess("data","app/data");
