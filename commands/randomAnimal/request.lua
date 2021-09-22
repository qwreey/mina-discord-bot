
--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

영어 명언 API
https://api.quotable.io/random

]]

local module = {};
local corohttp;
local json;

function module:setCoroHttp(NewCorohttp)
	corohttp = NewCorohttp;
	return self;
end
function module:setJson(NewJson)
	json = NewJson;
	return self;
end

local requests = {
	["cat"] = {
		alias = {"고먐미","고양이","캣","꼬야미","고얌이","꼬얌미"};
		func = function ()
			local Header,Body = corohttp.request("GET","https://api.thecatapi.com/v1/images/search");
			return json.decode(Body).url;
		end;
	};
};
local indexedRequests = {};
for i,v in pairs(requests) do
	local this = v.func;
	indexedRequests[i] = this;
	for _,i2 in ipairs(v.alias) do
		indexedRequests[i2] = this;
	end
end
requests = nil;

function module.fetch(name)
	local func = indexedRequests[name];
	if not func then
		return "오류! %s 는 유효한 식별가능한 동물이 아닙니다";
	end
	return func();
end

return module;