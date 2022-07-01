local json = require("json");
local fs = require("fs");
local posixTime = require("libs.posixTime");
local insert = table.insert;
local remove = table.remove;
local sort = table.sort;
local loveLeaderstatus = json.decode(fs.readFileSync("data/loveLeaderstatus.json"));
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
	return remove(loveLeaderstatus);
end

for _,thing in ipairs(fs.readdirSync("data/userData")) do
	local path = ("data/userData/%s"):format(thing);
	local file = fs.readFileSync(path);
	local data = json.decode(file);
	registeLeaderstatus(thing:match("%d+"),data);
end

local data = json.encode(loveLeaderstatus);
fs.writeFileSync("test/loveLeaderstatus.json",data);

return;
