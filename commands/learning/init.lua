
local module = {};

local learn = require "commands.learning.learn";
local errorType = learn.errorType;
--[[

가르치기 명령어
구현채 부분임

]]

local insert = table.insert;
local remove = table.remove;
local time = os.time;

return {
	["배워"] = {
		alias = {"기억해","배워라","배워봐","암기해","가르치기"};
		reply = "외우고 있어요 . . .";
		func = function (replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;

			local what,react = rawArgs:match("(.+)=(.+)");
			what = (what or ""):gsub("^ +",""):gsub(" +$","");
			react = (react or ""):gsub("^ +",""):gsub(" +$","");

			local userData = Content.getUserData();
			local user = Content.user;
			local result = learn.put(what,react,user.id,time(),userData);
			if result then
				if result == errorType.noData then
					return replyMsg:setContent("약관에 동의하지 않아 데이터를 저장할 수 없습니다!");
				elseif result == errorType.onCooltime then
					return replyMsg:setContent("너무 빠르게 가르치고 있어요! 조금만 쉬엄쉬엄 가르켜 주세요!\n> 하나를 가르칠 때 마다 5초의 쿨타임이 있습니다!");
				elseif result == errorType.alreadlyLearnByYou then
					return replyMsg:setContent("이미 그 내용은 가르치셨어요!");
				elseif result == errorType.mentionDetected then
					return replyMsg:setContent("유저 언급을 포함한 내용은 가르칠 수 없어요!");
				elseif result == errorType.channelDetected then
					return replyMsg:setContent("채널 언급을 포함한 내용은 가르칠 수 없어요!");
				elseif result == errorType.linkDetected then
					return replyMsg:setContent("링크를 포함한 반응은 가르칠 수 없어요!");
				elseif result == errorType.devDefined then
					return replyMsg:setContent("개발자가 이미 가르친 내용이에요!");
				elseif result == errorType.nullName then
					return replyMsg:setContent("가르치려는 이름이 비어 있으면 안돼요!");
				elseif result == errorType.nullValue then
					return replyMsg:setContent("가르치려는 내용이 비어 있으면 안돼요!");
				elseif result == errorType.tooLongName then
					return replyMsg:setContent(("'%s' 는 너무 길어요! 가르치려는 이름은 100 자보다 길면 안돼요!"):format(what));
				elseif result == errorType.tooLongValue then
					return replyMsg:setContent(("'%s' 는 너무 길어요! 가르치려는 내용은 200 자보다 길면 안돼요!"):format(react));
				elseif result == errorType.notEnoughLove then
					return replyMsg:setContent(("호감도가 부족해요! 미나에게 가르치려면 20 의 호감도가 필요해요!\n(현재 호감도는 %d 이에요)"):format(userData.love));
				end
				local nameIs;
				for i,v in pairs(errorType) do
					if v == result then
						nameIs = i;
					end
				end
				replyMsg:setContent(("알 수 없는 오류가 발생했습니다.\n```commands.learing.learn.errorType.%s ? got unexpected error type```")
					:format(tostring(nameIs))
				);
			end

			-- set user name
			local username = user.name;
			userData.latestName = username;
			local lastNames = userData.lastName;
			if lastNames[#lastNames] ~= username then
				insert(lastNames,username);
			end
			Content.saveUserData(); -- save everything

			replyMsg:setContent(("'%s' 는 '%s'! 다 외웠어요!\n`호감도 20 을 소모했어요 (현재 호감도는 %d 이에요)`"):format(what,react,userData.love));
		end;
	};
	["잊어"] = {
		alias = {"까먹어","잊어버려","잊어라","잊어줘"};
		reply = "에ㅔㅔㅔㅔㅔㅔㅔㅔㅔ";
		func = function(replyMsg,message,args,Content)

			-- checking arg
			local rawArgs = Content.rawArgs;
			rawArgs = tonumber(rawArgs:match("%d+"));
			if not rawArgs then
				replyMsg:setContent("지울 반응의 아이디를 입력해주세요!￦n> 반응 아이디는 리스트에서 확인할 수 있습니다");
				return;
			end

			-- get user data
			local userData = Content.getUserData();
			if not userData then
				replyMsg:setContent("유저 데이터를 찾지 못했습니다!￦n> 약관 동의가 되어 있는지 확인하세요!");
				return;
			end
			local learned = userData.learned;
			if not learned then
				replyMsg:setContent("아직 가르친 반응이 하나도 없어요!");
				return;
			end

			-- checking object from learned object
			local this = learned[rawArgs];
			if not this then
				replyMsg:setContent(("%d 번째 반응이 존재하지 않아요!"):format(rawArgs));
				return;
			end

			learn.remove(this);
			remove(learned,rawArgs); -- remove from indexs
			userData.lenLearned = userData.lenLearned - 1;
			Content.saveUserData();

			replyMsg:setContent(("'%s'? 그게 뭐였죠? 기억나지가 않아요"):format(rawArgs));
		end;
	};
	["기억"] = {
		alias = {"지식","가르침"};
		reply = "처리중 . . .";
		func = function (replyMsg,message,args,Content)
			
		end;
	};
};