local module = {};

local function makeError()
	return {
		title = ":/ 아직 통계가 없어요!";
		description = "혹시 새벽 시간인가요? 새벽 시간에는 데이터가 아직 모이지 않아서 불러올 수 없어요!\n또는 알 수 없는 오류가 발생했을수도 있어요!\n";
		color = embedColors.error;
		footer = {
			text = ":cry:";
		};
	};
end

-- class : youtubeEmbed
-- embed youtube search with youtube api's returns
-- it returns table for discordia's embed system

-- written by qwreey all right of this code had owned by qwreey;
-- 2021 / 07 / 04

local view = {
	{"decideCnt","확진자수"};
	{"deathCnt","사망자수"};
	-- {"examCnt","검사 진행수"};
	-- {"careCnt","치료중수"};
	-- {"clearCnt","격리 해재수"};
	-- {"accExamCnt","누적 검사수"};
	-- {"resutlNegCnt","결과 음성 수"};
	-- {"accExamCompCnt","누적 검사 완료수"};
	-- {"accDefRate","누적 확진률"};
};

function module:embed(today,yesterday)
	local fields = {};

	if (not yesterday) or (not today) then
		return makeError();
	end

	for _,v in ipairs(view) do
		local index = v[1];
		local name = v[2];

		logger.info(index)
		local todayV = today:getFirstChildByTag(index)[1];
		local yesterdayV = yesterday:getFirstChildByTag(index)[1];

		local changes = tonumber(todayV) - tonumber(yesterdayV);
		changes = (changes > 0 and "+" or "") .. tostring(changes);

		table.insert(fields,{
			name = name;
			inline = true;
			value = ("%s (전날과 차이 %s)"):format(todayV,changes);
		});
	end

	return {
		color = embedColors.success;
		footer = {
			text = "오늘 기준의 정보입니다";
		};
		author = {
			name = "보건복지부 코로나19 감염 현황";
			url = "http://ncov.mohw.go.kr/bdBoardList_Real.do";
		};
		description = "이 결과는 공공데이터포털의 \"공공데이터활용지원센터_보건복지부 코로나19 감염 현황\" API 의 호출 결과에 바탕을 둡니다, 실제와 상이할 수 있습니다";
		fields = fields;
	};
end

return module;
