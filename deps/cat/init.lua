local strParser = require("str").run;

-- p(strParser [[
--	 if asdf then
--		 print ("asdf",'asdf');
--	 end
-- ]]);

local extensions = {
	require("operator").operator;
	require("function").arrow;
	require("self").self;
	require("variable").let;
	-- require("variable").global;
	require("logical").compare;
	require("logical").null;
	require("logical").operator;
};

local module = {};

function module.compile(str,env)
	env = env or {};

	-- parse string
	local strParsed = strParser(str);

	-- run extensions and make output
	local out = "";
	for _,this in ipairs(strParsed) do
		local m = this.m;
		local tstr = this.s;
		if not m then
			for _,func in ipairs(extensions) do
				tstr = func(tstr,env);
			end
			out = out .. tstr;
		elseif m == 1 then
			out = out .. ('"%s"'):format(tstr:gsub("\n","\\n"));
		elseif m == 2 then
			out = out .. ("'%s'"):format(tstr:gsub("\n","\\n"));
		elseif m == 3 then
			local estr = ("\"%s\""):format(tstr:gsub("\n","\\n"):gsub("'","\\'"):gsub('"','\\"'));
			local spec = estr:match("(\n +).-$");
			estr = estr:gsub("^([ 	%s]-\n[ 	%s]-)",""); -- bug? we need fix this
			if spec then
				out = out .. estr:gsub(spec,"\n");
			else
				out = out .. estr;
			end
		elseif m == 4 then
			out = out .. ("[[%s]]"):format(tstr);
		end
	end

	return out,env;
end

function module.upgradeString()
	pcall(require,"upgradeString");
end

return module;
