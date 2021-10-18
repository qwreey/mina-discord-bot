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
local function registeLeaderstatus(userId,this)
	insert(loveLeaderstatus,{
		name = this.latestName;
		love = this.love;
		when = posixTime.now();
		userId = tostring(userId);
	});
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
