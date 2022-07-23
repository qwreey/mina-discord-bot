
local permission = enums.permission.manageGuild; ---@diagnostic disable-line
local insert = table.insert;
local codeblockEscape = ("`%s`%s`"):format(zwsp,zwsp);

local notPermitted = {
	content = zwsp;
	embed = {
		title = ":x: 권한이 부족합니다";
		description = "이 명령을 수행하려면 적어도 서버관리(manageGuild) 이상의 권한이 필요합니다";
	};
};

---@type table<string, Command>
local export = {
	resetwarn = {
		alias = {"경고초기화","경고리셋","경고 초기화","경고 리셋","warn reset","warnreset","reset warn"};
		disableDm = true;
		---@param message Message
		---@param Content commandContent
		---@param args table
		reply = function (message,args,Content,self)
			local guild = message.guild;
			local user = message.member;
			if (not guild) or (not user) then return; end
			if not user:hasPermission(permission) then ---@diagnostic disable-line
				return message:reply(notPermitted);
			end

			-- 타겟 유저 id 가져오기
			local targetUser = (Content.rawArgs or ""):match("%d+");
			if not targetUser then -- 타겟 유저 id 가 없음
				return message:reply(self.noTarget);
			end
			targetUser = guild:getMember(targetUser); -- 타겟 유저를 길드에서 뽑아옴
			if not targetUser then
				return message:reply(self.targetNotFound); -- 유저가 서버에 없음
			elseif targetUser.bot then ---@diagnostic disable-line
				return message:reply(self.isBot); -- 봇인경우
			end

			-- 서버 데이터를 가져와서 warnUsers 필드를 준비함
			local data = Content.loadServerData() or {};
			local warnUsers = data.warnUsers;
			if not warnUsers then
				return message:reply(self.warnNotFound);
			end

			-- 유저 경고 정보 불러오기
			local userId = targetUser.id; ---@diagnostic disable-line
			local thisUser = warnUsers[userId];
			if (not thisUser) or (#thisUser == 0) then -- 경고 데이터가 없음
				return message:reply(self.warnNotFound);
			end

			-- 초기화와 저장
			warnUsers[userId] = nil;
			Content.saveServerData(data);
			return message:reply{
				content = zwsp;
				embed = {
					title = ":white_check_mark: 성공적으로 초기화했습니다";
					description = ("유저 <@%s> 의 경고 목록을 초기화했습니다!"):format(userId);
				};
			};
		end;
		noTarget = {
			content = zwsp;
			embed = {
				title = ":x: 입력된 대상이 없습니다";
				description = "경고를 부여할 대상의 아이디를 입력하거나 맨션을 입력하세요";
			};
		};
		targetNotFound = {
			content = zwsp;
			embed = {
				title = ":x: 대상을 찾지 못했습니다";
				description = "대상을 이 서버에서 찾지 못했습니다";
			};
		};
		isBot = {
			content = zwsp;
			embed = {
				title = ":x: 봇에게는 경고가 없습니다";
			};
		};
		warnNotFound = {
			content = zwsp;
			embed = {
				title = ":x: 경고가 없습니다";
				description = "기록이 아주 깔끔하네요! 이 유저는 이 서버에서 받은 경고가 하나도 없습니다";
			};
		};
	};
	warn = {
		alias = {"경고"};
		command = {"warn"};
		disableDm = true;
		---@param message Message
		---@param Content commandContent
		reply = function (message,args,Content,self)
			local member = message.member;
			local guild = message.guild;
			if (not member) or (not guild) then return; end -- 버그방지
			---@diagnostic disable-next-line
			if not member:hasPermission(enums.permission.manageGuild) then
				return message:reply(notPermitted); -- 권한 없음
			end

			-- 타겟 유저와 타겟 메시지 가져오기
			---@diagnostic disable-next-line
			local replyed = message.referencedMessage; ---@type Message
			local targetUser,reason;
			if replyed then -- 리플로 타겟 메시지와 타겟 유저 가져오기
				targetUser = replyed.member;
				reason = Content.rawArgs;
			else -- 리플이 없음 = 인자에서 찾기
				local arg = Content.rawArgs; -- 저수준 인자
				targetUser,reason = arg:match" *(.-) (.*) *"; -- 이유와 타겟 유저를 가져옴
				targetUser = (targetUser or ""):match("%d+");
				if not targetUser then -- 유저 스트링이 비어있음
					return message:reply(self.noTarget);
				end
				targetUser = guild:getMember(targetUser); -- 유저 가져오기
			end

			if (not reason) or (#reason == 0) then
				reason = "사유 없음"; -- 사유가 비어있음
			end
			if not targetUser then
				return message:reply(self.targetNotFound); -- 유저를 찾지 못하면
			elseif targetUser.bot then ---@diagnostic disable-line
				return message:reply(self.isBot); -- 봇이면
			end

			-- 서버 데이터를 가져와서 warnUsers 필드를 준비함
			local data = Content.loadServerData() or {};
			local warnUsers = data.warnUsers;
			if not warnUsers then
				warnUsers = {};
				data.warnUsers = warnUsers;
			end

			-- 유저에게 경고상태를 준비함
			local userId = targetUser.id; ---@diagnostic disable-line
			local thisUser = warnUsers[userId];
			if not thisUser then
				thisUser = {};
				warnUsers[userId] = thisUser;
			end

			-- 경고가 너무 많으면 리턴
			local lenthisUser = #thisUser;
			if lenthisUser >= maxWarns then
				return message:reply(self.full);
			end

			-- 경고를 추가함
			insert(thisUser,{
				rm=replyed and replyed.content;
				rmid=replyed and replyed.id;
				r=reason,t=posixTime.now();
				by=member.id; ---@diagnostic disable-line
			});
			Content.saveServerData(data); -- 서버 데이터 저장

			-- 메시지 출력
			return message:reply{
				content = zwsp;
				embed = {
					title = ":white_check_mark: 성공적으로 경고를 부여했습니다";
					description = ("%s사유```\n%s\n```\n경고대상 : <@%s> | 총 경고수 : %d"):format(
						replyed and
							("메시지```\n%s\n```\n"):format(
								replyed.content:gsub("```",codeblockEscape):sub(1,1000)
							)
							or "",
						reason:gsub("```",codeblockEscape):sub(1,1000),
						userId,
						lenthisUser + 1
					);
				};
			};
		end;
		onSlash = commonSlashCommand {
			name = "경고";
			description = "유저에게 경고를 부여합니다. 메시지에 경고를 부여하려면 답장하기를 이용해 '미나 경고 <사유>' 를 입력하세요. 관리자만 이 명령을 수행할 수 있습니다";
			options = {
				{
					name = "유저";
					description = "대상 유저를 맨션하세요 (@ 를 입렵하세요)";
					type = discordia_enchant.enums.optionType.string;
					required = true;
				};
				{
					name = "사유";
					description = "경고 사유를 입력하세요";
					type = discordia_enchant.enums.optionType.string;
					required = false;
				};
			};

		};
		noTarget = {
			content = zwsp;
			embed = {
				title = ":x: 입력된 대상이 없습니다";
				description = "경고를 부여할 대상의 아이디를 입력하거나 맨션을 입력하세요\n혹은 특정 메시지에 답변하기로 이 명령을 사용해 메시지에 경고를 부여할 수 있습니다";
			};
		};
		targetNotFound = {
			content = zwsp;
			embed = {
				title = ":x: 대상을 찾지 못했습니다";
				description = "대상을 이 서버에서 찾지 못했습니다";
			};
		};
		isBot = {
			content = zwsp;
			embed = {
				title = ":x: 봇에게는 경고를 부여 할 수 없습니다";
			};
		};
		full = {
			content = zwsp;
			embed = {
				title = ":x: 너무 많은 경고가 있습니다";
				description = "사용할 수 있는 최대 유저당 경고수는 100개 입니다.\n`경고 초기화 <유저>` 를 통해 초기화하면 경고를 다시 추가 할 수 있습니다";
			};
		};
	};
};

return export;
