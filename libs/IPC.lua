local module = {};
local makeId = require "makeId";
local yield,resume,running = coroutine.yield,coroutine.resume,coroutine.running;

---Make new IPC wrapper with coro spawn
---@param target string target process
---@param args table|nil arg for child process
function module.new(target,args)
    local child = spawn(target,{});
    if not child then
        error"Failed to create child process";
    end
    local this = {process = child,waitter = {}};
    setmetatable(this,module);
    return this;
end

function module:request(body)
    local nonce = makeId();
    json.encode({o=nonce,d=body})
    running()
end

return module;
