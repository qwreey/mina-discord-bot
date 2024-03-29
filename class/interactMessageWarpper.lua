-- slash command callback message into message object (simulate)
local insert = table.insert;

local interactMessageWarpper = {};
interactMessageWarpper.__index = interactMessageWarpper;
function interactMessageWarpper:__edit(d,private)
	local this = self.this;

	-- content from string
	if type(d) == "string" then
		d = {
			content = d;
		};
	end

	-- embeds
	local embed = d.embed;
	if embed then
		d.embed = nil;
		local embeds = d.embeds;
		if not embeds then
			embeds = {};
			d.embeds = embeds;
		end
		if next(embed) then
			insert(embeds,embed);
		end
	end

	local content = d.content;
	if (not self.noInteractionHeader) and content then
		local user = this and this.user;
		local str = self.commandStr;
		if str and user then
			d.content = ("> %s:%s%s\n"):format(
				tostring(user and user.mentionString or "@NULL"),
				(str and str:match("\n")) and "\n> " or " ",
				tostring(str or "'NULL'"):gsub("\n","\n> ")
					:gsub("<[@&](%d+)>",function (str)
						return ("@%s"):format(tostring(str));
					end):gsub("@everyone","everyone"):gsub("@here","here")
			) .. content;
		end
	end

	-- merge with previons
	local last = self.last;
	if last then
		for i,v in pairs(d) do
			last[i] = v;
		end
	end
	last = last or d;

	-- update
	if self.replyed then
		this:update(last);
	else
		this:reply(last,private);
		self.replyed = true;
	end
	self.last = last;
	return self;
end
function interactMessageWarpper:update(d,private)
	if not d then
		return;
	end
	if type(d) == "table" then
		d.reference = false;
	end
	self:__edit(d,private);
end;
function interactMessageWarpper:setContent(str)
	self:__edit(tostring(str));
end;
function interactMessageWarpper:setEmbed(embed)
	self:__edit({embeds = {embed}});
end
function interactMessageWarpper:delete()
	self.this:delete();
end
function interactMessageWarpper:reply(d)
	return self.this.channel:send(d);
end
function interactMessageWarpper.new(this,commandStr,noInteractionHeader)
	local self = {
		this = this;
		commandStr = commandStr;
		id = this.id;
		slashCommand = true;
		noInteractionHeader = noInteractionHeader;
	};
	setmetatable(self,interactMessageWarpper);
	return self;
end

return interactMessageWarpper;
