local module = {};

local gsub = string.gsub;

function module.newline(str)
    -- return gsub(str,"([%(%)\n \t%[%];]?)|([%(%)\n \t%[%];]?)",formatting);
    return gsub(str,"\\\n"," ");
end

return module;
