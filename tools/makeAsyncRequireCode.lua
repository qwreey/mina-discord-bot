local function getNameAndPath(module)
	if type(module) == "table" then
		return module.name,module.path;
	end
	return module,module;
end

local insert,concat,fs,find,sub,gsub = table.insert,table.concat,require"fs",string.find,string.sub,string.gsub;

local function makeAsyncRequireCode(modules)
	local t,group,length = {"\t\t--THIS CODE WAS AUTO-GENERATED!\n\t\tdo\n"},modules.name,#modules;
	for _,module in ipairs(modules) do
		local name,path = getNameAndPath(module);
		insert(t,("\t\t\tlocal %s; ---@module \"%s\"\n"):format(name,path));
	end
	insert(t,("\t\t\tlocal %sWaitter = promise.waitter()\n"):format(group));
	for _,module in ipairs(modules) do
		local _,path = getNameAndPath(module);
		insert(t,("\t\t\t%sWaitter:add(asyncRequire(\"%s\"));\n"):format(group,path));
	end
	insert(t,"\t\t\t")
	for i,module in ipairs(modules) do
		local name,_ = getNameAndPath(module);
		insert(t,name);
		if i ~= length then
			insert(t,",");
		end
	end
	insert(t,(" = unpack(%sWaitter:await())\n\t\t\t"):format(group));
	for i,module in ipairs(modules) do
		local name,_ = getNameAndPath(module);
		insert(t,"_G.");
		insert(t,name);
		if i ~= length then
			insert(t,",");
		end
	end
	insert(t," = ");
	for i,module in ipairs(modules) do
		local name,_ = getNameAndPath(module);
		insert(t,name);
		if i ~= length then
			insert(t,",");
		end
	end
	insert(t,";\n\t\tend");
	return concat(t);
end

local function formatFile(file)
	local data = fs.readFileSync(file);
	local lastPos = 0;
	while true do
		local atStart,_ = find(data,"%-%-!!AUTOBUILD!!",lastPos);
		if not atStart then break; end
		local _,closeAtEnd = find(data,"%-%-!!/AUTOBUILD!!",lastPos);
		local _,headAtEnd = find(data,"%-%-!!HEAD!!",lastPos);
		local headCloseAtStart,_ = find(data,"%-%-!!/HEAD!!",lastPos);
		local _,blockAtEnd = find(data,"%-%-!!BLOCK!!",lastPos);
		local blockCloseAtStart,_ = find(data,"%-%-!!/BLOCK!!",lastPos);

		local head,err = loadstring("return "..
			gsub(
				gsub(
					sub(data,headAtEnd+1,headCloseAtStart-1),"%]%]",""
				),
				"%-%-%[%[",""
			)
		);
		if not head then error(err); end
		head = head();
		local block = makeAsyncRequireCode(head);
		local lastBlockLength = (blockCloseAtStart-1) - (blockAtEnd+1);
		local addedBlockLength = (#block - lastBlockLength);

		data = concat {
			sub(data,1,blockAtEnd);
			"\n"; block; "\n\t";
			sub(data,blockCloseAtStart,-1);
		};

		lastPos = closeAtEnd + 1 + addedBlockLength;
	end
	fs.writeFileSync(file,data);
end

return {makeAsyncRequireCode = makeAsyncRequireCode,formatFile = formatFile};
