local module = {};

-- 서버 데이터 캐싱
local interactionData = {};
module.interactionData = interactionData;

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

local function formatFileRoot(interactionId)
	return ("data/interactionData/%s.json"):format(interactionId);
end

-- 데이터 저장하기 (로드를 먼저 해야 작동함)
function module:saveData(interactionId)
	if not interactionId then
		return;
	end

	interactionId = tostring(interactionId);

	-- interactionData 가져오기
	local interactionData = interactionData[interactionId];
	if not interactionData then
		logger.warn("something want wrong... (load interaction data first and save data!)");
		logger.errorf("An error occur on save interaction data (file or interactionData was not found), interactionId : %s",tostring(interactionId));
		return;
	end
	local raw = json.encode(interactionData);

	-- 파일 열고 쓰고 닫기
	local passed,errorMsg = fs.writeFileSync(formatFileRoot(interactionId),raw);

	-- 오류 처리 (백업 시키기)
	if not passed then
		logger.errorf("an error occur on save data!\nerror message : %s\nfile : %s\ndata : %s",tostring(errorMsg),interactionId,raw);
	end
end

-- 데이터 읽어들이기
function module:loadData(interactionId)
	if not interactionId then
		return;
	end

	interactionId = tostring(interactionId);
	local data = interactionData[interactionId];
	if data then -- 이미 데이터가 존재하면 반환
		return data;
	end

	-- 파일 열기
	local file = fs.readFileSync(formatFileRoot(interactionId));
	if not file then
		return; -- 파일이 없으면 리턴
	end

	data = json.decode(file); -- json 디코딩
	interactionData[interactionId] = data; -- 서버 데이터 풀에 던짐
	return data; -- 서버 데이터 리턴
end

-- 데이터 파일 지우고 데이터 초기화
-- this is should be replaced with fs module
function module:resetData(interactionId)
	userDatas[userId] = nil;
	fs.unlink(formatFileRoot(interactionId));
end

function module:new(interactionId,data)
	interactionData[interactionId] = data;
	return fs.writeFile(formatFileRoot(interactionId),json.encode(data));
end

return module;
