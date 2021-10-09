local module = {};

local function isExistString(str)
    return str and str ~= "" and str ~= " " and str ~= "\n";
end

function module.download(vid)
	vid = module.getVID(vid);
	local url = ('https://www.youtube.com/watch?v=%s'):format(vid);

	-- if not exist already, create new it
	local newProcess = spawn("youtube-dl",{
		args = {
			'-q',"-g",'--print-json','--geo-bypass','--cache-dir','./data/youtubeCache',
			url
		};
		hide = true;
		cwd = "./";
		stdio = {nil,true,true};
	});
    local audio,info;
    local index = 1;
	for str in newProcess.stdout.read do
        if index == 2 then
            audio = str:sub(1,-2);
		elseif index == 3 then
            info = str;
        end
        index = index + 1;
	end
    newProcess.waitExit();
    if isExistString(info) and isExistString(audio) then
	    return audio,json.decode(info),url,vid;
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
