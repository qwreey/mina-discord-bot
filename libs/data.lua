local module = {};
local json = json;

function module.load(fileName)
	return json.decode(fs.readFileSync(fileName));
end

function module.save(fileName,data)
 	return fs.writeFile(fileName,json.encode(data));
end

function module.loadRaw(fileName)
	return fs.readFileSync(fileName);
end

function module.saveRaw(fileName,data)
	return fs.writeFile(fileName,data);
end

return module;
