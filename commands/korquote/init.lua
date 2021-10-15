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

return {
	["한글명언"] = {
		alias = {"한국어명언","한글 명언","한국어 명언","명언","korean quote","kor quote","koreanquote","korquote"};
		reply = "잠시만 기달려주세요 . . .";
		func = function(replyMsg,message,args,Content)
			replyMsg:update {
				embed = korquoteEmbed:embed(korquoteRequest.fetch());
				content = "한글 명언을 가져왔습니다";
			};
		end;
	};
	["타자연습 한글"] = {
		alias = {"타자연습 한국어","타자연습한글","타자한글","타자 한글","타자 한국어","타자연습한글"};
		reply = "잠시만 기달려주세요 . . .";
		-- embed = "잠시 뒤에 보이는 문구를 재빠르게 입력하세요!";
		func = function(replyMsg,message,args,Content)
			local text = korquoteRequest.fetch():gsub("[^ ](%(.-%))",""):gsub(" +"," "); -- 한자를 지우기 위해서 패턴 매칭을 사용합니다
			local expected = text:gsub("[%.,%(%)%[%]%*%-_%+=;:'\"]","");
			local lenText = utf8.len(text);
			local timeout = lenText * 10000;

			replyMsg:update {
				content = "아래의 문구를 따라 입력해주세요";
				embed = {
					description = text:gsub(" "," " .. zeroWidthSpace),
					footer = {text = ("제한 시간 : %s"):format(formatTime(timeout))}
				};
			};

			local startTime = os.clock();
			local isEnded = false;
			local newHook = hook.new {
				func = function (self,contents)
					local endTime = os.clock();
					if contents.user.id == Content.user.id then
						local userText = contents.text:gsub(" +"," "):gsub("[%.,%(%)%[%]%*%-_%+=;:'\"]","");
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
						elseif userText:match(zeroWidthSpace) then
							newMessage:reply {
								content = "복사/붇여넣기가 감지되었습니다!! 게임을 종료합니다";
								reference = {message = newMessage, mention = true};
							};
							self:detach();
						else
							newMessage:reply {
								content = "잘못된 글자가 있습니다!";
								reference = {message = newMessage, mention = true};
							};
						end
					end
				end;
			};
			newHook:attach();

			timeout(timeout,function ()
				if not isEnded then
					newHook:detach();
					message:reply {
						content = "시간 종료!! 제한 시간 내에 입력하지 못했어요";
						reference = {message = message, mention = true};
					};
				end
			end);
		end;
	};
};
