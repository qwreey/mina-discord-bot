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

local typesOfPermissionOverwrite = {member = 1,role = 0};
local function getRawPermissionOverwrites(channel)
    local permissionOverwrites = channel.permissionOverwrites;
    if not permissionOverwrites then return {} end
    local raw = {};
    for item in permissionOverwrites:iter() do
        local this = {
            id = item.id;
            type = typesOfPermissionOverwrite[item._type];
        };
        local deny = item._deny;
        local allow = item._allow;

        if deny then
            this.deny = deny;
        end
        if allow then
            this.allow = allow;
        end

        insert(raw,this);
    end
    return raw;
end

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

    local userId = initUser.id;
    local rawPermissionOverwrites = getRawPermissionOverwrites(channelMaker);
    local userPermission;
    for _,v in ipairs(rawPermissionOverwrites) do
        if v.id == userId then
            userPermission = v;
        end
    end
    if not userPermission then
        userPermission = {};
        insert(rawPermissionOverwrites,userPermission);
        userPermission.id = initUser.id;
        userPermission.type = 1;
    end

    userPermission.allow = channelPermissions;
    local initUserData = userData.loadData(initUser.id);
    local defaultNames = initUserData and initUserData.channelMakerDefaultNameByServers;
    local name = defaultNames and defaultNames[channelMaker.guild.id];

    local category = channelMaker.category;
    return {
        name = name or ("%s님의 개인채널"):format(initUser.name);
        -- user_limit = 10;
        parent_id = category and category.id;
        position = (channelMaker.position or 0);
        permission_overwrites = rawPermissionOverwrites;
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
    if member.user.bot then return; end
    -- data.channelMakerLoggerId
    local this = guild:createVoiceChannel(channelData(channel,member));
    if not this then return logger.errorf("[ChannelMaker] Couldn't make channel in guild %s, ignore channelMaker function",guild.id); end -- permission missing? idk what happened...
    member:setVoiceChannel(this);

    -- save this channel
    local createdChannels = data.createdChannels;
    if not createdChannels then
        createdChannels = {};
        data.createdChannels = createdChannels;
    end
    createdChannels[this.id] = member.id;
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
    ["채널삭제모드"] = {
        disableDm = true;
        command = "채널모드";
        alias = {
            "채널모드","채널 모드","음챗모드","음챗 모드",
            "음챗삭제모드","음챗 삭제모드","음챗삭제 모드","음챗 삭제모드",
            "채널 삭제모드","채널 삭제 모드","채널삭제 모드", --[[오타까지]] "채널삭재모드","채널 삭재모드","채널 삭재 모드","채널삭재 모드",
        };
        onSlash = commonSlashCommand {
            optionRequired = false;
            optionDescription = "설정할 모드입니다. 비워두면 모드를 확인합니다. 기본값은 유저 보호입니다.";
            optionChoices = {
                {
					name = "봇보호(봇만 있어도 채널이 유지됨)";
					value = "봇";
				};
                {
					name = "유저보호(유저가 있어야 채널이 유지됨)";
					value = "유저";
				};
                {
                    name = "안함(삭제를 하지 않고 유지합니다. 단 관리자만 이 설정을 사용할 수 있습니다)";
                    value = "안함";
                };
            };
            description = "자신이 있는 생성된 음성 채널모드를 변경하거나 확인합니다.";
		};
        channelIsNotGenerated = {
            content = zwsp;
            embed = {
                title = ":x: 생성된 채널이 아닙니다";
                description = "봇이 생성한 채널만 이름을 바꿀 수 있어요";
                color = embedColors.error;
            };
        };
        channelNotFound = {
            content = zwsp;
            embed = {
                title = ":x: 참여한 채널이 없습니다";
                description = "삭제 모드를 변경할 채널에 참가하세요";
                color = embedColors.error;
            };
        };
        channelNotOwn = {
            content = zwsp;
            embed = {
                title = ":x: 자신의 채널이 아닙니다";
                description = "관리자는 삭제 모드를 강제로 변경할 수 있습니다";
                color = embedColors.error;
            };
        };
        optionNotPermitted = {
            content = zwsp;
            embed = {
                title = ":x: 권한이 부족합니다";
                description = "선택한 모드가 관리자 권한을 필요로 합니다";
                color = embedColors.error;
            };
        };
        modes = {
            ['봇'] = "bot";
            ['유저'] = "user";
            ['안함'] = "none";
        };
        modeNotFound = {
            content = zwsp;
            embed = {
                title = ":x: 해당 모드가 없습니다";
                description = "유효한 모드는 봇, 유저, 안함 입니다";
                color = embedColors.error;
            };
        };
        ---@param message Message
        ---@param Content commandContent
        reply = function (message,args,Content,self)
            local arg = Content.rawArgs;
            

            local member = message.member; ---@type Member
            local channel = member.voiceChannel;
            if not channel then -- check member's channel
                return message:reply(self.channelNotFound);
            end

            -- check server data
            local serverData = Content.loadServerData();
            local createdChannels = serverData and serverData.createdChannels;
            if not createdChannels then -- if can't find created channel data, just ignore this command
                return message:reply(self.channelIsNotGenerated);
            end

            -- check ownership
            local owner = createdChannels[channel.id];
            local byForce; -- is forced, by admin permission
            if not owner then
                return message:reply(self.channelIsNotGenerated);
            elseif owner ~= member.id then
                if member:hasPermission(adminPermission) then
                    byForce = true;
                else
                    return message:reply(self.channelNotOwn);
                end
            end

            -- if forced
            if byForce then
                return message:reply(self.channelNameSettedByForce);
            end

            -- save to user data file
            local userData = Content.loadUserData();
            if not userData then
                return message:reply(self.noUserData);
            end
            local userDefaults = userData.channelMakerDefaultNameByServers;
            if not userDefaults then
                userDefaults = {};
                userData.channelMakerDefaultNameByServers = userDefaults;
            end
            userDefaults[message.guild.id] = Content.rawArgs;
            Content.saveUserData();

            return message:reply(self.channelNameSetted);
        end;
    };
    ["채널주인"] = {
        alias = {
            "채널방장","음챗방장","음챗주인","채널워너","음챗워너","채널오너","채널유저","음챗유저","음챗오너",
            "채널 방장","음챗 방장","음챗 주인","채널 워너","음챗 워너","채널 오너","음챗 오너","채널 유저","음챗 유저","채널 주인"
        };
        channelIsNotGenerated = {
            content = zwsp;
            embed = {
                title = ":x: 생성된 채널이 아닙니다";
                description = "유저가 생성한 채널만 주인이 있어요";
                color = embedColors.error;
            };
        };
        channelNotFound = {
            content = zwsp;
            embed = {
                title = ":x: 참여한 채널이 없습니다";
                description = "주인을 알고 싶은 채널에 참여하세요";
                color = embedColors.error;
            };
        };
        command = "채널주인";
        ---@param message Message
        ---@param Content commandContent
        reply = function (message,args,Content,self)
            local guild = message.guild;
            local member = message.member; ---@type Member
            if (not guild) or (not member) then return end
            local channel = member.voiceChannel;
            if not channel then -- check member's channel
                return message:reply(self.channelNotFound);
            end

            -- check server data
            local serverData = Content.loadServerData();
            local createdChannels = serverData and serverData.createdChannels;
            if not createdChannels then -- if can't find created channel data, just ignore this command
                return message:reply(self.channelIsNotGenerated);
            end

            -- check ownership
            local owner = createdChannels[channel.id];
            if not owner then
                return message:reply(self.channelIsNotGenerated);
            end
            local ownerMember = guild:getMember(owner);
            local ownerName = ownerMember and ownerMember.name

            return message:reply{
                content = zwsp;
                embed = {
                    title = ownerName;
                    description = ("채널의 주인은 <@%s> 입니다"):format(owner);
                    color = embedColors.success;
                };
            };
        end;
        onSlash = commonSlashCommand {
            noOption = true;
            description = "자신이 있는 생성된 음성 채널의 주인을 확인합니다.";
		};
    };
    ["채널이름"] = {
        alias = {"channel name","채널 이름","채널이름변경","채널 이름 변경","채널 이름변경","채널이름 변경"};
        disableDm = true;
        command = "채널이름";
        channelNameSetted = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 채널 이름을 설정했습니다";
                description = "다음번 생성되는 채널도 이 이름을 가집니다";
                color = embedColors.success;
            };
        };
        channelNotFound = {
            content = zwsp;
            embed = {
                title = ":x: 참여한 채널이 없습니다";
                description = "이름을 바꾸고 싶은 자신의 채널에 참여하세요";
                color = embedColors.error;
            };
        };
        channelNotOwn = {
            content = zwsp;
            embed = {
                title = ":x: 이 채널은 자신의 것이 아니에요";
                description = "관리 권한이 있다면 자신의 채널이 아니여도 이름을 바꿀 수 있어요";
                color = embedColors.error;
            };
        };
        channelIsNotGenerated = {
            content = zwsp;
            embed = {
                title = ":x: 생성된 채널이 아닙니다";
                description = "봇이 생성한 채널만 이름을 바꿀 수 있어요";
                color = embedColors.error;
            };
        };
        channelNameSettedByForce = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 채널 이름을 강제로 설정했습니다";
                description = "관리 권한을 이용해 강제로 채널 이름을 설정했습니다. 다음에 생성하는 자신의 채널의 이름에는 영향을 주지 않습니다";
                color = embedColors.info;
            };
        };
        -- nameNeeded = {
        --     content = zwsp;
        --     embed = {
        --         title = ":x: 이름을 비워둘 수 없습니다";
        --         description = "이름을 설정해주세요";
        --         color = embedColors.error;
        --     };
        -- };
        reset = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 채널 이름을 초기화 했습니다";
                description = "다음에 생성하는 자신의 채널 이름도 기본값이 사용됩니다";
                color = embedColors.success;
            };
        };
        noUserData = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 채널 이름을 설정했습니다";
                description = "그러나 약관 미동의로 기본값으로 설정하진 못했습니다 (데이터 저장 불가)";
                color = embedColors.warn;
            };
        };
        ---@param message Message
        ---@param Content commandContent
        reply = function (message,args,Content,self)
            --TODO: 초기화
            local channelName = Content.rawArgs;
            local reset;
            if (not channelName) or (#channelName == 0) then
                reset = true;
            end

            local member = message.member; ---@type Member
            local channel = member.voiceChannel;
            if not channel then -- check member's channel
                return message:reply(self.channelNotFound);
            end

            -- check server data
            local serverData = Content.loadServerData();
            local createdChannels = serverData and serverData.createdChannels;
            if not createdChannels then -- if can't find created channel data, just ignore this command
                return message:reply(self.channelIsNotGenerated);
            end

            -- check ownership
            local owner = createdChannels[channel.id];
            local byForce; -- is forced, by admin permission
            if not owner then
                return message:reply(self.channelIsNotGenerated);
            elseif owner ~= member.id then
                if member:hasPermission(adminPermission) then
                    byForce = true;
                else
                    return message:reply(self.channelNotOwn);
                end
            end

            -- set channel Name and check error
            local ok,err = channel:setName(channelName);
            if not ok then
                return message:reply{
                    content = zwsp;
                    embed = {
                        title = ":x: 채널 이름 변경에 실패했습니다";
                        description = ("디스코드가 잘못된 결과를 주었습니다\n```%s```"):format(tostring(err));
                        color = embedColors.error;
                    };
                };
            end

            -- if forced
            if byForce then
                return message:reply(self.channelNameSettedByForce);
            end

            -- save to user data file
            local userData = Content.loadUserData();
            if not userData then
                return message:reply(self.noUserData);
            end
            local userDefaults = userData.channelMakerDefaultNameByServers;
            if not userDefaults then
                userDefaults = {};
                userData.channelMakerDefaultNameByServers = userDefaults;
            end
            if reset then
                userDefaults[message.guild.id] = nil;
            else userDefaults[message.guild.id] = Content.rawArgs;
            end
            Content.saveUserData();

            return message:reply(reset and self.reset or self.channelNameSetted);
        end;
        onSlash = commonSlashCommand {
            optionName = "이름";
            optionRequired = true;
            optionsType = discordia_enchant.enums.optionType.string;
            optionDescription = "현재 자신이 있는 음성 채널의 변경할 이름을 입력하세요";
			description = "자신이 있는 생성된 음성 채널의 이름을 변경합니다. 오직 자신이 만든 음챗만 가능합니다!";
		};
    };
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
            local channelName = Content.rawArgs;
            if #channelName == 0 then -- if channel name was not defined, set as default name
                channelName = "「➕」음성채팅-생성";
            end

            local new,err = guild:createVoiceChannel(channelName);
            if not new then -- failed to create new channel
                return replyMsg:update({
                    content = zwsp;
                    embed = {
                        color = embedColors.error;
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
                color = embedColors.success;
            };
        };
        replaced = {
            content = zwsp;
            embed = {
                title = ":white_check_mark: 음성 채널 생성방을 만들었습니다!";
                description = "이전 음성 채널 생성방을 없에고 새로 만들었습니다";
                color = embedColors.success;
            };
        };
        notPermitted = {
            content = zwsp;
            embed = {
                title = ":x: 명령어를 실행할 권한이 부족합니다";
                description = "서버 관리자 권한이 있는 사람만 이 명령어를 실행할 수 있습니다";
                color = embedColors.error;
            };
        };
		onSlash = commonSlashCommand {
            name = "채널생성";
			description = "음성 채널 생성방을 만듭니다. 만들어진 채널의 이름은 디스코드 채널 설정에서 변경할 수 있습니다";
            optionName = "채널이름";
            optionDescription = "음성 채팅방을 생성하는 채널의 이름을 지정합니다. 비워두면 자동으로 기본값을 사용합니다. 나중에 디스코드 채널 설정으로 직접 편집할 수 있습니다";
            optionsType = discordia_enchant.enums.optionType.string;
            optionRequired = false;
		};
    };
    -- ["채널양도"] = {
    --     alias = {
    --         "채널소유권이전","채널 소유권 이전","채널소유권 이전","채널 소유권이전",
    --         "음챗소유권이전","음챗 소유권 이전","음챗소유권 이전","음챗 소유권이전",
    --         "음성채팅소유권이전","음성",
    --         "채널 양도","음챗양도","음챗 양도"
    --     };
    -- };
};

return export;
