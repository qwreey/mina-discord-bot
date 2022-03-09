local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;

local insert = table.insert;
local function combine(self,message)
	if type(message) == "string" then
		return {components = {components.actionRow.new{self}},content = message};
	end
	local tcomponents = message.components or {components.actionRow.new()};
	message.components = tcomponents;
	insert(tcomponents[1].components,self);
	return message;
end

return {
	action_remove = setmetatable(components.button.new{
		custom_id = "action_remove";
		style = discordia_enchant_enums.buttonStyle.danger;
		label = "메시지 삭제";
		emoji = components.emoji.new "✖";
		---@param object interaction
		func = function(object)
			local message = object.message;
			local channel = object.channel; ---@type GuildTextChannel
			if message then
				local referencedMessage = message.referencedMessage;
				if referencedMessage then
					if channel then
						pcall(channel.bulkDelete,channel,{referencedMessage,message});
					end
					pcall(referencedMessage.delete,referencedMessage);
				end
				pcall(message.delete,message);
			end
		end;
	},{__call = combine});
};
