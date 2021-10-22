local insert = table.insert;
local sort = table.sort;
local remove = table.remove;

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
---@param this table userData the table that inclued the user's data
---@return table | nil user what is poped user, when just updated it selfs, it will nil value
local function registeLeaderstatus(userId,this)
    userId = tostring(userId);

    -- check he/she is already on leaderstatus and then if exist, just update that
    for _,status in ipairs(loveLeaderstatus) do
        if status.userId == userId then
            setStatus(status,userId,this);
            sort(loveLeaderstatus,sortingLeaderstatus);
            return;
        end
    end

    -- couldn't find user on leaderstatus, just push user on leaderstatus
    -- and resort and pop the last thing and then return what is poped
	insert(loveLeaderstatus,setStatus({},userId,this));
	sort(loveLeaderstatus,sortingLeaderstatus);
	data.save(loveLeaderstatusPath,loveLeaderstatus);
	return remove(loveLeaderstatus);
end
_G.registeLeaderstatus = registeLeaderstatus;
return registeLeaderstatus;
