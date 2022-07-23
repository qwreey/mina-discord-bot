local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;

local insert = table.insert;
local function combine(self,message)
	if type(message) == "string" then
		return {components = {components.actionRow.new{self}},embed = {title = message}};
	end
	local tcomponents = message.components or {components.actionRow.new()};
	message.components = tcomponents;
	insert(tcomponents[1].components,self);
	return message;
end

-- remove owner only function
local notOwner = {
	content = zwsp;
	embed = {
		title = ":x: 메시지 주인만 이 명령을 사용할 수 있습니다";
	};
};
---@param id string
---@param object interaction
local function removeOwnerOnly(id,object)
	local ownerId = id:match("action_remove_owner_(%d+)");
	if ownerId then
		local member = object.member;
		local message = object.message;
		if (not member) or (not message) then
			return;
		elseif tostring(member.id) ~= ownerId then ---@diagnostic disable-line
			object:reply(notOwner,true);
			return;
		end
		pcall(message.delete,message);
	end
end
client:onSync("buttonPressed",promise.async(removeOwnerOnly));

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
	action_remove_noreferenced = setmetatable(components.button.new{
		custom_id = "action_remove_noref";
		style = discordia_enchant_enums.buttonStyle.danger;
		label = "메시지 삭제";
		emoji = components.emoji.new "✖";
		---@param object interaction
		func = function(object)
			local message = object.message;
			if message then
				pcall(message.delete,message);
			end
		end;
	},{__call = combine});
	action_remove_owneronly = function(owner)
		return components.button.new{
			custom_id = ("action_remove_owner_%s"):format(owner);
			style = discordia_enchant_enums.buttonStyle.danger;
			label = "메시지 삭제";
			emoji = components.emoji.new "✖";
		};
	end;
};
