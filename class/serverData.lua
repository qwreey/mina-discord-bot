local module = {};

-- 서버 데이터 캐싱
local serverDatas = {};
module.serverDatas = serverDatas;

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

local function formatFileRoot(serverId)
	return ("data/serverData/%s.json"):format(serverId);
end

-- 데이터 저장하기 (로드를 먼저 해야 작동함)
function module:saveData(serverId)
	if not serverId then
		return;
	end

	serverId = tostring(serverId);

	-- serverData 가져오기
	local serverData = serverDatas[serverId];
	if not serverData then
		logger.warn("something want wrong... (load server data first and save data!)");
		logger.errorf("un error occur on save server data (file or serverData was not found), serverId : %s",tostring(serverId));
		return;
	end
	local raw = json.encode(serverData);

	-- 파일 열고 쓰고 닫기
	local passed = fs.writeFileSync(formatFileRoot(serverId),raw);

	-- 오류 처리 (백업 시키기)
	if not passed then
		logger.errorf("un error occur on save data! (%s) : data = %s",serverId,raw);
		local now = os.date("*t");
		local errFile = io.open("data/crash/" .. ("er%s.uid%s.tm%dm%dd%dh%dm%ds"):format(
			makeId(),serverId,now.month,now.day,now.hour,now.min,now.sec
		));
	end
end

-- 데이터 읽어들이기
function module:loadData(serverId)
	if not serverId then
		return;
	end

	serverId = tostring(serverId);
	local data = serverDatas[serverId];
	if data then -- 이미 데이터가 존재하면 반환
		return data;
	end

	-- 파일 열기
	local file = fs.readFileSync(formatFileRoot(serverId));
	if not file then
		return; -- 파일이 없으면 리턴
	end

	data = json.decode(file); -- json 디코딩
	serverDatas[serverId] = data; -- 서버 데이터 풀에 던짐
	return data; -- 서버 데이터 리턴
end

-- 데이터 파일 지우고 데이터 초기화
-- this is should be replaced with fs module
function module:resetData(serverId)
	serverDatas[serverId] = nil;
	return pcall(function ()
		os.remove(formatFileRoot(serverId));
	end);
end

return module;
