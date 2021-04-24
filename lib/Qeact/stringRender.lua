-- 그냥 string 으로 렌더링 해서 디버깅을 하기 위한 목적으로 사용됨
--[[
엘리멘트리 {
    프로퍼티 = 값;
    이벤트 = 함수;
    이름 = 엘리멘트리 {
        프로퍼티 = 값;
    };
};
]]
-- 이렇게 렌더링됨
local Tab = string.rep("\32",3);
local LF = "\n";

local IgnoreProperties = {
    IsElement = true;
    ClassName = true;
};

local function strRender(Element) -- render for string tree
    local this = Element.ClassName .. " {";

    -- 프로퍼티 먼저
    for Index,Value in pairs(Element) do
        local IndexType = type(Index); -- 인덱스 타입
        local ValueType = type(Value); -- 벨류 타입

        if IndexType == "string" and ValueType ~= "table" then -- 프로퍼티, 이벤트
            if ValueType == "function" then -- 이벤트
                this = this .. ("%s%s%s = \"&Event\";"):format(LF,Tab,Index);
            elseif not IgnoreProperties[Index] then -- 프로퍼티
                this = this .. ("%s%s%s = %s;"):format(LF,Tab,Index,tostring(Value));
            end
        end
    end

    -- 그다음 엘리멘트리
    for Index,Value in pairs(Element) do
        local IndexType = type(Index); -- 인덱스 타입
        local ValueType = type(Value); -- 벨류 타입

        if ValueType == "table" and Value.IsElement then -- 엘리멘트리 (내부 children)
            Value.Name = IndexType == "string" and Index or Value.Name;
            this = this .. LF .. Tab .. string.gsub(strRender(Value),LF,LF .. Tab);
        end
    end

    this = this .. LF .. "};";

    return this;
end

return strRender;