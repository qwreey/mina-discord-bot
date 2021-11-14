local module = {};

-- 유저 데이터 캐싱
local userDatas = {};
module.userDatas = userDatas;

-- JSON 가져오기
local json;
function module:setJson(newJson)
	json = newJson;
	return self;
end

-- 로거 가져오기
local logger;
function module:setlogger(newlogger)
	logger = newlogger;
	return self;
end

-- MakeId 를 가져오기
local makeId;
function module:setMakeId(newMakeId)
	makeId = newMakeId;
	return self;
end

local function formatFileRoot(userId)
	return ("data/userData/%s.json"):format(userId);
end

---inclueding user's data
---@class userDataObject
---@field public lastCommand table key/value pairs of command id and timestamp of when last this user used command
---@field public learned table | nil Array of user leanred reactions
---@field public lenLearned number | nil Length of learend table
---@field public love number User's love stats
---@field public lastLearnTime number | nil timestamp of when last this user used learning command
---@field public premiumStatus number | nil user's premium status, this is pointing end of premium's timestamp
---@field public lastName table Array of user's lastname *CACHED NAME ONLY*
---@field public latestName string User's lastest name *CACHED NAME ONLY*

---Save user data to userdata storage
---@param userId Snowflake pointing data what want to save
---@return nil
function module:saveData(userId)
	if not userId then
		return;
	end

	userId = tostring(userId);

	-- userData 가져오기
	local userData = userDatas[userId];
	if not userData then
		logger.warn("something want wrong... (load user data first and save data!)");
		logger.errorf("un error occur on save user data (file or userData was not found), UserId : %s",tostring(userId));
		return;
	end
	local raw = json.encode(userData);

	-- 파일 열고 쓰고 닫기
	local passed,errorMsg = fs.writeFileSync(formatFileRoot(userId),raw);

	-- 오류 처리 (백업 시키기)
	if not passed then
		logger.errorf("An error occur on save data!\nerror message : %s\nfile : %s\ndata : %s",tostring(errorMsg),userId,raw);
	end
end

---Get user data from userdata storage
---@param userId Snowflake pointing data what want to get
---@return userDataObject | nil userDataObject user's data
function module:loadData(userId)
	if not userId then
		return;
	end

	userId = tostring(userId);
	local data = userDatas[userId];
	if data then -- 이미 데이터가 존재하면 반환
		return data;
	end

	-- 파일 열기
	local file = fs.readFileSync(formatFileRoot(userId));
	if not file then
		return; -- 파일이 없으면 (아에 약관 동의를 안했으면) 리턴
	end

	data = json.decode(file); -- json 디코딩
	userDatas[userId] = data; -- 유저 데이터 풀에 던짐
	return data; -- 유저 데이터 리턴
end

-- remove data
function module:resetData(userId)
	userDatas[userId] = nil;
	fs.unlink(formatFileRoot(userId));
end

return module;
