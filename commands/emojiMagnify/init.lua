local discordia_enchant = _G.discordia_enchant;
local components = discordia_enchant.components;
local key = "emojiMagnify";

---@type table<string, Command>
local export = {
    ["이모지확대"] = {
		disableDm = true;
		command = {"이모지확대"};
        ---@param Content commandContent
		reply = function(message,args,Content,self)
            local serverData = Content.loadServerData() or {};

			local rawArgs = Content.rawArgs;
			local setTo = not serverData[key];
			if onKeywords[rawArgs] then
				setTo = true;
			elseif onKeywords[rawArgs] then
				setTo = false;
			end

			Content.saveServerData(serverData);
		end;
		onSlash = commonSlashCommand {
			description = "이모지 확대 기능을 켜거나 끕니다, 관리자만 이 기능을 사용할 수 있습니다!";
			name = "이모지확대";
			optionDescription = "이모지 확대를 켤지 끌지 결정해주세요! (아무것도 입력하지 않으면 토글합니다)";
			optionRequired = false;
			optionChoices = {
				{
					name = "이모지 확대 기능을 켭니다!";
					value = "켜기";
				};
				{
					name = "이모지 확대 기능을 끕니다!";
					value = "끄기";
				};
			};
		};
	};
};

local defaultComponents = {
    components.actionRow {
        buttons.action_remove;
    };
};

local match = string.match;
local this = hook.new{
    type = hook.types.before;
    destroy = function (self) -- this function never be called, should never happen
        self:detach();
        logger.info("[emojiMagnifying] Module unloaded!");
    end;
    ---@param contents hookContent
    func = function (self,contents)
        if contents.isDm then return; end
        local text = contents.text;
        local emojiId = match(text,"^ *<:[%w_]+:(%d+)> *$");
        if emojiId then
            local message = contents.message;
            local member = message.member;
            local guild = message.guild;
            if (not guild) or (not member) then return; end
            local guildId = guild.id;
            local serverData = serverData.loadData(guildId);
            if (not serverData) or (not serverData[key]) then
                return true;
            end

            message:reply{
                content = zwsp;
                embed = {
                    footer = {
                        text = ("%s 님이 사용한 이모지"):format(member.nickname or member.name);
                    };
                    image = {
                        url = ("https://cdn.discordapp.com/emojis/%s"):format(emojiId);
                    };
                };
                components = defaultComponents;
                reference = {message = message, mention = false};
            };
            return true;
        end
    end;
};
this:attach();

return export;
