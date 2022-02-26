--[[
IPC = require "libs.IPC" new = IPC.new("python",{"server/youtubeServer/main.py"})
new:request('{"o":"asdfasdf","d":{"url":"https://www.youtube.com/watch?v=esaeuzXIr-4","file":"asdf"}}')
new:request{url="https://www.youtube.com/watch?v=esaeuzXIr-4",file="asdf"}
]]

local module = {};
local makeId = require "makeId";
local yield,resume,running,wrap = coroutine.yield,coroutine.resume,coroutine.running,coroutine.wrap;
module.__index = module;
local encode,decode = json.encode,json.decode;

---Make new IPC wrapper with coro spawn
---@param target string target process
---@param args table|nil arg for child process
---@param newlinebuffer boolean|nil if this value is true, using \n as buffer splitter on stdout 
function module.new(target,args,newlinebuffer)
    local child = spawn(target,{args = args,stdio = {true,true,2}});
    if not child then
        error"Failed to create child process";
    end
    local this = {process = child,waitter = {}};
    setmetatable(this,module);
    wrap(module.stdoutReader)(this,newlinebuffer);
    return this;
end

function module:request(body,key)
    local nonce = makeId();
    self.process.stdin.write(encode({o=nonce,d=body,f=key}).."\n");
    self.waitter[nonce] = running();
    local data,err = yield();
    if err then
        error(err);
    end
    return data;
end

function module.resume(waitter,...)
    resume(waitter,...);
end

function module:onbuffer(str)
    local data = decode(str);
    if not data then
        return logger.warnf("failed to decode stdout, stdout was\n%s",str);
    end
    local waitter = self.waitter[data.o];
    if waitter then
        wrap(module.resume)(waitter,data.d,data.e);
    else
        logger.warnf("failed to get waitter, nonce id was %s",tostring(data.o));
    end
end

function module:stdoutReader(newlinebuffer)
    local buffer = "";
    for str in self.process.stdout.read do
        if newlinebuffer then
            if buffer then
                str = buffer .. str;
	        end
            if str:match"\n" then
                buffer = nil;
		        self:onbuffer(str);
            else buffer = str;
            end
        else module.onbuffer(str);
        end
    end
end

return module;
