local game = {};
local insert = table.insert;

local cRandom = _G.cRandom or require("libs.cRandom"); ---@diagnostic disable-line

---@type table<string, boolean> stop commands
local stopCommand = {
    ["끝"] = true;
    ["미나끝"] = true;
    ["멈춰"] = true;
    ["미나멈춰"] = true;
    ["끄기"] = true;
    ["미나끄기"] = true;
    ["그만"] = true;
    ["미나그만"] = true;
    ["stop"] = true;
    ["미나stop"] = true;
    ["minastop"] = true;
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

local numIcon = {
    [0] = "0️⃣​";
    "1️⃣​","2️⃣​","3️⃣​","4️⃣​","5️⃣​","6️⃣​","7️⃣​","8️⃣​","9️⃣​",
    "🇦​","🇧​","🇨​","🇩​","🇪​","🇫​","🇬​","🇭​","🇮​","🇯​","🇰​","🇱​","🇳​",
    "🇲​","🇴​","🇵​","🇶​","🇷​","🇸​","🇹​","🇺​","🇻​","🇼​","🇽​","🇾​","🇿​"
};
local num = {
    ["1"] = 1;
    ["2"] = 2;
    ["3"] = 3;
    ["4"] = 4;
    ["5"] = 5;
    ["6"] = 6;
    ["7"] = 7;
    ["8"] = 8;
    ["9"] = 9;
    ["0"] = 0;
    ["a"] = 10;
    ["b"] = 11;
    ["c"] = 12;
    ["d"] = 13;
    ["e"] = 14;
    ["f"] = 15;
    ["g"] = 16;
    ["h"] = 17;
    ["i"] = 18;
    ["j"] = 19;
    ["k"] = 20;
    ["l"] = 21;
    ["m"] = 22;
    ["n"] = 23;
    ["o"] = 24;
    ["p"] = 25;
    ["q"] = 26;
    ["r"] = 27;
    ["s"] = 28;
    ["t"] = 29;
    ["u"] = 30;
    ["v"] = 31;
    ["w"] = 32;
    ["x"] = 33;
    ["y"] = 34;
    ["z"] = 35;
};
local none = "⬛​";

local defaultGameSize = 12;
local defaultGameMinesweepers = 18;
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
        for x = 1,size do
            yThis[x] = false;
        end
        insert(clicked,yThis);
    end

    local flagged = {};
    for _y = 1,size do
        local yThis = {};
        for x = 1,size do
            yThis[x] = false;
        end
        insert(flagged,yThis);
    end
    new.size = size;

    return new,clicked,flagged;
end
game.initGame = initGame;

local function draw(gameInstance,clicked,flagged)
    logger.info("[Minesweeper] Drawing object ...");
    flagged = flagged or {};
    local str = "현재 상태```\n" .. none:rep(2);
    -- local str = "```\n";
    local size = gameInstance.size;
    for i = 1,size do
        str = str .. numIcon[i];
    end
    str = str .. "\n" .. none:rep(size + 2) .. " \n";
    for y,clickedTable in ipairs(clicked or gameInstance) do
        str = str .. numIcon[y] .. none;
        for x,xClicked in ipairs(clickedTable) do
            local flaggedY = flagged[y];
            local isFlagged = flaggedY and flaggedY[x];
            local this = gameInstance[y][x];

            str = str .. ((isFlagged and "✅​") or
                (xClicked and (
                    (this == true and "💥​") or
                    (this == 0 and block) or
                    (this == 1 and "1️⃣​") or
                    (this == 2 and "2️⃣​") or
                    (this == 3 and "3️⃣​") or
                    (this == 4 and "4️⃣​") or
                    (this == 5 and "5️⃣​") or
                    (this == 6 and "6️⃣​") or
                    (this == 7 and "7️⃣​") or
                    (this == 8 and "8️⃣​")
                )
            ) or "🔲​");
        end
        str = str .. " \n";
    end
    -- str = str .. "```";
    logger.info("[Minesweeper] End to draw object! ...");
    return str .. "```";
end
game.draw = draw;

local function click(gameInstance,clicked,flagged,x,y)
    local point = gameInstance[y][x];
    if not point then
        return ("%s,%s 는 존재하지 않는 위치입니다!"):format(tostring(x),tostring(y));
    end
    flagged[y][x] = false;
    clicked[y][x] = true;

    if point ~= 0 then
        return point;
    end

    for indexY = y-1,y+1,2 do
        local thisY = gameInstance[indexY];
        for indexX = x-1,x+1 do
            local this = thisY[indexX];
            if this and (this ~= true) then
                click(gameInstance,clicked,flagged,indexX,indexY);
            end
        end
    end
    for indexX = x-1,x+1,2 do
        local this = gameInstance[y][indexX];
        if this and (this ~= true) then
            click(gameInstance,clicked,flagged,indexX,y);
        end
    end
end

local function flag(gameInstance,clicked,flagged)

end

local embed = {
    title = "지뢰찾기!";
    description = "게임은 다음과 같이 진행 할 수 있습니다!";
    footer = {
        text = "지뢰찾기를 그만두려면 '지뢰찾기 멈춰' 를 입력하세요!";
    };
    fields = {
        {
            name = "칸 열기";
            value = "```c(세로 좌표)(가로 좌표)```\n> 예시 : c12";
            inline = true;
        };
        {
            name = "깃발 놓기";
            value = "```f(세로 좌표)(가로 좌표)```\n> 예시 : f23";
            inline = true;
        };
    };
};
local endingEmbed = {
    title = "게임이 끝났어요!";
    description = "지뢰를 건들였어요";
};

local channelGames = {};
local userGames = {};
---Make new game instance
---@param replyMsg Message message that bot replyed
---@param message Message message of stated this game
---@param channel TextChannel | PrivateChannel | GuildTextChannel | GuildChannel channel of stated this game
function game.new(replyMsg,message,channel)
    local channelId = channel:__hash();
    if channelGames[channelId] then
        replyMsg:update("이미 이 채널에는 진행중인 게임이 있습니다!");
        return;
    end

    local newHook = hook.new {
        type = hook.types.before;
    };

    local gameInstance,clicked,flagged = initGame(defaultGameSize,defaultGameMinesweepers);
    local lastMessage = replyMsg;
    replyMsg:update({
        content = game.draw(gameInstance,clicked,flagged);
        embed = embed;
        reference = {message = message, mention = false};
    });

    newHook.func = function (self,contents)
        local newMessage = contents.message;
        local hookChannel = contents.channel;
        local text = contents.text;
        if hookChannel:__hash() == channelId then
            if stopCommand[text:gsub(" ","")] then
                pcall(self.destroy,self);
                channel:send({
                    content = "성공적으로 게임을 종료했습니다!";
                    reference = {message = message, mention = false};
                });
                return true;
            else
                local y = num[text:sub(2,2):lower()];
                local x = num[text:sub(3,3):lower()];
                if x and y then
                    logger.infof("[Minesweeper] clicked %d,%d on channel %s",y,x,channelId);
                    if text:sub(1,1) == "c" then
                        local object = click(gameInstance,clicked,flagged,x,y);
                        if object == true then -- ended
                            coroutine.wrap(function()
                                lastMessage:update({
                                    content = game.draw(gameInstance);
                                    reference = {message = message, mention = false};
                                    embed = endingEmbed;
                                });
                                newMessage:delete();
                                self:destroy();
                            end)();
                            return true;
                        end
                        logger.infof("[Minesweeper] making new message on %s",channelId);
                        coroutine.wrap(function()
                            lastMessage:update({
                                content = game.draw(gameInstance,clicked,flagged);
                                reference = {message = message, mention = false};
                                embed = embed;
                            });
                            newMessage:delete();
                        end)();
                        logger.infof("[Minesweeper] delete user message on %s",channelId);
                        return true; --precessed
                    end
                end
            end

        end
    end;
    newHook.destroy = function (self)
        pcall(self.detach,self);
        gameInstance = nil;
        clicked = nil;
        flagged = nil;
        newHook = nil;
        lastMessage = nil;
        channelGames[channelId] = nil;
    end;
    newHook:attach();
end

return game;
