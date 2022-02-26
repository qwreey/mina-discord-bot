local API = require('discordia/libs/client/API')
local GroupChannel = require('discordia/libs/containers/GroupChannel')
local Guild = require('discordia/libs/containers/Guild')
local PrivateChannel = require('discordia/libs/containers/PrivateChannel')
local User = require('discordia/libs/containers/User')
local Webhook = require('discordia/libs/containers/Webhook')
local Relationship = require('discordia/libs/containers/Relationship')
local Cache = require('discordia/libs/iterables/Cache')
local WeakCache = require('discordia/libs/iterables/WeakCache')
local Emitter = require('discordia/libs/utils/Emitter')
local Logger = require('discordia/libs/utils/Logger')
local Mutex = require('discordia/libs/utils/Mutex')
local enums = require('discordia/libs/enums')
local logLevel = enums.logLevel
local VoiceManager = require('discordia/libs/voice/VoiceManager')
local discordia = require("discordia")
local classes = discordia.class.classes
local Client = classes.Client
local format = string.format

-- do not change these options here
-- pass a custom table on client initialization instead
local defaultOptions = {
	routeDelay = 250,
	maxRetries = 5,
	shardCount = 0,
	firstShard = 0,
	lastShard = -1,
	largeThreshold = 100,
	cacheAllMembers = false,
	autoReconnect = true,
	compress = true,
	bitrate = 64000,
	logFile = 'discordia.log',
	logLevel = logLevel.info,
	gatewayFile = 'gateway.json',
	dateTime = '%F %T',
	syncGuilds = false,
    wssProps = {},
}

local function parseOptions(customOptions)
	if type(customOptions) == 'table' then
		local options = {}
		for k, default in pairs(defaultOptions) do -- load options
			local custom = customOptions[k]
			if custom ~= nil then
				options[k] = custom
			else
				options[k] = default
			end
		end
		for k, v in pairs(customOptions) do -- validate options
			local default = type(defaultOptions[k])
			local custom = type(v)
			if default ~= custom then
				return error(format('invalid client option %q (%s expected, got %s)', k, default, custom), 3)
			end
			if custom == 'number' and (v < 0 or v % 1 ~= 0) then
				return error(format('invalid client option %q (number must be a positive integer)', k), 3)
			end
		end
		return options
	else
		return defaultOptions
	end
end

function Client:__init(options)
	Emitter.__init(self)
	options = parseOptions(options)
	self._options = options
	self._shards = {}
	self._api = API(self)
	self._mutex = Mutex()
	self._users = Cache({}, User, self)
	self._guilds = Cache({}, Guild, self)
	self._group_channels = Cache({}, GroupChannel, self)
	self._private_channels = Cache({}, PrivateChannel, self)
	self._relationships = Cache({}, Relationship, self)
	self._webhooks = WeakCache({}, Webhook, self) -- used for audit logs
	self._logger = Logger(options.logLevel, options.dateTime, options.logFile)
	self._voice = VoiceManager(self)
	self._role_map = {}
	self._emoji_map = {}
	self._channel_map = {}
	self._events = require('discordia/libs/client/EventHandler')
end
