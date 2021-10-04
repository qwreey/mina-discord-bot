-- 디버그 스테커
-- debug {테이블화 된 내용}
-- 하면 디버그 스텍에 쌓임

local insert = table.insert;
_G.debugStack = {};
local qDebug = {};
setmetatable(qDebug,{
	__call = function (self,t)
		t.timestemp = os.date("%c");
		insert(self,t);
		-- fs.appendFile("log/debug.log","[\"" .. os.date("%c") .. "\"] = " .. table.dump(t) .. "\n");
		fs.appendFile("log/debug.log",table.dump(t) .. "\n");
	end;
});
function qDebug:display(index)
	index = index or 1;
	local lenself = #self;
	io.write("\27[2K\r\27[\27[0m");
	for indexer = lenself - index + 1,lenself do
		table.print(self[indexer]);
	end
	return true;
end
-- function qDebug:dump()

-- end
return qDebug;