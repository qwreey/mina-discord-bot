local module = {};

function module.run(str)
    return str:gsub("null","nil");
end

return module;