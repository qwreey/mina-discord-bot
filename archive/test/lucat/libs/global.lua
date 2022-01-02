local module = {};

function module.run(str)
    return str:gsub("[%[%]%(%)%.]? -global -","_G.");
end

return module;