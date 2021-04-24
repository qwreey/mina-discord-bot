local script = script;
local Instance = Instance;

local Qeact = {
    importElement = require(script and script.importElement or "Qeact/importElement");
    makeInstanceFunc = function (className,Parent)
        return Instance.new(className,Parent);
    end;
};


--
-- 엘리멘트 {
--     Event = function() -- 값이 함수임 (이벤트 연결)
--         print("이벤트 연결")
--     end;
--     Size = UDim2.new(1,0,1,0); -- 값이 특수값이며 인덱스가 문자열임 (프로퍼티 설정)
--     엘리멘트2 { -- 값이 특수 테이블임 (children 추가)
--         Size = UDim2.new(1,0,1,0);
--     };
--     엘리멘트이름 = 엘리멘트3 {
--         Size = UDim2.new(1,0,1,0);
--     };
--     "TestValue"; -- 메모? 이건 나중에 추가해야 할꺼 같은 유형
-- };
--
-- => 렌더러에 넘김
--

local IgnoreProperties = {
    IsElement = true;
    ClassName = true;
};

-- 로블록스 개체 렌더러 (인스턴스)
function Qeact:rbxRender(Element,Parent) -- render for roblox ui
    local this = self.makeInstanceFunc(Element.ClassName,Parent);

    for Index,Value in pairs(Element) do
        local IndexType = type(Index); -- 인덱스 타입
        local ValueType = type(Value); -- 벨류 타입

        if ValueType == "table" and Value.IsElement then -- 엘리멘트 (내부 children)
            Value.Name = IndexType == "string" and Index or Value.Name;
            self:rbxRender(Value,this); -- 렌더링
        elseif IndexType == "string" then -- 프로퍼티, 이벤트
            if ValueType == "function" then -- 이벤트
                if Index ~= "WhenCreated" then
                    this[Index]:Connect(Value);
                end
            elseif not IgnoreProperties[Index] then -- 프로퍼티
                this[Index] = Value;
            end
        --elseif IndexType == "number" then
        --end
        end
    end

    local WhenCreated = Element.WhenCreated;
    if type(WhenCreated) == "function" then
        WhenCreated(this);
    end

    return this;
end

-- 글자 렌더러 (트리 뷰, 디버깅용)
local strRender;
function Qeact:strRender(Element)
    strRender = strRender or require(script and script.stringRender or "Qeact/stringRender");
    return strRender(Element);
end

-- NOP 렌더러
function Qeact:nopRender()
    return;
end

-- TODO : 렌더러에서 나중에 부분 다시 렌더링 만들기 (마치 react 의 엘리멘트 재사용 알고리즘 처럼)
-- TODO : 이걸 이제 MaterialUI 와 연결하기, 그리고 이걸로 doc 만들고 등등..

return Qeact;