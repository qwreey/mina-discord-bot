
return function (path,ffi)
    if ffi.os == "Linux" then
        ffi.cdef [[
            double clock_alternative();
        ]]
        local bind = ffi.load(path or "./ptimelua.so");
        local t0 = bind.clock_alternative();
        local function clock_override()
            return bind.clock_alternative() - t0;
        end
        os.clock = clock_override;
    end
end
