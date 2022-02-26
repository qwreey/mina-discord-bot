-- warp user's slash command action into message object (simulate)

local interactMessageWarpper = require("class.interactMessageWarpper");

return function (content,interaction,noInteractionHeader)
	local replyMessage;
	return {
		reply = function(self,d,private)
			if not replyMessage then
				replyMessage = interactMessageWarpper.new(interaction,content,noInteractionHeader);
				replyMessage:update(d,private);
				return replyMessage;
			end
			return self.channel:send(d);
		end;
		content = content;
		guild = interaction.guild;
		channel = interaction.channel;
		member = interaction.member;
		author = interaction.user;
		slashCommand = true;
	};
end;
