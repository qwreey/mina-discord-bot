local server = IPC.new("python",{"class/music/youtubeDownload/server/main.py"},true);

local module = {};

local musicFile = "./data/youtubeFiles/%s";
local errMessage = "^ERR:(.+)";
local errTimeout = "^TIMEOUT\n?";
local mutexs = setmetatable({},{__mode = "v"});
function module.download(url,vid)
	local file = musicFile:format(vid:gsub("%-","."));
    local exist = fs.existsSync(file);

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
				return module.timeoutMessage;
			end
			downloadMutex:unlock();
			return file,nil,err;
		end
	end
	downloadMutex:unlock();
	return file,data,nil;
end

return module;
