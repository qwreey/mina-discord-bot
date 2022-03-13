local module = {};
local dat,len;

local random,json;
function module:setJson(newJson)
	json = newJson;
	return self;
end
function module:setrandom(newrandom)
	random = newrandom;
	return self;
end

function module.fetch()
	if not dat then
		dat = json.decode(fs.readFileSync("commands/korquote/base.json"));
		len = #dat;
	end
	return dat[random(1,len)];
end

return module;
