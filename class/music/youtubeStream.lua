local module = {};

local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = true;

local function download(url)
	local newProcess = spawn("youtube-dl",{
		args = {
			'-q','-s','-g','--print-json','--cache-dir','./data/youtubeCache',url
		};
		hide = true;
		cwd = "./";
		stdio = {nil,true,true};
	});
	local audio;
	local info = "";
	local traceback = "";
	local index = 1;
	for str in newProcess.stdout.read do
		if index == 2 then
			audio = str:gsub("\n","");
		elseif index >= 3 then
			info = info .. str;
		end
		traceback = traceback .. str;
		index = index + 1;
	end
	newProcess.waitExit(); -- ah... it ok? idk. i just think, it should be on top of stdout.read
	return audio, info, traceback, newProcess;
end

function module.download(vid)
	vid = module.getVID(vid);
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	if not vid then
		error("You inputed invalid video id!");
	end

	-- if not exist already, create new it
	local audio,info,traceback,newProcess = download(url);
	if isExistString(info) and isExistString(audio) then
		return audio,json.decode(info),url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg = ("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!\n```log\n%s\n```"):format(traceback);
	logger.error(errormsg);
	qDebug {
		title = "failed to download video from youtube";
		traceback = traceback;
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
function module.search()
	local Header,Body = corohttp.request("GET",
		searchURLTemp:format(urlCode.urlEncode(Keyword))
	);
	if not Body then return end
	Body = json.decode(Body);
	if not Body then return end
	local thing = Body[1];
	if not thing then return end
	local id = thing.id;
	if not id then return end
	return id.videoId;
end
function module.getVID(url)
	return url:match(vidWatch) or url:match(vidShort) or (url:gsub("^ +",""):gsub(" +$",""):match(vidFormat)) or module.search(url);
end

return module;
