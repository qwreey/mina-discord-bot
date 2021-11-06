--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

-- Load env
local app = _G.app;
local options = app and app.options;
local date = os.date;
local fs = _G.fs;
-- Make log module object
local log = {
	_version = "0.1.0";
	buildPrompt = _G.buildPrompt;
	prefix = options["--logger_prefix"];
	usecolor = true;
	outfile = nil;
	minLevel = 1;
	disable = false;
};
local root = process and process.cwd();
if not root then
	local new = io.popen("cd");
	root = new:read("*l");
	new:close();
end
log.root = root;
local rootLen = #root;

-- Base
local function runLog(levelName,levelNumber,color,debugInfo,...)
	if log.disable then -- If log is disabled, return this
		return;
	elseif levelNumber < log.minLevel then -- If it not enough to display, return this
		return;
	end

	local msg = tostring(...); -- msg

	-- Get file name and line
	local src = debugInfo.short_src;
	if string.sub(src,1,rootLen) == root then -- remove root prefix
		src = string.sub(src,rootLen+2,-1);
	end
	src = (src
		:gsub("%.lua$","") -- remove .lua
		:gsub("^%.[/\\]","") -- remove ./
		:gsub("[\\//]",".")
		:gsub("%.init$","") -- remove .init
	); -- change \ and / into .
	local lineinfo = ("%s:%s"):format(src,tostring(debugInfo.currentline)); -- source:line

	-- Make header
	local usecolor = log.usecolor;
	local prefix = log.prefix;
	local header = string.format("%s[%-6s%s]%s %s%s ",
		usecolor and color or "",
		levelName, -- Level
		date("%H:%M"), -- add date
		usecolor and "\27[0m" or "", -- reset color
		prefix and ("%s(%s)%s "):format(
			usecolor and "\27[93m" or "",
			tostring(prefix),
			usecolor and "\27[0m" or ""
		) or "", -- print perfix
		lineinfo -- line info
	);
	local headerLen = #(header:gsub("\27%[%d+m",""));
	local liner = headerLen%6;
	if liner ~= 0 then
		local adding = 6 - liner;
		headerLen = headerLen + adding;
		header = header .. (" "):rep(adding);
	end
	headerLen = headerLen + 2;
	header = header .. "│ ";
	msg = msg:gsub("\n","\n" .. (" "):rep(headerLen-2) .. "│ ");

	-- print / build prompt
	local buildPrompt = _G.buildPrompt;
	local str = buildPrompt and {"\27[2K\r\27[0m",header,msg,"\n",buildPrompt()} or {"\27[2K\r\27[0m",header,msg,"\n"};
	local prettyPrint = _G.prettyPrint;
	if prettyPrint then
		prettyPrint.stdout:write(str);
	else
		io.write(unpack(str));
	end

	-- Adding message into output
	if log.outfile then
		local data = ("[%-6s%s] %s: %s\n"):format(levelName, os.date(), lineinfo, msg);
		if fs then
			fs.appendFile(log.outfile,data);
		else
			local fp = io.open(log.outfile, "a");
			fp:write();
			fp:close();
		end
	end

	return str;
end

-- 모드들
local modes = {
	[-2] = {name = "cmd",color = "\27[95m"};
	[-1] = {name = "exit",color = "\27[95m"};
	[0] = {name = "setup",color = "\27[93m"};
	[1] = {name = "trace",color = "\27[34m"};
	[2] = {name = "debug",color = "\27[36m"};
	[3] = {name = "info", color = "\27[32m"};
	[4] = {name = "warn", color = "\27[33m"};
	[5] = {name = "error",color = "\27[31m"};
	[6] = {name = "fatal",color = "\27[35m"};
};
for i,v in pairs(modes) do
	v.level = i;
	v.upName = string.upper(v.name);

	log[v.name] = function (...)
		return runLog(v.upName,v.level,v.color,debug.getinfo(2, "Sl"),...);
	end;
	log[v.name .. "f"] = function (...)
		return runLog(v.upName,v.level,v.color,debug.getinfo(2, "Sl"),string.format(...));
	end;
end

---@class loggerPrint
---@param message string what you want to print
---@return string printData
local function loggerPrint(message) end

---@class loggerFormat
---@param message string what you want to print
---@param format any will formated into message
---@return string printData
local function loggerFormat(message,format,...) end

log.cmd		= log.cmd;    ---@type loggerPrint
log.cmdf	= log.cmdf;   ---@type loggerFormat
log.exit	= log.exit;   ---@type loggerPrint
log.exitf	= log.exitf;  ---@type loggerFormat
log.setup	= log.setup;  ---@type loggerPrint
log.setupf	= log.setupf; ---@type loggerFormat
log.trace	= log.trace;  ---@type loggerPrint
log.tracef	= log.trace;  ---@type loggerFormat
log.debug	= log.debug;  ---@type loggerPrint
log.debugf	= log.debugf; ---@type loggerFormat
log.info	= log.info;   ---@type loggerPrint
log.infof	= log.infof;  ---@type loggerFormat
log.warn	= log.warn;   ---@type loggerPrint
log.warnf	= log.warnf;  ---@type loggerFormat
log.error	= log.error;  ---@type loggerPrint
log.errorf	= log.errorf; ---@type loggerFormat
log.fatal	= log.fatal;  ---@type loggerPrint
log.fatalf	= log.fatalf; ---@type loggerFormat

return log;