
local loaded = package.loaded;
local root = "./app/inject/";
local function load(path)
	return dofile(root .. path .. ".lua");
end
local function getInjection(self,path)
	local injection = rawget(self,"__INJECTED");
	if not injection then
		logger.warnf("Modlue '%s' injected!",path);
		injection = load(path);
		rawset(self,"__INJECTED",injection);
	end
	return injection;
end

local function inject(path,id)

	local new = {};
	loaded[id] = new;

	setmetatable(new,{
		__index = function (self,k)
			return getInjection(self,path)[k];
		end;
		__newindex = function (self,k,v)
			getInjection(self,path)[k] = v;
		end;
		__call = function (self,...)
			return getInjection(self,path)(...);
		end;
	});

end

return inject;
