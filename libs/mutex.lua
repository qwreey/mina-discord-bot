---@class mutex
local mutex = {};
mutex.__index = mutex;

local insert = table.insert;
local remove = table.remove;
local resume = coroutine.resume;
local running = coroutine.running;
local yield = coroutine.yield;
local wrap = coroutine.wrap;

--- wait for mutex is unlocked
function mutex:wait(this)
    this = this or running();
    if not this then
        error("mutex:wait() must be runned on coroutine!");
    end
    if self.__locked then
        local wait = self.__wait;
        if not wait then
            wait = {};
            self.__wait = wait;
        end
        insert(wait,this);
        return yield(mutex);
    end
end

function mutex:lock(this)
    this = this or running();
    if not this then
        error("mutex:lock() must be runned on coroutine!");
    end
    self:wait(this);
    self.__locked = true;
end

function mutex:unlock()
    local wait = self.__wait;
    if wait and #wait ~= 0 then
        local this = remove(wait,1);
        wrap(resume)(this);
        return mutex;
    end
    self.__locked = false;
end

function mutex:isLocked()
    return self.__locked;
end

function mutex.new()
    local new = {};
    setmetatable(new,mutex);
    return new;
end
mutex.__index = mutex;

return mutex;
