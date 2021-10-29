local module = {};

function module.run(str)
    return str:gsub("!=","~=");
end

return module;