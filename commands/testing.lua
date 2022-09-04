local discordia_enchant = discordia_enchant;
local compEnums = discordia_enchant.enums;
local components = discordia_enchant.components;
local export = {
	["버튼"] = {
		reply = "디스코드 버튼 컴포넌트 라이브러리 v1 (by Qwreey75)";
		components = {
			components.actionRow.new{
				components.button.new {
					label = "안녕!";
					custom_id = "testingButton";
					style = compEnums.buttonStyle.primary;
				};
			};
		};
	};
	["텍스트인풋"] = {
		reply = "알수없는 무언가";
		components = {
			components.actionRow.new{
				components.button.new{
					custom_id = "testingModal";
					style = compEnums.buttonStyle.primary;
					label = "알수없는 무언가를 열기";
				};
			};
		};
		init = function (self)

			local function modalSubmitted(id,values,object)
				if id == "testingModalCommit" then
					object:reply({
						content = zwsp;
						embed = {
							title = "훌륭해요!";
							description = values.testingTextInput .. "\n\n를 입력했어요";
						};
					},true);
				end
			end
			client:onSync("modalSubmitted",promise.async(modalSubmitted));

			---@param id string
			---@param object interaction
			local function buttonPressed(id,object)
				if id ~= "testingModal" then return; end
				object:modal("testingModalCommit","우와왕",{components.actionRow.new{
					components.textInput.new{
						custom_id = "testingTextInput";
						label = "실험적인 무언가";
						style = compEnums.textInputStyle.paragraph;
						max_length = 1000;
						required = true;
						placeholder = "아무거나 적어보세요";
					};
					components.textInput.new{
						custom_id = "testingTextInput2";
						label = "이건 진짜 아무것도 아님";
						style = compEnums.textInputStyle.short;
						placeholder = "아무거나 적지마세요";
					};
				}});
			end
			client:onSync("buttonPressed",promise.async(buttonPressed));

		end;
	};
};

local replys = {
	"안녕!";
	"반가워!";
	"버튼!";
	"Testing";
	"Is working?";
	"작동함!";
	"버튼을 눌렀어!";
	"Working!";
	"Button!";
};
local replysLen = #replys;

---when button is clicked
---@param id string button id
---@param object interaction button pressed interaction
local function buttonPressed(id,object)
	if id == "testingButton" then
		object.message:setContent(replys[random(1,replysLen)]);
		object:ack();
	end
end
client:onSync("buttonPressed",promise.async(buttonPressed));

return export;
