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
args[0] = nil;
args[1] = "app/main";

-- set os flag
local osFlag = "";
for i,v in pairs(args) do
    local matching = v:match"os%.flag=(.*)";
    if matching then
        osFlag = matching;
        break;
    end
end

local bin = {
	Windows = "./bin/Windows_%s/luvit.exe";
	Linux = "./bin/Linux_%s/luvit";
};

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
-- Setup binary executables
if jit.os == "Linux" then -- if this os is linux, adding executing permissions to bin files
	local binPath = ("./bin/Linux_%s"):format(jit.arch);
	for _,binFile in ipairs(listOfBinFiles) do
		chmod("u+x",("%s/%s"):format(binPath,binFile)); -- adding execute permissions on bin files
	end
end

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

local function spawnProcess(path,thisArgs)
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

	local newProcess = spawn(bin[jit.os]:format(jit.arch),{
		stdio = {0,1,2};
		args = newArgs;
		cwd = "./";
	});
	return newProcess.waitExit();
end

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

loopProcess("main","app/main",{
	"--logger_prefix","main";
});
-- loopProcess("data","app/data");
