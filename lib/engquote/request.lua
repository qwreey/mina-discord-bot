
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

function module.fetch()
	local Header,Body = corohttp.request("GET","https://api.quotable.io/random");
	return json.decode(Body);
end

return module;