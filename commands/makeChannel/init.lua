
local unpack = table.unpack;
local permission = discordia.enums.permission;
local adminPermission = permission.administrator;
local channelPermissions = {
    permission.connect;
    permission.speak;
    permission.useVoiceActivity;
    permission.manageChannels;
    permission.moveMembers;
    permission.stream;
};
local function updateChannel(this,channelMaker,initUser)
    this:setUserLimit(10); -- init limit
    local category = channelMaker.category;
    if category then this:setCategory(channelMaker.category); end -- set category to same for maker
    this:moveDown(math.huge); -- make it under positioned
    local permissionOverwriter = channelMaker:getPermissionOverwriteFor(initUser);
    if permissionOverwriter then
        permissionOverwriter:allowPermissions(unpack(channelPermissions));
    else logger.wranf("[ChannelMaker] Couldn't make permissionOverwriter for user generated channel\nguild: %s; channel: %s",this.guild.id,this.id);
    end
end

---@param member Member
---@param channel GuildVoiceChannel
client:onSync("voiceChannelJoin",promise.async(function (member, channel)
    local guild = channel.guild;
    if not guild then return; end
    local data =serverData.loadData(guild.id);
    local channelMaker = data and data.channelMaker;
    if channel.id ~= channelMaker then return logger.errorf("[ChannelMaker] Couldn't make channel in guild %s, ignore channelMaker function",guild.id); end

    local this = guild:createVoiceChannel(("%s 님의 개인 채널"):format(member.name));
    if not this then return; end -- permission missing? idk what happened...
    member:setVoiceChannel(this);
    updateChannel(this,channel,member); -- update channel permission, position, category and more...
    logger.infof("[ChannelMaker] Channel %s created for guild %s user %s",this.id,guild.id,member.id);
end));

---@type table<string, Command>
local export = {
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

            local new,err = guild:createVoiceChannel("「🎤」음성채팅-생성");
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
    };
};

return export;
