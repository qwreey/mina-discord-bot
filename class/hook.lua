-- HOOK SYSTEM

-- setup hook storage
---Hook storage (for before hooks)
local beforeHook = {};
---Hook storage (for after hooks)
local afterHook = {};

-- setup hook class
---This is will allow to execute something on message processing
---@class hook
---@field public id string hook id
---@field public hookType hookType type of hook
---@field public isAttach boolean the value of this hook is attached
local hook = {};
hook.__index = hook;

---Hook types, after will execute on message processed and before will execute before message processing
---@class hookType
---@class hookTypes
hook.types = {
	---@type hookType
	after = 1;
	---@type hookType
	before = 2;
};

-- define hook object
---Base of hook system
---@class hookConfig
---@field public type hookType | nil
---@return hook hook

---Init new hook object
---@param self hookConfig
---@return hook hook
function hook.new(self)
	self.id = makeId();
	self.type = self.type or self.types.before;
	setmetatable(self,hook);
	return self;
end

---Attach self into hook storage. after running this method, hook will executing on message processing
---@return nil
function hook:attach()
	if self.isAttach then
		error("This hook already attached to message event!");
	end
	((self.type == self.types.after and afterHook) or (self.type == self.types.before and beforeHook))[self.id] = self;
	self.isAttach = true;
end

---Detach self into hook storage. after running this method, hook will not executing on message processing
---@return nil
function hook:detach()
	if not self.isAttach then
		error("couldn't detach this hook from message event, it seemed not attached yet!");
	end
	((self.type == self.types.after and afterHook) or (self.type == self.types.before and beforeHook))[self.id] = nil;
	self.isAttach = false;
end

_G.hook = hook;
_G.afterHook = afterHook;
_G.beforeHook = beforeHook;

hook.afterHook = afterHook;
hook.beforeHook = beforeHook;

return hook;
