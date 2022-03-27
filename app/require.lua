return function (originalRequire)
    local requireProfiler = profiler.new("Require Items");
    local loaded = package.loaded;
    local require = function (namespace)
        local module = loaded[namespace];
        if module then return module; end
        requireProfiler:start(namespace);
        module = originalRequire(namespace);
        requireProfiler:stop();
        return module;
    end
    _G.requireProfiler = requireProfiler;
    _G.require = require;
    return require;
end;
