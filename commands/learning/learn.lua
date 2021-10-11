local root = "data/userLearn/%s";
local indexedFile = "data/userLearn/index";
local indexedCache = json.decode(
	("{%s}"):format(fs.readFileSync(indexedFile):sub(1,-2))
);
local module = {};

local errorType = {
	tooLongValue = 1;
	tooLongName = 2;
	notEnoughLove = 3;
	nullValue = 4;
	nullName = 5;
	devDefined = 6;
	linkDetected = 7;
};
module.errorType = errorType;

--- get react
function module.get(name)
	local hash = sha1(name);
	local id = indexedCache[hash];
	if not id then
		return;
	end

	local path = root:format(id);
	local maxIndex = tonumber((fs.readFileSync(path .. "/index") or ""):match("%d+"));

	if not maxIndex then
		return;
	end

	local index = cRandom(1,maxIndex);
	local this = json.decode(fs.readFileSync(("%s/%d"):format(path,index)));

	return this;
end

local maxValueLength = 200;
local maxNameLength = 100;
local costLove = 20;
local utf8Len = utf8.len;
local insert = table.insert;
--- Add new react
function module.put(name,value,author,when,userData)
	if commandHandler.findCommandFrom(reacts,name) then
		return errorType.devDefined;
	end
	local love = userData.love;
    if (not name) or name == "" or name == " " or name == "\n" then
        return errorType.nullName;
    elseif (not value) or value == "" or value == " " or value == "\n" then
        return errorType.nullValue;
    elseif love < costLove then
		return errorType.notEnoughLove;
	elseif utf8Len(value) > maxValueLength then
		return errorType.tooLongValue;
	elseif utf8Len(name) > maxNameLength then
		return errorType.tooLongName;
	end
	name = name:lower();
	userData.love = love - costLove;
	if name:find("https://",1,true) or
	name:find("http://","1",true) or
	name:match(".-%.org") or
	name:match(".-%.com") or
	name:match(".-%.net") then
		return errorType.linkDetected;
	end

	-- setup database
	local hash = sha1(name);
	local id = indexedCache[hash];
	local path;
	local index;
	if not id then -- write new
		id = makeId(); -- make new identifier
		indexedCache[hash] = id;
		fs.appendFileSync(indexedFile,('"%s":"%s",\n'):format(hash,id));
		path = root:format(id);
		fs.mkdirSync(path);
		fs.writeFile(path .. "/name",name);
		fs.writeFile(path .. "/index","1");
		index = 1;
	else
		path = root:format(id);
		index = tonumber(fs.readFileSync(path .. "/index"):match("%d+"));
		index = index + 1;
		fs.writeFileSync(path .. "/index",tostring(index));
	end

	-- save to file
	fs.writeFileSync(("%s/%d"):format(path,index),json.encode({
		author = tostring(author);
		when = tonumber(when);
		content = value;
	}));

	-- save into user data
	local learned = userData.learned;
	if not learned then
		learned = {};
		userData.learned = learned;
		userData.lenLearned = 0;
	end
	insert(learned,{
		("%s/%d"):format(hash,index)
	});
	userData.lenLearned = userData.lenLearned + 1;
end

return module;