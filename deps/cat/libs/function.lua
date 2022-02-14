
local module = {};

local gsub = string.gsub;
local format = string.format;

local function normalFormatter(str,method)
    if method then return format(" = function(%s)",str); end
    return format("function(%s)",str);
end

local function selfFormatter(str,method)
    local comma = str == "" and "" or ",";
    if method then return format(" = function(self%s%s)",comma,str); end
    return format("function(self%s%s)",comma,str);
end

function module.arrow(str)
    return gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(str,
        " ?%((.-)%) -%-(%-?)>",normalFormatter),
        " ?([%w_]-) -%-(%-?)>",normalFormatter),
        " ?%((.-)%) -=(=?)>",selfFormatter),
        " ?([%w_]-) -=(=?)>",selfFormatter),
        " ?%-%->"," = function()"),
        " ?==>"," = function(self)"),
        " ?%->"," function()"),
        " ?=>"," function(self)"
    )
end

return module;
