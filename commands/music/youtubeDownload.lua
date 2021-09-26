local module = {};

local exts = {"opus", "m4a", "mp3", "wav", "best", "aac", "flac", "vorbis"};

function module.download(vid)
	vid = module.getVID(vid);

	-- create stream
	local newProcess = spawn("youtube-dl",{
		args = {
			-- '-q','-x','--audio-quality','0','--print-json','--write-thumbnail','--geo-bypass','-o','./data/youtubeFiles/%(id)s.%(ext)s','--cache-dir','./data/youtube.Cache',
			'--print-json','-g','--cache-dir','./data/youtube.Cache','--geo-bypass',
			('https://www.youtube.com/watch?v=%s'):format(vid)
		};
		hide = true;
		cwd = "./";
		stdio = {nil,true,true};
	});
	local audio,info = "","";
	local index = 1;
	for str in newProcess.stdout.read do
		if index == 2 then
			audio = str;
		elseif index == 3 then
			info = str;
		end
		index = index + 1;
	end
	newProcess.waitExit();

	-- return it
	if info and audio then
		return audio:sub(1,-2),json.decode(info);
	end

	-- video was not found from youtube? or something want wrongly
	iLogger.errorf("something want wrong! video was not found from youtube or youtube-dl process was terminated with exit!");
	qDebug {
		title = "failed to download video from youtube";
		trace = newProcess;
		vid = vid;
        info = info;
		status = "error";
	};
	return nil;
end

function module.getVID(url)
	return url:match("watch%?v=(...........)") or url;
end

return module;