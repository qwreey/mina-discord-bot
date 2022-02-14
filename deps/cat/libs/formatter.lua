
local module = {};

local gsub = string.gsub;

function module.arrow(str)
    return gsub(str,"\\\n","");
end

return module;
