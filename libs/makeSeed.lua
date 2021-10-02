local piP = math.pi^14/10101010;
local time = os.clock;
local floor = math.floor
return function (min,max)
	local rm = collectgarbage("count")^2%1*piP;
	local ts = time()%1^2*piP*10;
	return floor((rm+ts)*10000000000000)%100000000000000000000000;
end;
