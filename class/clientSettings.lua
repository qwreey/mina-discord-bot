-- client initing config
local floor = math.floor;
_G.clientSettings = {
	routeDelay = floor(1000/50);
	largeThreshold = 2048;
	cacheAllMembers = false;
	compress = true;
	bitrate = 64000;
	logFile = nil;
	wssProps = {
		['$browser'] = "Discord iOS";
	}
};
return _G.clientSettings;
