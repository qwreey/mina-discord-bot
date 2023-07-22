local components = discordia_enchant.components;
local enums = discordia_enchant.enums;

local rolefemaleId = "1131564409525899325";
local rolemaleId = "1131566180080025600";
local guildId = "1130079569697837086";

_G.unhanunhanmalefemale = function (channel)
    channel:send{
        content = zwsp;
        embed = {
            title = "성별 역할 받아가기 (남/여)";
        };
        components = {
            components.actionRow.new{
                components.button.new{
                    custom_id = "action_unhanunhan_male";
                    label = "남";
                    emoji = components.emoji.new("♂");
                    style = enums.buttonStyle.primary;
                };
                components.button.new{
                    custom_id = "action_unhanunhan_female";
                    label = "여";
                    emoji = components.emoji.new("♀");
                    style = enums.buttonStyle.danger;
                };
            };
        };
    };
end;


---@param id string
---@param object interaction
local function buttonPressed(id,object)
    if object.guild.id ~= guildId then return; end
    if not id:match("^action_unhanunhan_") then return; end
    if id == "action_unhanunhan_male" then
        if object.member:hasRole(rolefemaleId) then
            object.member:removeRole(rolefemaleId);
        end
        if not object.member:hasRole(rolemaleId) then
            object.member:addRole(rolemaleId);
        end

        object:reply({
            content = zwsp;
            embed = {
                title = "역할을 받았어요!";
            };
        },true);
    end
    if id == "action_unhanunhan_female" then
        if object.member:hasRole(rolemaleId) then
            object.member:removeRole(rolemaleId);
        end
        if not object.member:hasRole(rolefemaleId) then
            object.member:addRole(rolefemaleId);
        end

        object:reply({
            content = zwsp;
            embed = {
                title = "역할을 받았어요!";
            };
        },true);
    end
end
client:onSync("buttonPressed",promise.async(buttonPressed));

logger.info("QwreeyLand script loaded");
