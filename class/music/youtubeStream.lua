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
	local stdout = "";
	for str in newProcess.stdout.read do
		stdout = stdout .. str;
	end
	local splitted = strSplit(stdout,"\n");
	-- newProcess.waitExit(); -- ah... it ok? idk. i just think, it should be on top of stdout.read
	return splitted[2], splitted[3], stdout, newProcess;
end

function module.download(vid)
	vid = module.getVID(vid);
	if not vid then
		error("You inputed invalid video id!");
	end
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local audio,info,traceback,newProcess = download(url);
	if isExistString(info) and isExistString(audio) then
		return audio,json.decode(info),url,vid;
	end

	-- video was not found from youtube? or something want wrongly
	local errormsg = ("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!");
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
