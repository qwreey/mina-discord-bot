local module = {};

local gsub = string.gsub;

function module.eof(str)
    return gsub(str,"|","end");
end

return module;
