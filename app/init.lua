local uv = require("uv");
local exitCodes = require("app.exitCodes");

local function app()
    local _,_,exitCode = os.execute("bin\\luvit.exe app/main");
    return exitCode;
end

while true do
    local exitCode = app();

    if exitCode == exitCodes.exit then
        os.exit(0);
    elseif exitCode == exitCodes.error then
        uv.sleep(5000);
    elseif exitCode == exitCodes.reload then
    else
        os.exit(0);
    end
end
