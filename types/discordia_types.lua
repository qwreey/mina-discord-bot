-- Do not touch, automatically generated!
-- Generated on Tue Jan 26 15:33:14 2021

---Represents a Discord guild member. Though one user may be a member in more than one guild, each presence is represented by a different member object associated with that guild. Note that any method or property that exists for the User class is also available in the Member class.
---@class Member: UserPresence
---@field public roles ArrayIterable An iterable array of guild roles that the member has. This does not explicitly include the default everyone role. Object order is not guaranteed.
---@field public name string If the member has a nickname, then this will be equivalent to that nickname. Otherwise, this is equivalent to `Member.user.username`.
---@field public nickname string | nil The member's nickname, if one is set.
---@field public joinedAt string | nil The date and time at which the current member joined the guild, represented as an ISO 8601 string plus microseconds when available. Member objects generated via presence updates lack this property.
---@field public premiumSince string | nil The date and time at which the current member boosted the guild, represented as an ISO 8601 string plus microseconds when available.
---@field public voiceChannel GuildVoiceChannel | nil The voice channel to which this member is connected in the current guild.
---@field public muted boolean Whether the member is voice muted in its guild.
---@field public deafened boolean Whether the member is voice deafened in its guild.
---@field public guild Guild The guild in which this member exists.
---@field public highestRole Role The highest positioned role that the member has. If the member has no explicit roles, then this is equivalent to `Member.guild.defaultRole`.
---@overload fun():Member
local Member = {}
---Returns a color object that represents the member's color as determined by its highest colored role. If the member has no colored roles, then the default color with a value of 0 is returned.
---@return Color
function Member:getColor() end
---Checks whether the member has a specific permission. If `channel` is omitted, then only guild-level permissions are checked. This is a relatively expensive operation. If you need to check multiple permissions at once, use the `getPermissions` method and check the resulting object.
---@param channel GuildChannel
---@param perm Permissions | number
---@return boolean
function Member:hasPermission(channel, perm) end
---Returns a permissions object that represents the member's total permissions for the guild, or for a specific channel if one is provided. If you just need to check one permission, use the `hasPermission` method.
---@param channel GuildChannel
---@return Permissions
function Member:getPermissions(channel) end
---Adds a role to the member. If the member already has the role, then no action is taken. Note that the everyone role cannot be explicitly added.
---@param id Role | string
---@return boolean
function Member:addRole(id) end
---Removes a role from the member. If the member does not have the role, then no action is taken. Note that the everyone role cannot be removed.
---@param id Role | string
---@return boolean
function Member:removeRole(id) end
---Checks whether the member has a specific role. This will return true for the guild's default role in addition to any explicitly assigned roles.
---@param id Role | string
---@return boolean
function Member:hasRole(id) end
---Sets the member's nickname. This must be between 1 and 32 characters in length. Pass `nil` to remove the nickname.
---@param nick string
---@return boolean
function Member:setNickname(nick) end
---Moves the member to a new voice channel, but only if the member has an active voice connection in the current guild. Due to complexities in voice state handling, the member's `voiceChannel` property will update asynchronously via WebSocket; not as a result of the HTTP request.
---@param id Channel | string
---@return boolean
function Member:setVoiceChannel(id) end
---Mutes the member in its guild.
---@return boolean
function Member:mute() end
---Unmutes the member in its guild.
---@return boolean
function Member:unmute() end
---Deafens the member in its guild.
---@return boolean
function Member:deafen() end
---Undeafens the member in its guild.
---@return boolean
function Member:undeafen() end
---Equivalent to `Member.guild:kickUser(Member.user, reason)`
---@param reason string
---@return boolean
function Member:kick(reason) end
---Equivalent to `Member.guild:banUser(Member.user, reason, days)`
---@param reason string
---@param days number
---@return boolean
function Member:ban(reason, days) end
---Equivalent to `Member.guild:unbanUser(Member.user, reason)`
---@param reason string
---@return boolean
function Member:unban(reason) end
---Create a new Member
---@return Member
function Member:__init() end

---Defines the base methods and properties for all Discord objects and structures. Container classes are constructed internally with information received from Discord and should never be manually constructed.
---@class Container
---@field public client Client A shortcut to the client object to which this container is visible.
---@field public parent Container | Client The parent object of to which this container is a child. For example, the parent of a role is the guild in which the role exists.
---@overload fun():Container
local Container = {}
---Defines the behavior of the `==` operator. Allows containers to be directly compared according to their type and `__hash` return values.
---@return boolean
function Container:__eq() end
---Defines the behavior of the `tostring` function. All containers follow the format `ClassName: hash`.
---@return string
function Container:__tostring() end
---Create a new Container
---@return Container
function Container:__init() end

---Iterable class that contains objects in a constant, ordered fashion, although the order may change if the internal array is modified. Some versions may use a map function to shape the objects before they are accessed.
---@class ArrayIterable: Iterable
---@field public first any The first object in the array
---@field public last any The last object in the array
---@overload fun():ArrayIterable
local ArrayIterable = {}
---Returns an iterator for all contained objects in a consistent order.
---@return function
function ArrayIterable:iter() end
---Create a new ArrayIterable
---@return ArrayIterable
function ArrayIterable:__init() end

---Iterable class that wraps another iterable and serves a subset of the objects that the original iterable contains.
---@class FilteredIterable: Iterable
---@overload fun():FilteredIterable
local FilteredIterable = {}
---Returns an iterator that returns all contained objects. The order of the objects is not guaranteed.
---@return function
function FilteredIterable:iter() end
---Create a new FilteredIterable
---@return FilteredIterable
function FilteredIterable:__init() end

---Represents a handle used to send webhook messages to a guild text channel in a one-way fashion. This class defines methods and properties for managing the webhook, not for sending messages.
---@class Webhook: Snowflake
---@field public guildId string The ID of the guild in which this webhook exists.
---@field public channelId string The ID of the channel in which this webhook exists.
---@field public user User | nil The user that created this webhook.
---@field public token string The token that can be used to access this webhook.
---@field public name string The name of the webhook. This should be between 2 and 32 characters in length.
---@field public type number The type of the webhook. See the `webhookType` enum for a human-readable representation.
---@field public avatar string | nil The hash for the webhook's custom avatar, if one is set.
---@field public avatarURL string Equivalent to the result of calling `Webhook:getAvatarURL()`.
---@field public defaultAvatar number The default avatar for the webhook. See the `defaultAvatar` enumeration for a human-readable representation. This should always be `defaultAvatar.blurple`.
---@field public defaultAvatarURL string Equivalent to the result of calling `Webhook:getDefaultAvatarURL()`.
---@overload fun():Webhook
local Webhook = {}
---Returns a URL that can be used to view the webhooks's full avatar. If provided, the size must be a power of 2 while the extension must be a valid image format. If the webhook does not have a custom avatar, the default URL is returned.
---@param size number
---@param ext string
---@return string
function Webhook:getAvatarURL(size, ext) end
---Returns a URL that can be used to view the webhooks's default avatar.
---@param size number
---@return string
function Webhook:getDefaultAvatarURL(size) end
---Sets the webhook's name. This must be between 2 and 32 characters in length.
---@param name string
---@return boolean
function Webhook:setName(name) end
---Sets the webhook's avatar. If `nil` is passed, the avatar is removed.
---@param avatar string
---@return boolean
function Webhook:setAvatar(avatar) end
---Permanently deletes the webhook. This cannot be undone!
---@return boolean
function Webhook:delete() end
---Create a new Webhook
---@return Webhook
function Webhook:__init() end

---The main point of entry into a Discordia application. All data relevant to Discord is accessible through a client instance or its child objects after a connection to Discord is established with the `run` method. In other words, client data should not be expected and most client methods should not be called until after the `ready` event is received. Base emitter methods may be called at any time. See [[client options]].
---@class Client: Emitter
---@field public shardCount number | nil The number of shards that this client is managing.
---@field public totalShardCount number | nil The total number of shards that the current user is on.
---@field public user User | nil User object representing the current user.
---@field public owner User | nil User object representing the current user's owner.
---@field public verified boolean | nil Whether the current user's owner's account is verified.
---@field public mfaEnabled boolean | nil Whether the current user's owner's account has multi-factor (or two-factor) authentication enabled. This is equivalent to `verified`
---@field public email string | nil The current user's owner's account's email address (user-accounts only).
---@field public guilds Cache An iterable cache of all guilds that are visible to the client. Note that the guilds present here correspond to which shards the client is managing. If all shards are managed by one client, then all guilds will be present.
---@field public users Cache An iterable cache of all users that are visible to the client. To access a user that may exist but is not cached, use `Client:getUser`.
---@field public privateChannels Cache An iterable cache of all private channels that are visible to the client. The channel must exist and must be open for it to be cached here. To access a private channel that may exist but is not cached, `User:getPrivateChannel`.
---@field public groupChannels Cache An iterable cache of all group channels that are visible to the client. Only user-accounts should have these.
---@field public relationships Cache An iterable cache of all relationships that are visible to the client. Only user-accounts should have these.
---@overload fun(options: table):Client
local Client = {}
---Authenticates the current user via HTTPS and launches as many WSS gateway shards as are required or requested. By using coroutines that are automatically managed by Luvit libraries and a libuv event loop, multiple clients per process and multiple shards per client can operate concurrently. This should be the last method called after all other code and event handlers have been initialized. If a presence table is provided, it will act as if the user called `setStatus` and `setGame` after `run`.
---@param token string
---@param presence table
---@return nil
function Client:run(token, presence) end
---Disconnects all shards and effectively stop their loops. This does not empty any data that the client may have cached.
---@return nil
function Client:stop() end
---Sets the client's username. This must be between 2 and 32 characters in length. This does not change the application name.
---@param username string
---@return boolean
function Client:setUsername(username) end
---Sets the client's avatar. To remove the avatar, pass an empty string or nil. This does not change the application image.
---@param avatar string
---@return boolean
function Client:setAvatar(avatar) end
---Creates a new guild. The name must be between 2 and 100 characters in length. This method may not work if the current user is in too many guilds. Note that this does not return the created guild object; wait for the corresponding `guildCreate` event if you need the object.
---@param name string
---@return boolean
function Client:createGuild(name) end
---Creates a new group channel. This method is only available for user accounts.
---@return GroupChannel
function Client:createGroupChannel() end
---Gets a webhook object by ID. This always makes an HTTP request to obtain a static object that is not cached and is not updated by gateway events.
---@param id string
---@return Webhook
function Client:getWebhook(id) end
---Gets an invite object by code. This always makes an HTTP request to obtain a static object that is not cached and is not updated by gateway events.
---@param code string
---@param counts boolean
---@return Invite
function Client:getInvite(code, counts) end
---Gets a user object by ID. If the object is already cached, then the cached object will be returned; otherwise, an HTTP request is made. Under circumstances which should be rare, the user object may be an old version, not updated by gateway events.
---@param id User | string
---@return User
function Client:getUser(id) end
---Gets a guild object by ID. The current user must be in the guild and the client must be running the appropriate shard that serves this guild. This method never makes an HTTP request to obtain a guild.
---@param id Guild | string
---@return Guild
function Client:getGuild(id) end
---Gets a channel object by ID. For guild channels, the current user must be in the channel's guild and the client must be running the appropriate shard that serves the channel's guild. For private channels, the channel must have been previously opened and cached. If the channel is not cached, `User:getPrivateChannel` should be used instead.
---@param id Channel | string
---@return Channel
function Client:getChannel(id) end
---Gets a role object by ID. The current user must be in the role's guild and the client must be running the appropriate shard that serves the role's guild.
---@param id Role | string
---@return Role
function Client:getRole(id) end
---Gets an emoji object by ID. The current user must be in the emoji's guild and the client must be running the appropriate shard that serves the emoji's guild.
---@param id Emoji | string
---@return Emoji
function Client:getEmoji(id) end
---Returns a raw data table that contains a list of voice regions as provided by Discord, with no formatting beyond what is provided by the Discord API.
---@return table
function Client:listVoiceRegions() end
---Returns a raw data table that contains a list of connections as provided by Discord, with no formatting beyond what is provided by the Discord API. This is unrelated to voice connections.
---@return table
function Client:getConnections() end
---Returns a raw data table that contains information about the current OAuth2 application, with no formatting beyond what is provided by the Discord API.
---@return table
function Client:getApplicationInformation() end
---Sets the current users's status on all shards that are managed by this client. See the `status` enumeration for acceptable status values.
---@param status string
---@return nil
function Client:setStatus(status) end
---Sets the current users's game on all shards that are managed by this client. If a string is passed, it is treated as the game name. If a table is passed, it must have a `name` field and may optionally have a `url` or `type` field. Pass `nil` to remove the game status.
---@param game string | table
---@return nil
function Client:setGame(game) end
---Set the current user's AFK status on all shards that are managed by this client. This generally applies to user accounts and their push notifications.
---@param afk boolean
---@return nil
function Client:setAFK(afk) end
---Create a new Client
---@param options table
---@return Client
function Client:__init(options) end

---Iterable class that holds references to Discordia Class objects in no particular order.
---@class Cache: Iterable
---@overload fun():Cache
local Cache = {}
---Returns an individual object by key, where the key should match the result of calling `__hash` on the contained objects. Unlike Iterable:get, this method operates with O(1) complexity.
---@param k any
---@return any
function Cache:get(k) end
---Returns an iterator that returns all contained objects. The order of the objects is not guaranteed.
---@return function
function Cache:iter() end
---Create a new Cache
---@return Cache
function Cache:__init() end

---Represents an entry made into a guild's audit log.
---@class AuditLogEntry: Snowflake
---@field public changes table | nil A table of audit log change objects. The key represents the property of the changed target and the value contains a table of `new` and possibly `old`, representing the property's new and old value.
---@field public options table | nil A table of optional audit log information.
---@field public actionType number The action type. Use the `actionType `enumeration for a human-readable representation.
---@field public targetId string | nil The Snowflake ID of the affected entity. Will be `nil` for certain targets.
---@field public userId string The Snowflake ID of the user who commited the action.
---@field public reason string | nil The reason provided by the user for the change.
---@field public guild Guild The guild in which this audit log entry was found.
---@overload fun():AuditLogEntry
local AuditLogEntry = {}
---Returns two tables of the target's properties before the change, and after the change.
---@return table table
function AuditLogEntry:getBeforeAfter() end
---Gets the target object of the affected entity. The returned object can be: [[Guild]], [[GuildChannel]], [[User]], [[Member]], [[Role]], [[Webhook]], [[Emoji]], nil
---@return any
function AuditLogEntry:getTarget() end
---Gets the user who performed the changes.
---@return User
function AuditLogEntry:getUser() end
---Gets the member object of the user who performed the changes.
---@return Member | nil
function AuditLogEntry:getMember() end
---Create a new AuditLogEntry
---@return AuditLogEntry
function AuditLogEntry:__init() end

---Represents a Discord user's presence data, either plain game or streaming presence or a rich presence. Most if not all properties may be nil.
---@class Activity
---@field public start number | nil The Unix timestamp for when this Rich Presence activity was started.
---@field public stop number | nil The Unix timestamp for when this Rich Presence activity was stopped.
---@field public name string | nil The game that the user is currently playing.
---@field public type number | nil The type of user's game status. See the `activityType` enumeration for a human-readable representation.
---@field public url string | nil The URL that is set for a user's streaming game status.
---@field public applicationId string | nil The application id controlling this Rich Presence activity.
---@field public state string | nil string for the Rich Presence state section.
---@field public details string | nil string for the Rich Presence details section.
---@field public textSmall string | nil string for the Rich Presence small image text.
---@field public textLarge string | nil string for the Rich Presence large image text.
---@field public imageSmall string | nil URL for the Rich Presence small image.
---@field public imageLarge string | nil URL for the Rich Presence large image.
---@field public partyId string | nil Party id for this Rich Presence.
---@field public partySize number | nil Size of the Rich Presence party.
---@field public partyMax number | nil Max size for the Rich Presence party.
---@field public emojiId string | nil The ID of the emoji used in this presence if one is set and if it is a custom emoji.
---@field public emojiName string | nil The name of the emoji used in this presence if one is set and if it has a custom emoji. This will be the raw string for a standard emoji.
---@field public emojiHash string | nil The discord hash for the emoji used in this presence if one is set. This will be the raw string for a standard emoji.
---@field public emojiURL string | nil string The URL that can be used to view a full version of the emoji used in this activity if one is set and if it is a custom emoji.
---@overload fun():Activity
local Activity = {}
---Create a new Activity
---@return Activity
function Activity:__init() end

---Represents a Discord guild ban. Essentially a combination of the banned user and a reason explaining the ban, if one was provided.
---@class Ban: Container
---@field public reason string | nil The reason for the ban, if one was set. This should be from 1 to 512 characters in length.
---@field public guild Guild The guild in which this ban object exists.
---@field public user User The user that this ban object represents.
---@overload fun():Ban
local Ban = {}
---Returns `Ban.user.id`
---@return string
function Ban:__hash() end
---Deletes the ban object, unbanning the corresponding user. Equivalent to `Ban.guild:unbanUser(Ban.user)`.
---@return boolean
function Ban:delete() end
---Create a new Ban
---@return Ban
function Ban:__init() end

---Iterable class that wraps another cache. Objects added to or removed from a secondary cache are also automatically added to or removed from the primary cache that it wraps.
---@class SecondaryCache: Iterable
---@overload fun():SecondaryCache
local SecondaryCache = {}
---Returns an individual object by key, where the key should match the result of calling `__hash` on the contained objects. Unlike the default version, this method operates with O(1) complexity.
---@param k any
---@return any
function SecondaryCache:get(k) end
---Returns an iterator that returns all contained objects. The order of the objects is not guaranteed.
---@return function
function SecondaryCache:iter() end
---Create a new SecondaryCache
---@return SecondaryCache
function SecondaryCache:__init() end

---Represents a voice channel in a Discord guild, where guild members can connect and communicate via voice chat.
---@class GuildVoiceChannel: GuildChannel
---@field public bitrate number The channel's bitrate in bits per second (bps). This should be between 8000 and 96000 (or 128000 for partnered servers).
---@field public userLimit number The amount of users allowed to be in this channel. Users with `moveMembers` permission ignore this limit.
---@field public connectedMembers TableIterable An iterable of all users connected to the channel.
---@field public connection VoiceConnection | nil The VoiceConnection for this channel if one exists.
---@overload fun():GuildVoiceChannel
local GuildVoiceChannel = {}
---Sets the channel's audio bitrate in bits per second (bps). This must be between 8000 and 96000 (or 128000 for partnered servers). If `nil` is passed, the default is set, which is 64000.
---@param bitrate number
---@return boolean
function GuildVoiceChannel:setBitrate(bitrate) end
---Sets the channel's user limit. This must be between 0 and 99 (where 0 is unlimited). If `nil` is passed, the default is set, which is 0.
---@param user_limit number
---@return boolean
function GuildVoiceChannel:setUserLimit(user_limit) end
---Join this channel and form a connection to the Voice Gateway.
---@return VoiceConnection
function GuildVoiceChannel:join() end
---Leave this channel if there is an existing voice connection to it. Equivalent to GuildVoiceChannel.connection:close()
---@return boolean
function GuildVoiceChannel:leave() end
---Create a new GuildVoiceChannel
---@return GuildVoiceChannel
function GuildVoiceChannel:__init() end

---Defines the base methods and properties for all Discord text channels.
---@class TextChannel: Channel
---@field public messages WeakCache An iterable weak cache of all messages that are visible to the client. Messages that are not referenced elsewhere are eventually garbage collected. To access a message that may exist but is not cached, use `TextChannel:getMessage`.
---@overload fun():TextChannel
local TextChannel = {}
---Gets a message object by ID. If the object is already cached, then the cached object will be returned; otherwise, an HTTP request is made.
---@param id Message | string
---@return Message
function TextChannel:getMessage(id) end
---Returns the first message found in the channel, if any exist. This is not a cache shortcut; an HTTP request is made each time this method is called.
---@return Message
function TextChannel:getFirstMessage() end
---Returns the last message found in the channel, if any exist. This is not a cache shortcut; an HTTP request is made each time this method is called.
---@return Message
function TextChannel:getLastMessage() end
---Returns a newly constructed cache of between 1 and 100 (default = 50) message objects found in the channel. While the cache will never automatically gain or lose objects, the objects that it contains may be updated by gateway events.
---@param limit number
---@return SecondaryCache
function TextChannel:getMessages(limit) end
---Returns a newly constructed cache of between 1 and 100 (default = 50) message objects found in the channel after a specific id. While the cache will never automatically gain or lose objects, the objects that it contains may be updated by gateway events.
---@param id Message | string
---@param limit number
---@return SecondaryCache
function TextChannel:getMessagesAfter(id, limit) end
---Returns a newly constructed cache of between 1 and 100 (default = 50) message objects found in the channel before a specific id. While the cache will never automatically gain or lose objects, the objects that it contains may be updated by gateway events.
---@param id Message | string
---@param limit number
---@return SecondaryCache
function TextChannel:getMessagesBefore(id, limit) end
---Returns a newly constructed cache of between 1 and 100 (default = 50) message objects found in the channel around a specific point. While the cache will never automatically gain or lose objects, the objects that it contains may be updated by gateway events.
---@param id Message | string
---@param limit number
---@return SecondaryCache
function TextChannel:getMessagesAround(id, limit) end
---Returns a newly constructed cache of up to 50 messages that are pinned in the channel. While the cache will never automatically gain or lose objects, the objects that it contains may be updated by gateway events.
---@return SecondaryCache
function TextChannel:getPinnedMessages() end
---Indicates in the channel that the client's user "is typing".
---@return boolean
function TextChannel:broadcastTyping() end
---Sends a message to the channel. If `content` is a string, then this is simply sent as the message content. If it is a table, more advanced formatting is allowed. See [[managing messages]] for more information.
---@param content string | table
---@return Message
function TextChannel:send(content) end
---Sends a message to the channel with content formatted with `...` via `string.format`
---@param content string
---@vararg any
---@return Message
function TextChannel:sendf(content, ...) end
---Create a new TextChannel
---@return TextChannel
function TextChannel:__init() end

---Used to periodically execute code according to the ticking of the system clock instead of arbitrary interval.
---@class Clock: Emitter
---@overload fun():Clock
local Clock = {}
---Starts the main loop for the clock. If a truthy argument is passed, then UTC time is used; otherwise, local time is used. As the clock ticks, an event is emitted for every `os.date` value change. The event name is the key of the value that changed and the event argument is the corresponding date table.
---@param utc boolean
---@return nil
function Clock:start(utc) end
---Stops the main loop for the clock.
---@return nil
function Clock:stop() end
---Create a new Clock
---@return Clock
function Clock:__init() end

---Iterable class that wraps a basic Lua table, where order is not guaranteed. Some versions may use a map function to shape the objects before they are accessed.
---@class TableIterable: Iterable
---@overload fun():TableIterable
local TableIterable = {}
---Returns an iterator that returns all contained objects. The order of the objects is not guaranteed.
---@return function
function TableIterable:iter() end
---Create a new TableIterable
---@return TableIterable
function TableIterable:__init() end

---Represents an object that is used to allow or deny specific permissions for a role or member in a Discord guild channel.
---@class PermissionOverwrite: Snowflake
---@field public type string The overwrite type; either "role" or "member".
---@field public channel GuildChannel The channel in which this overwrite exists.
---@field public guild Guild The guild in which this overwrite exists. Equivalent to `PermissionOverwrite.channel.guild`.
---@field public allowedPermissions number The number representing the total permissions allowed by this overwrite.
---@field public deniedPermissions number The number representing the total permissions denied by this overwrite.
---@overload fun():PermissionOverwrite
local PermissionOverwrite = {}
---Deletes the permission overwrite. This can be undone by creating a new version of the same overwrite.
---@return boolean
function PermissionOverwrite:delete() end
---Returns the object associated with this overwrite, either a role or member. This may make an HTTP request if the object is not cached.
---@return Role | Member
function PermissionOverwrite:getObject() end
---Returns a permissions object that represents the permissions that this overwrite explicitly allows.
---@return Permissions
function PermissionOverwrite:getAllowedPermissions() end
---Returns a permissions object that represents the permissions that this overwrite explicitly denies.
---@return Permissions
function PermissionOverwrite:getDeniedPermissions() end
---Sets the permissions that this overwrite explicitly allows and denies. This method does NOT resolve conflicts. Please be sure to use the correct parameters.
---@param allowed Permissions[] | number[]
---@param denied Permissions[] | number[]
---@return boolean
function PermissionOverwrite:setPermissions(allowed, denied) end
---Sets the permissions that this overwrite explicitly allows.
---@param allowed Permissions[] | number[]
---@return boolean
function PermissionOverwrite:setAllowedPermissions(allowed) end
---Sets the permissions that this overwrite explicitly denies.
---@param denied Permissions[] | number[]
---@return boolean
function PermissionOverwrite:setDeniedPermissions(denied) end
---Allows individual permissions in this overwrite.
---@vararg number
---@return boolean
function PermissionOverwrite:allowPermissions(...) end
---Denies individual permissions in this overwrite.
---@vararg number
---@return boolean
function PermissionOverwrite:denyPermissions(...) end
---Clears individual permissions in this overwrite.
---@vararg number
---@return boolean
function PermissionOverwrite:clearPermissions(...) end
---Allows all permissions in this overwrite.
---@return boolean
function PermissionOverwrite:allowAllPermissions() end
---Denies all permissions in this overwrite.
---@return boolean
function PermissionOverwrite:denyAllPermissions() end
---Clears all permissions in this overwrite.
---@return boolean
function PermissionOverwrite:clearAllPermissions() end
---Create a new PermissionOverwrite
---@return PermissionOverwrite
function PermissionOverwrite:__init() end

---Represents a channel category in a Discord guild, used to organize individual text or voice channels in that guild.
---@class GuildCategoryChannel: GuildChannel
---@field public textChannels FilteredIterable Iterable of all textChannels in the Category.
---@field public voiceChannels FilteredIterable Iterable of all voiceChannels in the Category.
---@overload fun():GuildCategoryChannel
local GuildCategoryChannel = {}
---Creates a new GuildTextChannel with this category as it's parent. Similar to `Guild:createTextChannel(name)`
---@param name string
---@return GuildTextChannel
function GuildCategoryChannel:createTextChannel(name) end
---Creates a new GuildVoiceChannel with this category as it's parent. Similar to `Guild:createVoiceChannel(name)`
---@param name string
---@return GuildVoiceChannel
function GuildCategoryChannel:createVoiceChannel(name) end
---Create a new GuildCategoryChannel
---@return GuildCategoryChannel
function GuildCategoryChannel:__init() end

---Represents a text channel in a Discord guild, where guild members and webhooks can send and receive messages.
---@class GuildTextChannel: GuildChannel: TextChannel
---@field public topic string | nil The channel's topic. This should be between 1 and 1024 characters.
---@field public nsfw boolean Whether this channel is marked as NSFW (not safe for work).
---@field public rateLimit number Slowmode rate limit per guild member.
---@field public isNews boolean Whether this channel is a news channel of type 5.
---@field public members FilteredIterable A filtered iterable of guild members that have permission to read this channel. If you want to check whether a specific member has permission to read this channel, it would be better to get the member object elsewhere and use `Member:hasPermission` rather than check whether the member exists here.
---@overload fun():GuildTextChannel
local GuildTextChannel = {}
---Creates a webhook for this channel. The name must be between 2 and 32 characters in length.
---@param name string
---@return Webhook
function GuildTextChannel:createWebhook(name) end
---Returns a newly constructed cache of all webhook objects for the channel. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects.
---@return Cache
function GuildTextChannel:getWebhooks() end
---Bulk deletes multiple messages, from 2 to 100, from the channel. Messages over 2 weeks old cannot be deleted and will return an error.
---@param messages Message[] | string[]
---@return boolean
function GuildTextChannel:bulkDelete(messages) end
---Sets the channel's topic. This must be between 1 and 1024 characters. Pass `nil` to remove the topic.
---@param topic string
---@return boolean
function GuildTextChannel:setTopic(topic) end
---Sets the channel's slowmode rate limit in seconds. This must be between 0 and 120. Passing 0 or `nil` will clear the limit.
---@param limit number
---@return boolean
function GuildTextChannel:setRateLimit(limit) end
---Enables the NSFW setting for the channel. NSFW channels are hidden from users until the user explicitly requests to view them.
---@return boolean
function GuildTextChannel:enableNSFW() end
---Disables the NSFW setting for the channel. NSFW channels are hidden from users until the user explicitly requests to view them.
---@return boolean
function GuildTextChannel:disableNSFW() end
---Create a new GuildTextChannel
---@return GuildTextChannel
function GuildTextChannel:__init() end

---Wrapper for 24-bit colors packed as a decimal value. See the static constructors for more information.
---@class Color
---@field public value number The raw decimal value that represents the color value.
---@field public r number The value that represents the color's red-level.
---@field public g number The value that represents the color's green-level.
---@field public b number The value that represents the color's blue-level.
---@overload fun(value: number):Color
local Color = {}
---Returns a 6-digit hexadecimal string that represents the color value.
---@return string
function Color:toHex() end
---Returns the red, green, and blue values that are packed into the color value.
---@return number number number
function Color:toRGB() end
---Returns the hue, saturation, and value that represents the color value.
---@return number number number
function Color:toHSV() end
---Returns the hue, saturation, and lightness that represents the color value.
---@return number number number
function Color:toHSL() end
---Sets the color's red-level.
---@return nil
function Color:setRed() end
---Sets the color's green-level.
---@return nil
function Color:setGreen() end
---Sets the color's blue-level.
---@return nil
function Color:setBlue() end
---Returns a new copy of the original color object.
---@return Color
function Color:copy() end
---Constructs a new Color object from a hexadecimal string. The string may or may not be prefixed by `#`; all other characters are interpreted as a hex string.
---@param hex string
---@return Color
function Color.fromHex(hex) end
---Constructs a new Color object from RGB values. Values are allowed to overflow though one component will not overflow to the next component.
---@param r number
---@param g number
---@param b number
---@return Color
function Color.fromRGB(r, g, b) end
---Constructs a new Color object from HSV values. Hue is allowed to overflow while saturation and value are clamped to [0, 1].
---@param h number
---@param s number
---@param v number
---@return Color
function Color.fromHSV(h, s, v) end
---Constructs a new Color object from HSL values. Hue is allowed to overflow while saturation and lightness are clamped to [0, 1].
---@param h number
---@param s number
---@param l number
---@return Color
function Color.fromHSL(h, s, l) end
---Create a new Color
---@param value number
---@return Color
function Color:__init(value) end

---Represents a Discord group channel. Essentially a private channel that may have more than one and up to ten recipients. This class should only be relevant to user-accounts; bots cannot normally join group channels.
---@class GroupChannel: TextChannel
---@field public recipients SecondaryCache A secondary cache of users that are present in the channel.
---@field public name string The name of the channel.
---@field public ownerId string The Snowflake ID of the user that owns (created) the channel.
---@field public owner User | nil Equivalent to `GroupChannel.recipients:get(GroupChannel.ownerId)`.
---@field public icon string | nil The hash for the channel's custom icon, if one is set.
---@field public iconURL string | nil The URL that can be used to view the channel's icon, if one is set.
---@overload fun():GroupChannel
local GroupChannel = {}
---Sets the channel's name. This must be between 1 and 100 characters in length.
---@param name string
---@return boolean
function GroupChannel:setName(name) end
---Sets the channel's icon. To remove the icon, pass `nil`.
---@param icon string
---@return boolean
function GroupChannel:setIcon(icon) end
---Adds a user to the channel.
---@param id User | string
---@return boolean
function GroupChannel:addRecipient(id) end
---Removes a user from the channel.
---@param id User | string
---@return boolean
function GroupChannel:removeRecipient(id) end
---Removes the client's user from the channel. If no users remain, the channel is destroyed.
---@return boolean
function GroupChannel:leave() end
---Create a new GroupChannel
---@return GroupChannel
function GroupChannel:__init() end

---Represents an emoji that has been used to react to a Discord text message. Both standard and custom emojis can be used.
---@class Reaction: Container
---@field public emojiId string | nil The ID of the emoji used in this reaction if it is a custom emoji.
---@field public emojiName string The name of the emoji used in this reaction. This will be the raw string for a standard emoji.
---@field public emojiHash string The discord hash for the emoji used in this reaction. This will be the raw string for a standard emoji.
---@field public emojiURL string | nil string The URL that can be used to view a full version of the emoji used in this reaction if it is a custom emoji.
---@field public me boolean Whether the current user has used this reaction.
---@field public count number The total number of users that have used this reaction.
---@field public message Message The message on which this reaction exists.
---@overload fun():Reaction
local Reaction = {}
---Returns `Reaction.emojiId or Reaction.emojiName`
---@return string
function Reaction:__hash() end
---Returns a newly constructed cache of all users that have used this reaction in its parent message. The cache is not automatically updated via gateway events, but the internally referenced user objects may be updated. You must call this method again to guarantee that the objects are update to date.
---@param limit number
---@return SecondaryCache
function Reaction:getUsers(limit) end
---Returns a newly constructed cache of all users that have used this reaction before the specified id in its parent message. The cache is not automatically updated via gateway events, but the internally referenced user objects may be updated. You must call this method again to guarantee that the objects are update to date.
---@param id User | string
---@param limit number
---@return SecondaryCache
function Reaction:getUsersBefore(id, limit) end
---Returns a newly constructed cache of all users that have used this reaction after the specified id in its parent message. The cache is not automatically updated via gateway events, but the internally referenced user objects may be updated. You must call this method again to guarantee that the objects are update to date.
---@param id User | string
---@param limit number
---@return SecondaryCache
function Reaction:getUsersAfter(id, limit) end
---Equivalent to `Reaction.message:removeReaction(Reaction)`
---@param id User | string
---@return boolean
function Reaction:delete(id) end
---Create a new Reaction
---@return Reaction
function Reaction:__init() end

---Represents an invitation to a Discord guild channel. Invites can be used to join a guild, though they are not always permanent.
---@class Invite: Container
---@field public code string The invite's code which can be used to identify the invite.
---@field public guildId string The Snowflake ID of the guild to which this invite belongs.
---@field public guildName string The name of the guild to which this invite belongs.
---@field public channelId string The Snowflake ID of the channel to which this belongs.
---@field public channelName string The name of the channel to which this invite belongs.
---@field public channelType number The type of the channel to which this invite belongs. Use the `channelType` enumeration for a human-readable representation.
---@field public guildIcon string | nil The hash for the guild's custom icon, if one is set.
---@field public guildBanner string | nil The hash for the guild's custom banner, if one is set.
---@field public guildSplash string | nil The hash for the guild's custom splash, if one is set.
---@field public guildIconURL string | nil The URL that can be used to view the guild's icon, if one is set.
---@field public guildBannerURL string | nil The URL that can be used to view the guild's banner, if one is set.
---@field public guildSplashURL string | nil The URL that can be used to view the guild's splash, if one is set.
---@field public guildDescription string | nil The guild's custom description, if one is set.
---@field public guildVerificationLevel number | nil The guild's verification level, if available.
---@field public inviter User | nil The object of the user that created the invite. This will not exist if the invite is a guild widget or a vanity invite.
---@field public uses number | nil How many times this invite has been used. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public maxUses number | nil The maximum amount of times this invite can be used. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public maxAge number | nil How long, in seconds, this invite lasts before it expires. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public temporary boolean | nil Whether the invite grants temporary membership. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public createdAt string | nil The date and time at which the invite was created, represented as an ISO 8601 string plus microseconds when available. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public revoked boolean | nil Whether the invite has been revoked. This will not exist if the invite is accessed via `Client:getInvite`.
---@field public approximatePresenceCount number | nil The approximate count of online members.
---@field public approximateMemberCount number | nil The approximate count of all members.
---@overload fun():Invite
local Invite = {}
---Returns `Invite.code`
---@return string
function Invite:__hash() end
---Permanently deletes the invite. This cannot be undone!
---@return boolean
function Invite:delete() end
---Create a new Invite
---@return Invite
function Invite:__init() end

---Defines the base methods and properties for all Discord guild channels.
---@class GuildChannel: Channel
---@field public permissionOverwrites Cache An iterable cache of all overwrites that exist in this channel. To access an overwrite that may exist, but is not cached, use `GuildChannel:getPermissionOverwriteFor`.
---@field public name string The name of the channel. This should be between 2 and 100 characters in length.
---@field public position number The position of the channel, where 0 is the highest.
---@field public guild Guild The guild in which this channel exists.
---@field public category GuildCategoryChannel | nil The parent channel category that may contain this channel.
---@field public private boolean Whether the "everyone" role has permission to view this channel. In the Discord channel, private text channels are indicated with a lock icon and private voice channels are not visible.
---@overload fun():GuildChannel
local GuildChannel = {}
---Sets the channel's name. This must be between 2 and 100 characters in length.
---@param name string
---@return boolean
function GuildChannel:setName(name) end
---Sets the channel's parent category.
---@param id Channel | string
---@return boolean
function GuildChannel:setCategory(id) end
---Moves a channel up its list. The parameter `n` indicates how many spaces the channel should be moved, clamped to the highest position, with a default of 1 if it is omitted. This will also normalize the positions of all channels.
---@param n number
---@return boolean
function GuildChannel:moveUp(n) end
---Moves a channel down its list. The parameter `n` indicates how many spaces the channel should be moved, clamped to the lowest position, with a default of 1 if it is omitted. This will also normalize the positions of all channels.
---@param n number
---@return boolean
function GuildChannel:moveDown(n) end
---Creates an invite to the channel. Optional payload fields are: max_age: number time in seconds until expiration, default = 86400 (24 hours), max_uses: number total number of uses allowed, default = 0 (unlimited), temporary: boolean whether the invite grants temporary membership, default = false, unique: boolean whether a unique code should be guaranteed, default = false
---@param payload table
---@return Invite
function GuildChannel:createInvite(payload) end
---Returns a newly constructed cache of all invite objects for the channel. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects.
---@return Cache
function GuildChannel:getInvites() end
---Returns a permission overwrite object corresponding to the provided member or role object. If a cached overwrite is not found, an empty overwrite with zero-permissions is returned instead. Therefore, this can be used to create a new overwrite when one does not exist. Note that the member or role must exist in the same guild as the channel does.
---@param obj Role | Member
---@return PermissionOverwrite
function GuildChannel:getPermissionOverwriteFor(obj) end
---Permanently deletes the channel. This cannot be undone!
---@return boolean
function GuildChannel:delete() end
---Create a new GuildChannel
---@return GuildChannel
function GuildChannel:__init() end

---Represents a length of time and provides utilities for converting to and from different formats. Supported units are: weeks, days, hours, minutes, seconds, and milliseconds.
---@class Time
---@overload fun():Time
local Time = {}
---Returns a human-readable string built from the set of normalized time values that the object represents.
---@return string
function Time:toString() end
---Returns the total number of weeks that the time object represents.
---@return number
function Time:toWeeks() end
---Returns the total number of days that the time object represents.
---@return number
function Time:toDays() end
---Returns the total number of hours that the time object represents.
---@return number
function Time:toHours() end
---Returns the total number of minutes that the time object represents.
---@return number
function Time:toMinutes() end
---Returns the total number of seconds that the time object represents.
---@return number
function Time:toSeconds() end
---Returns the total number of milliseconds that the time object represents.
---@return number
function Time:toMilliseconds() end
---Returns a table of normalized time values that represent the time object in a more accessible form.
---@return number
function Time:toTable() end
---Constructs a new Time object from a value interpreted as weeks, where a week is equal to 7 days.
---@param t number
---@return Time
function Time.fromWeeks(t) end
---Constructs a new Time object from a value interpreted as days, where a day is equal to 24 hours.
---@param t number
---@return Time
function Time.fromDays(t) end
---Constructs a new Time object from a value interpreted as hours, where an hour is equal to 60 minutes.
---@param t number
---@return Time
function Time.fromHours(t) end
---Constructs a new Time object from a value interpreted as minutes, where a minute is equal to 60 seconds.
---@param t number
---@return Time
function Time.fromMinutes(t) end
---Constructs a new Time object from a value interpreted as seconds, where a second is equal to 1000 milliseconds.
---@param t number
---@return Time
function Time.fromSeconds(t) end
---Constructs a new Time object from a value interpreted as milliseconds, the base unit represented.
---@param t number
---@return Time
function Time.fromMilliseconds(t) end
---Constructs a new Time object from a table of time values where the keys are defined in the constructors above (eg: `weeks`, `days`, `hours`).
---@param t table
---@return Time
function Time.fromTable(t) end
---Create a new Time
---@return Time
function Time:__init() end

---Extends the functionality of a regular cache by making use of weak references to the objects that are cached. If all references to an object are weak, as they are here, then the object will be deleted on the next garbage collection cycle.
---@class WeakCache: Cache
---@overload fun():WeakCache
local WeakCache = {}
---Create a new WeakCache
---@return WeakCache
function WeakCache:__init() end

---Used to log formatted messages to stdout (the console) or to a file. The `dateTime` argument should be a format string that is accepted by `os.date`. The file argument should be a relative or absolute file path or `nil` if no log file is desired. See the `logLevel` enumeration for acceptable log level values.
---@class Logger
---@overload fun(level: number, dateTime: string, file: string):Logger
local Logger = {}
---If the provided level is less than or equal to the log level set on initialization, this logs a message to stdout as defined by Luvit's `process` module and to a file if one was provided on initialization. The `msg, ...` pair is formatted according to `string.format` and returned if the message is logged.
---@param level number
---@param msg string
---@vararg any
---@return string
function Logger:log(level, msg, ...) end
---Create a new Logger
---@param level number
---@param dateTime string
---@param file string
---@return Logger
function Logger:__init(level, dateTime, file) end

---Mutual exclusion class used to control Lua coroutine execution order.
---@class Mutex
---@overload fun():Mutex
local Mutex = {}
---If the mutex is not active (if a coroutine is not queued), this will activate the mutex; otherwise, this will yield and queue the current coroutine.
---@param prepend boolean
---@return nil
function Mutex:lock(prepend) end
---If the mutex is active (if a coroutine is queued), this will dequeue and resume the next available coroutine; otherwise, this will deactivate the mutex.
---@return nil
function Mutex:unlock() end
---Asynchronously unlocks the mutex after a specified time in milliseconds. The relevant `uv_timer` object is returned.
---@param delay number
---@return userdata
function Mutex:unlockAfter(delay) end
---Create a new Mutex
---@return Mutex
function Mutex:__init() end

---Represents a connection to a Discord voice server.
---@class VoiceConnection
---@field public channel GuildVoiceChannel | nil The corresponding GuildVoiceChannel for this connection, if one exists.
---@overload fun():VoiceConnection
local VoiceConnection = {}
---Returns the bitrate of the interal Opus encoder in bits per second (bps).
---@return nil
function VoiceConnection:getBitrate() end
---Sets the bitrate of the interal Opus encoder in bits per second (bps). This should be between 8000 and 128000, inclusive.
---@param bitrate number
---@return nil
function VoiceConnection:setBitrate(bitrate) end
---Returns the complexity of the interal Opus encoder.
---@return number
function VoiceConnection:getComplexity() end
---Sets the complexity of the interal Opus encoder. This should be between 0 and 10, inclusive.
---@param complexity number
---@return nil
function VoiceConnection:setComplexity(complexity) end
---Plays PCM data over the established connection. If a duration (in milliseconds) is provided, the audio stream will automatically stop after that time has elapsed; otherwise, it will play until the source is exhausted. The returned number is the time elapsed while streaming and the returned string is a message detailing the reason why the stream stopped. For more information about acceptable sources, see the [[voice]] page.
---@param source string | function | table | userdata
---@param duration number
---@return number string
function VoiceConnection:playPCM(source, duration) end
---Plays audio over the established connection using an FFmpeg process, assuming FFmpeg is properly configured. If a duration (in milliseconds) is provided, the audio stream will automatically stop after that time has elapsed; otherwise, it will play until the source is exhausted. The returned number is the time elapsed while streaming and the returned string is a message detailing the reason why the stream stopped. For more information about using FFmpeg, see the [[voice]] page.
---@param path string
---@param duration number
---@return number string
function VoiceConnection:playFFmpeg(path, duration) end
---Temporarily pauses the audio stream for this connection, if one is active. Like most Discordia methods, this must be called inside of a coroutine, as it will yield until the stream is actually paused, usually on the next tick.
---@return nil
function VoiceConnection:pauseStream() end
---Resumes the audio stream for this connection, if one is active and paused. Like most Discordia methods, this must be called inside of a coroutine, as it will yield until the stream is actually resumed, usually on the next tick.
---@return nil
function VoiceConnection:resumeStream() end
---Irreversibly stops the audio stream for this connection, if one is active. Like most Discordia methods, this must be called inside of a coroutine, as it will yield until the stream is actually stopped, usually on the next tick.
---@return nil
function VoiceConnection:stopStream() end
---Stops the audio stream for this connection, if one is active, disconnects from the voice server, and leaves the corresponding voice channel. Like most Discordia methods, this must be called inside of a coroutine.
---@return boolean
function VoiceConnection:close() end
---Create a new VoiceConnection
---@return VoiceConnection
function VoiceConnection:__init() end

---Used to measure an elapsed period of time. If a truthy value is passed as an argument, then the stopwatch will initialize in an idle state; otherwise, it will initialize in an active state. Although nanosecond precision is available, Lua can only reliably provide microsecond accuracy due to the lack of native 64-bit integer support. Generally, milliseconds should be sufficient here.
---@class Stopwatch
---@field public milliseconds number The total number of elapsed milliseconds. If the stopwatch is running, this will naturally be different each time that it is accessed.
---@overload fun():Stopwatch
local Stopwatch = {}
---Defines the behavior of the `tostring` function. Returns a string that represents the elapsed milliseconds for convenience of introspection.
---@return string
function Stopwatch:__tostring() end
---Effectively stops the stopwatch.
---@return nil
function Stopwatch:stop() end
---Effectively starts the stopwatch.
---@return nil
function Stopwatch:start() end
---Effectively resets the stopwatch.
---@return nil
function Stopwatch:reset() end
---Returns a new Time object that represents the currently elapsed time. This is useful for "catching" the current time and comparing its many forms as required.
---@return Time
function Stopwatch:getTime() end
---Create a new Stopwatch
---@return Stopwatch
function Stopwatch:__init() end

---Wrapper for a bitfield that is more specifically used to represent Discord permissions. See the `permission` enumeration for acceptable permission values.
---@class Permissions
---@field public value number The raw decimal value that represents the permissions value.
---@overload fun():Permissions
local Permissions = {}
---Defines the behavior of the `tostring` function. Returns a readable list of permissions stored for convenience of introspection.
---@return string
function Permissions:__tostring() end
---Defines the behavior of the `==` operator. Allows permissions to be directly compared according to their value.
---@return boolean
function Permissions:__eq() end
---Enables a specific permission or permissions. See the `permission` enumeration for acceptable permission values.
---@vararg number
---@return nil
function Permissions:enable(...) end
---Disables a specific permission or permissions. See the `permission` enumeration for acceptable permission values.
---@vararg number
---@return nil
function Permissions:disable(...) end
---Returns whether this set has a specific permission or permissions. See the `permission` enumeration for acceptable permission values.
---@vararg number
---@return boolean
function Permissions:has(...) end
---Enables all permissions values.
---@return nil
function Permissions:enableAll() end
---Disables all permissions values.
---@return nil
function Permissions:disableAll() end
---Returns the hexadecimal string that represents the permissions value.
---@return string
function Permissions:toHex() end
---Returns a table that represents the permissions value, where the keys are the permission names and the values are `true` or `false`.
---@return table
function Permissions:toTable() end
---Returns an array of the names of the permissions that this objects represents.
---@return table
function Permissions:toArray() end
---Returns a new Permissions object that contains the permissions that are in either `self` or `other` (bitwise OR).
---@param other Permissions
---@return Permissions
function Permissions:union(other) end
---Returns a new Permissions object that contains the permissions that are in both `self` and `other` (bitwise AND).
---@param other Permissions
---@return Permissions
function Permissions:intersection(other) end
---Returns a new Permissions object that contains the permissions that are not in `self` or `other` (bitwise XOR).
---@param other Permissions
---@return Permissions
function Permissions:name(other) end
---Returns a new Permissions object that contains the permissions that are not in `self`, but are in `other` (or the set of all permissions if omitted).
---@param other Permissions
---@return Permissions
function Permissions:complement(other) end
---Returns a new copy of the original permissions object.
---@return Permissions
function Permissions:copy() end
---Returns a Permissions object with all of the defined permissions.
---@vararg number
---@return Permissions
function Permissions.fromMany(...) end
---Returns a Permissions object with all permissions.
---@return Permissions
function Permissions.all() end
---Create a new Permissions
---@return Permissions
function Permissions:__init() end

---Represents a custom emoji object usable in message content and reactions. Standard unicode emojis do not have a class; they are just strings.
---@class Emoji: Snowflake
---@field public name string The name of the emoji.
---@field public guild Guild The guild in which the emoji exists.
---@field public mentionString string A string that, when included in a message content, may resolve as an emoji image in the official Discord client.
---@field public url string The URL that can be used to view a full version of the emoji.
---@field public managed boolean Whether this emoji is managed by an integration such as Twitch or YouTube.
---@field public requireColons boolean Whether this emoji requires colons to be used in the official Discord client.
---@field public hash string String with the format `name:id`, used in HTTP requests. This is different from `Emoji:__hash`, which returns only the Snowflake ID.
---@field public animated boolean Whether this emoji is animated.
---@field public roles ArrayIterable An iterable array of roles that may be required to use this emoji, generally related to integration-managed emojis. Object order is not guaranteed.
---@overload fun():Emoji
local Emoji = {}
---Sets the emoji's name. The name must be between 2 and 32 characters in length.
---@param name string
---@return boolean
function Emoji:setName(name) end
---Sets the roles that can use the emoji.
---@param roles Role[] | string[]
---@return boolean
function Emoji:setRoles(roles) end
---Permanently deletes the emoji. This cannot be undone!
---@return boolean
function Emoji:delete() end
---Returns whether or not the provided role is allowed to use the emoji.
---@param id Role | string
---@return boolean
function Emoji:hasRole(id) end
---Create a new Emoji
---@return Emoji
function Emoji:__init() end

---Defines the base methods and properties for all Discord channel types.
---@class Channel: Snowflake
---@field public type number The channel type. See the `channelType` enumeration for a human-readable representation.
---@field public mentionString string A string that, when included in a message content, may resolve as a link to a channel in the official Discord client.
---@overload fun():Channel
local Channel = {}
---Create a new Channel
---@return Channel
function Channel:__init() end

---Represents a single moment in time and provides utilities for converting to and from different date and time formats. Although microsecond precision is available, most formats are implemented with only second precision.
---@class Date
---@overload fun(seconds: number, microseconds: number):Date
local Date = {}
---Returns a string from this Date object via Lua's `os.date`. If no format string is provided, the default is '%a %b %d %Y %T GMT%z (%Z)'.
---@param fmt string
---@return string
function Date:toString(fmt) end
---Returns an ISO 8601 string that represents the stored date and time. If `sep` and `tz` are both provided, then they are used as a custom separator and timezone; otherwise, `T` is used for the separator and `+00:00` is used for the timezone, plus microseconds if available.
---@param sep string
---@param tz string
---@return string
function Date:toISO(sep, tz) end
---Returns an RFC 2822 string that represents the stored date and time.
---@return string
function Date:toHeader() end
---Returns a synthetic Discord Snowflake ID based on the stored date and time. Due to the lack of native 64-bit support, the result may lack precision. In other words, `Date.fromSnowflake(id):toSnowflake() == id` may be `false`.
---@return string
function Date:toSnowflake() end
---Returns a Lua date table that represents the stored date and time as a local time. Equivalent to `os.date('*t', s)` where `s` is the Unix time in seconds.
---@return table
function Date:toTable() end
---Returns a Lua date table that represents the stored date and time as a UTC time. Equivalent to `os.date('!*t', s)` where `s` is the Unix time in seconds.
---@return table
function Date:toTableUTC() end
---Returns a Unix time in seconds that represents the stored date and time.
---@return number
function Date:toSeconds() end
---Returns a Unix time in milliseconds that represents the stored date and time.
---@return number
function Date:toMilliseconds() end
---Returns a Unix time in microseconds that represents the stored date and time.
---@return number
function Date:toMicroseconds() end
---Returns the seconds and microseconds that are stored in the date object.
---@return number number
function Date:toParts() end
---Converts an ISO 8601 string into a Unix time in seconds. For compatibility with Discord's timestamp format, microseconds are also provided as a second return value.
---@param str string
---@return number number
function Date.parseISO(str) end
---Converts an RFC 2822 string (an HTTP Date header) into a Unix time in seconds.
---@param str string
---@return number
function Date.parseHeader(str) end
---Converts a Discord Snowflake ID into a Unix time in seconds. Additional decimal points may be present, though only the first 3 (milliseconds) should be considered accurate.
---@param id string
---@return number
function Date.parseSnowflake(id) end
---Interprets a Lua date table as a local time and converts it to a Unix time in seconds. Equivalent to `os.time(tbl)`.
---@param tbl table
---@return number
function Date.parseTable(tbl) end
---Interprets a Lua date table as a UTC time and converts it to a Unix time in seconds. Equivalent to `os.time(tbl)` with a correction for UTC.
---@param tbl table
---@return number
function Date.parseTableUTC(tbl) end
---Constructs a new Date object from an ISO 8601 string. Equivalent to `Date(Date.parseISO(str))`.
---@param str string
---@return Date
function Date.fromISO(str) end
---Constructs a new Date object from an RFC 2822 string. Equivalent to `Date(Date.parseHeader(str))`.
---@param str string
---@return Date
function Date.fromHeader(str) end
---Constructs a new Date object from a Discord/Twitter Snowflake ID. Equivalent to `Date(Date.parseSnowflake(id))`.
---@param id string
---@return Date
function Date.fromSnowflake(id) end
---Constructs a new Date object from a Lua date table interpreted as a local time. Equivalent to `Date(Date.parseTable(tbl))`.
---@param tbl table
---@return Date
function Date.fromTable(tbl) end
---Constructs a new Date object from a Lua date table interpreted as a UTC time. Equivalent to `Date(Date.parseTableUTC(tbl))`.
---@param tbl table
---@return Date
function Date.fromTableUTC(tbl) end
---Constructs a new Date object from a Unix time in seconds.
---@param s number
---@return Date
function Date.fromSeconds(s) end
---Constructs a new Date object from a Unix time in milliseconds.
---@param ms number
---@return Date
function Date.fromMilliseconds(ms) end
---Constructs a new Date object from a Unix time in microseconds.
---@param us number
---@return Date
function Date.fromMicroseconds(us) end
---Create a new Date
---@param seconds number
---@param microseconds number
---@return Date
function Date:__init(seconds, microseconds) end

---An implementation of a double-ended queue.
---@class Deque
---@overload fun():Deque
local Deque = {}
---Returns the total number of values stored.
---@return number
function Deque:getCount() end
---Adds a value of any type to the left side of the deque.
---@param obj any
---@return nil
function Deque:pushLeft(obj) end
---Adds a value of any type to the right side of the deque.
---@param obj any
---@return nil
function Deque:pushRight(obj) end
---Removes and returns a value from the left side of the deque.
---@return any
function Deque:popLeft() end
---Removes and returns a value from the right side of the deque.
---@return any
function Deque:popRight() end
---Returns the value at the left side of the deque without removing it.
---@return any
function Deque:peekLeft() end
---Returns the value at the right side of the deque without removing it.
---@return any
function Deque:peekRight() end
---Iterates over the deque from left to right.
---@return function
function Deque:iter() end
---Create a new Deque
---@return Deque
function Deque:__init() end

---Represents a text message sent in a Discord text channel. Messages can contain simple content strings, rich embeds, attachments, or reactions.
---@class Message: Snowflake
---@field public reactions Cache An iterable cache of all reactions that exist for this message.
---@field public mentionedUsers ArrayIterable An iterable array of all users that are mentioned in this message.
---@field public mentionedRoles ArrayIterable An iterable array of known roles that are mentioned in this message, excluding the default everyone role. The message must be in a guild text channel and the roles must be cached in that channel's guild for them to appear here.
---@field public mentionedEmojis ArrayIterable An iterable array of all known emojis that are mentioned in this message. If the client does not have the emoji cached, then it will not appear here.
---@field public mentionedChannels ArrayIterable An iterable array of all known channels that are mentioned in this message. If the client does not have the channel cached, then it will not appear here.
---@field public cleanContent string The message content with all recognized mentions replaced by names and with @everyone and @here mentions escaped by a zero-width space (ZWSP).
---@field public mentionsEveryone boolean Whether this message mentions @everyone or @here.
---@field public pinned boolean Whether this message belongs to its channel's pinned messages.
---@field public tts boolean Whether this message is a text-to-speech message.
---@field public nonce string | number | boolean | nil Used by the official Discord client to detect the success of a sent message.
---@field public editedTimestamp string | nil The date and time at which the message was most recently edited, represented as an ISO 8601 string plus microseconds when available.
---@field public oldContent string | table Yields a table containing keys as timestamps and value as content of the message at that time.
---@field public content string The raw message content. This should be between 0 and 2000 characters in length.
---@field public author User The object of the user that created the message.
---@field public channel TextChannel The channel in which this message was sent.
---@field public type number The message type. Use the `messageType` enumeration for a human-readable representation.
---@field public embed table | nil A raw data table that represents the first rich embed that exists in this message. See the Discord documentation for more information.
---@field public attachment table | nil A raw data table that represents the first file attachment that exists in this message. See the Discord documentation for more information.
---@field public embeds table A raw data table that contains all embeds that exist for this message. If there are none, this table will not be present.
---@field public attachments table A raw data table that contains all attachments that exist for this message. If there are none, this table will not be present.
---@field public guild Guild | nil The guild in which this message was sent. This will not exist if the message was not sent in a guild text channel. Equivalent to `Message.channel.guild`.
---@field public member Member | nil The member object of the message's author. This will not exist if the message is not sent in a guild text channel or if the member object is not cached. Equivalent to `Message.guild.members:get(Message.author.id)`.
---@field public link string URL that can be used to jump-to the message in the Discord client.
---@field public webhookId string | nil The ID of the webhook that generated this message, if applicable.
---@overload fun():Message
local Message = {}
---Sets the message's content. The message must be authored by the current user (ie: you cannot change the content of messages sent by other users). The content must be from 1 to 2000 characters in length.
---@param content string
---@return boolean
function Message:setContent(content) end
---Sets the message's embed. The message must be authored by the current user. (ie: you cannot change the embed of messages sent by other users).
---@param embed table
---@return boolean
function Message:setEmbed(embed) end
---Hides all embeds for this message.
---@return boolean
function Message:hideEmbeds() end
---Shows all embeds for this message.
---@return boolean
function Message:showEmbeds() end
---Indicates whether the message has a particular flag set.
---@param flag number
---@return boolean
function Message:hasFlag(flag) end
---Sets multiple properties of the message at the same time using a table similar to the one supported by `TextChannel.send`, except only `content` and `embed` are valid fields; `mention(s)`, `file(s)`, etc are not supported. The message must be authored by the current user. (ie: you cannot change the embed of messages sent by other users).
---@param data table
---@return boolean
function Message:update(data) end
---Pins the message in the channel.
---@return boolean
function Message:pin() end
---Unpins the message in the channel.
---@return boolean
function Message:unpin() end
---Adds a reaction to the message. Note that this does not return the new reaction object; wait for the `reactionAdd` event instead.
---@param emoji Emoji | Reaction | string
---@return boolean
function Message:addReaction(emoji) end
---Removes a reaction from the message. Note that this does not return the old reaction object; wait for the `reactionRemove` event instead. If no user is indicated, then this will remove the current user's reaction.
---@param emoji Emoji | Reaction | string
---@param id User | string
---@return boolean
function Message:removeReaction(emoji, id) end
---Removes all reactions from the message.
---@return boolean
function Message:clearReactions() end
---Permanently deletes the message. This cannot be undone!
---@return boolean
function Message:delete() end
---Equivalent to `Message.channel:send(content)`.
---@param content string | table
---@return Message
function Message:reply(content) end
---Create a new Message
---@return Message
function Message:__init() end

---Represents a private Discord text channel used to track correspondences between the current user and one other recipient.
---@class PrivateChannel: TextChannel
---@field public name string Equivalent to `PrivateChannel.recipient.username`.
---@field public recipient User The recipient of this channel's messages, other than the current user.
---@overload fun():PrivateChannel
local PrivateChannel = {}
---Closes the channel. This does not delete the channel. To re-open the channel, use `User:getPrivateChannel`.
---@return boolean
function PrivateChannel:close() end
---Create a new PrivateChannel
---@return PrivateChannel
function PrivateChannel:__init() end

---Abstract base class that defines the base methods and properties for a general purpose data structure with features that are better suited for an object-oriented environment. Note: All sub-classes should implement their own `__init` and `iter` methods and all stored objects should have a `__hash` method.
---@class Iterable
---@overload fun():Iterable
local Iterable = {}
---Defines the behavior of the `pairs` function. Returns an iterator that returns a `key, value` pair, where `key` is the result of calling `__hash` on the `value`.
---@return function
function Iterable:__pairs() end
---Defines the behavior of the `#` operator. Returns the total number of objects stored in the iterable.
---@return function
function Iterable:__len() end
---Returns an individual object by key, where the key should match the result of calling `__hash` on the contained objects. Operates with up to O(n) complexity.
---@param k any
---@return any
function Iterable:get(k) end
---Returns the first object that satisfies a predicate.
---@param fn function
---@return any
function Iterable:find(fn) end
---Returns an iterator that returns all objects that satisfy a predicate.
---@param fn function
---@return function
function Iterable:findAll(fn) end
---Iterates through all objects and calls a function `fn` that takes the objects as an argument.
---@param fn function
---@return nil
function Iterable:forEach(fn) end
---Returns a random object that is contained in the iterable.
---@return any
function Iterable:random() end
---If a predicate is provided, this returns the number of objects in the iterable that satistfy the predicate; otherwise, the total number of objects.
---@param fn function
---@return number
function Iterable:count(fn) end
---Returns a sequentially-indexed table that contains references to all objects. If a `sortBy` string is provided, then the table is sorted by that particular property. If a predicate is provided, then only objects that satisfy it will be included.
---@param sortBy string
---@param fn function
---@return table
function Iterable:toArray(sortBy, fn) end
---Similarly to an SQL query, this returns a sorted Lua table of rows where each row corresponds to each object in the iterable, and each value in the row is selected from the objects according to the keys provided.
---@vararg string
---@return table
function Iterable:select(...) end
---This returns an iterator that, when called, returns the values from each encountered object, picked by the provided keys. If a key is a string, the objects are indexed with the string. If a key is a function, the function is called with the object passed as its first argument.
---@vararg string | function
---@return function
function Iterable:pick(...) end
---Create a new Iterable
---@return Iterable
function Iterable:__init() end

---Represents a relationship between the current user and another Discord user. This is generally either a friend or a blocked user. This class should only be relevant to user-accounts; bots cannot normally have relationships.
---@class Relationship: UserPresence
---@field public name string Equivalent to `Relationship.user.username`.
---@field public type number The relationship type. See the `relationshipType` enumeration for a human-readable representation.
---@overload fun():Relationship
local Relationship = {}
---Create a new Relationship
---@return Relationship
function Relationship:__init() end

---Represents a Discord guild role, which is used to assign priority, permissions, and a color to guild members.
---@class Role: Snowflake
---@field public hoisted boolean Whether members with this role should be shown separated from other members in the guild member list.
---@field public mentionable boolean Whether this role can be mentioned in a text channel message.
---@field public managed boolean Whether this role is managed by some integration or bot inclusion.
---@field public name string The name of the role. This should be between 1 and 100 characters in length.
---@field public position number The position of the role, where 0 is the lowest.
---@field public color number Represents the display color of the role as a decimal value.
---@field public permissions number Represents the total permissions of the role as a decimal value.
---@field public mentionString string A string that, when included in a message content, may resolve as a role notification in the official Discord client.
---@field public guild Guild The guild in which this role exists.
---@field public members FilteredIterable A filtered iterable of guild members that have this role. If you want to check whether a specific member has this role, it would be better to get the member object elsewhere and use `Member:hasRole` rather than check whether the member exists here.
---@field public emojis FilteredIterable A filtered iterable of guild emojis that have this role. If you want to check whether a specific emoji has this role, it would be better to get the emoji object elsewhere and use `Emoji:hasRole` rather than check whether the emoji exists here.
---@overload fun():Role
local Role = {}
---Permanently deletes the role. This cannot be undone!
---@return boolean
function Role:delete() end
---Moves a role down its list. The parameter `n` indicates how many spaces the role should be moved, clamped to the lowest position, with a default of 1 if it is omitted. This will also normalize the positions of all roles. Note that the default everyone role cannot be moved.
---@param n number
---@return boolean
function Role:moveDown(n) end
---Moves a role up its list. The parameter `n` indicates how many spaces the role should be moved, clamped to the highest position, with a default of 1 if it is omitted. This will also normalize the positions of all roles. Note that the default everyone role cannot be moved.
---@param n number
---@return boolean
function Role:moveUp(n) end
---Sets the role's name. The name must be between 1 and 100 characters in length.
---@param name string
---@return boolean
function Role:setName(name) end
---Sets the role's display color.
---@param color number | Color
---@return boolean
function Role:setColor(color) end
---Sets the permissions that this role explicitly allows.
---@param permissions Permissions | number
---@return boolean
function Role:setPermissions(permissions) end
---Causes members with this role to display above unhoisted roles in the member list.
---@return boolean
function Role:hoist() end
---Causes member with this role to display amongst other unhoisted members.
---@return boolean
function Role:unhoist() end
---Allows anyone to mention this role in text messages.
---@return boolean
function Role:enableMentioning() end
---Disallows anyone to mention this role in text messages.
---@return boolean
function Role:disableMentioning() end
---Enables individual permissions for this role. This does not necessarily fully allow the permissions.
---@vararg number
---@return boolean
function Role:enablePermissions(...) end
---Disables individual permissions for this role. This does not necessarily fully disallow the permissions.
---@vararg number
---@return boolean
function Role:disablePermissions(...) end
---Enables all permissions for this role. This does not necessarily fully allow the permissions.
---@return boolean
function Role:enableAllPermissions() end
---Disables all permissions for this role. This does not necessarily fully disallow the permissions.
---@return boolean
function Role:disableAllPermissions() end
---Returns a color object that represents the role's display color.
---@return Color
function Role:getColor() end
---Returns a permissions object that represents the permissions that this role has enabled.
---@return Permissions
function Role:getPermissions() end
---Create a new Role
---@return Role
function Role:__init() end

---Represents a Discord guild (or server). Guilds are a collection of members, channels, and roles that represents one community.
---@class Guild: Snowflake
---@field public shardId number The ID of the shard on which this guild is served. If only one shard is in operation, then this will always be 0.
---@field public name string The guild's name. This should be between 2 and 100 characters in length.
---@field public icon string | nil The hash for the guild's custom icon, if one is set.
---@field public iconURL string | nil The URL that can be used to view the guild's icon, if one is set.
---@field public splash string | nil The hash for the guild's custom splash image, if one is set. Only partnered guilds may have this.
---@field public splashURL string | nil The URL that can be used to view the guild's custom splash image, if one is set. Only partnered guilds may have this.
---@field public banner string | nil The hash for the guild's custom banner, if one is set.
---@field public bannerURL string | nil The URL that can be used to view the guild's banner, if one is set.
---@field public large boolean Whether the guild has an arbitrarily large amount of members. Guilds that are "large" will not initialize with all members cached.
---@field public lazy boolean Whether the guild follows rules for the lazy-loading of client data.
---@field public region string The voice region that is used for all voice connections in the guild.
---@field public vanityCode string | nil The guild's vanity invite URL code, if one exists.
---@field public description string | nil The guild's custom description, if one exists.
---@field public maxMembers number | nil The guild's maximum member count, if available.
---@field public maxPresences number | nil The guild's maximum presence count, if available.
---@field public mfaLevel number The guild's multi-factor (or two-factor) verification level setting. A value of 0 indicates that MFA is not required; a value of 1 indicates that MFA is required for administrative actions.
---@field public joinedAt string The date and time at which the current user joined the guild, represented as an ISO 8601 string plus microseconds when available.
---@field public afkTimeout number The guild's voice AFK timeout in seconds.
---@field public unavailable boolean Whether the guild is unavailable. If the guild is unavailable, then no property is guaranteed to exist except for this one and the guild's ID.
---@field public totalMemberCount number The total number of members that belong to this guild. This should always be greater than or equal to the total number of cached members.
---@field public verificationLevel number The guild's verification level setting. See the `verificationLevel` enumeration for a human-readable representation.
---@field public notificationSetting number The guild's default notification setting. See the `notficationSetting` enumeration for a human-readable representation.
---@field public explicitContentSetting number The guild's explicit content level setting. See the `explicitContentLevel` enumeration for a human-readable representation.
---@field public premiumTier number The guild's premier tier affected by nitro server boosts. See the `premiumTier` enumeration for a human-readable representation
---@field public premiumSubscriptionCount number The number of users that have upgraded the guild with nitro server boosting.
---@field public features table Raw table of VIP features that are enabled for the guild.
---@field public me Member | nil Equivalent to `Guild.members:get(Guild.client.user.id)`.
---@field public owner Member | nil Equivalent to `Guild.members:get(Guild.ownerId)`.
---@field public ownerId string The Snowflake ID of the guild member that owns the guild.
---@field public afkChannelId string | nil The Snowflake ID of the channel that is used for AFK members, if one is set.
---@field public afkChannel GuildVoiceChannel | nil Equivalent to `Guild.voiceChannels:get(Guild.afkChannelId)`.
---@field public systemChannelId string | nil The channel id where Discord's join messages will be displayed.
---@field public systemChannel GuildTextChannel | nil The channel where Discord's join messages will be displayed.
---@field public defaultRole Role Equivalent to `Guild.roles:get(Guild.id)`.
---@field public connection VoiceConnection | nil The VoiceConnection for this guild if one exists.
---@field public roles Cache An iterable cache of all roles that exist in this guild. This includes the default everyone role.
---@field public emojis Cache An iterable cache of all emojis that exist in this guild. Note that standard unicode emojis are not found here; only custom emojis.
---@field public members Cache An iterable cache of all members that exist in this guild and have been already loaded. If the `cacheAllMembers` client option (and the `syncGuilds` option for user-accounts) is enabled on start-up, then all members will be cached. Otherwise, offline members may not be cached. To access a member that may exist, but is not cached, use `Guild:getMember`.
---@field public textChannels Cache An iterable cache of all text channels that exist in this guild.
---@field public voiceChannels Cache An iterable cache of all voice channels that exist in this guild.
---@field public categories Cache An iterable cache of all channel categories that exist in this guild.
---@overload fun():Guild
local Guild = {}
---Asynchronously loads all members for this guild. You do not need to call this if the `cacheAllMembers` client option (and the `syncGuilds` option for user-accounts) is enabled on start-up.
---@return boolean
function Guild:requestMembers() end
---Asynchronously loads certain data and enables the receiving of certain events for this guild. You do not need to call this if the `syncGuilds` client option is enabled on start-up. Note: This is only for user accounts. Bot accounts never need to sync guilds!
---@return boolean
function Guild:sync() end
---Gets a member object by ID. If the object is already cached, then the cached object will be returned; otherwise, an HTTP request is made.
---@param id User | string
---@return Member
function Guild:getMember(id) end
---Gets a role object by ID.
---@param id Role | string
---@return Role
function Guild:getRole(id) end
---Gets a emoji object by ID.
---@param id Emoji | string
---@return Emoji
function Guild:getEmoji(id) end
---Gets a text, voice, or category channel object by ID.
---@param id Channel | string
---@return GuildChannel
function Guild:getChannel(id) end
---Creates a new text channel in this guild. The name must be between 2 and 100 characters in length.
---@param name string
---@return GuildTextChannel
function Guild:createTextChannel(name) end
---Creates a new voice channel in this guild. The name must be between 2 and 100 characters in length.
---@param name string
---@return GuildVoiceChannel
function Guild:createVoiceChannel(name) end
---Creates a channel category in this guild. The name must be between 2 and 100 characters in length.
---@param name string
---@return GuildCategoryChannel
function Guild:createCategory(name) end
---Creates a new role in this guild. The name must be between 1 and 100 characters in length.
---@param name string
---@return Role
function Guild:createRole(name) end
---Creates a new emoji in this guild. The name must be between 2 and 32 characters in length. The image must not be over 256kb, any higher will return a 400 Bad Request
---@param name string
---@param image string
---@return Emoji
function Guild:createEmoji(name, image) end
---Sets the guilds name. This must be between 2 and 100 characters in length.
---@param name string
---@return boolean
function Guild:setName(name) end
---Sets the guild's voice region (eg: `us-east`). See `listVoiceRegions` for a list of acceptable regions.
---@param region string
---@return boolean
function Guild:setRegion(region) end
---Sets the guild's verification level setting. See the `verificationLevel` enumeration for acceptable values.
---@param verification_level number
---@return boolean
function Guild:setVerificationLevel(verification_level) end
---Sets the guild's default notification setting. See the `notficationSetting` enumeration for acceptable values.
---@param default_message_notifications number
---@return boolean
function Guild:setNotificationSetting(default_message_notifications) end
---Sets the guild's explicit content level setting. See the `explicitContentLevel` enumeration for acceptable values.
---@param explicit_content_filter number
---@return boolean
function Guild:setExplicitContentSetting(explicit_content_filter) end
---Sets the guild's AFK timeout in seconds.
---@param afk_timeout number
---@return number
function Guild:setAFKTimeout(afk_timeout) end
---Sets the guild's AFK channel.
---@param id Channel | string
---@return boolean
function Guild:setAFKChannel(id) end
---Sets the guild's join message channel.
---@param id Channel | string
---@return boolean
function Guild:setSystemChannel(id) end
---Transfers ownership of the guild to another user. Only the current guild owner can do this.
---@param id User | string
---@return boolean
function Guild:setOwner(id) end
---Sets the guild's icon. To remove the icon, pass `nil`.
---@param icon string
---@return boolean
function Guild:setIcon(icon) end
---Sets the guild's banner. To remove the banner, pass `nil`.
---@param banner string
---@return boolean
function Guild:setBanner(banner) end
---Sets the guild's splash. To remove the splash, pass `nil`.
---@param splash string
---@return boolean
function Guild:setSplash(splash) end
---Returns the number of members that would be pruned from the guild if a prune were to be executed.
---@param days number
---@return number
function Guild:getPruneCount(days) end
---Prunes (removes) inactive, roleless members from the guild who have not been online in the last provided days. If the `count` boolean is provided, the number of pruned members is returned; otherwise, `0` is returned.
---@param days number
---@param count boolean
---@return number
function Guild:pruneMembers(days, count) end
---Returns a newly constructed cache of all ban objects for the guild. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects.
---@return Cache
function Guild:getBans() end
---This will return a Ban object for a giver user if that user is banned from the guild; otherwise, `nil` is returned.
---@param id User | string
---@return Ban
function Guild:getBan(id) end
---Returns a newly constructed cache of all invite objects for the guild. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects.
---@return Cache
function Guild:getInvites() end
---Returns a newly constructed cache of audit log entry objects for the guild. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects. If included, the query parameters include: query.limit: number, query.user: UserId Resolvable query.before: EntryId Resolvable, query.type: ActionType Resolvable
---@param query table
---@return Cache
function Guild:getAuditLogs(query) end
---Returns a newly constructed cache of all webhook objects for the guild. The cache and its objects are not automatically updated via gateway events. You must call this method again to get the updated objects.
---@return Cache
function Guild:getWebhooks() end
---Returns a raw data table that contains a list of available voice regions for this guild, as provided by Discord, with no additional parsing.
---@return table
function Guild:listVoiceRegions() end
---Removes the current user from the guild.
---@return boolean
function Guild:leave() end
---Permanently deletes the guild. The current user must owner the server. This cannot be undone!
---@return boolean
function Guild:delete() end
---Kicks a user/member from the guild with an optional reason.
---@param id User | string
---@param reason string
---@return boolean
function Guild:kickUser(id, reason) end
---Bans a user/member from the guild with an optional reason. The `days` parameter is the number of days to consider when purging messages, up to 7.
---@param id User | string
---@param reason string
---@param days number
---@return boolean
function Guild:banUser(id, reason, days) end
---Unbans a user/member from the guild with an optional reason.
---@param id User | string
---@param reason string
---@return boolean
function Guild:unbanUser(id, reason) end
---Create a new Guild
---@return Guild
function Guild:__init() end

---Represents a single user of Discord, either a human or a bot, outside of any specific guild's context.
---@class User: Snowflake
---@field public bot boolean Whether this user is a bot.
---@field public name string Equivalent to `User.username`.
---@field public username string The name of the user. This should be between 2 and 32 characters in length.
---@field public discriminator number The discriminator of the user. This is a 4-digit string that is used to discriminate the user from other users with the same username.
---@field public tag string The user's username and discriminator concatenated by an `#`.
---@field public avatar string | nil The hash for the user's custom avatar, if one is set.
---@field public defaultAvatar number The user's default avatar. See the `defaultAvatar` enumeration for a human-readable representation.
---@field public avatarURL string Equivalent to the result of calling `User:getAvatarURL()`.
---@field public defaultAvatarURL string Equivalent to the result of calling `User:getDefaultAvatarURL()`.
---@field public mentionString string A string that, when included in a message content, may resolve as user notification in the official Discord client.
---@field public mutualGuilds FilteredIterable A iterable cache of all guilds where this user shares a membership with the current user. The guild must be cached on the current client and the user's member object must be cached in that guild in order for it to appear here.
---@overload fun():User
local User = {}
---Returns a URL that can be used to view the user's full avatar. If provided, the size must be a power of 2 while the extension must be a valid image format. If the user does not have a custom avatar, the default URL is returned.
---@param size number
---@param ext string
---@return string
function User:getAvatarURL(size, ext) end
---Returns a URL that can be used to view the user's default avatar.
---@param size number
---@return string
function User:getDefaultAvatarURL(size) end
---Returns a private channel that can be used to communicate with the user. If the channel is not cached an HTTP request is made to open one.
---@return PrivateChannel
function User:getPrivateChannel() end
---Equivalent to `User:getPrivateChannel():send(content)`
---@param content string | table
---@return Message
function User:send(content) end
---Equivalent to `User:getPrivateChannel():sendf(content)`
---@param content string
---@return Message
function User:sendf(content) end
---Create a new User
---@return User
function User:__init() end

---Defines the base methods and/or properties for classes that represent a user's current presence information. Note that any method or property that exists for the User class is also available in the UserPresence class and its subclasses.
---@class UserPresence: Container
---@field public status string The user's overall status (online, dnd, idle, offline).
---@field public webStatus string The user's web status (online, dnd, idle, offline).
---@field public mobileStatus string The user's mobile status (online, dnd, idle, offline).
---@field public desktopStatus string The user's desktop status (online, dnd, idle, offline).
---@field public user User The user that this presence represents.
---@field public activity Activity | nil The Activity that this presence represents.
---@overload fun():UserPresence
local UserPresence = {}
---Returns `UserPresence.user.id`
---@return string
function UserPresence:__hash() end
---Create a new UserPresence
---@return UserPresence
function UserPresence:__init() end

---Implements an asynchronous event emitter where callbacks can be subscribed to specific named events. When events are emitted, the callbacks are called in the order that they were originally registered.
---@class Emitter
---@overload fun():Emitter
local Emitter = {}
---Subscribes a callback to be called every time the named event is emitted. Callbacks registered with this method will automatically be wrapped as a new coroutine when they are called. Returns the original callback for convenience.
---@param name string
---@param fn function
---@return function
function Emitter:on(name, fn) end
---Subscribes a callback to be called only the first time this event is emitted. Callbacks registered with this method will automatically be wrapped as a new coroutine when they are called. Returns the original callback for convenience.
---@param name string
---@param fn function
---@return function
function Emitter:once(name, fn) end
---Subscribes a callback to be called every time the named event is emitted. Callbacks registered with this method are not automatically wrapped as a coroutine. Returns the original callback for convenience.
---@param name string
---@param fn function
---@return function
function Emitter:onSync(name, fn) end
---Subscribes a callback to be called only the first time this event is emitted. Callbacks registered with this method are not automatically wrapped as a coroutine. Returns the original callback for convenience.
---@param name string
---@param fn function
---@return function
function Emitter:onceSync(name, fn) end
---Emits the named event and a variable number of arguments to pass to the event callbacks.
---@param name string
---@vararg any
---@return nil
function Emitter:emit(name, ...) end
---Returns an iterator for all callbacks registered to the named event.
---@param name string
---@return function
function Emitter:getListeners(name) end
---Returns the number of callbacks registered to the named event.
---@param name string
---@return number
function Emitter:getListenerCount(name) end
---Unregisters all instances of the callback from the named event.
---@param name string
---@param fn function
---@return nil
function Emitter:removeListener(name, fn) end
---Unregisters all callbacks for the emitter. If a name is passed, then only callbacks for that specific event are unregistered.
---@param name string | nil
---@return nil
function Emitter:removeAllListeners(name) end
---When called inside of a coroutine, this will yield the coroutine until the named event is emitted. If a timeout (in milliseconds) is provided, the function will return after the time expires, regardless of whether the event is emitted, and `false` will be returned; otherwise, `true` is returned. If a predicate is provided, events that do not pass the predicate will be ignored.
---@param name string
---@param timeout number
---@param predicate function
---@return boolean ...
function Emitter:waitFor(name, timeout, predicate) end
---Create a new Emitter
---@return Emitter
function Emitter:__init() end

---Defines the base methods and/or properties for all Discord objects that have a Snowflake ID.
---@class Snowflake: Container
---@field public id string The Snowflake ID that can be used to identify the object. This is guaranteed to be unique except in cases where an object shares the ID of its parent.
---@field public createdAt number The Unix time in seconds at which this object was created by Discord. Additional decimal points may be present, though only the first 3 (milliseconds) should be considered accurate. Equivalent to `Date.parseSnowflake(Snowflake.id)`.
---@field public timestamp string The date and time at which this object was created by Discord, represented as an ISO 8601 string plus microseconds when available. Equivalent to `Date.fromSnowflake(Snowflake.id):toISO()`.
---@overload fun():Snowflake
local Snowflake = {}
---Returns `Snowflake.id`
---@return string
function Snowflake:__hash() end
---Returns a unique Date object that represents when the object was created by Discord. Equivalent to `Date.fromSnowflake(Snowflake.id)`
---@return Date
function Snowflake:getDate() end
---Create a new Snowflake
---@return Snowflake
function Snowflake:__init() end



-- Hand written Discordia types for things which are also hand written in the documentation

-- Add in auto complete for events

---@alias clientEvents string
---| "'ready'"                  # Emitted after all shards and guilds are fully loaded.
---| "'shardReady'"             # Emitted after a shard successfully connects to a Discord gateway and loads all corresponding guilds.
---| "'shardResume'"            # Emitted after the client successfully resumes a severed gateway connection.
---| "'channelCreate'"          # Emitted when a guild channel is created, when a private channel is opened, or when a group channel is joined.
---| "'channelUpdate'"          # Emitted when a channel property is updated, such as its name, topic, bitrate, etc.
---| "'channelDelete'"          # Emitted when a guild channel is deleted, when a private channel is closed, or when a group channel is left.
---| "'recipientAdd'"           # Emitted when a new recipient is added to a group channel. User-accounts only.
---| "'recipientRemove'"        # Emitted when a new recipient is removed from a group channel. User-accounts only.
---| "'guildAvailable'"         # Emitted when a guild becomes available. This can occur after a server outage or as guild data is streamed in after login.
---| "'guildCreate'"            # Emitted when a guild is created from the perspective of the current user, usually after the client user joins a new one.
---| "'guildUpdate'"            # Emitted when a guild property is updated such as its name, region, icon, etc.
---| "'guildUnavailable'"       # Emitted when a guild becomes unavailable, potentially due to a server outage. Unavailable guilds may lack significant data.
---| "'guildDelete'"            # Emitted when a guild is deleted from the perspective of the current user, usually after the client leaves one.
---| "'userBan'"                # Emitted when a user is banned from a guild.
---| "'userUnban'"              # Emitted when a user is unbanned from a guild.
---| "'emojisUpdate'"           # Emitted when a guild's custom emoji is updated.
---| "'memberJoin'"             # Emitted when a new user joins a guild.
---| "'memberLeave'"            # Emitted when a user leaves a guild.
---| "'memberUpdate'"           # Emitted when a guild member property is updated, such as its roles or nickname. See presenceUpdate for status changes.
---| "'roleCreate'"             # Emitted when a guild role is created.
---| "'roleUpdate'"             # Emitted when a guild role property is updated, such as its name, color, permissions, etc.
---| "'roleDelete'"             # Emitted when a guild role is deleted.
---| "'messageCreate'"          # Emitted when a text channel message is created.
---| "'messageUpdate'"          # Emitted when the content of a text channel message is edited.
---| "'messageUpdateUncached'"  # Emitted when the content of a text channel message is edited, but the message is not cached by the client.
---| "'messageDelete'"          # Emitted when a text channel message is deleted. Bulk deletions will fire this for every message that is deleted.
---| "'messageDeleteUncached'"  # Emitted when a text channel message is deleted, but the message is not cached by the client. Bulk deletions will fire this for every message that is deleted, but not cached.
---| "'reactionAdd'"            # Emitted when an emoji reaction is added to message.
---| "'reactionAddUncached'"    # Emitted when an emoji reaction is added to message, but the message is not cached by the client.
---| "'reactionRemove'"         # Emitted when an emoji reaction is removed from a message.
---| "'reactionRemoveUncached'" # Emitted when an emoji reaction is removed from a message, but the message is not cached by the client.
---| "'pinsUpdate'"             # Emitted when a message is pinned or unpinned in a channel.
---| "'presenceUpdate'"         # Emitted when a guild member's status or user properties change. See memberUpdate for role and nickname changes.
---| "'relationshipUpdate'"     # Emitted when a relationship's (friend, blocked user) status or user properties change. User-accounts only.
---| "'relationshipAdd'"        # Emitted when a relationship (friend, blocked user) is added. User-accounts only.
---| "'relationshipRemove'"     # Emitted when a relationship (friend, blocked user) is removed. User-accounts only.
---| "'typingStart'"            # Emitted when a user starts typing in a text channel.
---| "'userUpdate'"             # Emitted when the client user updates itself.
---| "'voiceConnect'"           # Emitted when a guild member connects to voice chat.
---| "'voiceDisconnect'"        # Emitted when a guild member disconnects from voice chat.
---| "'voiceUpdate'"            # Emitted when a guild member's mute/deaf status changes.
---| "'voiceChannelJoin'"       # Emitted when a guild member joins a voice channel.
---| "'voiceChannelLeave'"      # Emitted when a guild member leaves a voice channel.
---| "'webhooksUpdate'"         # Emitted when a guild's text channel's webhooks have updated.
---| "'heartbeat'"              # Emitted when Discord responds with a heartbeat acknowledgement.
---| "'raw'"                    # Emitted for every Discord gateway event.
---| "'debug'"                  # Emitted to provide detailed information regarding specific library behavior.
---| "'info'"                   # Emitted to provide helpful information regarding general library behavior.
---| "'warning'"                # Emitted when something went wrong, but your code will probably continue operating normally.
---| "'error'"                  # Emitted when something went wrong and your code may not continue operating normally.

---Subscribes a callback to be called every time the named event is emitted. Callbacks registered with this method will automatically be wrapped as a new coroutine when they are called. Returns the original callback for convenience.
---@param name clientEvents
---@param fn function
---@return function
---@overload fun(name: 'ready', fn: fun()): function
---@overload fun(name: 'shardReady', fn: fun(shardId: number)): function
---@overload fun(name: 'shardResumed', fn: fun(shardId: number)): function
---@overload fun(name: 'channelCreate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelUpdate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelDelete', fn: fun(channel: Channel)): function
---@overload fun(name: 'recipientAdd', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'recipientRemove', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'guildAvailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildCreate', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildUnavailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildDelete', fn: fun(guild: Guild)): function
---@overload fun(name: 'userBan', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'userUnban', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'emojisUpdate', fn: fun(guild: Guild)): function
---@overload fun(name: 'memberJoin', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberLeave', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberUpdate', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'roleCreate', fn: fun(role: Role)): function
---@overload fun(name: 'roleUpdate', fn: fun(role: Role)): function
---@overload fun(name: 'roleDelete', fn: fun(role: Role)): function
---@overload fun(name: 'messageCreate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdateUncached', fn: fun(channel: TextChannel, messageId: string)): function
---@overload fun(name: 'reactionAdd', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionAddUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'reactionRemove', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionRemoveUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'pinsUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'presenceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'relationshipUpdate', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipAdd', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipRemove', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'typingStart', fn: fun(userId: string, channelId: string, timestamp: string)): function
---@overload fun(name: 'userUpdate', fn: fun(user: User)): function
---@overload fun(name: 'voiceConnect', fn: fun(member: Member)): function
---@overload fun(name: 'voiceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'voiceChannelJoin', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'voiceChannelLeave', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'webhooksUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'debug', fn: fun(message: string)): function
---@overload fun(name: 'info', fn: fun(message: string)): function
---@overload fun(name: 'warning', fn: fun(message: string)): function
---@overload fun(name: 'error', fn: fun(message: string)): function
---@overload fun(name: 'heartbeat', fn: fun(shardId: number, latency: number)): function
---@overload fun(name: 'raw', fn: fun(json: string)): function
function Client:on(name, fn) end
---Subscribes a callback to be called only the first time this event is emitted. Callbacks registered with this method will automatically be wrapped as a new coroutine when they are called. Returns the original callback for convenience.
---@param name clientEvents
---@param fn function
---@return function
---@overload fun(name: 'ready', fn: fun()): function
---@overload fun(name: 'shardReady', fn: fun(shardId: number)): function
---@overload fun(name: 'shardResumed', fn: fun(shardId: number)): function
---@overload fun(name: 'channelCreate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelUpdate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelDelete', fn: fun(channel: Channel)): function
---@overload fun(name: 'recipientAdd', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'recipientRemove', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'guildAvailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildCreate', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildUnavailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildDelete', fn: fun(guild: Guild)): function
---@overload fun(name: 'userBan', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'userUnban', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'emojisUpdate', fn: fun(guild: Guild)): function
---@overload fun(name: 'memberJoin', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberLeave', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberUpdate', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'roleCreate', fn: fun(role: Role)): function
---@overload fun(name: 'roleUpdate', fn: fun(role: Role)): function
---@overload fun(name: 'roleDelete', fn: fun(role: Role)): function
---@overload fun(name: 'messageCreate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdateUncached', fn: fun(channel: TextChannel, messageId: string)): function
---@overload fun(name: 'reactionAdd', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionAddUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'reactionRemove', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionRemoveUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'pinsUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'presenceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'relationshipUpdate', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipAdd', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipRemove', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'typingStart', fn: fun(userId: string, channelId: string, timestamp: string)): function
---@overload fun(name: 'userUpdate', fn: fun(user: User)): function
---@overload fun(name: 'voiceConnect', fn: fun(member: Member)): function
---@overload fun(name: 'voiceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'voiceChannelJoin', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'voiceChannelLeave', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'webhooksUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'debug', fn: fun(message: string)): function
---@overload fun(name: 'info', fn: fun(message: string)): function
---@overload fun(name: 'warning', fn: fun(message: string)): function
---@overload fun(name: 'error', fn: fun(message: string)): function
---@overload fun(name: 'heartbeat', fn: fun(shardId: number, latency: number)): function
---@overload fun(name: 'raw', fn: fun(json: string)): function
function Client:once(name, fn) end
---Subscribes a callback to be called every time the named event is emitted. Callbacks registered with this method are not automatically wrapped as a coroutine. Returns the original callback for convenience.
---@param name clientEvents
---@param fn function
---@return function
---@overload fun(name: 'ready', fn: fun()): function
---@overload fun(name: 'shardReady', fn: fun(shardId: number)): function
---@overload fun(name: 'shardResumed', fn: fun(shardId: number)): function
---@overload fun(name: 'channelCreate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelUpdate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelDelete', fn: fun(channel: Channel)): function
---@overload fun(name: 'recipientAdd', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'recipientRemove', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'guildAvailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildCreate', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildUnavailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildDelete', fn: fun(guild: Guild)): function
---@overload fun(name: 'userBan', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'userUnban', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'emojisUpdate', fn: fun(guild: Guild)): function
---@overload fun(name: 'memberJoin', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberLeave', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberUpdate', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'roleCreate', fn: fun(role: Role)): function
---@overload fun(name: 'roleUpdate', fn: fun(role: Role)): function
---@overload fun(name: 'roleDelete', fn: fun(role: Role)): function
---@overload fun(name: 'messageCreate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdateUncached', fn: fun(channel: TextChannel, messageId: string)): function
---@overload fun(name: 'reactionAdd', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionAddUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'reactionRemove', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionRemoveUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'pinsUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'presenceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'relationshipUpdate', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipAdd', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipRemove', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'typingStart', fn: fun(userId: string, channelId: string, timestamp: string)): function
---@overload fun(name: 'userUpdate', fn: fun(user: User)): function
---@overload fun(name: 'voiceConnect', fn: fun(member: Member)): function
---@overload fun(name: 'voiceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'voiceChannelJoin', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'voiceChannelLeave', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'webhooksUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'debug', fn: fun(message: string)): function
---@overload fun(name: 'info', fn: fun(message: string)): function
---@overload fun(name: 'warning', fn: fun(message: string)): function
---@overload fun(name: 'error', fn: fun(message: string)): function
---@overload fun(name: 'heartbeat', fn: fun(shardId: number, latency: number)): function
---@overload fun(name: 'raw', fn: fun(json: string)): function
function Client:onSync(name, fn) end
---Subscribes a callback to be called only the first time this event is emitted. Callbacks registered with this method are not automatically wrapped as a coroutine. Returns the original callback for convenience.
---@param name clientEvents
---@param fn function
---@return function
---@overload fun(name: 'ready', fn: fun()): function
---@overload fun(name: 'shardReady', fn: fun(shardId: number)): function
---@overload fun(name: 'shardResumed', fn: fun(shardId: number)): function
---@overload fun(name: 'channelCreate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelUpdate', fn: fun(channel: Channel)): function
---@overload fun(name: 'channelDelete', fn: fun(channel: Channel)): function
---@overload fun(name: 'recipientAdd', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'recipientRemove', fn: fun(channel: Channel, user: User)): function
---@overload fun(name: 'guildAvailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildCreate', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildUnavailable', fn: fun(guild: Guild)): function
---@overload fun(name: 'guildDelete', fn: fun(guild: Guild)): function
---@overload fun(name: 'userBan', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'userUnban', fn: fun(user: User, guild: Guild)): function
---@overload fun(name: 'emojisUpdate', fn: fun(guild: Guild)): function
---@overload fun(name: 'memberJoin', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberLeave', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'memberUpdate', fn: fun(member: Member, guild: Guild)): function
---@overload fun(name: 'roleCreate', fn: fun(role: Role)): function
---@overload fun(name: 'roleUpdate', fn: fun(role: Role)): function
---@overload fun(name: 'roleDelete', fn: fun(role: Role)): function
---@overload fun(name: 'messageCreate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdate', fn: fun(message: Message)): function
---@overload fun(name: 'messageUpdateUncached', fn: fun(channel: TextChannel, messageId: string)): function
---@overload fun(name: 'reactionAdd', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionAddUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'reactionRemove', fn: fun(reaction: Reaction, userId: string)): function
---@overload fun(name: 'reactionRemoveUncached', fn: fun(channel: TextChannel, messageId: string, hash: string, userId: string)): function
---@overload fun(name: 'pinsUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'presenceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'relationshipUpdate', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipAdd', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'relationshipRemove', fn: fun(relationship: Relationship)): function
---@overload fun(name: 'typingStart', fn: fun(userId: string, channelId: string, timestamp: string)): function
---@overload fun(name: 'userUpdate', fn: fun(user: User)): function
---@overload fun(name: 'voiceConnect', fn: fun(member: Member)): function
---@overload fun(name: 'voiceUpdate', fn: fun(member: Member)): function
---@overload fun(name: 'voiceChannelJoin', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'voiceChannelLeave', fn: fun(member: Member, channel: GuildVoiceChannel)): function
---@overload fun(name: 'webhooksUpdate', fn: fun(channel: TextChannel)): function
---@overload fun(name: 'debug', fn: fun(message: string)): function
---@overload fun(name: 'info', fn: fun(message: string)): function
---@overload fun(name: 'warning', fn: fun(message: string)): function
---@overload fun(name: 'error', fn: fun(message: string)): function
---@overload fun(name: 'heartbeat', fn: fun(shardId: number, latency: number)): function
---@overload fun(name: 'raw', fn: fun(json: string)): function
function Client:onceSync(name, fn) end

--- Send a debug level(4) message
---
--- Used for all HTTP requests, all gateway events, gateway debugging information
---@param msg string
---@vararg any
function Client:debug(msg, ...) end

--- Send an info level(3) message
---
--- Used for messages about connecting to the gateway, launching shards, receiving select gateway events
---@param msg string
---@vararg any
function Client:info(msg, ...) end

--- Send a warning level(2) message
---
--- Used for uncached objects and unhandled gateway events, unacknowledged heartbeats, gateway reconnections
---@param msg string
---@vararg any
function Client:warning(msg, ...) end

--- Send an error level(1) message
---
--- Used for API request failures (HTTP 4xx/5xx), sharding issues, authentication issues
---@param msg string
---@vararg any
function Client:error(msg, ...) end

--- The Lua language does not have classes, but it does have all of the tools needed to write them.
--- Discordia uses a custom class system that was written explicitly to encapsulate data provided by Discord in intuitive, efficient structures.
---
--- The `class` module used by Discordia is available to users in the main Discordia module.
--- The class module is both the module table and a callable class constructor.
---
--- ```lua
--- local discordia = require('discordia')
--- local class = discordia.class
--- ```
---
--- ## Constructing Classes and Objects
---
--- All Discordia classes must be uniquely named and must have an `__init` method.
--- `UpperCamelCase` is used for class names while `lowerCamelCase` is used for public instances, properties, and methods.
---
--- ```lua
--- local Apple = class('Apple') -- construct a new class
---
--- function Apple:__init(color) -- define the initializer
---   ...
--- end
---
--- local apple = Apple('red') -- call the class table to instantiate a new object
--- ```
---
--- ## Properties
---
--- Discordia enforces a "protected" property policy.
--- All new properties written directly to class objects must be prefixed with an underscore.
--- Directly accessing underscored properties outside of the class definitions is not recommended.
--- Additionally, to avoid potential compatibility issues, **writing custom properties to pre-defined Discordia classes is not recommended**.
---
--- ```lua
--- local Apple = class('Apple')
---
--- function Apple:__init(color)
---	self._color = color -- define a "protected" property
--- end
--- ```
---
--- Because of this underscore policy, Discordia classes also have **getters** and **setters** that can be used to define public properties.
--- These are empty tables and should be populated by functions where getters return a value and setters modify a property.
--- Note that an explicit `self` must be passed for these functions.
---
--- ```lua
--- local Apple, get, set = class('Apple') -- multiple return values
---
--- function Apple:__init(color)
---	self._color = color
--- end
---
--- function get.color(self) -- define a getter
---	return self._color
--- end
---
--- function set.color(self, color) -- define a setter
---   self._color = color
--- end
--- ```
---
--- With getters and setters, you can indirectly get/access and set/mutate protected (underscored) properties without having to use a method.
--- More importantly, if a setter is not defined for a specific property, Discordia will prevent users from overwriting that property.
--- Note Discordia itself never uses setters, but the option is available for people who want to make their own classes.
---
--- ```lua
--- local apple = Apple('red')
--- print(apple.color) -- 'red'
---
--- apple.color = 'green'
--- print(apple.color) -- 'green'
--- ```
---
--- ### Member Methods
---
--- Member methods are defined and called using Lua's colon notation so that an implicit `self` is passed to the function.
---
--- ```lua
--- local Apple = class('Apple')
---
--- function Apple:__init(color)
---	self._color = color
--- end
---
--- function Apple:getColor() -- define a member method
---   return self._color
--- end
---
--- local user = Apple('red')
--- print(user:getColor()) -- 'red'
--- ```
---
--- ### Static Methods
---
--- Static methods are defined and called using Lua's dot notation.
--- No implicit (or explicit) self is required for static methods.
---
--- ```lua
--- local colors = {'red', 'yellow', 'green'}
---
--- function Apple.random() -- returns a random apple object
---	return Apple(colors[math.random(#colors)])
--- end
--- ```
---
--- ## Inheritance
---
--- Discordia classes support single and multiple inheritance.
--- Base or super classes are passed to the class constructor.
---
--- ```lua
--- local Fruit = class('Fruit') -- Fruit is a base class
---
--- function Fruit:__init(color)
---	self._color = color
--- end
---
--- function Fruit:getColor()
---	return self._color
--- end
---
--- local Apple = class('Apple', Fruit) -- Apple inherits from Fruit
---
--- function Apple:__init(color)
--- 	Fruit.__init(self, color) -- base constructor must be explicitly called
--- end
---
--- local apple = Apple('red')
---
--- print(apple:getColor()) -- 'red'; method inherited from Fruit
--- ```
---
--- ## Utilities
---
--- The class module contains a variety of tables and functions that may be useful to regular users.
---
--- #### classes
---
--- Table of all defined classes, indexed by name.
---
---@class class
---@field public classes table<string, any>
local class = {}

---@type class | fun(name: string, ...): any, table, table
class = class

--- Function that returns true only if the provided argument is a Discordia class module.
---
--- ```lua
--- print(class.isClass(Color)) -- true
--- print(class.isClass(1337)) -- false
--- ```
---@param obj any
---@return boolean
function class.isClass(obj) end

--- Function that returns true only if the provided argument is an instance of a Discordia class.
---
--- ```lua
--- local color = Color(...)
--- print(class.isObject(color)) -- true
--- print(class.isObject(1337)) -- false
--- ```
---@param obj any
---@return boolean
function class.isObject(obj) end

--- Function that returns true if the first argument is a subclass of the second argument.
--- Note that classes are considered to be subclasses of themselves.
---
--- ```lua
--- print(class.isSubclass(TextChannel, Channel)) -- true
--- print(class.isSubclass(Color, Channel)) -- false
--- print(class.isSubclass(Channel, Channel)) -- true
--- ```
---@param obj any
---@param obj2 any
---@return boolean
function class.isSubclass(obj, obj2) end

--- Function that returns the type of the provided argument.
--- If the argument is a Discordia object, then this will return the name of its class; otherwise, it will return the result of calling Lua's global `type` function.
---
--- ```lua
--- print(class.type(color)) -- 'Color'
--- print(class.type(1337)) -- 'number'
--- ```
--- @param obj any
--- @return string
function class.type(obj) end

--- Function that returns the number of each class instance currently alive (ie, not garbage collected) in table form.
---
--- ```lua
--- local data = class.profile()
--- for name, count in pairs(data) do
---	print(name, count)
--- end
--- ```
---@return table<string, number>
function class.profile() end

--- gameType enum
---@class enums_gameType
---@field public custom number | "4"
---@field public listening number | "2"
---@field public streaming number | "1"
---@field public default number | "0"


--- messageType enum
---@class enums_messageType
---@field public call number | "3"
---@field public channelNameChange number | "4"
---@field public pinnedMessage number | "6"
---@field public memberJoin number | "7"
---@field public recipientRemove number | "2"
---@field public recipientAdd number | "1"
---@field public premiumGuildSubscriptionTier1 number | "9"
---@field public premiumGuildSubscriptionTier3 number | "11"
---@field public premiumGuildSubscription number | "8"
---@field public premiumGuildSubscriptionTier2 number | "10"
---@field public channelIconchange number | "5"
---@field public default number | "0"


--- activityType enum
---@class enums_activityType
---@field public custom number | "4"
---@field public listening number | "2"
---@field public streaming number | "1"
---@field public default number | "0"


--- verificationLevel enum
---@class enums_verificationLevel
---@field public none number | "0"
---@field public medium number | "2"
---@field public high number | "3"
---@field public low number | "1"
---@field public veryHigh number | "4"


--- messageFlag enum
---@class enums_messageFlag
---@field public suppressEmbeds number | "4"
---@field public urgent number | "16"
---@field public isCrosspost number | "2"
---@field public sourceMessageDeleted number | "8"
---@field public crossposted number | "1"


--- webhookType enum
---@class enums_webhookType
---@field public incoming number | "1"
---@field public channelFollower number | "2"


--- notificationSetting enum
---@class enums_notificationSetting
---@field public allMessages number | "0"
---@field public onlyMentions number | "1"


--- logLevel enum
---@class enums_logLevel
---@field public none number | "0"
---@field public info number | "3"
---@field public debug number | "4"
---@field public error number | "1"
---@field public warning number | "2"


--- relationshipType enum
---@class enums_relationshipType
---@field public none number | "0"
---@field public friend number | "1"
---@field public blocked number | "2"
---@field public pendingOutgoing number | "4"
---@field public pendingIncoming number | "3"


--- defaultAvatar enum
---@class enums_defaultAvatar
---@field public blurple number | "0"
---@field public green number | "2"
---@field public gray number | "1"
---@field public red number | "4"
---@field public orange number | "3"


--- explicitContentLevel enum
---@class enums_explicitContentLevel
---@field public none number | "0"
---@field public medium number | "1"
---@field public high number | "2"


--- actionType enum
---@class enums_actionType
---@field public memberUpdate number | "24"
---@field public messageBulkDelete number | "73"
---@field public webhookDelete number | "52"
---@field public channelDelete number | "12"
---@field public messageDelete number | "72"
---@field public channelOverwriteDelete number | "15"
---@field public roleDelete number | "32"
---@field public channelUpdate number | "11"
---@field public inviteCreate number | "40"
---@field public messageUnpin number | "75"
---@field public inviteUpdate number | "41"
---@field public memberMove number | "26"
---@field public messagePin number | "74"
---@field public channelOverwriteUpdate number | "14"
---@field public integrationDelete number | "82"
---@field public webhookUpdate number | "51"
---@field public memberBanAdd number | "22"
---@field public inviteDelete number | "42"
---@field public channelOverwriteCreate number | "13"
---@field public emojiCreate number | "60"
---@field public memberPrune number | "21"
---@field public channelCreate number | "10"
---@field public integrationUpdate number | "81"
---@field public webhookCreate number | "50"
---@field public emojiDelete number | "62"
---@field public memberBanRemove number | "23"
---@field public integrationCreate number | "80"
---@field public memberDisconnect number | "27"
---@field public guildUpdate number | "1"
---@field public memberRoleUpdate number | "25"
---@field public memberKick number | "20"
---@field public roleUpdate number | "31"
---@field public roleCreate number | "30"
---@field public botAdd number | "28"
---@field public emojiUpdate number | "61"


--- permission enum
---@class enums_permission
---@field public manageGuild number | "32"
---@field public createInstantInvite number | "1"
---@field public mentionEveryone number | "131072"
---@field public manageRoles number | "268435456"
---@field public addReactions number | "64"
---@field public sendTextToSpeech number | "4096"
---@field public readMessageHistory number | "65536"
---@field public manageChannels number | "16"
---@field public administrator number | "8"
---@field public manageWebhooks number | "536870912"
---@field public viewAuditLog number | "128"
---@field public manageEmojis number | "1073741824"
---@field public attachFiles number | "32768"
---@field public moveMembers number | "16777216"
---@field public banMembers number | "4"
---@field public sendMessages number | "2048"
---@field public manageMessages number | "8192"
---@field public manageNicknames number | "134217728"
---@field public useVoiceActivity number | "33554432"
---@field public speak number | "2097152"
---@field public readMessages number | "1024"
---@field public connect number | "1048576"
---@field public kickMembers number | "2"
---@field public changeNickname number | "67108864"
---@field public deafenMembers number | "8388608"
---@field public muteMembers number | "4194304"
---@field public prioritySpeaker number | "256"
---@field public useExternalEmojis number | "262144"
---@field public embedLinks number | "16384"
---@field public stream number | "512"


--- status enum
---@class enums_status
---@field public invisible string | "'invisible'"
---@field public idle string | "'idle'"
---@field public doNotDisturb string | "'dnd'"
---@field public online string | "'online'"


--- premiumTier enum
---@class enums_premiumTier
---@field public none number | "0"
---@field public tier2 number | "2"
---@field public tier3 number | "3"
---@field public tier1 number | "1"


--- channelType enum
---@class enums_channelType
---@field public private number | "1"
---@field public group number | "3"
---@field public category number | "4"
---@field public news number | "5"
---@field public voice number | "2"
---@field public text number | "0"
---@field public gameType enums_gameType
---@field public messageType enums_messageType
---@field public activityType enums_activityType
---@field public verificationLevel enums_verificationLevel
---@field public messageFlag enums_messageFlag
---@field public webhookType enums_webhookType
---@field public notificationSetting enums_notificationSetting
---@field public logLevel enums_logLevel
---@field public relationshipType enums_relationshipType
---@field public defaultAvatar enums_defaultAvatar
---@field public explicitContentLevel enums_explicitContentLevel
---@field public actionType enums_actionType
---@field public permission enums_permission
---@field public status enums_status
---@field public premiumTier enums_premiumTier
---@field public channelType enums_channelType
---@class enums
--- The Discord API uses numbers to represent certain data types.
--- For convenience, these are enumerated in Discord as special read-only tables, found in the main Discordia module.
--- All available enumerations are listed at the end of this page.
---
--- ```lua
--- local discordia = require('discordia')
--- local enums = discordia.enums
--- ```
---
--- Enumerations (enums) can be accessed like a regular Lua table, but they cannot be modified.
--- This is completely optional, but it is generally easier to use and read enumerations than it is to use and read plain numbers.
--- For example, given a text channel object, the following are logically equivalent:
---
--- ```lua
--- if channel.type == 0 then
---   print('This is a text channel!')
--- end
---
--- if channel.type == enums.channelType.text then
---   print('This is a text channel!')
--- end
---
--- print(enums.verificationLevel.low) -- 1
--- ```
---
--- Additionally, enumerations work in reverse.
--- If you have the number, but you want to recall the human-readable version, simply call the enum;
--- it will return a string if the enumeration is valid.
---
--- ```lua
--- print(enums.channelType(channel.type)) -- 'text'
--- print(enums.verificationLevel(1)) -- 'low'
--- ```
---
--- If necessary, custom enumerations can be written using the enum constructor:
---
--- ```lua
--- local fruit = enums.enum {
---	apple =  0,
---	orange = 1,
---	banana = 2,
---	cherry = 3,
--- }
--- ```
---
--- ## Discord Enumerations
---
--- The enumerations are designed to be compatible with the Discord API. They are not necessarily unique to Discordia.
local enums = {}

--- Create a new enum
---@generic T
---@param data T
---@return T enum The newly constructed enum
function enums.enum(data) end

--- Extensions related to tables
---@class ext_table
---@overload fun()
local tableExt = {}

--- Returns the total number of elements in a table. This uses the global `pairs` function and respects any `__pairs` metamethods.
---@param tbl table
---@return number
function tableExt.count(tbl) end

--- Returns the total number of elements in a table, recursively.
--- If a table is encountered, it is recursively counted instead of being directly added to the total count.
--- This uses the global `pairs` function and respects any `__pairs` metamethods.
---@param tbl table
---@return number
function tableExt.deepcount(tbl) end

--- Returns a copy of the original table, recursively.
--- If a table is encountered, it is recursively deep-copied. Metatables are not copied.
---@param tbl table
---@return table
function tableExt.copy(tbl) end

--- Returns a copy of the original table, recursively.
--- If a table is encountered, it is recursively deep-copied. Metatables are not copied.
---@param tbl table
---@return table
function tableExt.deepcopy(tbl) end

--- Reverses the elements of an array-like table in place.
---@param tbl any[]
function tableExt.reverse(tbl) end

--- Returns a copy of an array-like table with its elements in reverse order.
--- The original table remains unchanged.
---@param tbl any[]
---@return any[]
function tableExt.reversed(tbl) end

--- Returns a new array-like table where all of its values are the keys of the original table.
---@param tbl table
---@return any[]
function tableExt.keys(tbl) end

--- Returns a new array-like table where all of its values are the values of the original table.
---@param tbl table
---@return any[]
function tableExt.values(tbl) end

--- Returns a random (index, value) pair from an array-like table.
---@param tbl any[]
---@return number, any
function tableExt.randomipair(tbl) end

--- Returns a random (key, value) pair from a dictionary-like table.
---@param tbl table
---@return any, any
function tableExt.randompair(tbl) end

--- Returns a copy of an array-like table sorted using Lua's `table.sort`.
---@param tbl any[]
---@param fn function
---@return any[]
function tableExt.sorted(tbl, fn) end

--- Iterates through a table until it finds a value that is equal to `value` according to the `==` operator.
--- The key is returned if a match is found.
---@param tbl table
---@param value any
---@return any
function tableExt.search(tbl, value) end

--- Returns a new table that is a slice of the original, defined by the start and stop bounds and the step size.
--- Default start, stop, and step values are 1, #tbl, and 1, respectively.
---@param tbl table
---@param start number
---@param stop number
---@param step number
---@return table
---@overload fun(tbl: table):table
---@overload fun(tbl: table, start: number):table
---@overload fun(tbl: table, start: number, stop: number):table
---@overload fun(tbl: table, start: number, stop: number, step: number):table
function tableExt.slice(tbl, start, stop, step) end

--- Utilities related to strings
---@class ext_string
---@overload fun()
local stringExt = {}

--- Splits a string into a table of specifically delimited sub-strings.
--- If the delimiter is omitted or empty, the string is split into a table of characters.
---@param str string
---@param delim string
---@return table
---@overload fun(str: string):table
function stringExt.split(str, delim) end

--- Returns a new string with all whitespace removed from the left and right sides of the original string.
---@param str string
---@return string
function stringExt.trim(str) end

---@alias alignment string | "'left'" | "'right'" | "'center'"

--- Returns a new string that is padded up to the desired length.
--- The alignment, either `left`, `right`, or `center` with left being the default, defines the placement of the original string.
--- The default pattern is a single space.
---@param str string
---@param len number
---@param align alignment
---@param pattern string
---@return string
---@overload fun(str: string, len: number):string
---@overload fun(str: string, len: number, align: alignment):string
function stringExt.pad(str, len, align, pattern) end

--- Returns whether a string starts with a specified sub-string or pattern.
--- The plain parameter is the same as that used in Lua's `string.find`.
---@param str string
---@param pattern string
---@param plain boolean
---@return boolean
---@overload fun(str: string, pattern: string):boolean
function stringExt.startswith(str, pattern, plain) end

--- Returns whether a string ends with a specified sub-string or pattern.
--- The plain parameter is the same as that used in Lua's `string.find`.
---@param str string
---@param pattern string
---@param plain boolean
---@return boolean
---@overload fun(str: string, pattern: string):boolean
function stringExt.endswith(str, pattern, plain) end

--- Returns the Levenshtein distance between two strings.
--- A higher number indicates a greater distance.
---@param str1 string
---@param str2 string
---@return number
function stringExt.levenshtein(str1, str2) end

--- Returns a string of random characters with the specified length.
--- If provided, the min and max bounds cannot be outside 0 to 255.
--- Use 32 to 126 for printable ASCII characters.
---@param len number
---@param min number
---@param max number
---@return string
---@overload fun(len: number):string
---@overload fun(len: number, min: number):string
function stringExt.random(len, min, max) end

--- Utilities related to math
---@class ext_math
---@overload fun()
local mathExt = {}

--- Returns a number that is at least as small as the minimum value and at most as large as the maximum value, inclusively.
--- If the original number is already with the bounds, the same number is returned.
---@param n number
---@param min number
---@param max number
---@return number
function mathExt.min(n, min, max) end

--- Returns a number that is rounded to the nearest defined digit.
--- The nearest integer is returned if the digit is omitted.
--- Negative values can be used for higher order places.
---@param n number
---@param digits number
---@return number
---@overload fun(n: number):number
function mathExt.round(n, digits) end

--- **Discordia** has some built-in Lua standard library extensions.
--- These provide complementary or supplementary, commonly used functions that the Lua standard library does not provide.
---
--- Extensions can be used directly...
---
--- ```lua
--- local str = "  abc  "
--- print(discordia.extensions.string.trim(str)) -- "abc"
--- ```
---
--- ... or they can be loaded into the global tables:
---
--- ```lua
--- local str = "  abc  "
--- discordia.extensions.string()
--- print(string.trim(str)) -- "abc"
--- ```
---
--- Note that calling the whole extensions module will load all sub-modules:
---
--- ```lua
--- discordia.extensions()
--- ```
---@class extensions
---@field public string ext_string
---@field public table ext_table
---@field public math ext_math

---@class package
---@field public license string | "'MIT'"
---@field public files string[]
---@field public version string | "'2.8.4'"
---@field public author string | "'Sinister Rectus'"
---@field public dependencies string[]
---@field public tags string[]
---@field public name string | "'SinisterRectus/discordia'"
---@field public homepage string | "'https://github.com/SinisterRectus/Discordia'"


--- To write a Discordia application, the library's main module must be required. If it's in a deps or libs folder, simply require it by name.
--- If you've manually installed the library elsewhere, then you will need to provide a relative or full path to the Discordia directory.
---
--- ```lua
--- local discordia = require('discordia')
--- ```
---
--- ## Classes
---
--- Discordia has many custom classes. Some of them are instantiated only by the library and not by users.
--- The classes that may be safely instantiated by users are included in the Discordia module:
---
--- * Client
--- * Clock
--- * Color
--- * Date
--- * Deque
--- * Emitter
--- * Logger
--- * Mutex
--- * Permissions
--- * Stopwatch
--- * Time
---
--- ## Sub-Modules
---
--- In addition to classes, the Discordia module has some generic modules that may be helpful in writing your applications.
---
--- ### class
---
--- Used to create custom classes and provides tools for inspecting classes and class instances.
---
--- ### enums
---
--- Used to create custom enumerations or access a variety of pre-defined enumerations.
---
--- ### extensions
---
--- Extensions to the Lua standard library. Functions can be used directly or can be loaded into the Lua global tables.
---
--- ### package
---
--- Not to be confused with the global Lua module, this Discordia's literal package metadata, used to define the module when it is uploaded to lit, the Luvit Invention Toolkit.
---
--- ### storage
---
--- An empty table that can be used to store user data.
--- This may be used an alternative to storing values on class instances or in global variables, both of which are not recommended.
---
---@class discordia
---@field public Client Client
---@field public Clock Clock
---@field public Color Color
---@field public Date Date
---@field public Deque Deque
---@field public Emitter Emitter
---@field public Logger Logger
---@field public Mutex Mutex
---@field public Permissions Permissions
---@field public Stopwatch Stopwatch
---@field public Time Time
---@field public class class
---@field public enums enums
---@field public extensions extensions | function
---@field public package package
---@field public storage table<any, any>
local discordia = {}
