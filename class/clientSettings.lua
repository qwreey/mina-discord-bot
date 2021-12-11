-- client initing config
local floor = math.floor;
_G.clientSettings = {
	routeDelay = floor(1000/50);
	largeThreshold = 0;--1024;--2048;
	cacheAllMembers = true;
	compress = true;
	bitrate = 64000; -- 72000
	logFile = nil;
};
return _G.clientSettings;
