!!!exe
for _,userId in ipairs{
  "695844821427814400"
} do
    local indexs = {}
    local learn = require "commands.learning.learn"
    local userData = loadUserData(userId).learned
    if userData then
        logger.infof("user %s's data was found, checking validity...", userId)
        for index,idx in ipairs(userData) do
            if not learn.rawGet(idx) then
                table.insert(indexs,index)
                logger.infof("Found unloadable learn index %d '%s'",index,idx)
            end
        end
        for indexNumber,index in ipairs(indexs) do
            table.remove(userData,index - indexNumber + 1)
        end
        saveUserData(userId)
    end
end
