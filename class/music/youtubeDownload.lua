<<<<<<< HEAD
<<<<<<< HEAD
local module = {};

local uv = require("uv");
local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = false;
local timeoutMessage = "Timeout! Audio Download takes too much time!";
module.timeoutMessage = timeoutMessage;

local ytdl = "yt-dlp";
for _,str in ipairs(app.args) do
    if str == "voice.ytdl" then
        ytdl = "youtube-dl";
    end
end

local insert = table.insert;
local musicFile = "./data/youtubeFiles/%s";
local timeoutMs = 15 * 1000;
local mutexs = setmetatable({},{__mode = "kv"});
local function download(url,vid)
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
		stdio = {nil,true,true};
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
        error(timeoutMessage);
    end
    finished = true;
    pcall(timer.clearTimer,killer);
	downloadMutex:unlock();

	return file, stdout, stderr, newProcess;
end

function module.download(vid)
	vid = module.getVID(vid);
	if not vid then
		error("got invalid video id!");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,stderr,newProcess = download(url,vid);
	if isExistString(info) and isExistString(audio) then
		return audio,json.decode(info),url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg = ("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!\nstderr : %s"):format(
		tostring(stderr)
	);
	logger.error(errormsg);
	qDebug {
		title = "failed to download video from youtube";
		traceback = stderr;
		process = newProcess;
		vid = vid;
		status = "error";
		msg = errormsg;
	};
	error(errormsg);
end

local vidFormat = ("[%w%-_]"):rep(11);
local vidWatch = ("watch%%?v=(%s)"):format(vidFormat);
local vidShort = ("https://youtu%%.be/(%s)"):format(vidFormat);
local searchURLTemp = ("https://www.googleapis.com/youtube/v3/search?key=%s&part=snippet&maxResults=8&q=%%s"):format(ACCOUNTData.GoogleAPIKey);
function module.search(url)
	local _,Body = corohttp.request("GET",
		searchURLTemp:format(urlCode.urlEncode(url))
	);
	if not Body then return end
	Body = json.decode(Body);
	if not Body then return end
	local items = Body.items;
	if not items then return end
	local thing = items[1];
	if not thing then return end
	local id = thing.id;
	if not id then return end
	return id.videoId;
end
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or module.search(url);
end

return module;
=======
local module = {};

local uv = require("uv");
local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = false;
local timeoutMessage = "Timeout! Audio Download takes too much time!";
module.timeoutMessage = timeoutMessage;

local ytdl = "yt-dlp";
for _,str in ipairs(app.args) do
    if str == "voice.ytdl" then
        ytdl = "youtube-dl";
    end
end

local insert = table.insert;
local musicFile = "./data/youtubeFiles/%s";
local timeoutMs = 15 * 1000;
local mutexs = setmetatable({},{__mode = "kv"});
local function download(url,vid)
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
		stdio = {nil,true,true};
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
        error(timeoutMessage);
    end
    finished = true;
    pcall(timer.clearTimer,killer);
	downloadMutex:unlock();

	return file, stdout, stderr, newProcess;
end

function module.download(vid)
	vid = module.getVID(vid);
	if not vid then
		error("got invalid video id!");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,stderr,newProcess = download(url,vid);
	if isExistString(info) and isExistString(audio) then
		return audio,json.decode(info),url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg = ("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!\nstderr : %s"):format(
		tostring(stderr)
	);
	logger.error(errormsg);
	qDebug {
		title = "failed to download video from youtube";
		traceback = stderr;
		process = newProcess;
		vid = vid;
		status = "error";
		msg = errormsg;
	};
	error(errormsg);
end

local vidFormat = ("[%w%-_]"):rep(11);
local vidWatch = ("watch%%?v=(%s)"):format(vidFormat);
local vidShort = ("https://youtu%%.be/(%s)"):format(vidFormat);
local searchURLTemp = ("https://www.googleapis.com/youtube/v3/search?key=%s&part=snippet&maxResults=8&q=%%s"):format(ACCOUNTData.GoogleAPIKey);
function module.search(url)
	local _,Body = corohttp.request("GET",
		searchURLTemp:format(urlCode.urlEncode(url))
	);
	if not Body then return end
	Body = json.decode(Body);
	if not Body then return end
	local items = Body.items;
	if not items then return end
	local thing = items[1];
	if not thing then return end
	local id = thing.id;
	if not id then return end
	return id.videoId;
end
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or module.search(url);
end

return module;
>>>>>>> 6f9009e3595c0f7c49c980abf1c40952b9193593
=======
local module = {};

local uv = require("uv");
local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = false;
local timeoutMessage = "Timeout! Audio Download takes too much time!";
module.timeoutMessage = timeoutMessage;

local ytdl = "yt-dlp";
for _,str in ipairs(app.args) do
    if str == "voice.ytdl" then
        ytdl = "youtube-dl";
    end
end

local insert = table.insert;
local musicFile = "./data/youtubeFiles/%s";
local timeoutMs = 15 * 1000;
local mutexs = setmetatable({},{__mode = "kv"});
local function download(url,vid)
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
		stdio = {nil,true,true};
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
        error(timeoutMessage);
    end
    finished = true;
    pcall(timer.clearTimer,killer);
	downloadMutex:unlock();

	return file, stdout, stderr, newProcess;
end

function module.download(vid)
	vid = module.getVID(vid);
	if not vid then
		error("got invalid video id!");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,stderr,newProcess = download(url,vid);
	if isExistString(info) and isExistString(audio) then
		return audio,json.decode(info),url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg = ("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!\nstderr : %s"):format(
		tostring(stderr)
	);
	logger.error(errormsg);
	qDebug {
		title = "failed to download video from youtube";
		traceback = stderr;
		process = newProcess;
		vid = vid;
		status = "error";
		msg = errormsg;
	};
	error(errormsg);
end

local vidFormat = ("[%w%-_]"):rep(11);
local vidWatch = ("watch%%?v=(%s)"):format(vidFormat);
local vidShort = ("https://youtu%%.be/(%s)"):format(vidFormat);
local searchURLTemp = ("https://www.googleapis.com/youtube/v3/search?key=%s&part=snippet&maxResults=8&q=%%s"):format(ACCOUNTData.GoogleAPIKey);
function module.search(url)
	local _,Body = corohttp.request("GET",
		searchURLTemp:format(urlCode.urlEncode(url))
	);
	if not Body then return end
	Body = json.decode(Body);
	if not Body then return end
	local items = Body.items;
	if not items then return end
	local thing = items[1];
	if not thing then return end
	local id = thing.id;
	if not id then return end
	return id.videoId;
end
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or module.search(url);
end

return module;
>>>>>>> 6f9009e3595c0f7c49c980abf1c40952b9193593
