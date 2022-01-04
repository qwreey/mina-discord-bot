local export = {
    ["변경사항"] = {
        alias = {"변경기록","변경 사항","채인지로그","체인지로그","변경 기록","업데이트","업데이트 사항","업데이트 기록","업데이트 내용"};
		reply = "링크를 확인해주세요!";
		embed = {
            title = "변경사항";
            description = ("**가장 최근 변경사항**\n%s\n[전체보기](%s)"):format(app.changelog.last,app.changelog.page)
        };
	};
};
return export;
