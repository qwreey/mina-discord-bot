local module = {};
local json;

function module:setJson(newJson)
    json = newJson;
end

function module.load(fileName)
	local file = io.open(fileName,"r");
	local raw = file:read("a");
	file:close();
	return json.decode(raw);
end

function module.save(fileName,data)
	local file = io.open(fileName,"r+");
	file:write(json.encoding(data));
	file:close();
	return true;
end

function module.loadRaw(fileName)
	local file = io.open(fileName,"r");
	local raw = file:read("a");
	file:close();
	return raw;
end

function module.saveRaw(fileName,data)
	local file = io.open("r+");
	file:write(data);
	file:close();
	return true;
end

return module;