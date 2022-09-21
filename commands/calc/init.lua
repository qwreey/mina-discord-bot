local worker = require "worker";
local calcHandler
promise.spawn(function ()
    calcHandler = worker.new("strCalcWorker",
        ---@param handler workerChildHandler
        function (handler)
            local strCalc = require "commands.calc.strCalc"
            local funcs = {
                sin = math.sin;
                abs = math.abs;
                acos = math.acos;
                asin = math.asin;
                atan = math.atan;
                atan2 = math.atan2;
                ceil = math.ceil;
                cos = math.cos;
                cosh = math.cosh;
                deg = math.deg;
                exp = function (x,y)
                    if not y then
                        if not x then error "Exp function requires at least one argument" end
                        return math.exp(x)
                    end
                    return x^y
                end;
                floor = math.floor;
                mod = math.fmod;
                frexp = math.frexp;
                modf = math.modf;
            };
            local values = {
                pi = math.pi;
                PI = math.pi;
                inf = math.huge;
                huge = math.huge;
                HUGE = math.huge;
                INF = math.huge;
                e = 2.718281828459;
                E = 2.718281828459;
            };
            handler.onRequest(function (str)
                return strCalc.calc(str,values,funcs);
            end)
            handler.ready();
        end
    ):onRequest(function()end):ready();
end)

---@type table<string,Command>
local export = {
    ["계산"] = {
        alias = {"계산기","계산해","암산해","암산","calc","calculator","calculate","산수","수학"};
        tooLong = "흐아... 너무 복잡한거 같아요! 나도 모르겠어!";
        reply = function (message,args,Content,self)
            local str = Content.rawArgs;
            if #str > 400 then
                return message:reply(self.tooLong);
            end

            local passed,result = calcHandler:protectedRequest(str);
            if not passed then
                return message:reply({
                    content = zwsp;
                    embed = {
                        title = ":x: 계산에 실패했어요";
                        color = embedColors.error;
                        description = ("수식 `%s` 를 계산하지 못했어요\nERROR: %s"):format(str:gsub("`","\\`"),tostring(result));
                    };
                });
            end

            return message:reply({
                content = zwsp;
                embed = {
                    title = (":heavy_equals_sign: %s"):format(tostring(result));
                    description = ("수식 `%s` 를 계산한 결과에요!"):format(str:gsub("`","\\`"));
                };
            });
        end;
        onSlash = commonSlashCommand {
            name = "계산기";
            optionName = "계산식";
            optionRequired = false;
            optionsType = discordia_enchant.enums.optionType.string;
            optionDescription = "f(x)=x+2;y=sin(f(12));(y+12)*2 와 같이 함수, 변수를 사용할 수 있습니다";
			description = "미나미나에게 수식을 풀도록 만들어요!";
        };
    };
};
return export;
