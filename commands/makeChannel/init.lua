local insert = table.insert;
local remove = table.remove;
local unpack = table.unpack;
local huge = math.huge;
local permission = discordia.enums.permission; ---@diagnostic disable-line
local adminPermission = permission.administrator;
local channelPermissions = bit.bor(
    permission.connect,
    permission.speak,
    permission.useVoiceActivity,
    permission.manageChannels,
    permission.moveMembers,
    permission.stream
);

---Make channel data
---@param channelMaker GuildVoiceChannel
---@param initUser Member
---@return table
local function channelData(channelMaker,initUser)
    -- this:setUserLimit(10); -- init limit
    -- local category = channelMaker.category;
    -- if category then this:setCategory(channelMaker.category); end -- set category to same for maker
    -- this:moveDown(math.huge); -- make it under positioned
    -- local permissionOverwriter = channelMaker:getPermissionOverwriteFor(initUser);
    -- if permissionOverwriter then
    --     permissionOverwriter:allowPermissions(unpack(channelPermissions));
    -- else logger.wranf("[ChannelMaker] Couldn't make permissionOverwriter for user generated channel\nguild: %s; channel: %s",this.guild.id,this.id);
    -- end

    local category = channelMaker.category;
    return {
        name = ("%s-님의-개인-채널"):format(initUser.name:gsub(" ","-"));
        -- user_limit = 10;
        parent_id = category and category.id;
        position = (channelMaker.position or 0);
        permission_overwrites = {{
            id = initUser.id;
            type = 1;
            allow = tostring(channelPermissions);
        }};
    };
end

---Connect Join event
---@param member Member
---@param channel GuildVoiceChannel
client:onSync("voiceChannelJoin",promise.async(function (member, channel)
    -- get datas
    local channelId = channel.id;
    local guild = channel.guild;
    if not guild then return; end
    local data = serverData.loadData(guild.id);
    local channelMakerId = data and data.channelMaker;
    if channelId ~= channelMakerId then
        -- check user counts
        local createdChannels = data and data.createdChannels;
        if createdChannels and createdChannels[channelId] then
            local limit = channel.userLimit or 0;
            if (limit ~= 0) and (channel.connectedMembers:count() > limit) then ---@diagnostic disable-line
                member:setVoiceChannel(nil); -- kick member from that channel
            end
        end
        return;
    end

    -- make new channel
    local this = guild:createVoiceChannel(channelData(channel,member));
    if not this then return logger.errorf("[ChannelMaker] Couldn't make channel in guild %s, ignore channelMaker function",guild.id); end -- permission missing? idk what happened...
    member:setVoiceChannel(this);

    -- save this channel
    local createdChannels = data.createdChannels;
    if not createdChannels then
        createdChannels = {};
        data.createdChannels = createdChannels;
    end
    createdChannels[this.id] = true;
    serverData.saveData(guild.id,data);

    logger.infof("[ChannelMaker] Channel %s created for guild %s user %s",this.id,guild.id,member.id);
end));

---Connect Leave event, if channel was empty (bot is not user, bot is ignored for this operation)
---it will destroyed by this function
---@param member Member
---@param channel GuildVoiceChannel
client:onSync("voiceChannelLeave",promise.async(function (member,channel)
    local guild = channel.guild;
    if not guild then return; end
    local channelId = channel.id;

    -- check should be removed
    local tryRemove = true;
    for user in channel.connectedMembers:iter() do
        if not user.bot then
            tryRemove = false;
            break;
        end
    end

    -- it should be removed
    if tryRemove then
        -- check is generated channel
        local data = serverData.loadData(guild.id);
        local createdChannels = data and data.createdChannels;
        if not createdChannels then return; end
        if not createdChannels[channelId] then return; end

        -- remove channel and data
        channel:delete();
        createdChannels[channelId] = nil;
        serverData.saveData(guild.id,data);
        logger.infof("[ChannelMaker] Channel %s destroyed for guild %s",channel.id,guild.id);
    end
end));

-- connect to when channel destroyed, this event can be triggered with administrator's action
client:onSync("channelDelete", function(channel)
    local guild = channel.guild;
    local channelId = channel.id;
    if not guild then return; end
    local data = serverData.loadData(guild.id);
    local createdChannels = data and data.createdChannels;
    if not createdChannels then return; end
    if createdChannels[channelId] then
        createdChannels[channelId] = nil;
        serverData.saveData(guild.id,data);
    end
end);

---@type table<string, Command>
local export = {
    -- ["맴버수"] = {
    --     alias = {
    --         -- 유저/맴버/사용자/이용자 + 수
    --         "유저수","유저 수",
    --         "맴버 수","맴버수",
    --         "사용자 수","사용자수",
    --         "이용자 수","이용자수",
    --         -- 유저/맴버/사용자/이용자 + 제한
    --         "유저 제한","유저제한",
    --         "맴버 제한","맴버제한",
    --         "사용자 제한","사용자제한",
    --         "이용자 제한","이용자제한",
    --         -- 최대 + 유저/맴버/사용자/이용자
    --         "최대 유저","최대유저",
    --         "최대 맴버","최대맴버",
    --         "최대 사용자","최대사용자",
    --         "최대 이용자","최대이용자"
    --     };
    --     disableDm = true;
    --     command = "제한";
    --     ---@param message Message
	-- 	---@param args table
	-- 	---@param Content commandContent
    --     reply = function (message,args,Content,self)
    --         local member = Content.member;
    --         local channel = member.voiceChannel;

    --         if not channel then
    --             return message:reply(self.noVoiceChannel);
    --         end

    --         message:reply(self.notOwner);

    --     end;
    --     noVoiceChannel = {
    --         content = zwsp;
    --         embed = {
    --             title = ":x: 참여중인 채널이 없습니다";
    --         };
    --     };
    --     notOwner = {
    --         content = zwsp;
    --         embed = {
    --             title = ":x: 자신의 채널이 아닙니다";
    --         };
    --     };
    -- };
    ["음성채팅생성"] = {
        alias = {
            "채널생성","채널 생성","채널 생성기","채널생성기",
            "음성방생성","음성방 생성","음성채팅 생성","음성챗방 생성",
            "음성챗방생성","음성챗 생성","음성챗생성","보이스생성","보이스 생성"
        };
        disableDm = true;
        command = "채널생성";
        reply = zwsp;
        embed = {title = "잠시만 기다려주세요 . . ."};
        ---@param message Message
		---@param args table
		---@param Content commandContent
        func = function(replyMsg,message,args,Content,self)
            if not replyMsg then return logger.errorf("[ChannelMaker] replyMsg must be Message, but got nil or something not expected"); end

            -- no permission to execute this command
            if not Content.member:hasPermission(adminPermission) then ---@diagnostic disable-line we can do dis without adding channel but diagnostic will catch this method must be called with three arguments
                return replyMsg:update(self.notPermitted);
            end

            local guildData = Content.loadServerData() or {};
            local guild = Content.guild;
            local channelMaker = guildData.channelMaker;

            local new,err = guild:createVoiceChannel("「➕」음성채팅-생성");
            if not new then -- failed to create new channel
                return replyMsg:update({
                    content = zwsp;
                    embed = {
                        title = ":x: 음성 채널 생성방을 만들지 못했습니다";
                        description = ("채널을 생성할 권한이 없거나, 디스코드의 오류일 수 있습니다.\n권한 확인 후 다시 시도해주세요\n```\n%s\n```"):format(tostring(err));
                        footer = {text = "미나를 다시 초대하면 원활한 권한 설정을 맞출 수 있어요"};
                    };
                });
            end

            guildData.channelMaker = new.id; -- update
            Content.saveServerData(guildData);

            if channelMaker then
                local this = guild.voiceChannels:find(function (this)
                    return this.id == channelMaker;
                end);
                if this then
                    this:delete();
                    replyMsg:update(self.replaced)
                end
            end
            replyMsg:update(self.created);
        end;
        created = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 음성 채널 생성방을 만들었습니다!";
            }
        };
        replaced = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 음성 채널 생성방을 만들었습니다!";
                description = "이전 음성 채널 생성방을 없에고 새로 만들었습니다";
            }
        };
        notPermitted = {
            content = zwsp;
            embed = {
                title = ":x: 명령어를 실행할 권한이 부족합니다";
                description = "서버 관리자 권한이 있는 사람만 이 명령어를 실행할 수 있습니다";
            };
        };
		onSlash = commonSlashCommand {
			noOption = true;
			description = "음성 채널 생성방을 만듭니다!";
		};
    };
};

return export;
