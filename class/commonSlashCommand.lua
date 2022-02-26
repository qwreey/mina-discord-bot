
---@class commandSlashCommandOptions
---@field name string name of this slash command (will used on commit commands
---@field description string command decription
---@field optionDescription string description of command option
---@field optionsType number option type, default is string
---@field optionRequired boolean is option is required, default is true
---@field optionName string name of option
---@field optionChoices table option choices table
---@field noOption boolean|nil is no option provided
---@field headerEnabled boolean|nil is interaction header enabled 
local defaultOptionName = "내용";
local defaultOptionDescription = "명령어 사용에 쓰이는 내용입니다";

---comment
---@param options commandSlashCommandOptions table of options
---@return function
local function commonSlashCommand(options)
    return function (self,client)
        local optionRequired = options.optionRequired;
        local noInteractionHead = not options.headerEnabled;
        local parentName = self.name;
        local optionName = options.optionName or defaultOptionName;
        client:slashCommand({ ---@diagnostic disable-line
            name = options.name or parentName;
            description = options.description;
            options = (not options.noOption) and {
                {
                    name = optionName;
                    description = options.optionDescription or defaultOptionDescription;
                    type = options.optionsType or discordia_enchent.enums.optionType.string;
                    required = type(optionRequired) == "nil" or optionRequired;
                    choices = options.optionChoices;
                };
            };
            callback = function(interaction, params, cmd)
                local pass,err = pcall(
                    processCommand,
                    userInteractWarpper(
                        ("%s %s"):format(parentName,tostring(params[optionName] or "")),
                        interaction,noInteractionHead
                    )
                );
                if not pass then
                    logger.errorf("Error occurred on executing slash command from command '%s'\n%s",tostring(parentName),tostring(err));
                end
            end;
        });
    end
end

-- _G.commonSlashCommand = commonSlashCommand;
return commonSlashCommand;
