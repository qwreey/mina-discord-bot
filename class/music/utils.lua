local module = {};
local searchURLTemp = ("https://www.googleapis.com/youtube/v3/search?type=video&key=%s&part=snippet&maxResults=%%d&q=%%s"):format(ACCOUNTData.GoogleAPIKey);

function module.searchVideo(url)
	local _,Body = corohttp.request("GET",
		searchURLTemp:format(1,urlCode.urlEncode(url))
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

local insert = table.insert;
local toLuaStr = myXml.toLuaStr;
function module.searchVideos(url,maxResults,withData)
	local _,Body = corohttp.request("GET",
		searchURLTemp:format(maxResults or 10,urlCode.urlEncode(url))
	);
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
					title = toLuaStr(tostring(snippet.title));
					channelTitle = toLuaStr(tostring(snippet.channelTitle));
					description = toLuaStr(tostring(snippet.description));
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
local vidFormat = ("[%w%-_]"):rep(11);
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
