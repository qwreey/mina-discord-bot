local module = {};

---@param id string
---@param object interaction
local function buttonPressed(id,object)
    if id == "action_remove" then
        -- local message = object.message;
        -- if message then
        --     local referencedMessage = message.referencedMessage;
        --     if referencedMessage then
        --         pcall(referencedMessage.delete,referencedMessage);
        --     end
        --     pcall(message.delete,message);
        -- end
    end
end

function module.init()
    client:on("buttonPressed",buttonPressed);
end

local function combine(self,message)
    if type(message) == "string" then
        return {components = self,content = message};
    end
    message.components = self;
    return message;
end

local components = discordia_enchent.components;
local discordia_enchent_enums = discordia_enchent.enums;
_G.buttons = {
    action_remove = setmetatable(components.button.new{
        custom_id = "action_remove";
        style = discordia_enchent_enums.buttonStyle.danger;
        label = "메시지 삭제";
        emoji = components.emoji.new "❌";
        func = function(object)
            local message = object.message;
            if message then
                local referencedMessage = message.referencedMessage;
                if referencedMessage then
                    pcall(referencedMessage.delete,referencedMessage);
                end
                pcall(message.delete,message);
            end
        end;
    },{__call = combine});
};

return module;
