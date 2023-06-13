local http = require "coro-http";
local json = require "json";
local urlEncode = require "urlCode".urlEncode;
local commandHandler = require "class.commandHandler";

---@param gptOutput table|string
--- interface ChatResponse {
---     content: string;
---     error?: string;
--- }
local function formatOutput(gptOutput)
	if gptOutput.error or (not gptOutput.result) then
		return ("오류가 발생했습니다!\n%s"):format(tostring(gptOutput.error))
	end

	return ("GPT 의 응답:\n%s"):format(gptOutput.result)
end

---@return nil|table|any
local function safeJsonDecode(body)
	local pass,result = pcall(json.decode,body)
	if pass then return result end
end

local requestBase = "http://localhost:3000/ask?site=you&model=gpt3.5-turbo&prompt=%s"
local function executeGPT(prompt)
	local uri = requestBase:format(urlEncode(prompt))
	local resultHeader,resultBody = http.request("GET",uri)
	local data = safeJsonDecode(resultBody)
	if not data then
		return ("내부적 오류가 발생했습니다.\nbody: %s"):format(tostring(resultBody))
	end

	return formatOutput(data)
end

commandHandler.onSlash(function()
	client:slashCommand({ ---@diagnostic disable-line
		name = "gpt";
		description = "GPT 모델에게 메시징합니다";
		options = {
			{
				name = "내용";
				description = "입력할 프롬프트입니다";
				type = discordia_enchant.enums.optionType.string;
				required = true;
			};
		};
		callback = function(interaction, params, cmd)
			interaction:reply(
				executeGPT(params["내용"])
			);
		end;
	});
end,nil,nil,"GPT");

return {};
