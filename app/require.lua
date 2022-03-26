return function (originalRequire)
    local requireProfiler = profiler.new("Require Items");
    local loaded = package.loaded;
    local promise = promise;
    local waitter = promise.waitter;
    local requireProfiler = requireProfiler;
    local unpack = table.unpack;

    local loadModule = function (namespace)
        local module = loaded[namespace];
        if module then return module; end
        requireProfiler:start(namespace);
        module = originalRequire(namespace);
        requireProfiler:stop();
        return module;
    end
    local loadModuleAsync = promise.async(loadModule);

    local require = function (namespace,...)
        if select("#",...) == 0 then
            return loadModule(namespace);
        end
        local moduleWaitter = waitter();
        for _,v in ipairs{namespace,...} do
            moduleWaitter:add(loadModuleAsync(v));
        end
        return unpack(moduleWaitter:await());
    end
    _G.require = require;
    return require;
end;
