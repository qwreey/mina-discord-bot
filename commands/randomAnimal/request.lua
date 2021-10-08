
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
	["고양이"] = {
		alias = {"고먐미","cat","캣","꼬야미","고얌이","꼬얌미"};
		func = {
			function ()
				local Header,Body = corohttp.request("GET","https://api.thecatapi.com/v1/images/search");
				if not Body then return end
				local decoded = json.decode(Body);
				if not decoded then return end
				local this = decoded[1];
				if (not this) then return end
				return this.url;
			end;
			function ()
				local Header,Body = corohttp.request("GET","https://aws.random.cat/meow");
				if not Body then return end
				local decoded = json.decode(Body);
				if not decoded then return end
				return decoded.file;
			end;
		};
	};
	["강아지"] = {
		alias = {"dog","개","멍멍이","도그","멍뭉이","강얼지","강아쥐","강얼쥐","강알쥐","강알지"};
		func = function ()
			local Header,Body = corohttp.request("GET","https://dog.ceo/api/breeds/image/random");
			if not Body then return end
			local decoded = json.decode(Body);
			if not decoded then return end
			return decoded.message;
		end;
	};
	["여우"] = {
		alias = {"폭스","fox","녀우","여웅"};
		func = function ()
			local Header,Body = corohttp.request("GET","https://randomfox.ca/floof/");
			if not Body then return end
			local decoded = json.decode(Body);
			if not decoded then return end
			return decoded.image;
		end;
	};
};
local loadable = "";
local indexedRequests = {};
for i,v in pairs(requests) do
	local this = v.func;
	indexedRequests[i] = this;
	for _,i2 in ipairs(v.alias) do
		indexedRequests[i2] = this;
	end
	loadable = loadable .. ("'%s', "):format(i);
end
loadable = loadable:sub(1,-3);
requests = nil;
local loadableMsg = ("불러 올 수 있는 동물은 %s 입니다"):format(loadable)

function module.fetch(name)
	if (not name) or (name == '') then
		return loadableMsg;
	end
	local func = indexedRequests[name];
	if not func then
		return ("오류! %s 는 유효한 식별가능한 동물이 아닙니다\n%s"):format(name,loadableMsg);
	end
	if type(func) == "table" then
		func = func[cRandom(1,#func)];
	end
	return func();
end

return module;
