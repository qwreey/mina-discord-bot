
local module = {};

local gsub = string.gsub;

function module.operator(str)
    return gsub(gsub(gsub(str,
        " ?|| ?"," or "),
        " ?&& ?"," and "),
        "! ?","not "
    );
end

function module.compare(str)
    return gsub(str,"!=","~=");
end

function module.null(str)
    return gsub(str,"null","nil");
end

return module;
