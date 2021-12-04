local promise = {};
promise.__index = promise;

local insert = table.insert;
local remove = table.remove;
local unpack = unpack or table.unpack;

function promise:andThen(func)
	if self.__state then
		if self.__passed then
			func(self)
		end
		return;
	end

	-- insert into list
	local __then = self.__then;
	if not __then then
		__then = {};
		self.__then = __then;
	end
	insert(__then,func);
	return self;
end

--TODO: 이거 구현 해야됨
function promise:setRetry(num)
	self.__retry = num;
end

function promise:getRetry()
	return self.__retry;
end

-- is error in there
function promise:catch(func)
	if self.__state then
		if self.__passed then
			return;
		end
		func(self);
		return;
	end

	-- insert into list
	local __catch = self.__catch;
	if not __catch then
		__catch = {};
		self.__catch = __catch;
	end
	insert(__catch,func);
	return self;
end

-- local pcallWrapper = function (self,func,...)
-- 	local result = {pcall(func,...)};
-- 	self.__state = true;
-- 	local isPassed = remove(result,1);
-- 	if isPassed then
-- 		local andThen = self.__then;
-- 		if andThen then
-- 			andThen(unpack(result));
-- 		end
-- 	end
-- end;

function promise.new(func,...)
	local this = {};
	setmetatable(this,promise);

	local coroutine = coroutine.wrap(func);
	local callArgs = {...};
	coroutine.wrap(function ()
		local results = {pcall(func,unpack(callArgs))};
		this.__state = true;
		local passed = remove(results,1);
		this.__passed = passed;
		if passed then
			for _,f in ipairs(this.__then) do
				f(unpack(results));
			end
			this.__then = nil;
		else
			for _,f in ipairs(this.__catch) do
				f(unpack(results)); -- err, ...
			end
			this.__catch = nil;
		end
	end);

	return this;
end

local p = promise.new(function ()
	error("What");
	return "Hello world";
end):catch(function (err)
	print("Errored on running function");
end):andThen(function (something)

end);

_G.promise = promise;
return promise;
