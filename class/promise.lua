local promise = {};
promise.__index = promise;

local insert = table.insert;

function promise:andThen(func)
	if self.__state then
		if self.__passed then
			func(self)
		end
		return;
	end
	insert(self.__then,func);
	return self;
end

function promise:setRetry(num)

end

function promise:catch(func)
	if self.__state then
		if self.__passed then
			return;
		end
		
	end
end

local remove = table.remove;
local unpack = unpack or table.unpack;
local pcallWrapper = function (self,func,...)
	local result = {pcall(func,...)};
	self.__state = true;
	local isPassed = remove(result,1);
	if isPassed then
		local andThen = self.__then;
		if andThen then
			andThen(unpack(result));
		end
	end
end;

function promise.new(func,args)
	local this = {};
	
	
end

_G.promise = promise;
return promise;
