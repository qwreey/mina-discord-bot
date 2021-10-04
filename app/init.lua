local uv = require("uv");
local exitCodes = require("app.exitCodes");

local function app()
	local _,_,exitCode = os.execute("bin\\luvit.exe app/main");
	return exitCode;
end

while true do
	local exitCode = app();
	print("return code: ", exitCode);

	if exitCode == exitCodes.exit then
		print("app was passed process kill code; killing luvit app");
		os.exit(0);
	elseif exitCode == exitCodes.error then
		print("app was passed error code; reload with 500ms delay");
		uv.sleep(5000);
	elseif exitCode == exitCodes.reload then
		print("app called reloading; reload without some delays");
	else
		print("app was killed with some unexpected error; wait 5000ms before trying again");
		uv.sleep(5000);
	end
end
