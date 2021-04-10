--[[

[여러개 감싸기]
여러개가 필요한경우 {} 로 감싸서 , 로 하나하나 분리함
예 : {"안녕","안뇽","ㅎㅇ"}

주석쓰기]
그냥 노트가 필요한경우 -- 를 붇여서 노트를 사용 가능함
예 : -- 노트하기[

 말한사람 언급하기
만약 말한사람 언급이 필요한경우 {%:UserName:%} 을 사용할 수 있음
예 : "안녕하세요 {%:UserName:%} 님!"

[func 를 이용한 세부 반응]
나중에 가면 func 라는걸로 좀더 세세한 기능을 만들 수도 있음
함수 기능이기 때문에 여기에 string 라이브러리를 쓰거나
렌덤 라이브러리를 쓰거나 할 수도 있음
예 :
-- 주사위 굴리기
reply = function(message,args,Content)
    returns ("나온 수는 %d 이에요!"):format(cRandom(1,6));
end;
당연히 여러 반응과 묶을수도 있음
reply = {
    function(message,args,Content)
        returns ("나온 수는 %d 이에요!"):format(cRandom(1,6));
    end,
    "주사위를 찾지 못했어요",
    "어이쿠! 주사위를 떨어트렸어요",
    function(message,args,Content)
        returns ("(대구르르르...) 나온 수는 %d 이에요!"):format(cRandom(1,6));
    end
};

[글자 반복]
금사향! 금사향! 금사향! 처럼 반복되는걸 만들려면
string.rep("반복할 글자",1)
을 쓸 수 있음, 반복할 글자에는 원하는거 집어넣고 숫자부분엔
반복할 수를 추가하면 됨
예 :
reply = {"학교폭력 멈춰!",string.rep("멈춰! ",20)};
단독으로도 사용 가능
reply = string.rep("멈춰! ",20);


]]

local cRandom,json,client,discordia,enums,iLogger,makeId,urlCode,strSplit,ACCOUNTData;
return function (o)
    cRandom,json,client,discordia,enums,iLogger,makeId,urlCode,strSplit,ACCOUNTData = 
    o.cRandom,o.json,o.client,o.discordia,o.enums,o.iLogger,o.makeId,o.urlCode,o.strSplit
    ,o.ACCOUNTData;
    -- 여기에는 쓰지 맙쇼
    -- 기능을 임포트 하는 용도로 있는곳

    return {
        ["끝말잇기"] = { -- 나중에 기능 추가하면 이전 예정
            alias = "끝말 잇기";
            reply = "크시랑 하세요";
        };
        ["멈춰"] = {
            alias = {"학교폭력","학교폭력"};
            reply = {"학교폭력멈춰!","멈춰어어!!",string.rep("멈춰! ",20)};
        };
        ["장비를 정지합니다"] = {
            alias = {"장비를정지합니다","정지합니다"};
            reply = "어, 정..정지가 앙 돼. 정지시킬 수가 없어";
        };
        ["울프럼알파"] = {
            alias = "울프럼 알파";
            reply = "우린 답을 찾을것이다, 늘 그랬듯이";
        };
        ["수소"] ={
            alias = "Hydrogen";
            reply = "우주에서 가장 처음으로 만들어진 원소예요";
        };
        ["백만볼트"] ={
            reply = "피카 츄!!?";
        };
        ["헬륨"] ={
            alias = "Helium";
            reply = "세상에서 가장 유명한 비활성 기체예요";
        };
        ["심심해"] = {
            alias = {"심심하다","심심함"};
            reply = "놀아줄까?";
        };
        ["레고"] = {
            reply = "밟았어!";
        };
        ["뭫"] ={
            reply = "묑?"
        };
        ["술"] ={
            alias = {
                "참이슬", 
                "막걸리",
                "포도주",
                "맥주",
                "와인",
                "샴페인",
                "칵테일",
                "청주",
                "크바스",
                "소주",
                "코냑",
                "고량주",
                "위스키",
                "보드카",
                "럼주",
                "발티카"
            };
            reply = "봇은 술을 못 마셔요";
        };
        ["젤다"] = {
            alias = "젤다의 전설","젤다의전설";
            reply = "초록색 옷 입은 애가 젤다죠";
        };
        ["젤다의 전설 브레스 오브 더 와일드"] = {
            alias = {"젤다의전설브레스오브더와일드","젤다의 전설브레스오브와일드","젤다의 전설 브레스오브와일드","젤다의 전설 브레스 오브더와일드","젤다의 전설 브레스 오브 더와일드","젤다의 전설 브레스 오브 더 와일드","젤다의전설브레스오브더 와일드","젤다의전설브레스오브 더 와일드","젤다의전설브레스 오브 더 와일드","젤다의전설 브레스 오브 더 와일드"};
            reply = {"이젠 파란색 옷 입은 애가 젤다죠"};
        };
    };
end;
