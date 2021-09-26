local module = {};

function module.download(vid)
    vid = module.getVID(vid)
    -- if is exist already, just return it
    local filePath = ("data/youtubeFiles/%s.opus"):format(vid);
    if fs.existsSync(filePath) then
        return filePath;
    end

    -- if not exist already, create new it
    local child = spawn("youtube-dl",{
        args = {
            "-q"; "-x"; "--write-thumbnail"; "--geo-bypass";
            '-o "./data/youtubeFiles/%(id)s.%(ext)s"';
            "--cache-dir ./data/youtubeCache";
            --"--audio-format mp3";
            ('"https://www.youtube.com/watch?v=%s"'):format(vid);
        };
    });
    child:waitExit();

    if not fs.existsSync(filePath) then
        -- video was not found from youtube? or something want wrongly
        return nil;
    end

    return filePath;
end

function module.getVID(url)
    return url:match("watch%?v=(...........)") or url;
end

return module;