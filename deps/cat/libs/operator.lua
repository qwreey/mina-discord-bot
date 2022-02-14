local module = {};

local format = string.format;
local gsub = string.gsub;

local function ps(name)
    return format("%s = %s + ",name,name);
end
local function mi(name)
    return format("%s = %s - ",name,name);
end
local function mu(name)
    return format("%s = %s * ",name,name);
end
local function sq(name)
    return format("%s = %s ^ ",name,name);
end
local function di(name)
    return format("%s = %s / ",name,name);
end
local function md(name)
    return format("%s = %s %% ",name,name);
end

function module.operator(str)
    return gsub(gsub(gsub(gsub(gsub(gsub(str,
        "([%w_] -%+= -)",ps),
        "([%w_] -%-= -)",mi),
        "([%w_] -%*= -)",mu),
        "([%w_] -%^= -)",sq),
        "([%w_] -/= -)" ,di),
        "([%w_] -%%= -)",md
    );
end

return module;
