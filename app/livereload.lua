--[[
Live reload system for testing code
]]

return function(testingMode)
	if not testingMode then return; end
	local uv = uv or require("uv");
	for _,path in pairs({
		"./app";
		"./commands";
		"./deps";
		"./libs";
		"./class";
	}) do
		local fse = uv.new_fs_event();
		uv.fs_event_start(fse,path,{
			recursive = true;
		},function (err,fname,status)
			if(err) then
				logger.debugf("Error ", err);
			else
				if fname:match("%.git") then
					return;
				end
				if not fname:match("%.lua$") then
					return;
				end
				logger.infof("Some file was changed : %s", fname);
				if _G.livereloadEnabled then
					logger.infof("Try to do live reloading . . .");
					os.exit(require("app.exitCodes").reload);
				end
			end
		end);
	end
end