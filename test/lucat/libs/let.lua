local module = {};

function module.run(str)
    return str:gsub("let","local");
end

return module;