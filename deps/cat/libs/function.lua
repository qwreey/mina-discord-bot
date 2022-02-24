
local module = {};

local gsub = string.gsub;
local format = string.format;

local function normalFormatter(str,set)
    if set == "-" then return format(" = function(%s)",str); end
    return format("function(%s)",str);
end

local function selfFormatter(str,set)
    local comma = str == "" and "" or ",";
    if set == "=" then return format(" = function(self%s%s)",comma,str); end
    return format("function(self%s%s)",comma,str);
end

function module.arrow(str)
    return gsub(gsub(gsub(gsub(gsub(gsub(gsub(gsub(str,
        " ?%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?%-(%-?)>",normalFormatter),
        " ?([%w_]-) ?%-(%-?)>",normalFormatter),
        " ?%(([^%(%)%-%%%+=%?:'\\\"\n]-)%) ?=(=?)>",selfFormatter),
        " ?([%w_]-) ?=(=?)>",selfFormatter),
        " ?%-%->"," = function()"),
        " ?==>"," = function(self)"),
        " ?%->"," function()"),
        " ?=>"," function(self)"
    )
end

return module;
