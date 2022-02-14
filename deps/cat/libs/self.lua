local module = {};

local gsub = string.gsub;

local function selfFormatter(all,st,mid,ed)
    if st == "[" then
        return "self"..all;
    end
    return "self."..all;
end

function module.self(str)
    return gsub(str,"@((%[?)([^ ]-)(%]?))",selfFormatter);
end

return module;
