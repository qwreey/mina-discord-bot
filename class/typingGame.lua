local module = {};
local floor = math.floor;
local splitKoeran = require("class.splitKorean");

local function formatTime(time)
	local sec = math.floor(time % 60);
	local min = math.floor(time / 60);
	return ("%d분 %d 초"):format(min,sec);
end

local zeroWidthSpace = utf8.char(tonumber("200B",16));
local gameForUsers = {};

local stopTypingGame = {
	["멈춰"] = true;
	["끄기"] = true;
	["그만"] = true;
	["stop"] = true;
	["멈춰타자연습"] = true;
	["타자연습멈춰"] = true;
	["그만타자연습"] = true;
	["타자연습그만"] = true;
	["끄기타자연습"] = true;
	["타자연습끄기"] = true;
	["미나멈춰타자연습"] = true;
	["미나타자연습멈춰"] = true;
	["미나그만타자연습"] = true;
	["미나타자연습그만"] = true;
	["미나끄기타자연습"] = true;
	["미나타자연습끄기"] = true;
};
module.gameForUsers = gameForUsers;

---Making new typing game instances
---@param replyMsg Message Replyed message
---@param message Message Message that started this game
---@param Content commandContent inclueds command contents
---@param text string what user should typing
---@param title string title of this typing game (embed title)
---@return nil
function module.new(replyMsg,message,Content,text,title)
	local userId = Content.user.id;
	local channelId = Content.channel.id;
	if gameForUsers[userId] then
		replyMsg:setContent("이미 진행중인 게임이 있습니다!\n> 진행중인 게임을 멈추려면 `타자연습 멈춰` 를 입력해주세요");
	end

	text = text:gsub("[^ ](%(.-%))",""):gsub(" +"," "); -- 한자를 지우기 위해서 패턴 매칭을 사용합니다
	local expected = text:gsub("[ %.,%(%)%[%]%*%-_%+=;:'\"]",""):lower();
	local lenText = utf8.len(text);
	local timeoutMS = lenText * 4500;

	replyMsg:update {
		content = "아래의 문구를 따라 입력해주세요 (제목 미포함)";
		embed = {
			title = title;
			description = text:gsub(" "," " .. zeroWidthSpace),
			footer = {text = ("제한 시간 : %s\n진행중인 게임을 멈추려면 '타자연습 멈춰' 를 입력해주세요"):format(formatTime(timeoutMS / 1000))}
		};
	};

	local startTime = os.clock();
	local isEnded = false;
	local timer;
	local newHook = hook.new {
		type = hook.types.before;
		destroy = function (self)
			self:detach();
			gameForUsers[userId] = nil;
			isEnded = true;
			pcall(timer.clearTimer,timer);
		end;
		func = function (self,contents)
			local endTime = os.clock();
			if contents.user.id == userId then
				if contents.channel.id ~= channelId then
					message:reply {
						content = "다른 채널로 이동하여 타자연습 게임을 종료하였습니다!";
						reference = {message = message, mention = true};
					};
					self:destroy();
					return;
				end
				local userText = contents.text:gsub("[ %.,%(%)%[%]%*%-_%+=;:'\"]",""):lower();
				local newMessage = contents.message;
				if expected == userText then
					local tspend = endTime - startTime;
					newMessage:reply {
						content = "끝끝끝ㅌ끄ㅌ!!";
						embed = {
							description = ("걸린 시간 : %s 초!\n타수 : %s(key/m)!"):format(
								tostring(floor(tspend * 1000)/1000),
								tostring(
									floor(
										(utf8.len(splitKoeran.split(text)) / tspend) * 60000
									) / 1000
								)
							);
						};
						reference = {message = newMessage, mention = true};
					};
					self:destroy();
					return true;
				elseif userText:match(zeroWidthSpace) then
					newMessage:reply {
						content = "복사/붇여넣기가 감지되었습니다!! 게임을 종료합니다";
						reference = {message = newMessage, mention = true};
					};
					self:destroy();
					return true;
				elseif stopTypingGame[userText] then
					newMessage:reply {
						content = "타자 연습을 멈췄습니다!";
						reference = {message = newMessage, mention = true};
					};
					self:destroy();
					return true;
				else
					newMessage:reply {
						content = "잘못된 글자가 있습니다!\n> 진행중인 게임을 멈추려면 `타자연습 멈춰` 를 입력해주세요";
						reference = {message = newMessage, mention = true};
					};
					return true
				end
			end
		end;
	};
	newHook:attach();
	gameForUsers[userId] = newHook;

	timer = timeout(timeoutMS,function ()
		if not isEnded then
			pcall(newHook.detach,newHook);
			gameForUsers[userId] = nil;
			message:reply {
				content = "시간 종료!! 제한 시간 내에 입력하지 못했어요";
				reference = {message = message, mention = true};
			};
		end
	end);
end

return module;
