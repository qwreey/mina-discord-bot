local discordia = require("discordia")
local endpoints = require('../../endpoints')
local format = string.format
local applicationCommand = require('./applicationCommand')
local interaction = require('../interaction')
local client_m = discordia.Client
local guild_m = discordia.class.classes.Guild
local cache_m = discordia.class.classes.Cache
local enums = require('../../enums')
local eventHandler = require("../../eventHandler")

local typeConverter = {
	[enums.optionType.string] = function(val) return val end,
	[enums.optionType.integer] = function(val) return val end,
	[enums.optionType.boolean] = function(val) return val end,
	[enums.optionType.user] = function(val, args) return args and args:getMember(val) end,
	[enums.optionType.channel] = function(val, args) return args and args:getChannel(val) end,
	[enums.optionType.role] = function(val, args) return args and args:getRole(val) end,
}

local subCommand = enums.optionType.subCommand
local subCommandGroup = enums.optionType.subCommandGroup

local function makeParams(data, guild, output)
	if not data then return {} end
	output = output or {}

	for k, v in ipairs(data) do
		if v.type == subCommand or v.type == subCommandGroup then
			local t = {}
			output[v.name] = t
			makeParams(v.options, guild, t)
		else
			output[v.name] = typeConverter[v.type](v.value, guild)
		end
	end

	return output
end

eventHandler.make("INTERACTION_CREATE",function (args, client)
	if args.type ~= 2 then
		return false
	end
	local data = args.data
	local cmd = client:getSlashCommand(data.id)
	if not cmd then return client:warning('Uncached slash command (%s) on INTERACTION_CREATE', data.id) end
	if data.name ~= cmd._name then return client:warning('Slash command %s "%s" name doesn\'t match with interaction response, got "%s"! Guild %s, channel %s, member %s', cmd._id, cmd._name, data.name, args.guild_id, args.channel_id, args.member.user.id) end
	local ia = interaction(args, client)
	local params = makeParams(data.options, ia.guild)
	local cb = cmd._callback
	if not cb then return client:warning('Unhandled slash command interaction: %s "%s" (%s)!', cmd._id, cmd._name, cmd._guild and "Guild " .. cmd._guild.id or "Global") end
	coroutine.wrap(cb)(ia, params, cmd)
	return true
end)

function client_m:slashCommand(data)
	local found

	if not self._globalCommands then
		self:getSlashCommands()
	end

	do
		local name = data.name

		for _, v in pairs(self._globalCommands) do
			if v._name == name then
				found = v
				break
			end
		end
	end

	local cmd = applicationCommand(data, self)

	if found then
		if not found:_compare(cmd) then
			found:_merge(cmd)
		elseif not found._callback then
			found._callback = cmd._callback
		end

		return found
	else
		if cmd:publish() then
			self._globalCommands:_insert(cmd)
		else
			return nil
		end
	end

	return cmd
end

function guild_m:slashCommand(data)
	local found

	if not self._slashCommands then
		self:getSlashCommands()
	end

	do
		local name = data.name

		for _, v in pairs(self._slashCommands) do
			if v._name == name then
				found = v
				break
			end
		end
	end

	local cmd = applicationCommand(data, self)

	if found then
		if not found:_compare(cmd) then
			found:_merge(cmd)
		elseif not found._callback then
			found._callback = cmd._callback
		end

		return found
	else
		if cmd:publish() then
			self._slashCommands:_insert(cmd)
		else
			return nil
		end
	end

	return cmd
end

function client_m:getSlashCommands()
	local list, err = self._api:request('GET', format(endpoints.COMMANDS, self._slashid))
	if not list then return nil, err end
	local cache = cache_m(list, applicationCommand, self)
	self._globalCommands = cache

	return cache
end

function guild_m:getSlashCommands()
	local list, err = self.client._api:request('GET', format(endpoints.COMMANDS_GUILD, self.client._slashid, self.id))
	if not list then return nil, err end
	local cache = cache_m(list, applicationCommand, self)
	self._slashCommands = cache
	self.client._guildCommands[self] = cache

	return cache
end

function client_m:getSlashCommand(id)
	if not self._globalCommands then
		self:getSlashCommands()
	end

	local g = self._globalCommands:get(id)
	if g then return g end

	for _, v in pairs(self._guildCommands) do
		g = v:get(id)
		if g then return g end
	end

	return nil
end

return function (self)
	if self._slashCommandInjected then
		return
	end
	self._slashCommandsInjected = true

	self:once("ready", function()
		self._slashid = self:getApplicationInformation().id
		self._globalCommands = {}
		self._guildCommands = {}
		self:getSlashCommands()
		self:emit("slashCommandsReady")
		self:emit("slashCommandsCommited")
	end)

	return self
end
