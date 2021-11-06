-- client initing config
_G.clientSettings = {
	routeDelay = 0;
	largeThreshold = 2048;
	cacheAllMembers = true;
	compress = true;
	bitrate = 64000; -- 72000
	logFile = nil;
};
return _G.clientSettings;
