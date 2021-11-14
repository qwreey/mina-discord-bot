local discordia = require("discordia")
local endpoints = require('../endpoints')
local enums = require('../enums')
local format = string.format
local snowflake = discordia.class.classes.Snowflake
local deferredChannelMessageWithSource = enums.interactionResponseType.deferredChannelMessageWithSource
local channelMessageWithSource = enums.interactionResponseType.channelMessageWithSource

---@class interaction
---@field public message Message If this is message interaction (such as button), this is parent message of interaction else ApplicationCommand, this is nil
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
	local message = data.message
	local button = data.button
	local buttonId = button and button.custom_id

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
		channelObject = client:getChannel(userId) or user:getPrivateChannel()
	end
	messageObject = channelObject and message and channelObject._messages:_insert(message)

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
	self._message = messageObject
end

---Create a response to an Interaction from the gateway.
---@param type number type of response
---@param data table table of datas
---@return boolean
function interaction:createResponse(type, data)
	self._type = type

	return self._parent._api:request('POST', format(endpoints.INTERACTION_RESPONSE, self._id, self._token), {
		type = type,
		data = data,
	})
end

---Send act response.
---@return boolean
function interaction:ack()
	return self:createResponse(deferredChannelMessageWithSource)
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

return interaction
