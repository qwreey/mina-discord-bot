--
-- FORKED FROM rxi's log.lua
--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
-- MODIFYED BY qwreey75
--

--#region : Setup

-- Load env
local fs do
	local passed
	passed,fs = pcall(require,"fs")
	fs = passed and fs
end
local appendFile = fs and fs.appendFile
local prettyPrint do
	local passed
	passed,prettyPrint = pcall(require,"pretty-print")
	prettyPrint = passed and prettyPrint
end
local process = _G.process do
	if not process then
		local passed
		passed,process = pcall(require,"process")
		process = passed and process.globalProcess and (process.globalProcess())
	end
end
local jit = _G.jit do
	if not jit then
		local passed
		passed,jit = pcall(require,"jit")
		jit = passed and jit
	end
end
local stdout = prettyPrint and prettyPrint.stdout
local stdoutWrite = stdout and stdout.write
local dump = prettyPrint and prettyPrint.dump
local date = os.date
local insert = table.insert
local getinfo = debug.getinfo
local format = string.format
local upper = string.upper
local char = string.char
local gsub = string.gsub
local sub = string.sub
local rep = string.rep
local len = string.len
local iopen = io.open
local popen = io.popen
local iwrite = io.write
local tostring = tostring
local type = type
local pairs = pairs
local concat = table.concat

-- Read process args
local argParser = {};
function argParser.decode(split,optionArgs)
	optionArgs = optionArgs or {}
	local option = {}
	local args = {}

	local lastOpt

	for i,this in ipairs(split) do
		if i >= 1 then
			if this:sub(1,1) == "-" then -- this = option
				option[this] = true
				if optionArgs[this] then
					lastOpt = this
				else lastOpt = nil
				end
			elseif lastOpt then -- set option
				option[lastOpt] = this
				lastOpt = nil
			else
				insert(args,this)
			end
		end
	end

	return args,option
end
local options = _G.loggerOption
if not options then
	_,options = argParser.decode(_G.args or {},{ ---@diagnostic disable-line
		["--logger_prefix"] = true;
		["--logger_outfile"] = true;
		["--logger_minLevel"] = true;
		["--logger_color"] = true;
		["--logger_disabled"] = true;
		["--logger_outfile_dateformat"] = true;
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
	outfileDateFormat = options["--logger_outfile_dateformat"] or "%y %h %d %H:%M:%S"
}

-- get cwd
local root = process and process.cwd()
if not root then
	local cmd
	if jit then
		cmd = jit.os == "Windows" and "cd" or "pwd"
	else
		local checkOs = popen("where cmd.exe")
		local _,_,exitCode = checkOs:close()
		cmd = exitCode == 0 and "cd" or "pwd"
	end
	local new = popen(cmd or "cd")
	root = new:read("*l")
	new:close()
end
log.root = root
local rootLen = #root

--#endregion : Setup
--#region : Processing

-- ascii formatting
local ansiiFormat = "%s[%s]\27[0m"
local tab = char(9);
local ansii = {
	[char(1)]   = "SOH";
	[char(2)]   = "STX";
	[char(3)]   = "ETX";
	[char(4)]   = "EOT";
	[char(5)]   = "ENQ";
	[char(7)]   = "BEL";
	[char(8)]   = "BS";
	-- [char(9)]   = "TAB"; -- tab character
	[char(11)]  = "VT"; -- vertical tab character
	[char(12)]  = "FF"; -- form feed character
	[char(14)]  = "SO";
	[char(15)]  = "SI";
	[char(16)]  = "DEL";
	[char(17)]  = "DC1";
	[char(18)]  = "DC2";
	[char(19)]  = "DC3";
	[char(20)]  = "DC4";
	[char(21)]  = "NAK";
	[char(22)]  = "SYN";
	[char(23)]  = "ETB";
	[char(24)]  = "CAN";
	[char(25)]  = "EM";
	[char(26)]  = "SUB";
	-- [char(27)]  = "ESC";
	[char(28)]  = "FS";
	[char(29)]  = "GS";
	[char(30)]  = "RS";
	[char(31)]  = "US";
	[char(127)] = "DEL";
}
-- local esc = "(" .. char(27).."(%[?))"
local tabChar = " → │"
local tabCharColor = "\27[90m" .. tabChar .. "\27[0m"
local spcColor = "\27[30;45m" -- 4 (underline)
local function processMessage(str,useColor)
	local color = useColor and spcColor or ""
	for i,v in pairs(ansii) do
		str = gsub(str,i,format(ansiiFormat,color,v))
	end
	str = gsub(str,tab,useColor and tabCharColor or tabChar)
	-- for colors end ansi terminal escapes
	-- str = gsub(str,esc,function (all,isEscape)
	-- 	return (isEscape == "") and format(ansiiFormat,color,"ESC") or str
	-- end)
	return str
end

-- base function
local function base(levelName,levelNumber,color,debugInfo,object)
	-- check / load settings
	if log.disable then return -- If log is disabled, return this
	elseif levelNumber < log.minLevel then return end -- If it not enough to display, return this
	local objectType = type(object)
	local msg = dump and (objectType == "string" and object or dump(object)) or tostring(object) -- stringify message
	local refreshLine = log.refreshLine;
	local buildPrompt = (not refreshLine) and (log.buildPrompt or _G.buildPrompt); ---@diagnostic disable-line
	local usecolor = log.usecolor
	local prefix = log.prefix
	local outfile = log.outfile

	-- Get file name and line number
	local lineinfo
	local replaceinfo = logger.noLineInfo
	if replaceinfo then
		lineinfo = type(replaceinfo) == "string" and replaceinfo or ""
	else
		local src = debugInfo.short_src
		if sub(src,1,rootLen) == root then -- remove root prefix
			src = sub(src,rootLen+2,-1)
		end
		src = gsub(gsub(gsub(gsub(src,
			"%.lua$",""),  -- remove .lua
			"^%./",""),    -- remove ./
			"[\\//]","."), -- change / and \ into .
			"%.init$",""   -- remove .init
		)
		-- src = (src
		-- 	:gsub("%.lua$","") -- remove .lua
		-- 	:gsub("^%.[/\\]","") -- remove ./
		-- 	:gsub("[\\//]",".") -- change \ and / into .
		-- 	:gsub("%.init$","") -- remove .init
		-- )
		lineinfo = format("%s:%s",src,tostring(debugInfo.currentline)) -- source:line
	end

	-- Make header
	local header = format("%s[%-6s%s]%s %s%s",
		usecolor and color or "",
		levelName, -- Level
		date("%H:%M"), -- add date
		usecolor and "\27[0m" or "", -- reset color
		prefix and format(replaceinfo and "%s(%s)%s" or "%s(%s)%s ",
			usecolor and "\27[93m" or "",
			tostring(prefix),
			usecolor and "\27[0m" or ""
		) or "", -- print perfix
		lineinfo -- line info
	)
	local headerLen = len(gsub(header,"\27%[%d+m","")) -- Make 6*x len char
	if not logger.noLiner then
		local liner = headerLen%6
		if liner ~= 0 then
			local adding = 6 - liner
			headerLen = headerLen + adding
			header = header .. rep(" ",adding)
		end
	end
	headerLen = headerLen + 3
	header = header .. " │ "

	-- formatting msg
	local fmsg = gsub(
		processMessage(msg,usecolor),"\n",
		format("\n%s│ ",rep(" ",headerLen-2))
	)

	-- print / build prompt
	local str = buildPrompt and {"\27[2K\r\27[0m",header,fmsg,"\n",buildPrompt()} or {"\27[2K\r\27[0m",header,fmsg,"\n"}

	-- write into stdout
	if stdoutWrite then
		-- use luvit's prettyPrint library
		stdoutWrite(stdout,str)
	else
		-- use lua standard library
		iwrite(concat(str))
	end

	-- refresh readline
	if refreshLine then
		refreshLine()
	end

	-- Append into file
	if outfile then
		local data = format("[%-6s%s] %s: %s\n",
			levelName, date(log.outfileDateFormat),
			lineinfo, dump and (objectType == "string" and object or dump(object,nil,true)) or object
		)
		if appendFile then
			-- use luvit's fs library
			appendFile(outfile,data)
		else
			-- use lua standard library
			local file = iopen(outfile, "a")
			file:write()
			file:close()
			file = nil
		end
	end

	return str
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
}
for level,v in pairs(modes) do
	local name = v.name
	local upName,color = upper(name),v.color
	v.level = level
	v.upName = upName

	log[name] = function (object)
		return base(upName,level,color,getinfo(2, "Sl"),object)
	end
	log[name .. "f"] = function (...)
		return base(upName,level,color,getinfo(2, "Sl"),format(...))
	end
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

log.cmd		= log.cmd    ---@type loggerPrint
log.cmdf	= log.cmdf   ---@type loggerFormat
log.exit	= log.exit   ---@type loggerPrint
log.exitf	= log.exitf  ---@type loggerFormat
log.setup	= log.setup  ---@type loggerPrint
log.setupf	= log.setupf ---@type loggerFormat
log.trace	= log.trace  ---@type loggerPrint
log.tracef	= log.tracef ---@type loggerFormat
log.debug	= log.debug  ---@type loggerPrint
log.debugf	= log.debugf ---@type loggerFormat
log.info	= log.info   ---@type loggerPrint
log.infof	= log.infof  ---@type loggerFormat
log.warn	= log.warn   ---@type loggerPrint
log.warnf	= log.warnf  ---@type loggerFormat
log.error	= log.error  ---@type loggerPrint
log.errorf	= log.errorf ---@type loggerFormat
log.fatal	= log.fatal  ---@type loggerPrint
log.fatalf	= log.fatalf ---@type loggerFormat

--#endregion

return log;
