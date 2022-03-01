-- local piP = math.pi^14/10101010;
-- local uv = uv or require("uv");
-- local time = uv.hrtime;
-- local floor = math.floor;
-- local i = 0;
-- return function (min,max)
-- 	i = (i > 1000000000 and 1 or i) + 1;
-- 	local rm = collectgarbage("count")^2%1*piP;
-- 	local ts = time()%1^2*piP*10;
-- 	-- local sd = floor((rm+ts)*10000000000000)%100000000000000000000000;
-- 	-- logger.infof("Random seed generated : %d",sd);
-- 	return floor((rm+ts)*10000000000000)%100000000000000000000000+i;
-- end;

local uv = uv or require("uv");
local clock = uv.hrtime;
local getrusage = uv.getrusage;
local last = 0;
local index = 0;
local xor = bit.bxor;
local time = os.time;

return function ()
	index = index + 1;
	local status = getrusage();
	local this = xor(time(),clock(),collectgarbage("count")*100000000,status.maxrss,status.majflt,status.utime.usec,index,last);
	last = this;
	return this;
end
