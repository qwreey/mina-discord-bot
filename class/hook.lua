-- HOOK SYSTEM
local beforeHook = {};
local afterHook = {};
local hook = {};
hook.__index = hook;
hook.types = {after = 1; before = 2;};
function hook.new(self)
	self.id = makeId();
	self.type = self.type or self.types.before;
	setmetatable(self,hook);
	return self;
end
function hook:attach()
	if self.isAttach then
		error("This hook already attached to message event!");
	end
	((self.type == self.types.after and afterHook) or (self.type == self.types.before and beforeHook))[self.id] = self;
	self.isAttach = true;
end
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