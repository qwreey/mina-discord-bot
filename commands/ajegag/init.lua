
local json = require"json";
local fs = require"fs";
local data = fs.readFileSync("commands/ajegag/data.json");
data = json.decode(data);

if not data then
	logger.info("Error occured on loading command 'ajegag'\ndata expected as array but actually got nil");
	return {};
end

local lenAjegag = #data;
--- 아재개그를 랜덤으로 하나 뽑습니다 wow 즐거워요
local function getRandomAjegag()
	return data[random(1,lenAjegag)];
end
local function pickRandom(array)
	return array[random(1,#array)] or "";
end

local export = {
	["아재개그"] = {
		alias = {
			"개그","부장님개그","부장님 개그",
			"아재 개그","아제개그","아제 개그",
			"꺄르륵","조크","쪼크"
		};
		reply = function (message)
			local ajegag = getRandomAjegag();
			return message:reply{
				content = zwsp;
				embed = {
					color = 10448383;
					title = ajegag.quiz;
					description = ("||%s||"):format(pickRandom(ajegag.answer));
				};
				footer = {text = "안 웃기다고요? 어쩌라구요"};
			};
		end;
		onSlash = commonSlashCommand {
			noOption = true;
			description = "한강 물온도를 보여줍니다!";
		};
	};
};
return export;

