--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

LUA 렌덤을 핸들링

]]

return function (min,max)
    math.randomseed(os.time());
    return math.random(min,max);
end;