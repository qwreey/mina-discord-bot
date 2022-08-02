
local module = {};

local learn = require "commands.learning.learn";
local errorType = learn.errorType;
local discordia_enchant = _G.discordia_enchant;
local commonSlashCommand = _G.commonSlashCommand;
local components = discordia_enchant.components;
local discordia_enchant_enums = discordia_enchant.enums;
local floor = math.floor;

local help = [[
**가르치기 기능에 대한 도움말입니다**
> 주의! 이 기능으로 가르쳐진 데이터는 다른 모든이가 볼 수 있습니다. 불쾌한 내용을 담지 않도록 조심해주세요!

> 미나 배워 **가르칠것**=**반응**
미나에게 무언가를 가르칩니다! 호감도 20 을 사용해요
예시 : `미나 배워 디스코드가 뭐야?=만능 채팅 플랫폼!`

> 미나 잊어 **(가르친것-순번)**
명령어 `미나 기억` 에서 나온 번호를 사용해서 해당 지식을 지울 수 있습니다!
예시 : `미나 잊어 1` (가장 최근에 가르친것을 잊습니다)

> 미나 기억 **페이지**
지금까지 가르친 모든 내용을 보여줍니다!
제공된 페이지가 없으면 1 번째 페이지를 보여줍니다]];

local posixTime = _G.posixTime;
local insert = table.insert;
local remove = table.remove;
local time = posixTime.now;
local ceil = math.ceil;
local timeAgo = _G.timeAgo;
local concat = table.concat;

local itemsPerPage = 10;
local noNegative = {
	content = zwsp;
	embed = {
		title = ":x: 페이지에 마이너스는 없는것 같아요!";
	};
};
local noData = {
	content = zwsp;
	embed = {
		title = ":x: 유저 데이터가 존재하지 않습니다!\n유저 데이터는 약관 동의 후 부터 저장될 수 있어요!";
	};
};

---@param user User
local function listifyLearn(user,page)
	-- 마이너스인 경우
	if page < 1 then
		return noNegative;
	end
	local userId = user.id

	-- 데이터가 없는 경우
	local data = userData.loadData(userId);
	if not data then
		return noData;
	end

	-- 가르친게 없는 경우
	local learned = data.learned;
	if (not learned) or (#learned == 0) then
		return {
			content = zwsp;
			embed = {
				title = ("**%s** 님이 가르친건 하나도 없어요 :cry:"):format(user.name);
			};
		};
	end

	local title = ("**%s** 님의 기억 - **%d** 페이지"):format(user.name,page);
	local fields = {};
	local startAt,endAt = ((page-1)*itemsPerPage),page*itemsPerPage-1;
	local lenLearned = #learned;
	for index = startAt,endAt do
		local thisId = learned[lenLearned - index];
		if not thisId then
			break;
		end
		local this,name = learn.rawGet(thisId);
		if this then
			local when = this.when;
			insert(fields, {
				name = ("%d 번째 : %s%s"):format(
					index + 1,
					tostring(name),
					when and ((" (%s)"):format(timeAgo(when,time()))) or ""
				);
				value = tostring(this.content):gsub("`","\\`")
			});
		else
			insert(fields,{
				name = ("%d 번째 : (손상됨)"):format(index + 1);
				value = "`값이 손상되었습니다 (파일 시스템 오류일 수 있습니다)`";
			});
		end
	end

	if #fields == 0 then
		return {
			content = zwsp;
			embed = {
				title = title;
				description = "이 페이지에는 기억이 없어요!";
				footer = {
					text = ("총 기억 갯수 : %d | 총 페이지수 : %d"):format(lenLearned,ceil(lenLearned / itemsPerPage));
				};
				-- components = {
				-- 	components.actionRow.new{
				-- 		components.button.new{
				-- 			emoji =  components.emoji.new "🔄";
				-- 			label = 
				-- 		};
				-- 	};
				-- };
			};
		};
	elseif learned[endAt+1] then
		insert(fields, {
			name = "다음 페이지가 있어요!";
			value = ("**`미나 기억 %d`** 를 입력해서 다음 페이지를 볼 수 있어요!"):format(page + 1);
		});
	end

	return {
		content = zwsp;
		embed = {
			title = title;
			fields = fields;
			color = 8520189;
			footer = {
				text = ("총 기억 갯수 : %d | 총 페이지수 : %d"):format(lenLearned,ceil(lenLearned / itemsPerPage));
			};
		};
		components = {components.actionRow.new{
            components.button.new{
                custom_id = ("learn_page_%s_%d"):format(userId,page);
                style = discordia_enchant_enums.buttonStyle.success;
                emoji = components.emoji.new "🔄";
                label = "새로고침";
            };
            components.button.new{
                custom_id = ("learn_page_%s_%d"):format(userId,page-1);
                style = discordia_enchant_enums.buttonStyle.primary;
                label = "이전 페이지";
                emoji = components.emoji.new "⬅";
                disabled = page <= 1;
            };
            components.button.new{
                custom_id = ("learn_page_%s_%d"):format(userId,page+1);
                style = discordia_enchant_enums.buttonStyle.primary;
                label = "다음 페이지";
                emoji = components.emoji.new "➡";
                disabled = page >= floor(lenLearned/itemsPerPage);
            };
        }};
	};
end

---@param id string
---@param interaction interaction
local function buttonPressed(id,interaction)
	local user,page = id:match("learn_page_(%d+)_(%d+)");
	page = tonumber(page);
	if (not user) or (not page) then
		return;
	end

	local interact_user = interaction.user; ---@type User
	if (not interact_user) then return; end
	if interact_user.id ~= user then
		interaction:reply({
			content = zwsp;
			embed = {
				title = ":x: 메시지 주인만 이 명령을 사용할 수 있습니다";
				description = ("이 메시지의 주인은 %s 입니다"):format(user);
			};
		},true);
		return;
	end

	interaction:update(listifyLearn(interact_user,page));
end
client:on("buttonPressed",buttonPressed);

---@type table<string, Command>
local export = {
	["가르치기 도움말"] = {
		alias = {
			"도움말 기억","기억 도움말","기억도움말","도움말기억",
			"기억 사용법","사용법기억","도움말가르치기","도움말 가르치기",
			"가르치기 사용법","가르치기 사용법 알려줘","가르치기사용법",
			"가르치기 도움말 보여줘","가르치기 help","가르치기도움말"
		};
		reply = help;
		sendToDm = "개인 메시지로 도움말이 전송되었습니다!";
	};
	["배워"] = {
		alias = {"기억해","배워라","배워봐","암기해","가르치기"};
		reply = "외우고 있어요 . . .";
		func = function (replyMsg,message,args,Content)
			local rawArgs = Content.rawArgs;

			local what,react = rawArgs:match("(.+)=(.+)");
			what = (what or ""):gsub("^ +",""):gsub(" +$","");
			react = (react or ""):gsub("^ +",""):gsub(" +$","");

			local userData = Content.loadUserData();
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
					return replyMsg:setContent("가르치려는 이름이 비어 있으면 안돼요!\n> 사용법 : `미나 배워 이름=내용`");
				elseif result == errorType.nullValue then
					return replyMsg:setContent("가르치려는 내용이 비어 있으면 안돼요!\n> 사용법 : `미나 배워 이름=내용`");
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
		onSlash = function(self,client)
			local name = self.name;
			client:slashCommand({ --@diagnostic disable-line
				name = name;
				description = "미나에게 반응을 가르칩니다!";
				options = {
					{
						name = "문장";
						description = "가르칠 문장이나 단어입니다!";
						type = discordia_enchant.enums.optionType.string;
						required = true;
					};
					{
						name = "반응";
						description = "돌아올 반응입니다!";
						type = discordia_enchant.enums.optionType.string;
						required = true;
					};
				};
				callback = function(interaction, params, cmd)
					processCommand(userInteractWarpper(
						("%s %s=%s"):format(name,
						params["문장"]:gsub("=",""),
						params["반응"]:gsub("=","")
					),interaction));
				end;
			});
		end;
	};
	["잊어"] = {
		alias = {"까먹어","잊어버려","잊어라","잊어줘"};
		reply = "에ㅔㅔㅔㅔㅔㅔㅔㅔㅔ";
		func = function(replyMsg,message,args,Content)

			-- checking arg
			local rawArgs = Content.rawArgs;
			local id = learn.getId(rawArgs)
			local index = tonumber(rawArgs:match("%d+"));
			if (not index) and (not id) then
				return replyMsg:setContent("지울 반응의 번째 또는 이름를 입력해주세요!\n> 가르친 반응 목록은 `미나 기억` 으로 확인할 수 있습니다");
			end

			-- get user data
			local userData = Content.loadUserData();
			if not userData then
				return replyMsg:setContent("유저 데이터를 찾지 못했습니다!\n> 약관 동의가 되어 있는지 확인하세요!");
			end
			local learned = userData.learned;
			if not learned then
				return replyMsg:setContent("아직 가르친 반응이 하나도 없어요!");
			end

			-- checking object from learned object
			local lenLearned = #learned;
			local reversedIndex,this;
			if id then
				for sampleIndex=1,lenLearned do
					local sample = learned[sampleIndex];
					if sample and sample:sub(1,18) == id then
						reversedIndex,this = sampleIndex,sample;
					end
				end
				if not reversedIndex then
					return replyMsg:setContent(("'%s' 는 가르치신적이 없는거 같아요!"):format(rawArgs));
				end
			else
				reversedIndex = lenLearned - index + 1;
				this = learned[reversedIndex];
				if not this then
					logger.infof("not fount learning data %d",reversedIndex);
					return replyMsg:setContent(("%s 번째 반응이 존재하지 않아요!"):format(tostring(index)));
				end
			end

			local success,name = learn.remove(this);
			remove(learned,reversedIndex); -- remove from indexs
			userData.lenLearned = userData.lenLearned - 1;
			if not success then
				Content.saveUserData();
				return replyMsg:setContent(("처리중에 오류가 발생했어요!\n> 오류 내용 : %s"):format(tostring(name)));
			end

			userData.love = userData.love + 10;
			Content.saveUserData();
			local data = json.decode(success);
			if not data then
				return replyMsg:setContent(("'%s' 그게 뭐였죠? 기억나지가 않아요\n> 데이터가 손상되어 표시할 수 없습니다\n`❤ + 10 (호감도를 50%% 반환받았습니다)`"):format(tostring(name)));
			end
			replyMsg:setContent(("'%s' 그게 뭐였죠? 기억나지가 않아요\n> 가르치신 '%s' 를 잊었습니다!\n`❤ + 10 (호감도를 50%% 반환받았습니다)`"):format(tostring(name),tostring(data.content)));
		end;
		onSlash = commonSlashCommand {
			description = "기억을 잊습니다!";
			optionName = "지울것";
			optionDescription = "기억의 번째를 입력하세요!";
			optionsType = discordia_enchant.enums.optionType.string;
			optionRequired = true;
		};
	};
	["기억"] = {
		alias = {"지식","가르침"};
		reply = function(message,args,Content,self)
			local rawArgs = Content.rawArgs;
			rawArgs = tonumber(rawArgs:match("%d+")) or 1;
			return message:reply(listifyLearn(Content.user,rawArgs));
		end;
		onSlash = commonSlashCommand {
			description = "내가 가르친 기억들을 봅니다!";
			optionName = "페이지";
			optionDescription = "확인할 페이지를 입력하세요!";
			optionsType = discordia_enchant.enums.optionType.integer;
			optionRequired = false;
		};
	};
};
return export;
