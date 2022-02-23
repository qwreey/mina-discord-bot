local module = {};

local gsub = string.gsub;

-- local function formatting(st,ed)
--     st = st and st ~= "";
--     ed = ed and ed ~= "";
--     return (st and ed and "end") or (st and "end ") or (ed and " end");
-- end

function module.eof(str)
    -- return gsub(str,"([%(%)\n \t%[%];]?)|([%(%)\n \t%[%];]?)",formatting);
    return gsub(str,"|"," end ");
end

return module;
