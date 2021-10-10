-- live enable-disable able fast-feature switcher

local module = {};

local exitCodes = require("app.exitCodes");

module.types = {

};
function module.set(typeV,value)
	if type(typeV) == "string" then
		typeV = module.types[typeV];
	end
	
end

return module;
