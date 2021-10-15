local module = {};

local urlCode;
function module:setUrlCode(newUrlCode)
	urlCode = newUrlCode;
	return self;
end

function module:embed(body)
	local author = body.author;
	return {
		color = 16760299;
		footer = {
			text = "https://github.com/lukePeavey/quotable 의 API 를 이용한 검색 결과입니다";
		};
		author = {
			name = author;
			url = "https://www.google.co.kr/search?q=" .. urlCode.urlEncode(author);
		};
		description = body.content;
	};
end

return module;
