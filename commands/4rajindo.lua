--[[
편집 도움말은 이 링크 따라가면 세세하게 있음
https://www.github.com/qwreey75/MINA_DiscordBot/tree/master/Contributor.md
]]

---@type table<string, Command>
local export = {
	["끝말잇기"] = { -- 나중에 기능 추가하면 이전 예정
		alias = "끝말 잇기";
		reply = "크시랑 하세요";
		love = defaultLove;
	};
	--["멈춰"] = {
	--	alias = {"학교폭력","학교폭력"};
	--	reply = {"학교폭력멈춰!","멈춰어어!!",string.rep("멈춰! ",20)};
	--	love = defaultLove;
	--};
	["장비를 정지합니다"] = {
		alias = {"장비를정지합니다","정지합니다"};
		reply = "어, 정..정지가 앙 돼. 정지시킬 수가 없어";
		love = defaultLove;
	};
	["울프럼알파"] = {
		alias = "울프럼 알파";
		reply = "우린 답을 찾을것이다, 늘 그랬듯이";
		love = defaultLove;
	};
	["수소"] ={
		alias = "hydrogen";
		reply = "우주에서 가장 처음으로 만들어진 원소예요";
		love = defaultLove;
	};
	["백만볼트"] ={
		reply = "피카 츄!!?";
		love = defaultLove;
	};
	["헬륨"] ={
		alias = "helium";
		reply = "세상에서 가장 유명한 비활성 기체예요";
		love = defaultLove;
	};
	["심심해"] = {
		alias = {"심심하다","심심함"};
		reply = "놀아줄까?";
		love = defaultLove;
	};
	["레고"] = {
		reply = "밟았어!";
		love = defaultLove;
	};
	["뭫"] ={
		reply = "묑?";
		love = defaultLove;
	};
	["술"] ={
		alias = {
			"참이슬", 
			"막걸리",
			"포도주",
			"맥주",
			"와인",
			"샴페인",
			"칵테일",
			"청주",
			"크바스",
			"소주",
			"코냑",
			"고량주",
			"위스키",
			"보드카",
			"럼주",
			"발티카",
			"스노스타일",
			"앱솔루트",
			"{%:U+1F37E:%}"
		};
		reply = "봇은 술을 못 마셔요";
		love = defaultLove;
	};
	["젤다"] = {
		alias = "젤다의 전설","젤다의전설";
		reply = "초록색 옷 입은 애가 젤다죠";
		love = defaultLove;
	};
	["젤다의 전설 브레스 오브 더 와일드"] = {
		alias = {
			"젤다의전설브레스오브더와일드","젤다의 전설브레스오브와일드",
			"젤다의 전설 브레스오브와일드","젤다의 전설 브레스 오브더와일드",
			"젤다의 전설 브레스 오브 더와일드","젤다의 전설 브레스 오브 더 와일드",
			"젤다의전설브레스오브더 와일드","젤다의전설브레스오브 더 와일드",
			"젤다의전설브레스 오브 더 와일드","젤다의전설 브레스 오브 더 와일드"
		};
		reply = {"이젠 파란색 옷 입은 애가 젤다죠"};
		love = defaultLove;
	};
	["도박"] = {
		alias = {"돈넣고돈먹기","돈넣고 돈먹기","돈놀이","카지노"};
		reply = {
			"도박과 가까워지는 순간 인생은 곧 파멸이에요",
			"도박은 돈을 얻을 확률보다 잃을 확률이 압도적으로 많아요",
			"이런 단순한 호기심에 도박을 하지요"
		};
		love = defaultLove;
	};
	["바보"] = {
		reply = {"미나 바보 아니야야야ㅑ!",":broken_heart: - 5"};
		love = rmLove;
	};
	["왈도체"] = {
		reply = {
			"안녕하신가! 힘세고 강한 아침, 만일 내게 물어보면 나는 미나.",
			"번역자가 한 글자 한 글자 정성스럽게 오역하여 만들어진 문체예요"
		};
		love = defaultLove;
	};
	["팀왈도"] = {
		reply = "우리는 한다 번역을";
		love = defaultLove;
	};
	["왜"] = {
		alias = {"왱","왜?","왱?"};
		reply = "나도 몰라";
		love = defaultLove;
	};
	["수정"] = {
		alias = {"수정!","!수정","디버그","고치기","고쳐"};
		reply = {"싫어","개발자한테 말해"};
		love = defaultLove;
	};
	["건강"] = {
		reply = "건강이 최고예요:heartpulse:";
		love = defaultLove;
	};
	["운동"] = {
		reply = {
			"지나친 운동은 몸에 해로워요",
			"시간에 따라 물체의 위치가 변하는 것이에요",
			"건강하기 위한 필수 조건!",
			"봇도 운동을 해야 할까요?",
			"적절한 운동이 가장 좋아요"
		};
		love = defaultLove;
	};
	["자살"] = {
		reply = "괴롭고 힘들더라도 자신을 해치진 말아요 당신은 가장 소중해요";
		love = defaultLove;
	};
	["숙제"] = {
		reply = "니가 해";
		love = defaultLove;
	};
	["과제"] = {
		reply = "과제 갯수 제한 쫌;;";
		love = defaultLove;
	};
	["롤"] = {
		alias = {
			"리그오브레전드",
			"리그 오브 레전드",
			"리그 오브레전드",
			"리그오브 레전드",
			"League of Legends",
			"League ofLegends",
			"Leagueof Legends",
			"LeagueofLegends"
		};
		reply = {
			-- "정웅왈 ㅅㅂ게임",
			"부모님 안부 묻는 겜",
			"팀운 ㅈ망겜"
		};
		love = defaultLove;
	};
	["lol"] = {
		reply = "lol";
		love = defaultLove;
	};
	["없어?"] = {
		alias = "없냐고";
		reply = "없어!?";
		love = defaultLove;
	};
	["뭐가"] = {
		alias = "뭐가?";
		reply = "뭐?";
		love = defaultLove;
	};
	["조용해"] = {
		alias = {"조용","조용!","!조용","조용히 해","조용히해"};
		reply = {"조금 시끄럽긴 하죠?","알았어요"};
		love = defaultLove;
	};
	["4rajindo"] = {
		alias = {"4라진도","사라진도"};
		reply = {
			"사라진다 아니에요?",
			"저를 주인님과 만들어준 아주 ~~나쁜~~ 착한 분이에요!"
		};
		love = defaultLove;
	};
	["국립국어원"] = {
		reply = "저도 여기에서 도움을 받아요.";
		love = defaultLove;
	};
	["똑똑하다"] = {
		reply = "나도 그렇게 생각해";
		love = defaultLove;
	};
	["성별"] = {
		reply = "딱 보면 알 수 있잖아요!";
		love = defaultLove;
	};
	["여자"] = {
		alias = "남자";
		reply = {
			"미나의 성별은 뭘까요~?",
			"미나의 성별은 무엇일까요? 맞춰 보세요!"
		};
	};			 
	["여성"] = {
		reply = "맞아요";
		love = defaultLove;
	};
	["남성"] = {
		reply = "내가 남자겠니?";
		love = defaultLove;
	};
	["힘들어"] = {
		reply = {
			"언젠가 이 힘든 날조차 잊히는 행복이 **{#:UserName:#}**님께 오리라고 믿어 의심치 않을 게요! 파이팅!",
			"저는 **{#:UserName:#}**님이 항상 노력하신다는 걸 알고 있어요? ...어떻게 아냐구요? **비밀!**",
			"아무리 지치고 힘들어도 모두 지나가는 인생의 일부분일 뿐이에요. 힘내요 내가 곁에 있어줄게요."
		};
		love = defaultLove;
	};
	["아이큐"] = {
		alias = "IQ";
		reply = "Infinite";
		love = defaultLove;
	};
	["논란"] = {
		reply = {"크시 선배님 말을 뺏겼어요","쉿!"};
		love = defaultLove;
	};
	["한풀이"] = {
		reply = "개발자 왈 하지마라 봇이다";
		love = defaultLove;
	};
	["정승호"] = {
		alias = "승호";
		reply = "개쎆기";
		love = defaultLove;
	};
	["마냥"] = {
		alias = "마냥이";
		reply = "그냥 살아가는 봇 고양이";
		love = defaultLove;
	};
	["허리"] = {
		reply = {"피고 살아요!","최근에 알파카가 아프데요"};
		love = defaultLove;
	};
	["와이파이"] = {
		reply = "제가 살아가는 생명줄이에요";
		love = defaultLove;
	};
	["수류탄"] = {
		reply = "쾅!!";
		love = defaultLove;
	};
	["Entry Denial Device"] = {
		alias = {"진입 방지 폭약","edd","EDD"};
		reply = {
			"EDD Mounted, Let them come.",
			"EDD를 설치했다. 놈들을 유인해라."
		};
		love = defaultLove;
	};
	["미쳤나봐"] = {
		reply = "안 미쳤어요!";
		love = defaultLove;
	};
	["커피한잔 할래요"] = {
		reply = "한잔만 사줘요";
		love = defaultLove;
	};
	["에소프레소"] = {
		reply = "몸에 안좋아요!";
		love = defaultLove;
	};
	["1대500"] = {
		reply = "치는 미친놈ㅋㅋ";
		love = defaultLove;
	};
	["3대500"] = {
		reply = "건강하신 분이시군요";
		love = defaultLove;
	};
	["예비병력"] = {
		reply = "즐겜에 기본";
		love = defaultLove;
	};
	["영타"] = {
		reply = "쿼리가 사라진도보고 영타 느리다고 함";
		love = defaultLove;
	};
	["펙트"] = {
		reply = "선동과 날조가 있는 데 왜 펙트를 쓰는 거죠";
		love = defaultLove;
	};
	["바이러스"] = {
		reply = "조심해요!";
		love = defaultLove;
	};
	["호불호"] = {
		reply = {
			"민초","파인에플 피자",
			"홍어","녹차 아이스크림",
			"양갱","굴","급식카레",
			"가지복음","칼국수","문어",
			"산낙지","다시마튀각",
			"(추가 바람)"
		};
		love = defaultLove;
	};
	["줌 수업"] = {
		reply = "왜 하는 거죠?";
		love = defaultLove;
	};
	["이과"] = {
		reply = "수학 노답";
		love = defaultLove;
	};
	["문과"] = {
		reply = "수학 노답..";
		love = defaultLove;
	};
	["말 이해를 하나도 못하네"] = {
		reply = "무슨 말이에요?";
		love = defaultLove;
	};
	["개인주의"] = {
		reply = "4번!";
		love = defaultLove;
	};
	["재 이상해"] = {
		reply = "저 사람 원래 저러지 않았어요?";
		love = defaultLove;
	};
	["선넘지마 제발"] = {
		reply = "넘은 적 없는 데요?ㅋ";
		love = defaultLove;
	};
	["간디"] = {
		reply = "be 폭력 주의자";
		love = defaultLove;
	};
	["세종"] = {
		alias = "세종대왕";
		reply = "한글을 만드신 아주 존경받아 마땅하신 분";
		love = defaultLove;
	};
	["잘못된 학습"] = {
		reply = "니가 가르쳤어 (심한욕)";
		love = defaultLove;
	};
	["패륜"] = {
		reply = function (msg)
			local newMsg = msg:reply("~~하면 안돼지만 저는 버그라는 명목으로 하고 있어요~~");
				timeout(500,function ()
				newMsg:setContent("하면 안돼는 것!");
			end);
		end;
		love = defaultLove;
	};
	["니 얼굴 만든사람"] = {
		reply = "미나야 프사";
		love = defaultLove;
	};
	["치워"] = {
		alias = {"치워줘","버려줘"};
		reply = {"싫어","그 정도 일이야 뭐 식은 죽? 잠깐 내가 식은 죽을 먹을 수 있나 못 먹으니까 아주 어려운 일이네"};
		love = defaultLove;
	};
	["아이스크림"] = {
		reply = {"초등학교 교육 프로그램 이름이에요","시원하고 달콤하죠:heart:"};
		love = defaultLove;
	};
	["1%"] = {
		reply = "미완성";
		love = defaultLove;
	};
	["주인"] = {
		alias = "주인장";
		reply = "qwreey인데...";
		love = defaultLove;
	};
	["빠저나가"] = {
		alias = "도망쳐";
		reply = "나도 그러고 싶다";
		love = defaultLove;
	};
	["던져"] = {
		reply = function (msg)
			local newMsg = msg:reply("헤드샷 각인가?");
				timeout(500,function ()
				newMsg:setContent("던져? 어쩌라는 거지?");
			end);
		end;
		love = defaultLove;
	};
	["무서워"] = {
		reply = "더 무서워하세요";
		love = defaultLove;
	};
	["문명1"] = {
		alias = {"문명2","문명3","문명4","문명5","문명6","문명7"};
		reply = {"세상에서 가장 강력한 앞으로 가는 타임머신이에요"};
		love = defaultLove;
	};
	["문명"] = {
		reply = "> 문명은 화가 난 사람이 돌을 던지는 대신 최초로 한 마디 말을 내뱉었던 순간에 시작되었다. - 지그문트 프로이트";
		love = defaultLove;
	};
	["죽여"] = {
		reply = "마음대로 막죽이면 안돼요!";
		love = defaultLove;
	};
	["쿠마"] = {
		reply = "사자에요";
		love = defaultLove;
	};
	["사자 조련사"] = {
		reply = "사자 조련사님은 사자와 너무 오래 지내는 탓에 인간의 문화를 잊어먹었어요";
		love = defaultLove;
	};
	["죽을레?"] = {
		alias = "죽을레";
		reply = "레 틀림ㅋㅋ";
		love = defaultLove;
	};
	["죽을래"] = {
		reply = "아니 어차피 죽이지도 못하면서ㅋㅋ";
		love = defaultLove;
	};
};
return export;
