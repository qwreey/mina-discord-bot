local history = readline.History.new(); -- 히스토리 홀더 만들기
local editor = readline.Editor.new({stdin = process.stdin.handle, stdout = process.stdout.handle, history = history});

local version do
    local file = io.popen("git log -1 --format=%cd");
    version = file:read("*a");
    file:close();
    local month,day,times,year,gmt = version:match("[^ ]+ +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+)");
    version = ("%s %s %s"):format(month,day,tostring(times:match("%d+:%d+")));
end

local colors = {
    black = {30,40};
    red = {31,41};
    green = {32,42};
    yellow = {33,43};
    blue = {34,44};
    magenta = {35,45};
    cyan = {36,46};
    white = {37,47};
    gray = {90,100};
    brightRed = {91,101};
    brightGreen = {92,102};
    brightYellow = {93,103};
    brightBlue = {94,104};
    brightMagenta = {95,105};
    brightCyan = {96,106};
    brightWhite = {97,107};
};
local powerline_arrow_right = "";

local lastColor;
local function buildLine(color,text)
    local str = lastColor
        and (("\27[%d;%dm%s"):format(lastColor[1],color[2],powerline_arrow_right))
        or (("\27[%dm"):format(color[2]));
    str = str .. ("\27[30m %s "):format(text);
    lastColor = color;
    return str;
end
_G.buildLine = buildLine;

local function buildPrompt()
    local str = "";

    str = str .. buildLine(colors.blue,"TestBuild");
    str = str .. buildLine(colors.yellow," " .. version);

    -- set end point
    str = str .. ("\27[0m\27[%dm\27[0m "):format(lastColor[1]);
    lastColor = nil;
    return str;
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
_G.print = runEnv.print;
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
    local last = "";
    local function onLine(err, line, ...)
        if line then
            editor:readLine(buildPrompt(), onLine); -- 에디터가 개속 읽게 하기
            local func,err = (loadstring("return " .. line) or loadstring(line));
            -- if err:match "'<eof>'$" then
            --     last = 
            -- end

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
            process:exit();
        end
    end
    editor:readLine(buildPrompt(), onLine); -- 라인 읽기 시작
end