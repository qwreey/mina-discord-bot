local server = IPC.new("python",{"class/music/youtubeDownload/server/main.py"},true,"YTDL");

local module = {};

local setup = promise.spawn(function ()
	local rateLimit,disableServerSidePostprocessor;
	for _,str in ipairs(app.args) do
		rateLimit = str:match("voice%.download%-rate%-limit=(.-)");
		if str == "voice.disable-server-side-postprocessor" then
			disableServerSidePostprocessor = true;
		end
		if rateLimit and disableServerSidePostprocessor then break; end
	end
	if rateLimit then
		server:request(rateLimit,"setRateLimit");
		logger.infof("[YTDL] rate limit was changed to %s",tostring(rateLimit));
	end
	if disableServerSidePostprocessor then
		server:request(false,"setBuiltinPostProcessorEnabled");
	end
end);

local infoCache = {};
_G.youtubeVideoInfoCache = infoCache;
local musicFile = "./data/youtubeFiles/%s";
local errMessage = "^ERR:(.+)";
local errTimeout = "^TIMEOUT\n?";
local mutexs = setmetatable({},{__mode = "v"});
function module.download(url,vid,lastInfo)
	-- wait for setup server completed
	if setup then
		setup:wait();
		setup = nil;
	end

	local file = musicFile:format(vid:gsub("%-","."));
	local exist = fs.existsSync(file);

	local lastCache = infoCache[vid] or lastInfo;
	if exist and lastCache then
		if lastInfo then
			infoCache[vid] = lastInfo;
		end
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
	data = module.processData(data);
	infoCache[vid] = data;
	downloadMutex:unlock();
	return file,data,nil;
end

local remove = table.remove;
function module.processData(data)
	local subtitles = data.subtitles;
	local thumbnails = data.thumbnails;
	return {
		title = subtitles and subtitles.kr or data.title;
		duration = data.duration;
		thumbnails = thumbnails and {remove(thumbnails)};
		like_count = data.like_count;
		view_count = data.view_count;
		uploader = data.uploader;
		webpage_url = data.webpage_url;
		channel_url = data.channel_url;
		uploader_url = data.uploader_url;
	};
end

return module;
