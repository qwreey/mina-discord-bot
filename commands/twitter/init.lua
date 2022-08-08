

local tvidURL = "https://twitter.com/.-/status/(%d+)";


local maxFileSize = 8000000;

---@type table<string,Command>
local export = {
    ["twittervideo"] = {
        alias = {"트위터 영상","트위터영상","twitter video","트윗 영상","트윗영상"};
        onSlash = commonSlashCommand {
            name = "트위터영상";
            description = "트위터 영상을 올립니다. 8 메가바이트 이상의 영상은 올릴 수 없습니다";
            optionRequired = true;
            optionName = "URL";
            optionDescription = "영상이 포함된 트위터 링크입니다";
        };
        urlWorng = {
            content = zwsp;
            embed = {
                title = ":x: URL 이 잘못되었습니다";
                description = "일반적인 영상이 포함된 트윗 URL 을 입력해주세요";
                color = embedColors.error
            };
        };
        sizeOver = {
            content = zwsp;
            embed = {
                title = ":x: 영상의 크기가 너무 큽니다";
                description = "영상이 8 메가를 넘으면 디스코드에 올라가지 않습니다";
                color = embedColors.error;
            };
        };
        failed = {
            content = zwsp;
            embed = {
                color = embedColors.error;
                title = ":x: 오류로 인해 다운로드에 실패하였습니다";
                description = "이게 일어난 이유는 개발자도 모르겠데요\n~~절대 오류 안 일어날꺼 같은 부분에 넣은 메시지라네요~~";
            };
        };
        reply = zwsp;
        embed = { title = "⏳ 다운로드 받는중"; };
        func = function(replyMsg,message,args,Content,self)
            local url = Content.rawArgs;
            local vid = url:match(tvidURL);
            if not vid then
                return replyMsg:update(self.urlWorng);
            end

            local proc = spawn("yt-dlp",{args = {"--print","%(filesize,filesize_approx)s",url}});
            if not proc then error("yt-dlp not found"); end
            local sizeVideo = tonumber(proc.stdout.read():match("%d+"));
            if not sizeVideo then
                return replyMsg:update(self.urlWorng);
            end

            if sizeVideo > maxFileSize then
                return replyMsg:update(self.sizeOver);
            end

            local file = ("data/twitterVideo/%s.mp4"):format(vid);
            proc = spawn("yt-dlp",{args = {url,"-o",file}})
            if not proc then error("yt-dlp not found"); end
            proc.waitExit();

            if fs.existsSync(file) then
                return replyMsg:update({
                    content = zwsp;
                    embed = { title = ":white_check_mark: 받기 성공!"; };
                    file = file
                });
            else
                return replyMsg:update(self.failed);
            end
        end;
    };
};

return export;

