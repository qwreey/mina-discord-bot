--[[

원문 : https://gist.github.com/liukun/f9ce7d6d14fa45fe9b924a3eed5c3d99

수정/가공 : qwreey
2021y 04m 06d
7:07 (PM)

문자들을 URL 문자로 변형시켜주는 알고리즘

]]

local char_to_hex = function(c)
	return string.format("%%%02X", string.byte(c));
end
local HexToChar = function(x)
	return string.char(tonumber(x, 16));
end

local module = {};

function module.urlEncode(url)
	url = url or "";
	return url:gsub("\n", "\r\n"):gsub("([^%w/?&%:=%.#])", char_to_hex):gsub(" ", "+");
end

function module.urlDecode(url)
	url = url or "";
	return url:gsub("+", " "):gsub("%%(%x%x)", HexToChar);
end

return module;