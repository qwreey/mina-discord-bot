local module = {};
local urlCode,json,corohttp;

function module:setCoroHttp(newCorohttp)
	corohttp = newCorohttp;
	return self;
end
function module:setJson(newJson)
	json = newJson;
	return self;
end
function module:setUrlCode(newUrlCode)
	urlCode = newUrlCode;
	return self;
end

local url = "https://api.mozambiquehe.re/bridge?version=5&platform=PC&player=%s&auth=%s";
function module.fetch(query,ClientData)
	query = urlCode.urlDecode(query);
	local Header,Body = corohttp.request("GET",url:format(
		query,ClientData.ApexLegendsApiKey
	));
	return json.decode(Body);
end

return module;