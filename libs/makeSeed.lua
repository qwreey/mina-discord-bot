local piP = math.pi^14/10101010;
local uv = uv or require("uv");
local time = uv.hrtime;
local floor = math.floor;
local i = 0;
return function (min,max)
	i = (i > 1000000000 and 1 or i) + 1;
	local rm = collectgarbage("count")^2%1*piP;
	local ts = time()%1^2*piP*10;
	-- local sd = floor((rm+ts)*10000000000000)%100000000000000000000000;
	-- logger.infof("Random seed generated : %d",sd);
	return floor((rm+ts)*10000000000000)%100000000000000000000000+i;
end;
