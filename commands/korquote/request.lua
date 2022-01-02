local module = {};
local dat,len;

local cRandom,json;
function module:setJson(newJson)
	json = newJson;
	return self;
end
function module:setCRandom(newCRandom)
	cRandom = newCRandom;
	return self;
end

function module.fetch()
	if not dat then
		dat = json.decode(fs.readFileSync("commands/korquote/base.json"));
		len = #dat;
	end
	return dat[cRandom(1,len)];
end

return module;
