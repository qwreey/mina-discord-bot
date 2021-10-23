local loaded = package.loaded;
local root = "./app/inject/";
local injected = {};
local function inject(path,id)
    injected[id] = path;
    --loaded[id] = dofile(root .. path);
end
local orequire = require;
local nrequire = function (this)
    local path = injected[this];
    if path then
        local new = dofile(path);
        loaded[this] = new;
        return new;
    end
end
_G.require = require;

return inject;
