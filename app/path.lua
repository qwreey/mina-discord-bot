return function (path)
	local function add(newPath)
		if string.find(path,newPath .. ";",0,true) then
			return;
		end
		path = path .. newPath .. ";";
	end

	add(".\\?.lua");
	add(".\\?\\init.lua");
	add(".\\libs\\?.lua");
	add(".\\libs\\?\\init.lua");
	add(".\\deps\\?.lua");
	add(".\\deps\\?\\init.lua");
	add(".\\app\\?.lua");
	add(".\\app\\?\\init.lua");
	add(".\\bin\\?.lua");
	add(".\\bin\\?\\init.lua");

	return path;
end;
