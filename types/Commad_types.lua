---Base of command object, this is will making new command
---@class Command
---@field public disableDm string | boolean | nil whether this command is disabled on direct message. if this value is string, it will shows on channel
---@field public command table | string | nil this is will allow using command with special prefix (server setted prefix like ~)
---@field public alias table | string | nil other name of this command
---@field public reply table|function|string
---@field public func function | nil
---@field public sendToDm string | boolean | nil whether this command should be sent to direct message. if this value is string it will shows on channel
local Command = {};

---Make new reply message, this is can be string or function or table
---@param message Message original user's message
---@param args table table of splited arguments with space
---@param content commandContent inclueds command contents
function Command.reply(message,args,content) end

---Running command functions, this is can be nil
---@param replyMsg Message message that created by self.reply
---@param message Message original user's message
---@param args table table of splited arguments with space
---@param Content commandContent inclueds command contents
---@return nil
function Command.func(replyMsg,message,args,Content) end
