local game = {};
local insert = table.insert;

local cRandom = _G.cRandom or require("libs.cRandom");

---@type table<string, boolean> stop commands
local stopCommand = {
    ["멈춰"] = true;
    ["끄기"] = true;
    ["그만"] = true;
    ["stop"] = true;
	["멈춰지뢰찾기"] = true;
	["지뢰찾기멈춰"] = true;
	["그만지뢰찾기"] = true;
	["지뢰찾기그만"] = true;
	["끄기지뢰찾기"] = true;
	["지뢰찾기끄기"] = true;
	["미나멈춰지뢰찾기"] = true;
	["미나지뢰찾기멈춰"] = true;
	["미나그만지뢰찾기"] = true;
	["미나지뢰찾기그만"] = true;
	["미나끄기지뢰찾기"] = true;
	["미나지뢰찾기끄기"] = true;
};

-- local function ifind(table,value)
--     for i,v in ipairs(table) do
--         if v == value then
--             return i;
--         end
--     end
-- end

local defaultGameSize = 12;
local defaultGameMinesweepers = 42;
---Make new game table (status objects)
---@param size number Size of X and Y
---@param minesweepers number amount of minesweepers
---@return table game
local function initGame(size,minesweepers)
    local new = {};

    -- init arrays
    for _y = 1,size do
        local yThis = {};
        for x = 1,size do
            yThis[x] = 0;
        end
        insert(new,yThis);
    end

    -- init minesweepers
    local pickedY = {};
    local fullY = {};
    local pickedCount = 0;
    while true do
        local y = cRandom(1,size,fullY);

        local thisY = pickedY[y]; -- this y picked status
        if not thisY then
            thisY = {};
            pickedY[y] = thisY;
        end

        local x = cRandom(1,size,thisY);
        insert(thisY,x);

        if #thisY == size then -- it fully filled
            insert(fullY,y);
        end
        new[y][x] = true;

        pickedCount = pickedCount + 1;
        if pickedCount >= minesweepers then
            break;
        end
    end

    -- init numbers
    for y,itemsY in ipairs(new) do
        for x,xValue in ipairs(itemsY) do
            if xValue == true then
                for indexY = y-1,y+1 do
                    local edit = new[indexY];
                    if edit then
                        local left = edit[x-1];
                        local middle = edit[x];
                        local right = edit[x+1];

                        if type(left) == "number" then
                            edit[x-1] = left + 1;
                        end
                        if type(middle) == "number" then
                            edit[x] = middle + 1;
                        end
                        if type(right) == "number" then
                            edit[x+1] = right + 1;
                        end
                    end
                end
            end
        end
    end

    local clicked = {};
    for _y = 1,size do
        local yThis = {};
        insert(clicked,yThis);
    end

    local flagged = {};
    for _y = 1,size do
        local yThis = {};
        insert(flagged,yThis);
    end

    return new,clicked,flagged;
end
game.initGame = initGame;

local function draw(gameInstance,clicked,flagged)
    flagged = flagged or {};
    local str = "```\n";
    for y,clickedTable in ipairs(clicked or gameInstance) do
        for x,xClicked in ipairs(clickedTable) do
            local flaggedY = flagged[y];
            local isFlagged = flaggedY and flagged[x];
            local this = gameInstance[y][x];

            str = str .. ((isFlagged and "✅") or
                (xClicked and (
                    (this == true and "💥") or
                    (this == 0 and "0️⃣") or
                    (this == 1 and "1️⃣") or
                    (this == 2 and "2️⃣") or
                    (this == 3 and "3️⃣") or
                    (this == 4 and "4️⃣") or
                    (this == 5 and "5️⃣") or
                    (this == 6 and "6️⃣") or
                    (this == 7 and "7️⃣") or
                    (this == 8 and "8️⃣")
                )
            ) or "*️⃣");

        end
        str = str .. "\n";
    end
    str = str .. "```";
    return str;
end
game.draw = draw;

---Make new game instance
---@param channel TextChannel | PrivateChannel | GuildTextChannel | GuildChannel channel of stated this game
function game.new(channel)
    local newHook = hook.new {
        hookType = hook.types.before;
    };

    local gameStatus = initGame(defaultGameSize,defaultGameMinesweepers);

    local channelId = channel:__hash();
    newHook.func = function (self,contents)
        local hookChannel = contents.channel;
        local text = contents.text;
        if hookChannel:__hash() == channelId then
            if stopCommand[text:gsub(" ","")] then
                pcall(self.destroy,self);
                return true;
            end

            return true; --precessed
        end
    end;
    newHook.destroy = function (self)
        pcall(self.detach,self);
        gameStatus = nil;
        newHook = nil;
    end;
end

return game;
