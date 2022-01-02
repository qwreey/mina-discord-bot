-- get weather of country with open weather api
local function getWeather(country)
	local url = ("http://api.openweathermap.org/data/2.5/weather?q=%s&appid=b1b15e88fa797225412429c1c50c122a1"):format(urlCode.urlEncode(country));
	local _header,body = corohttp.request("GET",url);
	if body then
		local data = json.decode(body);
		if data then
			return data.weather[1].main;
		end
	end
	return "";
end
