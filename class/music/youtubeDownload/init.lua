local module = {};

local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = false;
local timeoutMessage = "Timeout! Audio Download takes too much time!";
module.timeoutMessage = timeoutMessage;

local download;
for _,str in ipairs(app.args) do
    if str == "voice.no-download-server" then
        download = require(... .. ".childprocess");
    end
end
download = download or require(... .. ".server");
download.timeoutMessage = timeoutMessage;
download = download.download;

function module.download(vid)
	vid = module.getVID(vid);
	if not vid then
		error("got invalid video id!");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,err = download(url,vid);
	if isExistString(info) and isExistString(audio) then
		return audio,info,url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg =
		("오류가 발생했습니다, YoutubeDL 이 잘못된 값을 출력했습니다.\nstderr : %s")
		:format(tostring(err));
	logger.error(errormsg);
	qDebug {
		title = "failed to download video from youtube";
		traceback = err;
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
---returns the video id of link
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or module.search(url);
end

return module;
