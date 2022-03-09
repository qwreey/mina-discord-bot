local module = {};

local uv = require("uv");
local stderr_new;
local ytdl = "yt-dlp";
for _,str in ipairs(app.args) do
	if str == "voice.ytdl" then
		ytdl = "youtube-dl";
	elseif str == "voice.stderr-tty" then
		stderr_new = function ()
			return uv.new_tty(2,false);
		end
	end
end
stderr_new = stderr_new or function ()
	return true;
end;

local insert = table.insert;
local musicFile = "./data/youtubeFiles/%s";
local timeoutMs = 45 * 1000;
local mutexs = setmetatable({},{__mode = "v"});
function module.download(url,vid)
	local file = musicFile:format(vid:gsub("%-","."));
	local args = {
		'-f','ba', -- download only audio
		'-o',file, --'./data/youtubeFiles/%(id)s', -- output file
		'--cache-dir','./data/youtubeCache', -- chache
		'-q','--print-json' -- print json
	};
	---@type mutex
	local downloadMutex = mutexs[vid] or mutex.new();
	mutexs[vid] = downloadMutex;
	downloadMutex:wait();
	if fs.existsSync(file) then
		insert(args,'-s');
	else
		downloadMutex:lock();
	end
	insert(args,url);

	local newProcess = spawn(ytdl,{
		args = args;
		cwd = "./";
		stdio = {nil,true,stderr_new()};
	});
	mutexs[vid] = nil;

	local finished;
	local killer = timeout(timeoutMs,function ()
		logger.warnf("[YT-DL] Timeout to download '%s' from youtube",vid);
		if not finished then
			finished = true;
			uv.process_kill(newProcess.handle);
		end
	end);

	local stdout = "";
	for str in newProcess.stdout.read do
		stdout = stdout .. (str or "");
	end
	local stderr = "";
	for str in newProcess.stderr.read do
		stderr = stderr .. (str or "");
	end
	newProcess.waitExit();

	if finished then
		fs.unlinkSync(file);
		fs.unlinkSync(file .. ".part");
		error(module.timeoutMessage);
	end
	finished = true;
	pcall(timer.clearTimer,killer);
	downloadMutex:unlock();

	return file, json.decode(stdout), stderr;
end

return module;
