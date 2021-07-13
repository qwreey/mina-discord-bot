local module = {};
local dat,len;

local json;
function module:setJson(nJson)
    json = nJson;
    return self;
end

local cRandom;
function module:setCRandom(nCRandom)
    cRandom = nCRandom;
    return self;
end

function module.fetch()
    if not dat then
        local file = io.open("src/lib/korquote/dat.json");
        local raw = file:read("a");
        dat = json.decode(raw);
        raw = nil;
        file:close();
        file = nil;
        len = #dat;
    end
    return dat[cRandom(1,len)];
end

return module;