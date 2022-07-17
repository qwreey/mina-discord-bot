local module = {};

function module.drawPerbar(per,size)
	local barsize = (size-8)*per;
	local barsizePoint = barsize%1;
	local cut = math.floor(per*10000)/100;
	local cutPoint = #tostring(cut%1);
	local perText = tostring(cut) .. (cutPoint == 1 and ".00" or cutPoint == 3 and "0" or "");
	return table.concat{
		string.rep("█",math.floor(barsize)),
		(barsizePoint == 0 and "") or
		(barsizePoint > (7/8) and "▉") or
		(barsizePoint > (3/4) and "▊") or
		(barsizePoint > (5/8) and "▋") or
		(barsizePoint > (1/2) and "▌") or
		(barsizePoint > (3/8) and "▍") or
		(barsizePoint > (1/4) and "▎") or
		(barsizePoint > (1/8) and "▏") or " ",
		barsize == size and "" or (string.rep(" ",math.floor(size-barsize-8))),
		string.rep(" ",6 - #perText),perText,"% "
	};
end
function module.drawPerbarWithBackground(per,size)
	local barsize = (size-7)*per;
	local barsizePoint = barsize%1;
	local cut = math.floor(per*10000)/100;
	local cutPoint = #tostring(cut%1);
	local perText = tostring(cut) .. (cutPoint == 1 and ".00" or cutPoint == 3 and "0" or "");
	return table.concat{
		string.rep(" ",6 - #perText),perText,"% ",
		string.rep("█",math.floor(barsize)),
		string.rep("░",math.floor(size-barsize-6.5))
	};
end
function module.drawPerbarWithFrame(title,per,size)
	size = math.max(size,8);
	local titlebarSize = (size-2)/2-(utf8.len(title)/2);
	io.write(
		"\n┌",string.rep("─",math.floor(titlebarSize+0.5)),
		title,string.rep("─",math.floor(titlebarSize)),"┐\n│",
		module.drawPerbar(per,size-2),
		"│\n└",string.rep("─",size-2),"┘"
	);
end
function module.drawPerbarWithFrameAndBackground(title,per,size)
	size = math.max(size,8);
	local titlebarSize = (size-2)/2-(utf8.len(title)/2);
	io.write(
		"\n┌",string.rep("─",math.floor(titlebarSize+0.5)),
		title,string.rep("─",math.floor(titlebarSize)),"┐\n│",
		module.drawPerbarWithBackground(per,size-2),
		"│\n└",string.rep("─",size-2),"┘"
	);
end

return module;
