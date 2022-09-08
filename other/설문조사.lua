local discordia_enchant = discordia_enchant;
local compEnums = discordia_enchant.enums;
local components = discordia_enchant.components;
local users = {}
local function modalSubmitted(id,values,object)
  if id == "surveyCommitTesting" then
    users[object.member.id] = true;
    object:reply({
      content = zwsp;
      embed = {
        title = ":white_check_mark: 설문조사 완료!";
      };
    },true);
  end
end
client:onSync("modalSubmitted",promise.async(modalSubmitted));

---@param id string
---@param object interaction
local function buttonPressed(id,object)
  if id ~= "surveyOpenTesting" then return; end
  if users[object.member.id] then
    object:reply({content = zwsp; embed = {title = ":x: 이미 이 설문에 참여했습니다"}},true)
    return;
  end
  object:modal("surveyCommitTesting","설문조사 실험",{
    components.actionRow.new{
      components.textInput.new{
        custom_id = "input1";
        label = "무엇을 추가할까요";
        style = compEnums.textInputStyle.paragraph;
        max_length = 1000;
        required = true;
        placeholder = "몰??루";
      };
    };
    components.actionRow.new{
      components.textInput.new{
        custom_id = "input2";
        label = "왜 추가할까요";
        style = compEnums.textInputStyle.paragraph;
        placeholder = "몰?루";
      };
    };
  });
end
client:onSync("buttonPressed",promise.async(buttonPressed));



local discordia_enchant = discordia_enchant;
local compEnums = discordia_enchant.enums;
local components = discordia_enchant.components;
send {
  content = "실험적인 설문조사";
  components = {
    components.actionRow.new{
      components.button.new{
        label = "참여하기";
				custom_id = "surveyOpenTesting";
				style = compEnums.buttonStyle.primary;
      };
    };
  };
} return {ignore = true}
