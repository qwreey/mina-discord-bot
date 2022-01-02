slocal jit = require "jit";
return function (path)
    local jitos = jit.os;
	local function add(newPath)
		if string.find(path,newPath .. ";",0,true) then
			return;
        end
        if jitos == "Windows" then
            newPath = newPath:gsub("/","\\");
        end
		path = path .. newPath .. ";";
	end

    local jitarch = jit.arc
    add("?.lua");
    add("?/init.lua");
   	add("./?.lua");
   	add("./?/init.lua");
   	add("./libs/?.lua");
   	add("./libs/?/init.lua");
   	add("./deps/?.lua");
   	add("./deps/?/init.lua");
   	add("./app/?.lua");
   	add("./app/?/init.lua");
	add(("./bin/%s_%s"):format(jitos,jitarch) .. "/?.lua");
	add(("./bin/%s_%s"):format(jitos,jitarch) .. "/?/init.lua");
	return path;
end;
