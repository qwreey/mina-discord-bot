local this = {};

local enums = require("../../enums");
local button = enums.componentType.button;
local messageComponent = enums.interactionType.messageComponent;
function this.new(props)
    -- local func = props.func;
    -- props.func = nil;
    props.type = button;
    return props;
end

this._events = {};
function this._events.INTERACTION_CREATE(data, client)
    if data.type == messageComponent then -- button
        local interactionId = data.id;
        local interactionToken = data.token;
        local message = data.message;
        local button = data.data;
        local member = data.member;
        local user = data.user;
        local userId = (user and user.id) or (member and member.user.id);
        local guildId = data.guild_id;

        local userObject = client:getUser(userId);
        local guildObject;
        local memberObject;
        local channelObject;

        if guildId then
            guildObject = client:getGuild(guildId);
            if guildObject then
                memberObject = guildObject:getMember(userId);
                channelObject = guildObject:getChannel(data.channel_id);
            else
                client:warning('Uncached Guild (%s) on INTERACTION_CREATE', guildId)
            end
        elseif user then
            channelObject = client:getChannel(userId) or user:getPrivateChannel();
        end

        local buttonId = button and button.custom_id;
        ---@class buttonPressedObject
        local object = {
            ---Id of pressed button
            ---@type string
            id  = buttonId;
            ---User who pressed this button
            ---@type User
            user = userObject;
            ---Guild where this button pressed
            ---@type Guild
            guild = guildObject;
            ---Guild where this button pressed
            ---@type Member
            member = memberObject;
            ---Channel where this button pressed
            ---@type TextChannel|Channel|GuildChannel
            channel = channelObject;
            ---Message witch contain this
            ---@type Message
            message = channelObject and message and channelObject._messages:_insert(message);
            ---@type table raw data
            data = data;
        };

        -- make acts
        client._api:interactionCallback(
            tostring(interactionId),
            tostring(interactionToken)
        );

        return true,client:emit('buttonPressed', buttonId, object);
    end
    return false;
end

return this;
