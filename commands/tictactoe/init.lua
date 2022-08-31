local discordia_enchant = _G.discordia_enchant
local components,enums = discordia_enchant.components,discordia_enchant.enums
local function fileFormatter(msgId)
    return ("tictactoe_%s"):format(tostring(msgId));
end
local insert = table.insert;
local function checkWins(blocks)
    for plr = 1,2 do
        for i=1,3 do
            if  blocks[i][1] == plr and
                blocks[i][2] == plr and
                blocks[i][3] == plr then
                return plr,{{i,1},{i,2},{i,3}};
            end
        end
        for i=1,3 do
            if  blocks[1][i] == plr and
                blocks[2][i] == plr and
                blocks[3][i] == plr then
                return plr,{{1,i},{2,i},{3,i}};
            end
        end
        if  blocks[1][1] == plr and
            blocks[2][2] == plr and
            blocks[3][3] == plr then
            return plr,{{1,1},{2,2},{3,3}};
        end
        if  blocks[1][3] == plr and
            blocks[2][2] == plr and
            blocks[3][1] == plr then
            return plr,{{1,3},{2,2},{3,1}};
        end
    end
    return false,nil;
end
local function buildMessage(id,data)
    if data.removed then
        return {
            content = zwsp;
            embed = {
                color = embedColors.error;
                title = ":x: 티택토 게임이 취소되었어요";
                description = ("게임을 생성한 유저 : <@%s>"):format(data.startedUser);
            };
            components = {};
        };
    end

    local blocks = data.blocks;
    local winPlayer,winLine = checkWins(blocks);
    local targetUser = data.targetUser;
    local startedUser = data.startedUser;
    local turn = data.turn;
    local isDraw = true;
    local msgComponents = {};

    if not winPlayer then
        for x = 1,3 do
            for y = 1,3 do
                if blocks[x][y] == 0 then
                    isDraw = false;
                    break;
                end
            end
            if not isDraw then break; end
        end
    end

    if targetUser then
        for x = 1,3 do
            local row = {};
            for y = 1,3 do
                local stat = blocks[x][y];
                local isWinline;
                if winLine then
                    for i = 1,3 do
                        local this = winLine[i];
                        if this[1] == x and this[2] == y then
                            isWinline = true;
                            break;
                        end
                    end
                end
                insert(row,components.button.new{
                    disabled = isDraw or (winPlayer and true) or stat ~= 0 or false;
                    label = (stat == 0 and "🟦") or
                            (stat == 1 and "⬜️") or
                            (stat == 2 and "⬛️") or nil;
                    custom_id = ("tictactoe_%s_%d_%d"):format(id,x,y);
                    style = (isDraw and enums.buttonStyle.secondary) or (isWinline and enums.buttonStyle.success) or enums.buttonStyle.primary;
                });
            end
            insert(msgComponents,components.actionRow.new(row));
        end
    else
        insert(msgComponents,components.actionRow.new{
            components.button.new{
                custom_id = ("tictactoe_join_%s"):format(id);
                style = enums.buttonStyle.primary;
                label = "참가하기";
                emoji = components.emoji.new"🚩";
            };
            components.button.new{
                custom_id = ("tictactoe_remove_%s_%s"):format(id,startedUser);
                style = enums.buttonStyle.danger;
                label = "취소";
                emoji = components.emoji.new"✖";
            };
        });
    end

    return {
        content = zwsp;
        embed = {
            color = winPlayer and embedColors.info or embedColors.success;
            title = ":game_die: 티택토!";
            description = ("👤 참여자: ⬜️<@%s>%s\n%s%s"):format(
                startedUser,
                targetUser and (" / ⬛️<@%s>"):format(targetUser) or "",
                (isDraw and "무승부!") or (
                    (winPlayer == 1 and ("<@%s> 승!"):format(startedUser)) or
                    (winPlayer == 2 and ("<@%s> 승!"):format(targetUser))
                ) or
                (targetUser and "🕑 게임이 진행중이에요" or "❕ 아무나 참여하세요!"),
                (targetUser and (not winPlayer) and turn) and (
                    (turn == 1 and ("\n⬜️<@%s> 의 턴"):format(startedUser)) or
                    (turn == 2 and ("\n⬛️<@%s> 의 턴"):format(targetUser))
                ) or ""
            );
        };
        components = msgComponents;
    };
end
local function makeGame(message,user)
    local gameData = {
        startedUser = user.id;
        blocks = {{0,0,0},{0,0,0},{0,0,0}};
    };
    local gameId = message.id
    interactionData:new(fileFormatter(gameId),gameData);
    message:update(buildMessage(gameId,gameData));
end

---@param id string
---@param object interaction
local function buttonPressed(id,object)
    do
        local gameId,remove = id:match("tictactoe_remove_(%d+)_(%d+)");
        if remove then
            if object.member.id ~= remove then
                return object:reply({
                    content = zwsp;
                    embed = {
                        color = embedColors.error;
                        title = ":x: 이 게임을 만든 사람만 취소할 수 있습니다";
                    };
                },true);
            end
            object:update(buildMessage(nil,{
                startedUser = remove;
                removed = true;
            }));
            interactionData:resetData(fileFormatter(gameId));
            return;
        end
    end

    do
        local join = id:match("tictactoe_join_(%d+)");
        if join then
            local file = fileFormatter(join);
            local data = interactionData.loadData(file);
            if not data then return end
            local interUser = object.member.id;
            if data.startedUser == interUser then
                return object:reply({
                    content = zwsp;
                    embed = {
                        title = ":x: 이미 참가했습니다";
                        color = embedColors.error;
                    };
                },true);
            end
            data.targetUser = interUser;
            data.turn = 1;
            interactionData.saveData(file,data);
            object:update(buildMessage(join,data));
            return;
        end
    end

    do
        local gameId,x,y = id:match("tictactoe_(%d+)_(%d)_(%d)");
        x,y = tonumber(x),tonumber(y);
        if x and y then
            local file = fileFormatter(gameId);
            local data = interactionData.loadData(file);
            if not data then return end
            local targetUser = data.targetUser;
            local startedUser = data.startedUser;
            local interUser = object.member.id;
            if interUser ~= targetUser and interUser ~= startedUser then
                return object:reply({
                    content = zwsp;
                    embed = {
                        title = ":x: 당신은 이 게임의 참가자가 아닙니다";
                        color = embedColors.warn;
                    }
                },true);
            end
            local turn = data.turn;
            if  (turn == 1 and interUser == targetUser) or
                (turn == 2 and interUser == startedUser) then
                return object:reply({
                    content = zwsp;
                    embed = {
                        title = ":x: 당신의 턴이 아닙니다";
                        color = embedColors.warn;
                    }
                },true);
            end
            data.blocks[x][y] = turn;
            if turn == 1 then
                data.turn = 2;
            else data.turn = 1;
            end
            interactionData.saveData(file,data);
            return object:update(buildMessage(gameId,data));
        end
    end
end
client:onSync("buttonPressed",promise.async(buttonPressed));

---@type table<string,Command>
local export = {
    ["tictactoe"] = {
        disableDm = true;
        alias = {"티텍토","티택토"};
        reply = "⏳ 잠시만 기다려주세요!";
        ---@param Content commandContent
        func = function (replyMsg,message,args,Content)
            makeGame(replyMsg,Content.user);
        end;
        onSlash = commonSlashCommand {
            name = "티택토";
            noOption = true;
            description = "두명에서 티택토를 진행합니다!";
        };
    };
};
return export
