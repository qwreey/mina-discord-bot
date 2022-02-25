local strSub = string.sub;
local tableInsert = table.insert;
local module = {};

function module.split(str)
	local tmp = "";
	local spt = {};

	local quote = false;
	local squote = false;
	local escape = false;

	local function push()
		if tmp == "" then
			return;
		end
		table.insert(spt,tmp .. (escape and "\\" or ""));
		tmp = "";
		escape = false;
	end

	for part in string.gmatch(str,".") do
		if (not squote) and part == "\"" and (not escape) then
			quote = not quote;
			push();
		elseif (not quote) and part == "\'" and (not escape) then
			squote = not squote;
			push();
		elseif part == "\32" and (not quote) and (not squote) then
			push();
		else
			tmp = tmp .. ((escape and part == "\\") and "\\" or part);
		end
		escape = false;
		if part == "\\" then
			escape = true;
		end
	end

	if tmp ~= "" then
		table.insert(spt,tmp);
	end

	return spt;
end

function module.decode(split,optionArgs)
	optionArgs = optionArgs or {};
	local option = {};
	local args = {};

	local lastOpt;

	for i,this in ipairs(split) do
		if i >= 1 then
			if strSub(this,1,1) == "-" then -- this = option
				option[this] = true;
				if optionArgs[this] then
					lastOpt = this;
				else lastOpt = nil;
				end
			elseif lastOpt then -- set option
				option[lastOpt] = this;
				lastOpt = nil;
			else
				tableInsert(args,this);
			end
		end
	end

	return args,option;
end

return module;
