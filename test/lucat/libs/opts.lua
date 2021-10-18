local module = {};

function module.run(str)
    return str:gsub("([%w_] -%+= -)",function (name)
        return ("%s = %s + "):format(name);
    end);
end

return module;