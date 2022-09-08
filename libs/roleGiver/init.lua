
---@type table<string,Command>
local exports = {
    ["역할받기"] = {
        alias = {
            "역할주기","역할선택","역할 주기","역할 선택","역할 받기",
            "룰주기","룰선택","룰받기","룰 주기","룰 선택","룰 받기"
        };
        reply = "";
        -- "<@&(%d+)>"
        onSlash = commonSlashCommand {
            name = "역할주기";
            description = "버튼을 누르면 역할을 주는 메시지를 만듭니다!";
            optionName = "역할들";
            optionDescription = "필요한 역할의 맨션을 넣으세요. (@역할이름) 여러개를 넣을 수 있습니다";
            optionRequired = true;
        };
    };
};

return exports;
