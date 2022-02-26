local discordia = require("discordia")
local endpoints = require('../endpoints')
local enums = require('../enums')
local format = string.format
local snowflake = discordia.class.classes.Snowflake
local deferredChannelMessageWithSource = enums.interactionResponseType.deferredChannelMessageWithSource
local channelMessageWithSource = enums.interactionResponseType.channelMessageWithSource
local deferredUpdateMessage = enums.interactionResponseType.deferredUpdateMessage
local componentButton = enums.componentType.button
local updateMessage = enums.interactionResponseType.updateMessage

---@class interaction
---@field public message Message If this is message's interaction (such as button), this is parent message of interaction else ApplicationCommand, this is nil
---@field public parentInteraction interaction If this is slash command's interaction (such as button), this is parent interaction of interaction
---@field public version number Always 1
---@field public token string token of this interaction
---@field public id string id of this interaction
---@field public buttonId string if this is button interaction, it will id of button
---@field public type number type of this interaction
---@field public member Member if this interaction is actived on guild, it will member who created this interaction
---@field public channel Channel|TextChannel|GuildChannel|GuildTextChannel where this interaction is actived on channel
---@field public guild Guild where this interaction is actived on guild
---@return interaction interaction return new object
local interaction
local interactionGetters
interaction, interactionGetters = discordia.class('Interaction', snowflake)

function interaction:__init(data, parent)
	-- print(table.dump(data))

	local message = data.message
	local messageType = message and message.type
	local this = data.data
	local componentType = this and this.component_type
	local buttonId = this and componentType == componentButton and this.custom_id

	local member = data.member
	local user = data.user
	local userId = (user and user.id) or (member and member.user.id)
	local guildId = data.guild_id

	local guildObject
	local memberObject
	local channelObject
	local userObject = parent:getUser(userId)
	local messageObject

	if guildId then
		guildObject = client:getGuild(guildId)
		if guildObject then
			memberObject = guildObject:getMember(userId)
			channelObject = guildObject:getChannel(data.channel_id)
		else
			client:warning('Uncached Guild (%s) on INTERACTION_CREATE', guildId)
		end
	elseif user then
		channelObject = client:getChannel(userId) or userObject:getPrivateChannel()
	end
	messageObject = messageType == 19 and (channelObject and message and channelObject._messages:_insert(message))

	self._user = userObject
	self._guild = guildObject
	self._channel = channelObject
	self._member = memberObject
	self._buttonId = buttonId
	self._id = data.id
	self._parent = parent
	self._type = data.type
	self._token = data.token
	self._version = data.version
	self._isComponent = componentType ~= nil
	self._message =  messageObject
	self._parentInteraction = messageType == 20 and interaction(message.interaction,parent);
end

---Create a response to an Interaction from the gateway.
---@param type number type of response
---@param data table table of datas
---@return boolean
function interaction:createResponse(type, data)
	self._type = type

	-- local api = self.parent._api;
	self.parent._api:request('POST', format(endpoints.INTERACTION_RESPONSE, self._id, self._token), {
		type = type,
		data = data,
	})
	-- p(api:request('GET',format(endpoints.GET_ORIGINAL_INTERACTION_RESPONSE, self._id, self._token)))
end
function interaction:createFollowup(data)
	self.parent._api:request('POST', format(endpoints.INTERACTION_FOLLOWUP_CREATE, self._id, self._token), data)
end

---Send act response.
---@return boolean
function interaction:ack()
	if self._isComponent then
		return self:createResponse(deferredUpdateMessage)
	else
		return self:createResponse(deferredChannelMessageWithSource)
	end
end

---Create reply message.
---@param data table table of datas, same with message data
---@param private boolean|nil set reply is only can see by called user
---@return boolean
function interaction:reply(data, private)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	if private then
		data.flags = 64
	end

	if self._initialResponse then
		return self:createFollowup(data);
	end

	self._initialResponse = data;

	return self:createResponse(channelMessageWithSource, data)
end

---Update reply message.
---@param data table table of datas, same with message data
---@return boolean
function interaction:update(data)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	if self._isComponent then -- if it is component
		return self:createResponse(updateMessage,data);
	end
	return self._parent._api:request('PATCH', format(endpoints.INTERACTION_RESPONSE_MODIFY, self._parent._slashid, self._token), data)
end

---Delete reply message.
---@return boolean
function interaction:delete()
	return self._parent._api:request('DELETE', format(endpoints.INTERACTION_RESPONSE_MODIFY, self._parent._slashid, self._token))
end

---Create new followup reply message (reply of reply).
---@param data table table of datas, same with message data
---@param private boolean|nil set reply is only can see by called user
---@return Message
function interaction:followUp(data, private)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	if private then
		if self._type == deferredChannelMessageWithSource then
			private = false
		else
			data.flags = 64
		end
	end

	local res = self._parent._api:request('POST', format(endpoints.INTERACTION_FOLLOWUP_CREATE, self._parent._slashid, self._token), data)

	if res.id then
		local msg

		if not private then
			msg = self._channel:getMessage(res.id)
		end

		return res.id, msg, res
	end

	return res
end

---Update followup reply message.
---@param id string followup message id
---@param data table table of datas, same with message data
---@return boolean
function interaction:updateFollowUp(id, data)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	return self._parent._api:request('PATCH', format(endpoints.INTERACTION_FOLLOWUP_MODIFY, self._parent._slashid, self._token, id), data)
end

---Delete followup reply message.
---@param id string followup message id
---@return boolean
function interaction:deleteFollowUp(id)
	return self._parent._api:request('DELETE', format(endpoints.INTERACTION_FOLLOWUP_MODIFY, self._parent._slashid, self._token, id))
end

function interactionGetters:guild()
	return self._guild
end

function interactionGetters:channel()
	return self._channel
end

function interactionGetters:member()
	return self._member
end

function interactionGetters:type()
	return self._type
end

function interactionGetters:buttonId()
	return self._buttonId
end

function interactionGetters:id()
	return self._id
end

function interactionGetters:token()
	return self._token
end

function interactionGetters:version()
	return self._version
end

function interactionGetters:message()
	return self._message
end

function interactionGetters:user()
	return self._user
end

function interactionGetters:isComponent()
	return self._isComponent
end

function interactionGetters:parentInteraction()
	return self._parentInteraction
end

return interaction
