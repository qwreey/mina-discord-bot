local korquoteRequest = require "commands.korquote.request";
local korquoteEmbed = require "commands.korquote.embed";
korquoteRequest:setCRandom(cRandom):setJson(json);
korquoteEmbed:setUrlCode(urlCode);

local function formatTime(time)
	local sec = math.floor(time % 60);
	local min = math.floor(time / 60);
	return ("%d분 %d 초"):format(min,sec);
end

local zeroWidthSpace = utf8.char(tonumber("200B",16));
local gameForUsers = {};

return {
	["한글명언"] = {
		alias = {"명언 한국어","명언 한글","한글명언","한국어명언","한글 명언","한국어 명언","명언","korean quote","kor quote","koreanquote","korquote"};
		reply = "잠시만 기달려주세요 . . .";
		func = function(replyMsg,message,args,Content)
			replyMsg:update {
				embed = korquoteEmbed:embed(korquoteRequest.fetch());
				content = "한글 명언을 가져왔습니다";
			};
		end;
	};
	["타자연습 그만"] = {
		alias = {"멈춰 타자연습","멈춰타자연습","타자연습 멈춰","그만타자연습","그만 타자연습","끄기 타자연습","타자연습 끄기"};
		reply = "잠기만 기달려주세요 . . .";
		func = function(replyMsg,message,args,Content)
			local userId = Content.user.id;
			local game = gameForUsers[userId];
			if game then
				game:detach();
				gameForUsers[userId] = nil;
				replyMsg:setContent("타자 연습을 멈췄습니다!");
			else
				replyMsg:setContent("진행중인 타자연습이 없습니다!");
			end
		end;
	};
	["타자연습 한글"] = {
		alias = {
			"한글 타자연습","한글타자연습","한글타자","한글 타자",
			"한국어 타자","한국어타자","한국어 타자연습",
			"한국어타자연습","타자연습 한국어","타자연습한글",
			"타자한글","타자 한글","타자 한국어","타자연습한글"
		};
		reply = "잠시만 기달려주세요 . . .";
		embed = "잠시 뒤에 보이는 문구를 재빠르게 입력하세요!";
		func = function(replyMsg,message,args,Content)
			local userId = Content.user.id;
			if gameForUsers[userId] then
				replyMsg:setContent("이미 진행중인 게임이 있습니다!\n> 진행중인 게임을 멈추려면 `타자연습 멈춰` 를 입력해주세요");
			end

			local this = korquoteRequest.fetch()
			local text = this.message:gsub("[^ ](%(.-%))",""):gsub(" +"," "); -- 한자를 지우기 위해서 패턴 매칭을 사용합니다
			local expected = text:gsub("[ %.,%(%)%[%]%*%-_%+=;:'\"]","");
			local lenText = utf8.len(text);
			local timeoutMS = lenText * 4500;

			replyMsg:update {
				content = "아래의 문구를 따라 입력해주세요 (제목 미포함)";
				embed = {
					title = this.author;
					description = text:gsub(" "," " .. zeroWidthSpace),
					footer = {text = ("제한 시간 : %s\n진행중인 게임을 멈추려면 **타자연습 멈춰** 를 입력해주세요"):format(formatTime(timeoutMS / 1000))}
				};
			};

			local startTime = os.clock();
			local isEnded = false;
			local newHook = hook.new {
				type = hook.types.before;
				func = function (self,contents)
					local endTime = os.clock();
					if contents.user.id == userId then
						local userText = contents.text:gsub("[ %.,%(%)%[%]%*%-_%+=;:'\"]","");
						local newMessage = contents.message;
						if expected == userText then
							newMessage:reply {
								content = "끝끝끝ㅌ끄ㅌ!!";
								embed = {
									description = ("걸린 시간 : %s 초!"):format(
										tostring(endTime - startTime)
									);
								};
								reference = {message = newMessage, mention = true};
							};
							self:detach();
							gameForUsers[userId] = nil;
							return true;
						elseif userText:match(zeroWidthSpace) then
							newMessage:reply {
								content = "복사/붇여넣기가 감지되었습니다!! 게임을 종료합니다";
								reference = {message = newMessage, mention = true};
							};
							self:detach();
							gameForUsers[userId] = nil;
							return true;
						else
							newMessage:reply {
								content = "잘못된 글자가 있습니다!\n> 진행중인 게임을 멈추려면 `타자연습 멈춰` 를 입력해주세요";
								reference = {message = newMessage, mention = true};
							};
							return true;
						end
					end
				end;
			};
			newHook:attach();
			gameForUsers[userId] = newHook;

			timeout(timeoutMS,function ()
				if not isEnded then
					newHook:detach();
					gameForUsers[userId] = nil;
					message:reply {
						content = "시간 종료!! 제한 시간 내에 입력하지 못했어요";
						reference = {message = message, mention = true};
					};
				end
			end);
		end;
	};
};
