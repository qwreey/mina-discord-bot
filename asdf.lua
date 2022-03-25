local module = {}

function module.testfunc()
    print("Hello world")
end

local getter = {}
setmetatable(getter,{__call = function (self,key)
  return module[key]
end})

return setmetatable({},{_ = getter})