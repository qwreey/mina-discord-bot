local module = {};

-- 서버 데이터 캐싱
local serverDatas = {};
module.serverDatas = serverDatas;

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
	local passed,errorMsg = fs.writeFileSync(formatFileRoot(serverId),raw);

	-- 오류 처리 (백업 시키기)
	if not passed then
		logger.errorf("An error occur on save data!\nerror message : %s\nfile : %s\ndata : %s",tostring(errorMsg),serverId,raw);
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
	fs.unlink(formatFileRoot(serverId));
end

return module;
