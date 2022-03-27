return function(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, ("([^%s]+)"):format(sep)) do
			table.insert(t, str)
	end
	return t
end