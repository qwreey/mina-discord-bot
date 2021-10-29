local module = {};

function module.run(str)
    return str:gsub("||","or");
end

return module;