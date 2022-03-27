local commitTime,commitCount = "","" do
	local errPrefix = "[GitVersion] %s";
	local errNewline = "\n"..(" "):rep(#errPrefix - 2);
	promise.new(function()
		timer.sleep(0);
		-- git last commit time
		local gitTime = spawn("git",{
			args = {"log","-1","--format=%cd"};
			stdio = {nil,true,true};
		});
		local waitter = promise.waitter();
		waitter:add(promise.new(function()
			for str in gitTime.stdout.read do
				commitTime = commitTime .. str;
			end
		end));
		waitter:add(promise.new(function()
			for str in gitTime.stderr.read do
				logger.errorf(errPrefix,str:gsub("\n",errNewline));
			end
		end));

		-- git commit counts
		local gitCount = spawn("git",{
			args = {"rev-list","--count","HEAD"};
			stdio = {nil,true,true};
		});
		waitter:add(promise.new(function()
			for str in gitCount.stdout.read do
				commitCount = commitCount .. str;
			end
		end));
		waitter:add(promise.new(function()
			for str in gitCount.stderr.read do
				logger.errorf(errPrefix,str:gsub("\n",errNewline));
			end
		end));
		waitter:wait();

		commitTime = commitTime:gsub("\n","");
		commitCount = commitCount:gsub("\n","");

		-- update version
		local month,day,times,year,gmt = commitTime:match("[^ ]+ +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+) +([^ ]+)");
		local version = ("%s %s %s Build %s"):format(month,day,tostring(times:match("%d+:%d+")),tostring(commitCount));
		app.version = version;

		-- refreshLine
		editor.prompt = buildPrompt();
		editor:refreshLine();

		-- wait process exit
		gitTime.waitExit();
		gitCount.waitExit();
	end);
end
