---@type table<string, Command>
local export = {
    ["음성채팅생성"] = {
        alias = {
            "채널생성","채널 생성","채널 생성기","채널생성기",
            "음성방생성","음성방 생성","음성채팅 생성","음성챗방 생성",
            "음성챗방생성","음성챗 생성","음성챗생성","보이스생성","보이스 생성"
        };
        disableDm = true;
        command = "채널생성";
        reply = zwsp;
        embed = {title = "잠시만 기다려주세요 . . ."};
        func = function(replyMsg,message,args,Content,self)
            
            replyMsg:update(self.created);
            --
        end;
        created = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 음성 채널 생성방을 만들었습니다!";
            }
        };
    };
};

return export;
