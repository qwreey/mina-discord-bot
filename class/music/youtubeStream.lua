local module = {};

local function isExistString(str)
	return str and str ~= "" and str ~= " " and str ~= "\n";
end

module.redownload = true;

local function download(url)
	local newProcess = spawn("youtube-dl",{
		args = {
			'-q',"-g",'--print-json','--cache-dir','./data/youtubeCache',url
		};
		hide = true;
		cwd = "./";
		stdio = {nil,true,true};
	});
	local audio,info;
	local traceback = "";
	local index = 1;
	for str in newProcess.stdout.read do
		if index == 2 then
			audio = str:sub(1,-2);
		elseif index == 3 then
			info = str;
		end
		traceback = traceback .. str;
		index = index + 1;
	end
	newProcess.waitExit();
	return audio, info, traceback, newProcess;
end

local retrys = 3;
function module.download(vid)
	vid = module.getVID(vid);
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	if not vid then
		error("You inputed invalid video id!");
	end

	-- if not exist already, create new it
	local audio,info,traceback,newProcess;
	for _ = 1,retrys do
		audio,info,traceback,newProcess = download(url);
		if audio then
			break;
		end
	end

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

function module.getVID(url)
	return url:match("watch%?v=(...........)") or url:match("https://youtu%.be/(...........)") or (url:gsub("^ +",""):gsub(" +$",""):match("(...........)"));
end

return module;
