local insert = table.insert;
local sort = table.sort;
local remove = table.remove;
local loveLeaderstatusMaxUsers = _G.loveLeaderstatusMaxUsers;

local loveLeaderstatus = _G.loveLeaderstatus;
local loveLeaderstatusPath = _G.loveLeaderstatusPath;
local function sortingLeaderstatus(a,b)
	return a.love > b.love;
end
local function setStatus(table,userId,this)
	table.name = this.latestName;
	table.love = this.love;
	table.when = posixTime.now();
	table.userId = userId;
	return table;
end
-- registe user's love in to leaderstatus
---Save user love into leaderstatus
---@param userId Snowflake userData the table that inclued the user's data
---@param this table userData the table that inclued the user's data
---@return table | nil user what is poped user, when just updated it selfs, it will nil value
local function registeLeaderstatus(userId,this)
	userId = tostring(userId);

	-- check he/she is already on leaderstatus and then if exist, just update that
	-- 이미 순위에 있으면, 호감도와 시간만 업데이트함
	for _,status in ipairs(loveLeaderstatus) do
		if status.userId == userId then
			setStatus(status,userId,this);
			sort(loveLeaderstatus,sortingLeaderstatus);
			data.save(loveLeaderstatusPath,loveLeaderstatus);
			return;
		end
	end

	local lenLoveLeaderstatus = #loveLeaderstatus
	if (loveLeaderstatus[lenLoveLeaderstatus].love > this.love)
	and loveLeaderstatusMaxUsers <= lenLoveLeaderstatus then
		return;
	end

	-- couldn't find user on leaderstatus, just push user on leaderstatus
	-- and resort and pop the last thing and then return what is poped
	insert(loveLeaderstatus,setStatus({},userId,this));
	sort(loveLeaderstatus,sortingLeaderstatus);
	local lastRemoved,removed;
	while #loveLeaderstatus > loveLeaderstatusMaxUsers do -- remove other . . .
		removed = remove(loveLeaderstatus);
		if not lastRemoved then
			lastRemoved = removed;
		end
	end
	data.save(loveLeaderstatusPath,loveLeaderstatus);
	return lastRemoved;
end
_G.registeLeaderstatus = registeLeaderstatus;
return registeLeaderstatus;
