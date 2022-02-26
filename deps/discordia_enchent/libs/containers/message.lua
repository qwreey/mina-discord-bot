--[=[
@c Message x Snowflake
@d Represents a text message sent in a Discord text channel. Messages can contain
simple content strings, rich embeds, attachments, or reactions.
]=]

local discordia = require("discordia")
local classes = discordia.class.classes

local json = require('json')
local insert = table.insert
local null = json.null

local Message = classes.Message

local function parseMentions(content, pattern)
	if not content:find('%b<>') then return {} end
	local mentions, seen = {}, {}
	for id in content:gmatch(pattern) do
		if not seen[id] then
			insert(mentions, id)
			seen[id] = true
		end
	end
	return mentions
end

function Message:_loadMore(data)

	local mentions = {}
	if data.mentions then
		for _, user in ipairs(data.mentions) do
			mentions[user.id] = true
			if user.member then
				user.member.user = user
				self._parent._parent._members:_insert(user.member)
			else
				self.client._users:_insert(user)
			end
		end
	end

	if data.referenced_message and data.referenced_message ~= null then
		if mentions[data.referenced_message.author.id] then
			self._reply_target = data.referenced_message.author.id
		end
		self._referencedMessage = self._parent._messages:_insert(data.referenced_message)
	end

	local content = data.content
	if content then
		if self._mentioned_users then
			self._mentioned_users._array = parseMentions(content, '<@!?(%d+)>')
			if self._reply_target then
				insert(self._mentioned_users._array, 1, self._reply_target)
			end
		end
		if self._mentioned_roles then
			self._mentioned_roles._array = parseMentions(content, '<@&(%d+)>')
		end
		if self._mentioned_channels then
			self._mentioned_channels._array = parseMentions(content, '<#(%d+)>')
		end
		if self._mentioned_emojis then
			self._mentioned_emojis._array = parseMentions(content, '<a?:[%w_]+:(%d+)>')
		end
		self._clean_content = nil
	end

	if data.embeds then
		self._embeds = #data.embeds > 0 and data.embeds or nil
	end

	if data.attachments then
		self._attachments = #data.attachments > 0 and data.attachments or nil
	end

    if data.components then
        self._components = #data.components > 0 and data.components or nil
    end

end

--[=[
@m update
@t http
@p data table
@r boolean
@d Sets multiple properties of the message at the same time using a table similar
to the one supported by `TextChannel.send`, except only `content` and `embed`
are valid fields; `mention(s)`, `file(s)`, etc are not supported. The message
must be authored by the current user. (ie: you cannot change the embed of messages
sent by other users).
]=]
function Message:update(data)
	return self:_modify({
		content = data.content or null,
		embed = data.embed or null,
        components = data.components or null,
	})
end

--[=[@p components of this message.]=]
function Message.__getters.components(self)
	return self._components
end

return Message
