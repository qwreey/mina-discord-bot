-- client initing config
local floor = math.floor;
_G.clientSettings = {
	routeDelay = floor(1000/50);
	largeThreshold = 4000;--2048;
	cacheAllMembers = false;
	compress = true;
	bitrate = 64000; -- 72000
	logFile = nil;
};
return _G.clientSettings;
