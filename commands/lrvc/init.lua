
--if not _G.app.args["event"] then
--    return {};
--end
--logger.info("학교 부스 축제용 코드 적용됨!");

local channelId = "918679407382642711";

---@class guessGameItem
---@field name string name of what user should say
---@field hints table a array of hint string that user can use it for guessing this
---@field question string the first hint of string name
local db = json.decode(fs.readFileSync("commands/lrvc/db.json") or fs.readFileSync("data/event/lrvc.json"));
if not db then
    return db;
end
local lenDb = #db;
local lastSelected = 0;
local guessGameHook;

local giveup = {
    ["포기"] = true;
};
local hint = {
    ["힌트"] = true;
}

local function checkAns(ans,text)
    return ans:lower():gsub(" ","") == text:lower():gsub(" ","");
end

-- 포기하려면 '포기' 를 입력해 주세요!
-- 모르겠다면 '힌트' 를 입력해 보세요!
-- 정답! 정확히 맞췄어요!
-- > 사용 힌트 수 : %d

local hook = _G.hook;
---@type table<string, Command>
local export = {
    ["추리게임"] = {
        alias = {"부스게임","추리 게임","부스 게임","부스"};
        disableDm = "이 명령어는 개인 DM 에서 사용 할 수 없습니다";
        reply = "잠시만 기다려 주세요!";
        func = function(replyMsg,message,args,Content)
            if guessGameHook then
                return replyMsg:setContent("이미 게임이 진행중입니다!");
            elseif channelId ~= tostring(Content.channel.id) then
                return replyMsg:setContent("이 명령어는 이벤트 체널에서만 이용 가능합니다!");
            end

            local index = cRandom(1,lenDb,{lastSelected});
            lastSelected = index;
            local selected = db[index];

            local ans = selected.name;
            local typeAns = type(ans);
            local hints = selected.hints;
            local hintsLen = #hints
            local lenHints = #hints;
            local question = selected.question or (hints[cRandom(1,lenHints)]);
            local trailing = selected.trailing or "";

            ---@type hook
            guessGameHook = hook.new{
                type = hook.types.before;
            };

            local hintCount = 0;
            local tryCount = 0;

            ---@param self hook
            ---@param content hookContent
            function guessGameHook:func(content)
                if tostring(content.channel.id) ~= channelId then
                    return;
                end
                local this = content.message;
                local text = content.text;
                if giveup[text] then -- 포기
                    self:detach();
                    this:reply{
                        content = "포기하였습니다!";
                        embed = {
                            title = "정답은";
                            description = ("`%s`%s 이였습니다!"):format(
                                typeAns == "table" and typeAns[1] or typeAns,trailing
                            );
                        };
                        reference = {message = this, mention = true};
                    };
                elseif hint[text] then -- 힌트
                    if hintsLen > hintCount then
                        this:reply{
                            content = "사용 할 수 있는 모든 힌드를 다 사용했어요";
                            embed = {
                                title = "힌트";
                                description = "더이상 힌트가 없습니다";
                            };
                            reference = {message = this,mention = true};
                        };
                        return;
                    end
                    hintCount = hintCount + 1;
                    local pick = cRandom(1,lenHints,hintPicked);
                    insert(hintPicked,pick);
                    this:reply{
                        content = "힌트를 사용했습니다!";
                        embed = {
                            title = "힌트";
                            description = hints[pick];
                        };
                        reference = {message = this,mention = true};
                    };
                else -- 정답확인
                    local isAns;
                    if typeAns == "table" then
                        for _, v in ipairs(ans) do
                            isAns = checkAns(v,text);
                            if isAns then
                                break;
                            end
                        end
                    else
                        isAns = checkAns(ans,text);
                    end
                    tryCount = tryCount + 1;
                    if isAns then
                        this:reply{
                            content = "정답!";
                            embed = {
                                title = "정답을 맞췄어요!";
                                description = (
                                    hintCount == 0
                                    and "힌트를 하나도 사용하지 않았어요\n"
                                    or ("힌트를 %d 개 사용했어요\n"):format(hintCount)
                                ) .. (
                                    tryCount == 1
                                    and "한번만에 맞췄어요"
                                    or ("%d 번 시도해서 맞췄어요"):format(tryCount)
                                );
                            };
                            reference = {message = this,mention = true};
                        };
                        self:detach();
                    else
                        this:reply{
                            content = "땡! 틀렸어요";
                            embed = {
                                title = "틀렸어요";
                                description = ("%d 번째 시도에요"):format(tryCount);
                            };
                        };
                    end
                end
                return true;
            end

            guessGameHook:attach();
            replyMsg:update{
                content = "정답을 맞춰보세요!";
                reference = {message = message,mention = true};
                embed = {
                    title = "맞춰보세요!";
                    description = question;
                };
            };
        end;
    };
};

return export;
