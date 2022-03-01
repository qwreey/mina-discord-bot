--[[

작성 : qwreey
2021y 04m 06d
7:07 (PM)

코로나 19 데이터 fetching (http://openapi.data.go.kr)

]]

local module = {};

local posixTime = _G.posixTime;
local dayInSec = 86400;
local hour9 = 9*60*60;
function module.get(clientData)
	local time = posixTime.now()+hour9;
	local today = os.date("*t",time);
	local yesterday = os.date("*t",time - dayInSec);

	local todayStr = tostring(today.year) do;
		local tmp;
		tmp = tostring(today.month);
		if #tmp < 2 then
			tmp = "0" .. tmp
		end
		todayStr = todayStr .. tmp

		tmp = tostring(today.day);
		if #tmp < 2 then
			tmp = "0" .. tmp
		end
		todayStr = todayStr .. tmp
	end

	local yesterdayStr = tostring(yesterday.year) do;
		local tmp;
		tmp = tostring(yesterday.month);
		if #tmp < 2 then
			tmp = "0" .. tmp
		end
		yesterdayStr = yesterdayStr .. tmp

		tmp = tostring(yesterday.day);
		if #tmp < 2 then
			tmp = "0" .. tmp
		end
		yesterdayStr = yesterdayStr .. tmp
	end

	local url = ("http://openapi.data.go.kr/openapi/service/rest/Covid19/getCovid19InfStateJson?serviceKey=%s&pageNo=1&numOfRows=1&startCreateDt=%s&endCreateDt=%s")
		:format(clientData.covid19Client,yesterdayStr,todayStr);
	local _,body = corohttp.request("GET",url);
	return myXml.xmlToItem(body);
end

return module;
