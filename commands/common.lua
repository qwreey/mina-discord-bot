local insert = table.insert;

local uv = uv or require("uv");
local time = uv.hrtime;
local msOffset = 1e6;
local usOffset = 1e3;
local ctime = os.clock;

local leaderstatusWords = _G.leaderstatusWords;
local timeAgo = _G.timeAgo;
local floor = math.floor;
local posixTime = _G.posixTime;

local function formatIDTime(this)
	local thisDate = Date.fromSnowflake(this);
	local thisTable = thisDate:toTable();
	local now = posixTime.now();
	return ("%d년 %d월 %d일 %d시 %d분 %d초 (%d 일전!)\n> 대한민국 시간대(GMT +9) 기준입니다!"):format(
		thisTable.year,thisTable.month,thisTable.day,thisTable.hour,thisTable.min,thisTable.sec,
		(now - thisDate:toSeconds()) / 86400
	);
end

return {
	--타이머
	["계정나이"] = {
		alias = "계정 나이";
		reply = function (message,args,content)
			local this = content.rawArgs:match("%d+");
			this = this or content.user.id;
			return formatIDTime(this);
		end;
	};
	["서버나이"] = {
		disableDm = true;
		alias = "서버 나이";
		reply = function (message,args,content)
			return formatIDTime(message.guild.id);
		end;
	};
	["호감도"] = {
		reply = function (message,args,content)
			if message.author.id == "480318544693821450" then
				return "미나는 **{#:UserName:#}** 님을 **10/25** 만금 좋아해요!";
			elseif message.author.id == "647101613047152640" then
				return "니 약관동의 안할 거잔아";
			end
			local rawArgs = content.rawArgs;
			rawArgs = rawArgs:gsub("^ +",""):gsub(" +$","");
			if rawArgs == "" then -- 내 호감도 불러오기
				local this = content.getUserData();
				if this == nil then -- 약관 동의하지 않았으면 리턴
					return eulaComment_love;
				end
				local numLove = tonumber(this.love);
				if numLove == nil then
					return "미나는 **{#:UserName:#}** 님을 **NULL (nil)** 만큼 좋아해요!\n\n오류가 발생하였습니다...\n```json : Userdata / love ? NULL```";	
				elseif numLove > 0 then
					return ("미나는 **{#:UserName:#}** 님을 **%d** 만큼 좋아해요!"):format(numLove);
				elseif numLove < 0 then
					return ("미나는 **{#:UserName:#}** 님을 **%d** 만큼 싫어해요;"):format(math.abs(numLove));
				elseif numLove == 0 then
					return "미나는 아직 **{#:UserName:#}** 님을 몰라요!";
				end
			elseif leaderstatusWords[rawArgs] then
				local fields = {};
				local now = posixTime.now();
				for nth,this in ipairs(loveLeaderstatus) do
					insert(fields,{
						name = ("%d 등! **%s**"):format(nth,this.name);
						value = ("❤ %d (%s)"):format(this.love,timeAgo(this.when,now));
					});
				end
				message:reply {
					content = ("호감도가 가장 높은 유저 %d 명입니다."):format(#loveLeaderstatus);
					embed = {
						title = "호감도 순위";
						fields = fields;
					};
				};
			else
				local id = rawArgs:match("%d+");
				if id and id ~= "" then
					local data = userData:loadData(id);
					if data then
						local love = data.love;
						local name = data.latestName;
						if love and name then
							message:reply(("**%s** 님의 호감도는 **%d** 이에요!"):format(name,love));
							return;
						end
					end
				end
			end
			message:reply("해당 유저는 존재하지 않습니다!");
		end
	};
	["핑"] = {
		alias = {"상태","status","ping","지연시간","응답시간"};
		reply = function (msg)
			local send = time();
			local new = msg:reply("🏓 봇 지연시간\n전송중 . . .");
			local msgPing = tostring((time()-send)/msOffset);
			local before = time();
			timeout(0,function ()
				local clock = tostring((time()-before)/usOffset);
				-- local dataReadSt = time();
				-- userData.load()
				-- local dataReadEd = time();
				
				new:setContent(
					("🏓 봇 지연시간\n> 서버 응답시간 : %s`ms`\n> 내부 클럭 속도 : %s`us`\n> 가동시간 : %s\n> 사용 RAM : %dMB")
					:format(
						msgPing,
						clock,
						timeAgo(0,ctime()),
						(collectgarbage("count")*1024 + uv.resident_set_memory())/1000000
					)
				);
			end);
		end;
	};
	["버전"] = {
		alias = "version";
		reply = ("미나의 현재버전은 `%s` 이에요 (From last git commit time)"):format(app.version);
		love = defaultLove;
	};
	["지워"] = {
		disableDm = true;
		alias = {"지우개","지워봐","지워라","지우기","삭제해","청소","삭제","청소해","clear"};
		func = function(replyMsg,message,args,Content)
			local RemoveNum = Content.rawArgs == "" and 5 or tonumber(Content.rawArgs);
			if (not RemoveNum) or type(RemoveNum) ~= "number" then -- 숫자가 아닌 다른걸 입력함
				message:reply("잘못된 명령어 사용법이에요!\n\n**올바른 사용 방법**\n> 미나야 지워 <지울 수>\n지울수 : 2 에서 100 까지의 숫자 (정수)");
				return;
			elseif (RemoveNum % 1) ~= 0 then -- 소숫점을 입력함
				local Remsg = message:reply("~~메시지를 반으로 쪼개서 지우라는거야? ㅋㅋㅋ~~");
				timeout(800,function()
					Remsg:setContent("<지울 수> 는 정수만 사용 가능해요!");
				end);
				return;
			elseif RemoveNum < 0 then -- 마이너스를 입력함
				local Remsg = message:reply("~~메시지를 더 늘려달라는거야? ㅋㅋㅋ~~");
				timeout(800,function()
					Remsg:setContent("적어도 2개 이상부터 지울 수 있어요!");
				end);
				return;
			elseif RemoveNum > 100 then -- 너무 많음
				local Remsg = message:reply("~~미쳤나봐... 작작 일 시켜~~");
				timeout(800,function()
					Remsg:setContent("100 개 이상의 메시지는 지울 수 없어요!");
				end);
				return;
			elseif RemoveNum < 2 then -- 범위를 넘어감
				local Remsg = message:reply("~~그정도는 니 손으로 좀 지워라~~");
				timeout(800,function()
					Remsg:setContent("너무 적어요! 2개 이상부터 지울 수 있어요!");
				end);
				return;
			elseif not message.member:hasPermission(message.channel,enums.permission.manageMessages) then
				message:reply("권한이 부족해요! 메시지 관리 권한이 있는 유저만 이 명령어를 사용 할 수 있어요");
				return;
			end

			message.channel:bulkDelete(message.channel:getMessagesBefore(message.id,RemoveNum));
			local infoMsg = message:reply(("최근 메시지 %s개를 지웠어요!"):format(RemoveNum));

			timeout(5000,function ()
				message:delete();
				infoMsg:delete();
			end);
		end;
	};
};
