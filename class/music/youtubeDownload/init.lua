local module = {};
local utils = require"class.music.utils";
local getVideoId = utils.getVideoId;
local isExistString = utils.isExistString;
local formatUrl = utils.formatUrl;

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

	if str:match("Sign in to confirm your age. This video may be inappropriate for some users") then
		return "나이 제한이 걸린 영상입니다";
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

function module.download(vid,lastInfo)
	vid = getVideoId(vid);
	if not vid then
		error("잘못된 영상 URL 또는 ID 를 입력했습니다");
	end
	local url = formatUrl(vid);

	-- if not exist already, create new it
	local audio,info,err = download(url,vid,lastInfo);
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
