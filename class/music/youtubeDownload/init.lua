local module = {};

local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = false;
local timeoutMessage = "ERR:TIMEOUT";
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

function module.errorFormater(str)
	-- blocked on country
	local ch = str:match"Video unavailable. This video contains content from (.-), who has blocked it in your country on copyright grounds";
	if ch then
		return ("이 영상에는 %s 의 컨탠츠가 포함됩니다, 저작권법 상 이 국가에서 영상을 사용할 수 없습니다"):format(ch);
	end

	if str:match("This video is no longer available because the YouTube account associated with this video has been terminated.") then
		return "이 영상과 연결된 유튜브 계정이 해지되어 더이상 볼 수 없는 동영상입니다";
	end

	if str:match("Private video. Sign in if you've been granted access to this video") then
		return "비공개 동영상입니다";
	end

	if str:match("Video unavailable. This video has been removed by the uploader") then
		return "업로더에 의해 삭제된 동영상입니다"
	end

	if str:match(timeoutMessage) then
		return "시간초과! 영상을 불러오는데 너무 많은 시간이 걸려 취소되었어요";
	end

	return ("이 영상은 이용이 불가능합니다 (%s)"):format(str);
end
local errorFormater = module.errorFormater;

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
local search = module.search;

---returns the video id of link
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or search(url);
end
local getVID = module.getVID;

function module.download(vid)
	vid = getVID(vid);
	if not vid then
		error("잘못된 영상 URL 또는 ID 를 입력했습니다");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,err = download(url,vid);
	if isExistString(info) and isExistString(audio) then
		return audio,info,url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg =
		("오류가 발생했습니다, 영상을 다운로드 받는데 실패했습니다.\n> %s")
		:format(errorFormater(err));
	logger.error(errormsg);
	error(errormsg);
end

return module;
