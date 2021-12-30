--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

--#region : Setup

-- Load env
local date = os.date;
local fs = require "fs";
local prettyPrint = require "pretty-print"
local insert = table.insert;
local argParser = {};
function argParser.decode(split,optionArgs)
	optionArgs = optionArgs or {};
	local option = {};
	local args = {};

	local lastOpt;

	for i,this in ipairs(split) do
		if i >= 1 then
			if this:sub(1,1) == "-" then -- this = option
				option[this] = true;
				if optionArgs[this] then
					lastOpt = this;
				else lastOpt = nil;
				end
			elseif lastOpt then -- set option
				option[lastOpt] = this;
				lastOpt = nil;
			else
				insert(args,this);
			end
		end
	end

	return args,option;
end

-- Read process args
local options = _G.loggerOption
if not options then
	_,options = argParser.decode(_G.args or {},{ ---@diagnostic disable-line
		["--logger_prefix"] = true;
		["--logger_outfile"] = true;
		["--logger_minLevel"] = true;
		["--logger_color"] = true;
		["--logger_disabled"] = true;
	})
end
local log = {
	_version = "1.0.3";
	buildPrompt = _G.buildPrompt; ---@diagnostic disable-line
	prefix = options["--logger_prefix"];
	usecolor = (
		type(options["--logger_color"]) == "nil" or
		options["--logger_color"] == true or
		(
			type(options["--logger_color"]) == "string" and
			options["--logger_color"]:lower() == "true"
		) or false
	);
	outfile = options["--logger_outfile"];
	minLevel = tonumber(options["--logger_minLevel"]) or 1;
	disable = (
		options["--logger_disabled"] == true or
		(
			type(options["--logger_disabled"]) == "string" and
			options["--logger_disabled"]:lower() == "true"
		) or false
	);
}

-- get cwd
local root = process and process.cwd()
if not root then
	local new = io.popen("cd")
	root = new:read("*l")
	new:close()
end
log.root = root
local rootLen = #root

--#endregion : Setup
--#region : Processing

-- ascii formatting
local ansii = {
	-- [0] = "NUL";
	[1] = "SOH";
	[2] = "STX";
	[3] = "ETX";
	[4] = "EOT";
	[5] = "ENQ";
	[7] = "BEL";
	[8] = "BS";
	[9] = "TAB"; -- tab character
	[11] = "VT"; -- vertical tab character
	[12] = "FF"; -- form feed character
	[14] = "SO";
	[15] = "SI";
	[16] = "DEL";
	[17] = "DC1";
	[18] = "DC2";
	[19] = "DC3";
	[20] = "DC4";
	[21] = "NAK";
	[22] = "SYN";
	[23] = "ETB";
	[24] = "CAN";
	[25] = "EM";
	[26] = "SUB";
	[27] = "ESC";
	[28] = "FS";
	[29] = "GS";
	[30] = "RS";
	[31] = "US";
	[127] = "DEL";
}
local char = string.char
local spcColor = "\27[30;45m"
local function processMessage(str,useColor)
	local color = useColor and spcColor or ""
	for i,v in pairs(ansii) do
		str = str:gsub(char(i),("%s[%s]\27[0m"):format(color,v))
	end
	return str
end

-- base function
local function runLog(levelName,levelNumber,color,debugInfo,...)
	if log.disable then -- If log is disabled, return this
		return;
	elseif levelNumber < log.minLevel then -- If it not enough to display, return this
		return;
	end

	local msg = tostring(...); -- msg

	-- Get file name and line number
	local src = debugInfo.short_src;
	if src:sub(1,rootLen) == root then -- remove root prefix
		src = src:sub(rootLen+2,-1);
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
	local header = ("%s[%-6s%s]%s %s%s"):format(
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
	local headerLen = #(header:gsub("\27%[%d+m","")); -- Make 6*x len char
	local liner = headerLen%6;
	if liner ~= 0 then
		local adding = 6 - liner;
		headerLen = headerLen + adding;
		header = header .. (" "):rep(adding);
	end
	headerLen = headerLen + 3;
	header = header .. " │ ";

	-- formatting msg
	local fmsg = processMessage(msg,usecolor):gsub("\n","\n" .. (" "):rep(headerLen-2) .. "│ ");

	-- print / build prompt
	local buildPrompt = log.buildPrompt or _G.buildPrompt; ---@diagnostic disable-line
	local str = buildPrompt and {"\27[2K\r\27[0m",header,fmsg,"\n",buildPrompt()} or {"\27[2K\r\27[0m",header,fmsg,"\n"};
	prettyPrint.stdout:write(str);

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

--#endregion : Processing
--#region : Setup Modes

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

--#endregion
--#region : Typing

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

--#endregion

return log;
