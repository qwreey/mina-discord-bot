local module = {};
local searchURLTemp = "https://www.googleapis.com/youtube/v3/search?type=video&key=%s&part=snippet&maxResults=%d&q=%s";
local apikeyIdx = 0

local maxApikeyIdx = #ACCOUNTData.GoogleAPIKeyFailback

function module.getAPIKey()
	return apikeyIdx == 0 and ACCOUNTData.GoogleAPIKey or ACCOUNTData.GoogleAPIKeyFailback[apikeyIdx];
end
local getAPIKey = module.getAPIKey;

function module.nextAPIKey(recurseCount)
	local nextKey = (apikeyIdx + 1)%(maxApikeyIdx + 1)
	logger.infof(
		"Error occurred on YoutubeApi key. recurse with using failback key instead for resolve limit issue\n |- Used key: %d%s\n |- Next key: %s\n |- Header dump: %s |- Body dump: %s",
		apikeyIdx,apikeyIdx == 0 and " (Default)" or "",
		nextKey,
		json.encode(header),json.encode(body)
	)
	apikeyIdx = nextKey
	if (recurseCount or 0) > maxApikeyIdx then return end
	return (recurseCount or 0) + 1
end
local nextAPIKey = module.nextAPIKey

function module.searchVideo(url,recurseCount)
	local header,body = corohttp.request("GET",
		searchURLTemp:format(
			getAPIKey(),1,urlCode.urlEncode(url)
		)
	);

	if header and header.code == 403 then
		return module.searchVideo(url,nextAPIKey(recurseCount))
	end

	-- logger.infof("Youtube search request: %s",url)
	-- logger.info(_)

	if not body then return end
	body = json.decode(body);
	if not body then return end
	local items = body.items;
	if not items then return end
	local thing = items[1];
	if not thing then return end
	local id = thing.id;
	if not id then return end
	return id.videoId;
end

local insert = table.insert;
local toLuaStr = myXml.toLuaStr;
function module.searchVideos(url,maxResults,withData,recurseCount)
	local header,Body = corohttp.request("GET",
		searchURLTemp:format(
			getAPIKey(),maxResults or 10,urlCode.urlEncode(url)
		)
	);

	if header and header.code == 403 then
		return module.searchVideos(url,maxResults,withData,nextAPIKey(recurseCount))
	end

	if not Body then return end
	Body = json.decode(Body);
	if not Body then return end
	local items = Body.items;
	if not items then return end

	local list = {};
	if withData then
		for _,thing in ipairs(items) do
			local videoId = thing.id;
			videoId = videoId and videoId.videoId;
			local snippet = thing.snippet;
			if videoId and snippet then
				insert(list,{
					videoId = videoId;
					title = toLuaStr(snippet.title or "NULL");
					channelTitle = toLuaStr(snippet.channelTitle or "NULL");
					description = toLuaStr(snippet.description or "NULL");
				});
			end
		end
	else
		for _,thing in ipairs(items) do
			local videoId = thing.id and thing.videoId;
			if videoId then
				insert(list,videoId);
			end
		end
	end

	return list;
end

local searchVideo = module.searchVideo;
local vidFormat = ("^[%w%-_]+$"):rep(11);
local vidWatch = ("watch%%?v=(%s)"):format(vidFormat);
local vidShort = ("https://youtu%%.be/(%s)"):format(vidFormat);
function module.getVideoId(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or searchVideo(url);
end

function module.isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

local urlFormat = "https://www.youtube.com/watch?v=%s";
function module.formatUrl(vid)
	return urlFormat:format(tostring(vid));
end

return module;
