local module = {};

function module.run(str)
	return str:gsub("&&","and");
end

return module;