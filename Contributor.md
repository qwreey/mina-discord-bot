# 편집시 도움말

## [이 봇이 사용하는 언어]  
http://www.lua.org/pil/contents.html  
Lua (luvit)  
이유 :  
무시무시하게 빠르고 가벼움, 저사양 기기에 돌리기 적합  
바로바로 리로드 가능  
C 랑 동기화가 쉬움  
js 랑 가까움 (그래서 js 모듈 이식작이 많음)  
비동기IO 로 처리 가능  

## [편집 주의 사항]  
편집기 열 때 가능하면 개속해서 git pull 받아서 온라인 스토리지로 부터  
파일을 받아오기  
세미 콜론이 필요한곳에는 꼭 ; 를 찍어서 오류 안나도록 하기  
-- ! Automatically generated ! 가 위 아래로 있는 부분은 건들지 말기  

## [봇 컨트롤 명령어]  
!!!sync : 내가 올린 명령어를 적용  
!!!reload : 봇을 한번 껏다 켬  
!!!help : 이외에 더 많은 명령어를 볼려면 사용  

## [여러개 감싸기]  
여러개가 필요한경우 {} 로 감싸서 , 로 하나하나 분리함  
예 : {"안녕","안뇽","ㅎㅇ"}  

## [주석쓰기]  
그냥 노트가 필요한경우 -- 를 붇여서 노트를 사용 가능함  
예 : -- 노트하기  

## [말한사람 언급하기]  
만약 말한사람 언급이 필요한경우 {#:UserName:#} 을 사용할 수 있음  
예 : "안녕하세요 {#:UserName:#} 님!"  

## [func 를 이용한 세부 반응]  
나중에 가면 func 라는걸로 좀더 세세한 기능을 만들 수도 있음  
함수 기능이기 때문에 여기에 string 라이브러리를 쓰거나  
렌덤 라이브러리를 쓰거나 할 수도 있음  
예 :  
-- 주사위 굴리기  
```lua
reply = function(message,args,Content)
    return ("나온 수는 %d 이에요!"):format(cRandom(1,6));
end;
```
당연히 여러 반응과 묶을수도 있음  
```lua
reply = {  
    function(message,args,Content)
        return ("나온 수는 %d 이에요!"):format(cRandom(1,6));
    end,
    "주사위를 찾지 못했어요",
    "어이쿠! 주사위를 떨어트렸어요",
    function(message,args,Content)
        return ("(대구르르르...) 나온 수는 %d 이에요!"):format(cRandom(1,6));
    end
};
```
  
## [글자 반복]  
금사향! 금사향! 금사향! 처럼 반복되는걸 만들려면  
string.rep("반복할 글자",1)  
을 쓸 수 있음, 반복할 글자에는 원하는거 집어넣고 숫자부분엔  
반복할 수를 추가하면 됨  
예 :  
```lua
reply = {"학교폭력 멈춰!",string.rep("멈춰! ",20)};
```
단독으로도 사용 가능  
```lua
reply = string.rep("멈춰! ",20);
```
  
## [호감도 오르거나 내리는 반응 (선택적 사항)]  
호감도 상승 반응  
```lua
["끝말잇기"] = {
    alias = "끝말 잇기";
    reply = "크시랑 하세요";
    love = 1; -- 호감도 1 상승
};
```
호감도 하락 반응  
```lua
["개새끼"] = {
    reply = "나빴어";
    love = -2; -- 호감도 2 하락
};
```
렌덤하게 호감도가 주어지는 반응  
```lua
["안녕"] = {
    reply = "안녕하세요! {%%:UserName:%%} 님!";
    love = function()

    end
};
```  
  
## [반복시 호감도가 내리는 반응 (선택적 사항)]  
```lua
["안녕"] = {
    reply = "안녕하세요";
    love = 2;
    repLove = -1; -- 5 번 반복시 호감도 1 하락
    repText = {"그만...","그만 하세요!"}; -- 반복시 나오는 글,
    -- 한개면 {} 안쓰고 "" 안에 써도 됨 (선택적 사항)
};
```
  
## [몇 초 뒤 바뀌는 반응]  
아래처럼 함수 기능을 사용할 수 있음, reply 에 안넣고 func 에 넣어서  
주의할껀 reply 에 함수 썼으면 msg 를 리턴하는게 필요함  
msg (메시지 개체) 받아서 편집도 가능함,  
아래 숫자 부분(스캐쥴러에 던지는 부분에서) 500 이거는 마이크로 초로 씀  
즉 500 = 0.5 (1ms = 0.001s)  
리플 부분에 함수 지정  
```lua
["ㅉㅉ"] = {
    alias = {"쯧...","쯧.","쯧..","쯔읏","ㅉ","쯧","쯧쯧"};
    reply = {
        function (msg)
            local newMsg = msg:reply("~~저저 꼰대 쉨~~");
            runSchedule(500,function ()
                newMsg:setContent("아! 아무것도 아니야 ㅎㅎ");
            end)
            return newMsg;
        end,
        "ㅉㅉ ?"
    };
};
```
아에 func 에 적용  
```lua
["ㅉㅉ"] = {
    alias = {"쯧...","쯧.","쯧..","쯔읏","ㅉ","쯧","쯧쯧"};
    reply = "~~저저 꼰대 쉨";
    func = function (msg)
        msg:setContent("아! 아무것도 아니야 ㅎㅎ")
    end
    reply = {
        function (msg)
            local newMsg = msg:reply("~~저저 꼰대 쉨~~");
            runSchedule(500,function ()
                newMsg:setContent("아! 아무것도 아니야 ㅎㅎ");
            end)
            return newMsg;
        end,
        "ㅉㅉ ?"
    };
};
```
  
## [커맨드 세부사항]  
```lua
{
    disableDm = bool; -- DM 에서 이 명령어를 쓸 수 있는지 여부 (true = 불가능,false = 가능)
    alias = table[array]/str; -- 다른 명령어로도 똑같은 기능 내도록
    reply = table[array]/str; -- 콜백
    func  = function(replyMsg,message,args,{
        commandName = string; -- 이 커맨드 이름
        rawCommandText = string; -- 접두사를 제외한 스트링
        prefix = string; -- 접두사(사용된)
        rawArgs = string; -- args 스트링 (커스텀 분석용)
        rawCommandName = string; -- 커맨드 이름 (앞에 무시된거 포함됨)
        self = Command:table; -- 지금 이 커맨드 개체를 반환
        getUserData = fnc; -- 유저 데이터 테이블 가져오기
        saveUserData = fnc; -- 유저 데이터 저장하기 (넘겨 받은 테이블 고치고 수행)
    }); -- 함수
    love = 1; -- love 주는 정도 (1시간 쿨탐 가짐, 선택사항)
    canRep = false; -- 반복해도 love 가 깍이지 않음 (아에 love 가 없으면 이거에 소용 없이 안줄어듬)

    -- 함수를 이용한 가변적인 결과
    reply = func(message,args,{위와(func 의 가장 뒤 인자) 동일한 테이블});
    love = function(userId) -- 렌덤적인 값을 반환 할 수 있음
        return cRandom(1,3);
    end;
};
```
<!-- repLove = -1; -- 5번 반복할 때 love 깍이는 정도 (10 분 뒤 초기화, 선택사항) -->
  
## [다른 모듈 설명]  
json : 루아 테이블을 json 으로 인코딩/디코딩 => https://luvit.io/api/json.html  
cRandom : 여러 난수를 섞은 렌덤함수, cRandom(최소값,최대값)  
client : discordia 모듈중 client 부분 => https://github.com/SinisterRectus/Discordia/wiki/Client  
enums : discordia 모듈중 enums 부분 => https://github.com/SinisterRectus/Discordia/wiki/Enumerations  
discordia : discordia 모듈 참조 => https://github.com/SinisterRectus/Discordia  
iLogger : 로거용 모듈  
    + trace : 추적 (디버깅)  
    + debug : 디버그  
    + info : 정보 (기본적으로 이거 쓰는걸 추천)  
    + warn : 경고 (오류는 아닌데 위험사항)  
    + error : 오류 (처리 할 수 없는 사항)  
    + fatal : 치명 (luvit 을 죽일만큼 심각한 사항)  
makeId : 랜덤한 18자 아이디를 만드는 함수, UUID 처럼 활용 가능 [lib/makeId.lua 와 연결]  
urlCode : 한글을 url 용으로 변환, [lib/urlCode.lua 와 연결]  
strSplit : 문자를 어떤 기준으로 나누는 함수 [lib/stringSplit.lua 와 연결]  
ACCOUNTData : 계정 정보 담긴 테이블 !사용 ㄴㄴ!  
qFilesystem : nt파일 시스템 [lib/qFilesystem.lua 와 연결]  
runSchedule : ms 초 뒤에 함수 실행시키는 함수 (루틴)  
ffi : C 코드 가져와서 바인딩 하는 라이브러리 => https://luajit.org/ext_ffi.html  
timer : luvit 의 timer 모듈 => https://luvit.io/api/timer.html  
fs : 파일 시스템 (luvit 내장) => https://luvit.io/api/fs.html  
thread : luvit 의 thread 모듈 => https://luvit.io/api/thread.html  
