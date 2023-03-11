local components = discordia_enchant.components;
local enums = discordia_enchant.enums;

local roleId = "1083995422080639017";
local guildId = "943167410209439805";
local guild = client:getGuild(guildId);
local role = guild:getRole(roleId);

_G.QwreeyLand = function (channel)
    channel:send{
        content = zwsp;
        embed = {
            title = "쿼리 뻘짓 구독하기";
            description = ("쿼리까 뻘짓 하는걸 맨션으로 알림받고 싶다면 <#&%s> 를 받아봐요")
                :format(roleId)
        };
        components = {
            components.actionRow.new{
                components.button.new{
                    custom_id = "action_qwreeyland_role_subscribe";
                    label = "역할 받기/버리기";
                    style = enums.buttonStyle.primary;
                };
            };
        };
    };
end;


---@param id string
---@param object interaction
local function buttonPressed(id,object)
    if id ~= "action_qwreeyland_role_subscribe" then return; end
    if object.guild.id ~= guildId then return; end
    if object.member:hasRole(role) then
        object.member:removeRole(role);
        object:reply({
            content = zwsp;
            embed = {
                title = "구독을 취소했어요!";
            };
        },true);
    else
        object.member:addRole(role);
        object:reply({
            content = zwsp;
            embed = {
                title = "구독에 성공했어요!";
            };
        },true);
    end
end
client:onSync("buttonPressed",promise.async(buttonPressed));
