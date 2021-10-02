local function drawAscii(font,text)
	text = text:gsub("\"","\\\"");
	local proc = io.popen(("figlet -f \"%s\" \"%s\""):format(font,text));
	local ret = proc:read("*a");
	proc:close();
	os.execute("title " .. _G.app.name);
	return ret;
end

return {
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
	};
	["열차그리기"] = {
		alias = {"train"};
		reply = "그리고 있어요 . . .";
		func = function(replyMsg,message,args,Content)
			replyMsg:setContent(("```\n%s```"):format(drawAscii("Train",Content.rawArgs)));
		end;
	};
};

-- adapt(function (callback)
--	 print(callback);
--	 replyMsg:setContent("```\n" .. callback .. "```");
-- end,coroutine.wrap(function ()
--	 print("calling figlet");
--	 local proc = io.popen(("figlet -f \"Soft\" \"%s\""):format(raw));
--	 local ret = proc:read("*a");
--	 proc:close();
--	 print("closed, return data",ret);
--	 return ret;
-- end));