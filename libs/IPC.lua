--[[
IPC = require "libs.IPC" new = IPC.new("python",{"server/youtubeServer/main.py"})
new:request('{"o":"asdfasdf","d":{"url":"https://www.youtube.com/watch?v=esaeuzXIr-4","file":"asdf"}}')
new:request{url="https://www.youtube.com/watch?v=esaeuzXIr-4",file="asdf"}
]]

local module = {};
local makeId = require "random".makeId;
local yield,resume,running,wrap = coroutine.yield,coroutine.resume,coroutine.running,coroutine.wrap;
module.__index = module;
local encode,decode = json.encode,json.decode;

local _,prettyPrint = pcall(require,"pretty-print");
local stdout = prettyPrint and prettyPrint.stdout;
local format = string.format;
function module:log(str,...)
	if select("#",...) ~= 0 then
		str = format(str,...);
	end
	local logger = logger;
	local err = logger and logger.error;
	if err then
		err(str,nil,{
			noLineInfo = true;
			prefix = self.name or "IPC";
		});
	elseif stdout then
		stdout:write(str);
	elseif io then
		io.write(str);
	end
end

---Make new IPC wrapper with coro spawn
---@param target string|table target process
---@param args table|nil arg for child process
---@param newlinebuffer boolean|nil if this value is true, using \n as buffer splitter on stdout
---@param name string|nil name of this process, it will displayed on console (for debug, this option will help you a lot)
function module.new(target,args,newlinebuffer,name)
	local child,err;
	if type(target) == "table" then
		for _,childTarget in ipairs(target) do
			child,err = spawn(childTarget, {args = args,stdio = {true,true,true}});
			if child then break; end
		end
	else
		child,err = spawn(target,{args = args,stdio = {true,true,true}});
	end
	if not child then
		error(("Failed to create child process\nError message was: %s"):format(err));
	end
	local this = {process = child,waitter = {},name = name};
	setmetatable(this,module);
	wrap(module.stdoutReader)(this,newlinebuffer);
	wrap(module.stderrReader)(this);
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
		return self:log("failed to decode stdout, stdout was\n%s",str);
	end
	local err = data.e;
	if err then
		self:log("error code was received from process, stdout was\n%s",str)
	end
	local waitter = self.waitter[data.o]; ---@diagnostic disable-line
	if waitter then
		wrap(module.resume)(waitter,data.d,data.e); ---@diagnostic disable-line
	else
		self:log(("failed to get waitter, nonce id was %s"):format(tostring(data.o))); ---@diagnostic disable-line
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

function module:stderrReader()
	for str in self.process.stderr.read do
		module:log(str);
	end
end

function module:setName(str)
	self.name = str;
end

return module;
