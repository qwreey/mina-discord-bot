--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

LUA 렌덤을 핸들링

]]

return function (min,max)
    local rm = collectgarbage("count")%1 * 1000000;
    local seed = math.floor(
        (
            math.floor(
                (os.clock()*((min^2+max^2)*math.pi^2+rm))*1000
            )
        )
    );
    math.randomseed(seed);
    return math.random(min,max);
end;