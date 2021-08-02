local module = {};

--local urlCode = require "src/lib/urlCode";

local function makeError(msg)
    return {
        title = ":/ 불러오기를 시도하던중 오류가 발생했습니다";
        description = "오류의 내용은 다음과 같습니다,\n" .. msg;
        color = 16711680;
        footer = {
            text = "외 안뎀...??";
        };
    };
end

-- check : https://embed.discord.website/
function module:embed(body)
    if not body then
        return makeError("사용자 정보를 확인할 수 없습니다 (BODY => NULL)");
    end
    local global = body.global;
    if not global then
        return makeError("사용자 정보를 확인할 수 없습니다 (BODY.global => NULL)");
    end

    local fields = {};

    local realtime = body.realtime;
    if realtime then
        -- 접속 상태
        table.insert(fields,{
            name = "상태";
            value = (realtime.isInGame == 1) and
                (((realtime.canJoin == 1) and "게임중 (참여 가능) %s 선택됨" or "게임중 %s 선택됨"):format(realtime.selectedLegend)) or
                (realtime.isOnline and "온라인" or "오프라인");
            inline = true;
        });
    end

    -- 랩
    local level = global.level;
    if level then
        table.insert(fields,{
            name = "레벨";
            value = tostring(global.level);
            inline = true;
        });
    end

    -- 랭크
    local rank = global.rank;
    if rank then
        table.insert(fields,{
            name = ("랭크 (시즌 %s)"):format(tostring(rank.rankedSeason:match("%d+")));
            value = ("%s (%d)"):format(rank.rankName,rank.rankScore);
            inline = true;
        });
    end

    local legendsAll = body.legends;
    legendsAll = legendsAll and legendsAll.all;
    if legendsAll then
        local topDamName,topDamValue,topDamPer,topKillName,topKillValue,topKillPer;
        for lName,v in pairs(legendsAll) do
            local data = v.data;
            if data then
                -- 킬이랑 데미지 읽기
                local dam,kill;
                for _,dataItem in pairs(data) do
                    if dataItem.name == "Damage" then
                        dam = dataItem;
                        if kill then
                            break;
                        end
                    elseif dataItem.name == "Kills" then
                        kill = dataItem;
                        if dam then
                            break;
                        end
                    end
                end

                -- 가장 큰걸로 푸싱 (데미지)
                local damv = dam and dam.value;
                local damr = dam and dam.rank;
                if dam and ((not topDamValue) or (topDamValue < damv)) then
                    topDamName = lName;
                    topDamValue = damv;
                    topDamPer = damr and damr.topPercent;
                end

                -- 가장 큰걸로 푸싱 (킬)
                local killv = kill and kill.value;
                local killr = kill and kill.rank;
                if kill and ((not topKillValue) or (topKillValue < killv)) then
                    topKillName = lName;
                    topKillValue = killv;
                    topKillPer = killr and killr.topPercent;
                end
            end
        end
        if topDamValue then
            table.insert(fields,{
                name = "데미지 최상 레전드";
                value = ("%s **(%s)**"):format(topDamName,
                    tostring(topDamValue) .. (topDamPer and ((" 상위 %d%%"):format(topDamPer)) or "")
                );
            });
        end
        if topKillValue then
            table.insert(fields,{
                name = "킬 최상 레전드";
                value = ("%s **(%s)**"):format(topKillName,
                    tostring(topKillValue) .. (topKillPer and ((" 상위 %d%%"):format(topKillPer)) or "")
                );
                inline = not not topDamValue;
            });
        end
    end

    local total = body.total;
    if total then
        local kills = total.kills; kills = kills and kills.value;
        local damage = total.damage; damage = damage and damage.value;
        if kills then
            table.insert(fields,{
                name = "전체 킬";
                value = tostring(kills);
            });
        end
        if damage then
            table.insert(fields,{
                name = "전체 데미지";
                value = tostring(damage);
                inline = not not kills;
            });
        end
    end

    return {
        title = "Apex Legends (Origin) 사용자 정보입니다";
        description = "[Apex API 서비스에서 가져온 정보입니다](https://apexlegendsapi.com/documentation.php)";
        color = 12661041;
        footer = {
            text = "굼금한데 이거 왜 됨...??";
        };
        thumbnail = {
            url = global.avatar;
        };
        author = {
            name = global.name;
            icon_url = "https://media.contentapi.ea.com/content/dam/apex-legends/common/logos/apex-white-nav-logo.svg";
        };
        fields = fields;
    };
end

return module;