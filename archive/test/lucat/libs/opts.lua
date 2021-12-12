local module = {};

local function ps(name)
    return ("%s = %s + "):format(name,name);
end
local function mi(name)
    return ("%s = %s - "):format(name,name);
end
local function mu(name)
    return ("%s = %s * "):format(name,name);
end
local function sq(name)
    return ("%s = %s ^ "):format(name,name);
end
local function di(name)
    return ("%s = %s / "):format(name,name);
end
local function md(name)
    return ("%s = %s %% "):format(name,name);
end

function module.run(str)
    return str
      :gsub("([%w_] -%+= -)",ps)
      :gsub("([%w_] -%-= -)",mi)
      :gsub("([%w_] -%*= -)",mu)
      :gsub("([%w_] -%^= -)",sq)
      :gsub("([%w_] -/= -)" ,di)
      :gsub("([%w_] -%%= -)",md);
end

return module;
