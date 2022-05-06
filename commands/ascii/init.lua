
local figlet = jit.os == "Windows" and "figlet.cmd" or "figlet";
local function drawAscii(font,text)
	text = text:gsub("\"","\\\"");

	local newProcess = spawn(figlet,{
		args = {
			'-f',font,text
		};
		hide = true;
		stdio = {nil,true,true};
	});
	local this = "";
	for str in newProcess.stdout.read do
		this = this .. str;
	end
	newProcess.waitExit();
	-- os.execute("title " .. _G.app.name);
	return this;
end

---@type table<string, Command>
local export = {
	["탱크"] = {
		reply = (
			"░░░░░░███████ ]▄▄▄▄▄▄▄▄▃\n" ..
			"▂▄▅█████████▅▄▃▂\n" ..
			"I███████████████████].\n" ..
			"◥⊙▲⊙▲⊙▲⊙▲⊙▲⊙▲⊙◤\n"
		);
	};
	["아스키"] = {
		alias = {"아스키 아트","아스키아트","ascii","글자아트","글자 아트"};
		reply = "그리고 있어요 . . .";
		func = function(replyMsg,message,args,Content)
			replyMsg:setContent(("```\n%s```"):format(drawAscii("Soft",Content.rawArgs)));
		end;
		onSlash = commonSlashCommand {
			optionRequired = false;
			description = "영문 아스키 아트를 그립니다!";
		};
	};
	["열차그리기"] = {
		alias = {"train"};
		reply = "그리고 있어요 . . .";
		func = function(replyMsg,message,args,Content)
			replyMsg:setContent(("```\n%s```"):format(drawAscii("Train",Content.rawArgs)));
		end;
		onSlash = commonSlashCommand {
			optionRequired = false;
			description = "영문 아스키 아트를 그립니다!";
		};
	};
};
return export;
