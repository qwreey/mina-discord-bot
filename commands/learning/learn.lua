local root = "data/userLearn/%s";
local indexedFile = "data/userLearn/index";
local indexedCache = json.decode(
	("{%s}"):format(fs.readFileSync(indexedFile))
);
local module = {};

local errorType = {
	unknown = 0;
	tooLongValue = 1;
	tooLongName = 2;
	notEnoughLove = 3;
	nullValue = 4;
	nullName = 5;
	devDefined = 6;
	linkDetected = 7;
	mentionDetected = 8;
	channelDetected = 9;
	alreadlyLearnByYou = 10;
	onCooltime = 11;
	noData = 12;
};
module.errorType = errorType;

---@class learnObject
---@field author Snowflake id of author on discord
---@field content string reply of this
---@field when number timestamp of when this is learned on posix time
----@field name string name of this learn if is exist

-- format
---make formatted string of learnObject
---@param userReact learnObject what you want to stringify
---@return string formatted formatted string of learnObject
function module.format(userReact)
	if not userReact then
		return "오류가 발생했어요!\n> 알 수 없는 유저 반응을 호출하려고 시도합니다\n```app.main : formatUserLearnReact(userReact) -> userReact == nil```";
	end

	local authorId = userReact.author;
	local when = userReact.when;
	local content = userReact.content;
	local author = authorId and userData:loadData(authorId);

	if (not author) or (not when) or (not content) then
		logger.errof("Error occurred on formatting learn data '%s' (id)\nObject was : %s",tostring(userReact),table.dump(userReact or {}));
		return "오류가 발생했어요!\n> 유저 반응이 잘못되었습니다\n```app.main : formatUserLearnReact(userReact) -> userReact has missing properties```";
	end

	return ("%s\n> '%s' 님이 가르쳐 주셨어요!"):format(content,author.latestName);
end

---get learnObject with name (not learnObject id)
---@param name string this is will be used as query
---@return learnObject|nil result searched object
function module.get(name)
	local hash = sha1(name);
	local id = indexedCache[hash];
	if not id then
		return;
	end

	local path = root:format(id);
	local maxIndex = tonumber((fs.readFileSync(path .. "/index") or ""):match("%d+"));
	local removed,passed; do
		local file = fs.readFileSync(path .. "/removed");
		if file then
			passed,removed = json.decode(("[%s]"):format(file));
			if (not passed) or (not removed) then
				logger.errorf("Error occurred on loading json data '%s/removed'\nError message was : %s",path,tostring(removed));
				return {};
			end
		end
	end

	if (not maxIndex) or (maxIndex == 0) or (removed and (#removed >= maxIndex)) then
		return;
	end

	local index = cRandom(1,maxIndex,removed);
	local this;
	passed,this = json.decode(fs.readFileSync(("%s/%d"):format(path,index)));

	if not passed then
		logger.errorf("Error occurred on loading json data '%s/%d'\nError messate was : %s",path,index,tostring(this));
		return {};
	end

	return this;
end

---get learnObject from id (pathed id)
---@param id string path of what you want to get
---@return learnObject|nil result result learnObject
---@return string|nil name name of this object
function module.rawGet(id)
	local data = fs.readFileSync(root:format(id));
	if not data then return end
	data = json.decode(data);
	if not data then return end

	local pathId = id:match("(.-)/");
	local path = root:format(pathId);
	local name = fs.readFileSync(path .. "/name");
	if not name then return end

	return data,name;
end

local maxValueLength = 200;
local maxNameLength = 100;
local costLove = 20;
local cooltime = 5;
local utf8Len = utf8.len;
local insert = table.insert;

---Make new learnObject and save
---@param name string name of this learnObject
---@param value string value of this learnObject
---@param author Snowflake id of author
---@param when number timestamp of when this object was created on posix time
---@param userData userDataObject author's user data object
---@return nil|number errorType description of error occurred, it is no error in execution, will return nil
function module.put(name,value,author,when,userData)
	if not userData then
		return errorType.noData;
	end
	local lastTime = userData.lastLearnTime;
	if lastTime and (lastTime + cooltime > when) then
		return errorType.onCooltime;
	elseif commandHandler.findCommandFrom(reacts,name) then
		return errorType.devDefined; -- if developers defined that
	elseif value:match("@everyone") or -- when user used mention
	value:match("@here") or
	value:match("<@!?[^ \\]+>") then
		return errorType.mentionDetected; -- user mention detected
	elseif value:match("<#[^ ]+>") then
		return errorType.channelDetected; -- channel mention detected
	end
	local love = userData.love; -- get user love from userData
	if (not name) or name == "" or name == " " or name == "\n" then
		return errorType.nullName; -- invalid name
	elseif (not value) or value == "" or value == " " or value == "\n" then
		return errorType.nullValue; -- invalid value
	elseif love < costLove then
		return errorType.notEnoughLove; -- if user's love didn't enough
	elseif utf8Len(value) > maxValueLength then
		return errorType.tooLongValue; -- if value is loner then max length
	elseif utf8Len(name) > maxNameLength then
		return errorType.tooLongName; -- if name is longer than max length
	end
	name = name:lower(); -- make name into lower cased
	userData.love = love - costLove; -- using love
	if value:find("https://",1,true) or -- when link detected
	value:find("http://","1",true) or
	value:match(".-%.org") or
	value:match(".-%.com") or
	value:match(".-%.net") then
		return errorType.linkDetected;
	end

	-- setup database
	local hash = sha1(name);
	local id = indexedCache[hash];
	local path;
	local index;
	local learned = userData.learned;
	if not learned then
		learned = {};
		userData.learned = learned;
		userData.lenLearned = 0;
	end
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
		-- check is exist already (learn by that user)
		local already;
		for _,this in pairs(learned) do -- 최적화 필요
			if this:sub(1,18) == id then
				local file = fs.readFileSync(root:format(this));
				if file then
					file = json.decode(file);
					if file and file.content == value then
						already = true;
						break;
					end
				end
			end
		end
		if already then
			return errorType.alreadlyLearnByYou;
		end

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
	userData.lastLearnTime = when;
	insert(learned,("%s/%d"):format(id,index));
	userData.lenLearned = userData.lenLearned + 1;
end

-- removing object
-- id = "ID/NUM"

---Remove learnObject
---@param id string path of what you want to remove
---@return boolean|nil isSuccess will return true if success
function module.remove(id)
	local this = root:format(id);
	if not fs.existsSync(this) then
		return;
	end

	local pathId,num = id:match("(.-)/(%d+)");
	local path = root:format(pathId);
	-- local indexPath = path .. "/index";

	-- adding sync?
	fs.appendFile(path .. "/removed",("%s,"):format(tostring(num)));
	fs.unlink(this);
	return true;
end

return module;
