--[[

작성 : qwreey
2021y 04m 07d
6:00 (PM)

LUA 렌덤을 핸들링

최소값 / 최대값을 입력받음
최소값을 min 이라는 값에 집어넣고
최대값을 max 이라는 값에 집어넣음

파이에 13 제곱한걸 pi3 이라는 값에 집어넣음

램 사용량 가져와서 소숫점 부분만 때서 pi3 를 곱하고 통채로 제곱하고 1000000 곱한걸 rm 이라는 값에 집어넣음

지금 시간 값을 마이크로초 단위로 가져 온 뒤 pi3 를 곱하고 통채로 제곱함 그리고 그걸 ts 이라는 값에 집어넣음

min 나누기 13(소수라서 씀) 에 제곱과 max 나누기 11 의 제곱을 더하고 거기에 pi3 을 곱한 뒤 통채로 제곱을 하고 거기에 ts 를 곱하고 rm 을 더한 뒤 seed 라는 값에 집어넣음

seed 를 루아 기본 난수 생성기에 집어넣고 루아 기본 난수 생성기로 난수를 생성 한 뒤 리턴

]]

local makeSeed = require "libs.makeSeed";
return function (min,max,ignore)
	math.randomseed(makeSeed(min,max));
	if ignore then
		local this = math.random(min,max - #ignore);
		for _,v in ipairs(ignore) do
			if this >= v then
				this = this + 1;
			end
		end
		return this;
	else
		return math.random(min,max);
	end
end;
