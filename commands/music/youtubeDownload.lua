local module = {};

local exts = {"opus", "m4a", "mp3", "wav", "best", "aac", "flac", "vorbis"};

function module.download(vid)
	vid = module.getVID(vid);
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if is exist already, just return it
	local filePath = ("data/youtubeFiles/%s.%%s"):format(vid);
	local info = fs.readFileSync(("data/youtubeFiles/%s.info"):format(vid)) or "";
	for _,str in ipairs(exts) do
		local this = filePath:format(str);
		if fs.existsSync(this) then
			return this,json.decode(info),url,vid;
		end
	end

	-- if not exist already, create new it
	local newProcess = spawn("youtube-dl",{
		args = {
			'-q','-x','--audio-quality','0','--print-json','--write-thumbnail','--geo-bypass','-o','./data/youtubeFiles/%(id)s.%(ext)s','--cache-dir','./data/youtube.Cache',
			url
		};
		hide = true;
		cwd = "./";
		stdio = {nil,true,true};
	});
	info = "";
	for str in newProcess.stdout.read do
		info = info .. str;
	end
	fs.writeFile(("data/youtubeFiles/%s.info"):format(vid),info);
	newProcess.waitExit();
	for _,str in ipairs(exts) do
		local this = filePath:format(str);
		if fs.existsSync(this) then
			return this,json.decode(info),url,vid;
		end
	end

	-- video was not found from youtube? or something want wrongly
	logger.errorf("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!");
	qDebug {
		title = "failed to download video from youtube";
		trace = newProcess;
		vid = vid;
		status = "error";
	};
	error("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!");
end

function module.getVID(url)
	return url:match("watch%?v=(...........)") or url:match("https://youtu%.be/(...........)") or (url:gsub("^ +",""):gsub(" +$",""));
end

return module;