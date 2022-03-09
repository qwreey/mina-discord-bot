local server = IPC.new("python",{"class/music/youtubeDownload/server/main.py"},true);

local module = {};

_G.youtubeVideoInfoCache = {};
local infoCache = {};
local musicFile = "./data/youtubeFiles/%s";
local errMessage = "^ERR:(.+)";
local errTimeout = "^TIMEOUT\n?";
local mutexs = setmetatable({},{__mode = "v"});
function module.download(url,vid)
	local file = musicFile:format(vid:gsub("%-","."));
    local exist = fs.existsSync(file);

	local lastCache = infoCache[file];
	if exist and lastCache then
		return file,lastCache,nil;
	end

	local downloadMutex = mutexs[vid] or mutex.new(); ---@type mutex
	mutexs[vid] = downloadMutex;
	if not exist then
		downloadMutex:lock();
	elseif downloadMutex:isLocked() then
		downloadMutex:wait();
	end

	local data = server:request{url=url,file=file};
	if type(data) == "string" then
		local err = data:match(errMessage);
		if err then
			if err:match(errTimeout) then
				fs.unlinkSync(file);
				fs.unlinkSync(file .. ".part");
				downloadMutex:unlock();
				return file,nil,module.timeoutMessage;
			end
			downloadMutex:unlock();
			return file,nil,err;
		end
	end
	infoCache[file] = data;
	downloadMutex:unlock();
	return file,data,nil;
end

return module;
