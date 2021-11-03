--[[
Bot process spawner

this is will enables live reload system and auto respawn process when process have exited with errors
]]

local insert = table.insert;
local uv = require("uv");
local exitCodes = require("app.exitCodes");
local spawn = require("coro-spawn");
local prettyPrint = require("pretty-print");
args[0] = nil;
args[1] = "app/main";

local function spawnProcess(path,thisArgs)
	-- return os.execute("bin\\luvit.exe " .. path .. table.concat(thisArgs or {}, " "));
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

	-- local _,_,exitCode = os.execute("bin\\luvit.exe app/main");
	-- return exitCode;
	local newProcess = spawn("./bin/luvit",{
		stdio = {0,1,2};
		args = newArgs;
		cwd = "./";
	});
	-- for str in newProcess.stdout.read do
	-- 	prettyPrint.stdout:write(str);
	-- end
	return newProcess.waitExit();
end

local function loopProcess(path,thisArgs)
	while true do
		local exitCode = spawnProcess(path,thisArgs);
		prettyPrint.stdout:write(("\27[2K\r\27[95m[EXIT  %s] \27[0m----------------------------------------------------------------------------\n"):format(os.date("%H:%M")));
		prettyPrint.stdout:write(("\27[2K\r\27[95m[EXIT  %s] \27[0mMain process was exited with return code : %s\n"):format(os.date("%H:%M"),tostring(exitCode)));

		if exitCode == exitCodes.exit then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[0mApp was passed process kill code. Killing luvit app tree ...\n"):format(os.date("%H:%M")));
			os.exit(0);
		elseif exitCode == exitCodes.error then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[0mApp was passed error code. Reload 5s later ...\n"):format(os.date("%H:%M")));
			uv.sleep(5000);
		elseif exitCode == exitCodes.reload then
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[0mApp called reloading ...\n"):format(os.date("%H:%M")));
		else
			prettyPrint.stdout:write(("\27[95m[EXIT  %s] \27[0mApp was killed with some unexpected error. Reload 5s later ...\n"):format(os.date("%H:%M")));
			uv.sleep(5000);
		end
		prettyPrint.stdout:write(("\27[2K\r\27[93m[SETUP %s] \27[0mSpawn new process!\n"):format(os.date("%H:%M")));
		prettyPrint.stdout:write(("\27[2K\r\27[93m[SETUP %s] \27[0m----------------------------------------------------------------------------\n"):format(os.date("%H:%M")));
	end
end
loopProcess = coroutine.wrap(loopProcess);

loopProcess("app/main");
