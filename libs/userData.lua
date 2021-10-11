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

-- 데이터 저장하기 (로드를 먼저 해야 작동함)
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
	local isPass,err = pcall(function ()
		local file = io.open(formatFileRoot(userId),"w");
		file:write(raw);
		file:close();
	end)

	-- 오류 처리 (백업 시키기)
	if not isPass then
		logger.errorf("un error occur on save data! (%s) : data = %s",userId,raw);
		local now = os.date("*t");
		local errFile = io.open("data/crash/" .. ("er%s.uid%s.tm%dm%dd%dh%dm%ds"):format(
			makeId(),userId,now.month,now.day,now.hour,now.min,now.sec
		));
	end
end

-- 데이터 읽어들이기
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
	local file = io.open(formatFileRoot(userId),"r+");
	if not file then
		return; -- 파일이 없으면 (아에 약관 동의를 안했으면) 리턴
	end

	local raw = file:read("a"); -- 파일 읽기
	file:close(); -- 파일 닫기
	data = json.decode(raw); -- json 디코딩
	userDatas[userId] = data; -- 유저 데이터 풀에 던짐
	return data; -- 유저 데이터 리턴
end

-- 데이터 파일 지우고 데이터 초기화
-- this is should be replaced with fs module
function module:resetData(userId)
	userDatas[userId] = nil;
	return pcall(function ()
		os.remove(formatFileRoot(userId));
	end);
end

return module;