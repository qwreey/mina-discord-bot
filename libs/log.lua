--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = {_version = "0.1.0"};
log.root = process.env.PWD;
if not log.root then
	log.root = io.popen("cd"):read("*l");
end
log.usecolor = true;
log.outfile = nil;
log.minLevel = 1;
log.disable = false;
local root = log.root;
local rootLen = #root;

-- 베이스 함수
local function runLog(thisName,thisLevel,color,debugInfo,...)
	local msg = tostring(...);

	if log.disable then
		return;
	end

	-- 최소 래밸에 도달하지 못한 경우 호출을 묵인
	if thisLevel < log.minLevel then
		return;
	end

	-- 파일명 : 라인 번호 를 가져옴
	local src = debugInfo.short_src;
	if string.sub(src,1,rootLen) == root then
		src = string.sub(src,rootLen+2,-1);
	end
	src = src:gsub("%.lua$",""):gsub("^%.[/\\]",""):gsub("[\\//]",".");
	local line = tostring(debugInfo.currentline);
	local lineinfo = src .. ":" .. line .. string.rep(" ",4-#line);

	-- 프린트
	local text = string.format("%s[%-6s%s]%s %s: %s ",
		log.usecolor and color or "",
		thisName,
		os.date("%H:%M"),
		log.usecolor and "\27[0m" or "",
		lineinfo,
		msg
	);
	--io.write(text .. "\n");
	local buildPrompt = _G.buildPrompt;
	local str = buildPrompt and {"\27[2K\r",text,"\n",buildPrompt()} or {text,"\n"};
	local prettyPrint = _G.prettyPrint;
	if prettyPrint then
		prettyPrint.stdout:write(str);
	else
		io.write(unpack(str));
	end

	-- 아웃풋 파일에 집어넣기
	if log.outfile then
		local fp = io.open(log.outfile, "a");
		local str = string.format("[%-6s%s] %s: %s\n",
			thisName, os.date(), lineinfo, msg
		);
		fp:write(str);
		fp:close();
	end

	return text;
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

log.cmd		= log.cmd;
log.cmdf	= log.cmdf;
log.exit	= log.exit;
log.exitf	= log.exitf;
log.setup	= log.setup;
log.setupf	= log.setupf;
log.trace	= log.trace;
log.tracef	= log.trace;
log.debug	= log.debug;
log.debugf	= log.debugf;
log.info	= log.info;
log.infof	= log.infof;
log.warn	= log.warn;
log.warnf	= log.warnf;
log.error	= log.error;
log.errorf	= log.errorf;
log.fatal	= log.fatal;
log.fatalf	= log.fatalf;

return log;