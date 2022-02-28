--[=[
@c TextChannel x Channel
@t abc
@d Defines the base methods and properties for all Discord text channels.
]=]


local pathjoin = require('pathjoin')
local Resolver
local requireResolverPassed = pcall(function ()
	Resolver = require("discordia/libs/client/Resolver")
end)
if not requireResolverPassed then
	Resolver = require("./resolver")
end

local fs = require('fs')

local splitPath = pathjoin.splitPath
local insert, remove, concat = table.insert, table.remove, table.concat
local format = string.format
local readFileSync = fs.readFileSync

local function parseFile(obj, files)
	if type(obj) == 'string' then
		local data, err = readFileSync(obj)
		if not data then
			return nil, err
		end
		files = files or {}
		insert(files, {remove(splitPath(obj)), data})
	elseif type(obj) == 'table' and type(obj[1]) == 'string' and type(obj[2]) == 'string' then
		files = files or {}
		insert(files, obj)
	else
		return nil, 'Invalid file object: ' .. tostring(obj)
	end
	return files
end

local function parseMention(obj, mentions)
	if type(obj) == 'table' and obj.mentionString then
		mentions = mentions or {}
		insert(mentions, obj.mentionString)
	else
		return nil, 'Unmentionable object: ' .. tostring(obj)
	end
	return mentions
end

local function send(self,content)
	local data, err

	if type(content) == 'table' then

		---@diagnostic disable
		local tbl = content
		content = tbl.content

		if type(tbl.code) == 'string' then
			content = format('```%s\n%s\n```', tbl.code, content)
		elseif tbl.code == true then
			content = format('```\n%s\n```', content)
		end

		local mentions
		if tbl.mention then
			mentions, err = parseMention(tbl.mention)
			if err then
				self.client:error(("Error occurred while send message (parseMention Error %s)"):format(err))
				return nil, err
			end
		end
		if type(tbl.mentions) == 'table' then
			for _, mention in ipairs(tbl.mentions) do
				mentions, err = parseMention(mention, mentions)
				if err then
					self.client:error(("Error occurred while send message (parseMention Error %s)"):format(err))
					return nil, err
				end
			end
		end

		if mentions then
			insert(mentions, content)
			content = concat(mentions, ' ')
		end

		local files
		if tbl.file then
			files, err = parseFile(tbl.file)
			if err then
				self.client:error(("Error occurred while send message (parseFile Error %s)"):format(err))
				return nil, err
			end
		end
		if type(tbl.files) == 'table' then
			for _, file in ipairs(tbl.files) do
				files, err = parseFile(file, files)
				if err then
					self.client:error(("Error occurred while send message (parseFile Error %s)"):format(err))
					return nil, err
				end
			end
		end

		local refMessage, refMention
		if tbl.reference then
			refMessage = {message_id = Resolver.messageId(tbl.reference.message)}
			refMention = {
				parse = {'users', 'roles', 'everyone'},
				replied_user = not not tbl.reference.mention,
			}
		end

		data, err = self.client._api:createMessage(self._id, {
			content = content,
			tts = tbl.tts,
			nonce = tbl.nonce,
			embed = tbl.embed,
			message_reference = refMessage,
			allowed_mentions = refMention,
			components = tbl.components,
		}, files)

	else

		data, err = self.client._api:createMessage(self._id, {content = content})

	end

	if data then
		return self._messages:_insert(data)
	else
		self.client:error(("Error occurred while send message (API Error %s)"):format(err))
		return nil, err
	end

end

local discordia = require("discordia")
local classes = discordia.class.classes
local TextChannel = classes.TextChannel
local PrivateChannel = classes.PrivateChannel
local GuildTextChannel = classes.GuildTextChannel

TextChannel.send = send;
PrivateChannel.send = send;
GuildTextChannel.send = send;
