local module = {};

local gsub = string.gsub;

function module.comment(str)
    return gsub(str,"//","--");
end

return module;
