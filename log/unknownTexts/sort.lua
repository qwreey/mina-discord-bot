local logFile = io.open("log/unknownTexts/raw.txt");
local log = logFile:read("a");
logFile:close();

local tb = {};

string.gsub(log,"(.-)\n",function(this)
    local sthis = tb[this];
    tb[this] = sthis and (sthis + 1) or 1;
    return;
end)

logFile = io.open("log/unknownTexts/sorted.txt","a+");
for str,much in pairs(tb) do
    local p = ("[%d] : %s"):format(much,str);
    print(p);
    logFile:write(str .. "\n");
end
logFile:close();

os.exit(0);
