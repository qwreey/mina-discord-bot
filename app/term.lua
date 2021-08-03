local history = readline.History.new(); -- 히스토리 홀더 만들기
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history});

local version do
    local file = io.popen("git log -1 --format=%cd");
    version = file:read("*a");
    file:close();
    local month,day,times,year,gmt = version:match("[^ ]+ +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+)");
end

local function buildPrompt()
    return "\27[44;30m TEST \27[0m\27[34m\27[0m ";
end
_G.buildPrompt = buildPrompt;

local runEnv = { -- 명령어 실행 환경 만들기
    runSchedule = runSchedule;
};
function runEnv.clear() -- 화면 지우기 명령어
    os.execute("cls");
    return "screen clear!";
end
function runEnv.exit() -- 봇 끄기
    os.exit(100);
end
function runEnv.reload() -- 다시 로드
    os.execute("cls");
    os.exit(101);
end
function runEnv.print(...)
    io.write("\27[2K\r");
    for _,v in pairs({...}) do
        if type(v) == "string" then
            io.write(v);
        else
            io.write(prettyPrint.dump(v));
        end
    end
    io.write("\n",buildPrompt());
end
runEnv.restart = runEnv.reload;
function runEnv.help() -- 도움말
    return {
        clear = "clear screen";
        exit = "kill luvit/cmd";
        reload = "reload code";
        restart = "same with reload";
        help = "show this msg";
        getUserData = "get user data table";
        saveUserData = "save user data table";
    };
end
function runEnv.getUserData(id)
    return userData:loadData(id);
end
function runEnv.saveUserData(id)
    return userData:saveData(id);
end
setmetatable(runEnv,{ -- wtf?? lua can use metable env... cuz lua's global is a table!!
    __index = _G;
    __newindex = _G;
});
-- 라인 읽기 함수
return function ()
    local function onLine(err, line, ...)
        if line then
            editor:readLine(buildPrompt(), onLine); -- 에디터가 개속 읽게 하기
            local func = (loadstring("return " .. line) or loadstring(line))
            local envfunc = setfenv(func or function ()
                error("Un error occur on loadstring");
            end,runEnv) -- 명령어 분석
            local pass,dat = pcall(envfunc); -- 보호 모드로 명령어를 실행
            if not pass then -- 오류 나면
                iLogger.error("LUA | error : " .. dat);
            else
                io.write("\27[2K\r",prettyPrint.dump(dat),"\n",buildPrompt());
            end
        else
            process:exit(); ---@diagnostic disable-line
        end
    end
    editor:readLine(buildPrompt(), onLine); -- 라인 읽기 시작
end