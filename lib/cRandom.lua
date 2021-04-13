--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

LUA 렌덤을 핸들링

]]

return function (min,max)
    local seed = math.floor((os.clock()*(min^2+max^2))*1000);
    math.randomseed(seed);
    return math.random(min,max);
end;