return function (originalRequire,originalModule,fenv)

    local luvitRequire = originalRequire("luvitRequire");
    local newRequire,newModule = luvitRequire(originalModule.path);
    fenv.module = newModule;
    originalRequire = newRequire;

    local requireProfiler = profiler.new("Require Items");
    local loaded = package.loaded;
    local promise = promise;
    local waitter = promise.waitter;
    local unpack = table.unpack;

    local loadModule = function (namespace)
        local this = loaded[namespace];
        if this then return this; end
        requireProfiler:start(namespace);
        this = newRequire(namespace);
        requireProfiler:stop();
        return this;
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
