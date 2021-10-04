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
		local file = io.open("commands/korquote/base.json");
		local raw = file:read("a");
		dat = json.decode(raw);
		raw = nil;
		file:close();
		file = nil;
		len = #dat;
	end
	return dat[cRandom(1,len)];
end

return module;