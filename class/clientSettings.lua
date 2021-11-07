-- client initing config
_G.clientSettings = {
	routeDelay = 1000/50;
	largeThreshold = 1024;--2048;
	cacheAllMembers = true;
	compress = true;
	bitrate = 64000; -- 72000
	logFile = nil;
};
return _G.clientSettings;
