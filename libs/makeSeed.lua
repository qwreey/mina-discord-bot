local pi3 = math.pi^13/10000000;
return function (min,max)
	local rm = (collectgarbage("count")*pi3)^2 * 1000000;
	local ts = (os.clock()*pi3)^2;
	local seed = math.floor(ts*((((min/13)^2+(max/11)^2)*pi3)^2+rm));

	return seed;
end;
