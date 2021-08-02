return function (path)
    local function add(newPath)
        if string.find(path,newPath .. ";",0,true) then
            return;
        end
        path = path .. newPath .. ";";
    end

    add(".\\libs\\?.lua");
    add(".\\deps\\?.lua");
    add(".\\app\\?.lua");
    add(".\\bin\\?.lua");

    print(path)
    return path;
end;
