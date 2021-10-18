local module = {};
local json;

function module:setJson(newJson)
	json = newJson;
	return self;
end

function module.load(fileName)
	return json.decode(fs.readFileSync(fileName));
end

function module.save(fileName,data)
 	return fs.writeFile(fileName,json.encoding(data));
end

function module.loadRaw(fileName)
	return fs.readFileSync(fileName);
end

function module.saveRaw(fileName,data)
	return fs.writeFile(fileName,data);
end

return module;
