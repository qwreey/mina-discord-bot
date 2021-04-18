local module = {};

-- 유저 데이터 캐싱
local userDatas = {};
module.userDatas = userDatas;

-- 열린 파일들 (빠른 색인을 위해서 사용됨)
local files = {};
module.files = files;

-- get json module from main module
local json;
function module:setJson(newJson)
    json = newJson;
end

-- get logger module from main module
local iLogger;
function module:setILogger(newILogger)
    iLogger = newILogger;
end

local function openFile(userId)
    local userId = tostring(userId);
    if userId == "" then
        iLogger.error("userId '' is not not available!");
    end

end

function module:getValue(userId,valueName)
    
end

function module:setValue(userId,valueName,value)
    userId = tostring(userId);
    local userData = userDatas[userId]
    if not userData then
        userData = self:loadData(userId);
    end


end

function module:saveData(userId)
    userId = tostring(userId);
    local file = files[userId];
    local userData = userDatas[userId];

    if (not file) or (not userData) then
        iLogger.warn("something want wrong... (load user data first and save data!)");
        iLogger.errorf("un error occur on save user data (file or userData was not found), UserId : %s",tostring(userId));
        return;
    end

    local raw = json.encode(userData);
    file:write(raw);
    file:close();
    files[userId] = io.open("data/userData/" .. userId,"r+");
end

function module:loadData(userId)
    userId = tostring(userId);
    local file = io.open("data/userData/" .. userId,"r+");
    local raw = file:read("a");
    local data = json.decode(raw);
    files[userId] = file;
    userDatas[userId] = data;
    return data;
end

function module:resetData()

end

return module;