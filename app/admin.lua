--[[
Admin command
]]

local injectLogger = {};
local prettyPrint = prettyPrint or require("pretty-print");

---@param Text string
---@param message Message
local function adminCmd(Text,message) -- 봇 관리 커맨드 실행 함수
	local cmd = Text:match("^[^ ]+");
	if not cmd then return; end
	local args = Text:sub(#cmd+2,-1);
	if ACCOUNTData.testing then return end
	if (cmd == "!!!stop" or cmd == "!!!kill") then
		message:reply('> 프로그램 죽이는중 . . .');
		os.exit(exitCodes.exit); -- 프로그램 킬
	elseif (cmd == "!!!restart" or cmd == "!!!reload") then
		logger.info("Restarting ...");
		message:reply('> 재시작중 . . . (2초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 프로그램 다시시작
	elseif (cmd == "!!!pull" or cmd == "!!!download") then
		logger.info("Download codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 받는중 . . .');
		_G.livereloadEnabled = false;
		os.execute("git pull"); -- git 에서 변동사항 가져와 적용하기
		_G.livereloadEnabled = true;
		msg:setContent('> 적용중 . . . (3초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 다운로드 (리로드)
	elseif (cmd == "!!!push" or cmd == "!!!upload") then
		logger.info("Upload codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 코드를 업로드중 . . .');
		_G.livereloadEnabled = false;
		os.execute("git add .&&git commit -m 'MINA : Upload in main code (bot.lua)'&&git push");
		_G.livereloadEnabled = true;
		msg:setContent('> 완료!');
		return; -- 업로드
	elseif (cmd == "!!!sync") then
		logger.info("Sync codes ...");
		local msg = message:reply('> GITHUB qwreey75/MINA_DiscordBot 로 부터 코드를 동기화중 . . . (8초 내로 완료됩니다)');
		_G.livereloadEnabled = false;
		os.execute('git add .&&git commit -m "MINA : Sync in main code (Bot.lua)"&&git pull&&git push');
		_G.livereloadEnabled = true;
		msg:setContent('> 적용중 . . . (3초 내로 완료됩니다)');
		reloadBot();
		os.exit(exitCodes.reload); -- 동기화 (리로드)
	elseif (cmd == "!!!help" or cmd == "!!!cmds") then
		message:reply(
			'!!!help 또는 !!!cmds : 이 창을 띄웁니다\n' ..
			'!!!stop 또는 !!!kill : 봇을 멈춥니다\n' ..
			'!!!restart 또는 !!!reload : 봇을 다시로드 시킵니다\n' ..
			'!!!pull 또는 !!!download : 클라우드로부터 코드를 내려받고 다시 시작합니다\n' ..
			'!!!push 또는 !!!upload : 클라우드로 코드를 올립니다\n' ..
			'!!!sync : 클라우드와 코드를 동기화 시킵니다 (차이 비교후 병합)\n'
		);
	elseif (cmd == "!!!exe" or cmd == "!!!exec" or cmd == "!!!execute" or cmd == "loadstring") then
		local new = message:reply("[WARN] Executing codes can cause issues on main loop thread!\n[INFO] Executing lua string with env by _G");
		-- first, decoding lua
		local func,err = loadstring("return " .. args);
		if not func then
			func,err = loadstring(args);
		end
		if err or (not func) then
			new:setContent(new.content .. "\n[ERROR] Error occured on loadstring! traceback : " .. tostring(err));
			return;
		end
		local setfenvPassed,setfenvTraceback = pcall(setfenv,func,_G);
		if not setfenvPassed then
			new:setContent(new.content .. "\n[ERROR] Error occured on setting env! traceback : " .. tostring(setfenvTraceback));
		end
		local passed,value = pcall(setfenvTraceback);
		if passed then
			new:setContent(new.content .. "\n[INFO] Execution success! traceback : ```\n" .. tostring(prettyPrint.dump(value,nil,false)) .. "\n```");
		else -- on error
			new:setContent(new.content .. "\n[ERROR] Error occured running function! traceback : ```\n" .. tostring(value) .. "\n```");
		end
	end
end

return adminCmd;
