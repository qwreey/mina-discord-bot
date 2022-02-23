local module = {};

local format = string.format;
local gsub = string.gsub;
local match = string.match;

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

local function removeSpace(str)
	return gsub(gsub(str,"^[\t ]+",""),"[\t ]+$","");
end
local function getIndent(line)
	return match(line,"^ *");
end

local function formatWhen(opt,pass,doing)
	if pass == "=" then return; end
	local indent = getIndent(opt);
	opt,doing = removeSpace(opt),removeSpace(doing);
	if opt == "" then
		opt = doing;
		doing = "";
	end
	if opt == "" then return; end
	if doing == "" then
		return format("%sif %s then",indent,opt);
	end
	return format("%sif %s then %s",indent,opt,doing);
end

function module.whenopt(str)
	return gsub(str,"([^\n]-)~([~=]?)([^\n]+)",formatWhen);
end

return module;

