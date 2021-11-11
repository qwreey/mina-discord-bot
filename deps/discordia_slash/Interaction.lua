local discordia = require("discordia")
local endpoints = require('./endpoints')
local enums = require('./enums')
local f = string.format
local Snowflake_m = discordia.class.classes.Snowflake
local IA, IAgetters = discordia.class('Interaction', Snowflake_m)

function IA:__init(data, parent)
	self._id = data.id
	self._parent = parent
	self._type = data.type
	self._token = data.token
	self._version = data.version

	local guildId = data.guild_id
	local member = data.member;
	local userId = (member and member.user.id) or data.user.id;
	local user = parent:getUser(userId);
	self._user = user;
	if guildId then
		local guild = parent:getGuild(guildId)
		if not guild then return parent:warning('Uncached Guild (%s) on INTERACTION_CREATE', guildId) end
		self._guild = guild
		self._member = guild:getMember(userId)
		self._channel = guild:getChannel(data.channel_id)
	else
		self._channel = parent:getChannel(userId) or user:getPrivateChannel();
	end
end

function IA:createResponse(type, data)
	self._type = type

	return self._parent._api:request('POST', f(endpoints.INTERACTION_RESPONSE, self._id, self._token), {
		type = type,
		data = data,
	})
end

local deferredChannelMessageWithSource = enums.interactionResponseType.deferredChannelMessageWithSource
local channelMessageWithSource = enums.interactionResponseType.channelMessageWithSource

function IA:ack()
	return self:createResponse(deferredChannelMessageWithSource)
end

function IA:reply(data, private)
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

function IA:update(data)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	return self._parent._api:request('PATCH', f(endpoints.INTERACTION_RESPONSE_MODIFY, self._parent._slashid, self._token), data)
end

function IA:delete()
	return self._parent._api:request('DELETE', f(endpoints.INTERACTION_RESPONSE_MODIFY, self._parent._slashid, self._token))
end

function IA:followUp(data, private)
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

	local res = self._parent._api:request('POST', f(endpoints.INTERACTION_FOLLOWUP_CREATE, self._parent._slashid, self._token), data)

	if res.id then
		local msg

		if not private then
			msg = self._channel:getMessage(res.id)
		end

		return res.id, msg, res
	end

	return res
end

function IA:updateFollowUp(id, data)
	if type(data) == "string" then
		data = {
			content = data
		}
	end

	return self._parent._api:request('PATCH', f(endpoints.INTERACTION_FOLLOWUP_MODIFY, self._parent._slashid, self._token, id), data)
end

function IA:deleteFollowUp(id)
	return self._parent._api:request('DELETE', f(endpoints.INTERACTION_FOLLOWUP_MODIFY, self._parent._slashid, self._token, id))
end

function IAgetters:guild()
	return self._guild
end

function IAgetters:channel()
	return self._channel
end

function IAgetters:member()
	return self._member
end

function IAgetters:user()
	return self._user
end

return IA