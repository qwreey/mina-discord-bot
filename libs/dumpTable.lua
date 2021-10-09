local module = {}

local baseTab = "  ";
local numberIndex = ('\n%%s%s[%%s] = %%s;'):format(baseTab);
local otherIndex = ('\n%%s%s["%%s"] = %%s;'):format(baseTab);
local normalIndex = ('\n%%s%s%%s = %%s;'):format(baseTab);
local normalString = "[%w_]+";

local function escape(this)
	return tostring(this):gsub("\"","\\\""):gsub("\n","\\n");
end
local function getBody(index,indexType)
	indexType = indexType or type(index);
	if indexType == "number" then
		return numberIndex;
	elseif indexType == "string" then
		if index:match(normalString) == index then
			return normalIndex;
		else
			return otherIndex;
		end
	end
	return otherIndex;
end
local function getValue(value,valueType)
	valueType = valueType or type(value);
	if valueType == "number" or
	valueType == "boolean" or
	valueType == "function" or
	valueType == "userdata" or
	valueType == "thread" then
		return tostring(value);
	elseif valueType == "table" then
		return value;
	else
		return ("\"%s\""):format(escape(value));
	end
end

function module.dump(this,deep,status)
	deep = deep or 0;
	status = status or {};
	status[tostring(this)] = true;
	local tab = string.rep(baseTab,deep);
	local strSpace = "{";

	for index,value in pairs(this) do
		local valueType = type(value);
		if valueType == "table" then
			local id = tostring(value);
			if status[id] then
				value = "\"#Recursive detected#\"";
			else
				value = module.dump(value,deep + 1,status);
			end
		end
		local indexType = type(index);

		strSpace = strSpace .. getBody(index,indexType):format(
			tab, -- tab
			escape(index), -- index
			getValue(value,valueType) -- value
		);
	end
	if strSpace == "{" then
		return "{}";
	end
	strSpace = strSpace .. "\n".. tab .."}";
	return strSpace;
end
function module.print(this)
	io.write(module.dump(this),"\n");
end
table.print = module.print;
table.dump = module.dump;

return module;