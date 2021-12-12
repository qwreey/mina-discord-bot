local module = {};

function module.run(str)
    return str:gsub("!","not ");
end

return module;