--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

네이버 사전에 검색하기 API
자세한 사항은 네이버 공식 API 문서 참조 바람
https://developers.naver.com/docs/serviceapi/search/encyclopedia/encyclopedia.md#%EB%B0%B1%EA%B3%BC%EC%82%AC%EC%A0%84

]]

local module = {};
local corohttp;
local urlCode;
local json;

function module:setCoroHttp(NewCorohttp)
	corohttp = NewCorohttp;
	return self;
end
function module:setJson(NewJson)
	json = NewJson;
	return self;
end
function module:setUrlCode(NewUrlCode)
	urlCode = NewUrlCode;
	return self;
end

function module.searchFromNaverDirt(Keyword,ClientData)
	local KeywordUrl = urlCode.urlEncode(Keyword);
	local Header,Body = corohttp.request("GET",
		("https://openapi.naver.com/v1/search/encyc.json?query=%s&display=8"):format(KeywordUrl),{
			{"X-Naver-Client-Id",ClientData.naverClientId},
			{"X-Naver-Client-Secret",ClientData.naverClientSecret}
		}
	);
	return json.decode(Body),KeywordUrl;
end

return module;