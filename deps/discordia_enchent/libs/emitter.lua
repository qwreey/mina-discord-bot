local discordia = require("discordia")
local classes = discordia.class.classes
local Emitter = classes.Emitter

function Emitter:emit(name, ...)
	local listeners = self._listeners[name]
	if not listeners then return end
	for i = 1, #listeners do
		local listener = listeners[i]
		if listener then
			local fn = listener.fn
			if listener.once then
				listeners[i] = false
			end
			if listener.sync then
				pcall(fn,...)
			else
				pcall(wrap(fn),...)
			end
		end
	end
	if listeners._removed then
		for i = #listeners, 1, -1 do
			if not listeners[i] then
				remove(listeners, i)
			end
		end
		if #listeners == 0 then
			self._listeners[name] = nil
		end
		listeners._removed = nil
	end
end
