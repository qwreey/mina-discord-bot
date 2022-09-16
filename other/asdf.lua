-- local thread = require("thread")

-- local function asdf(a)
--     while true do
--     end
-- end

-- local function wow(a)
--     print(a)
-- end
local uv = require"uv"
thread.start(function () end,uv)




-- local threading = {}
-- threading.__index = threading

-- function threading.new(func)
--     return setmetatable({_func = func,_work = thread.work(func)},threading)
-- end

-- function threading:call(...)
--     thread.queue(self.work,...)
-- end


-- local promise = require "promise"

-- local threading = {}
-- threading.__index = threading

-- function threading.new()

-- end


-- while true do
--     print("wow")
-- end
