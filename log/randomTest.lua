local min,max = 1,12;
local cRandom = require("libs.cRandom");
local drawPer = require("libs.drawPer");
local tests = 100000;
-------------------------------------------------------------------------------------------------------------------------------------------------------local titles = {"​슈​가​냥​이​가 ​젤​귀​엽​다","​존​경​이​가 ​젤​귀​엽​다","​냥​냥​이​가 ​젤​귀​엽​다","​댭​댜​비​가 ​젤​귀​엽​다","​익​명​이​가 ​젤​귀​엽​다","​콤​콥​이​가 ​잴​귀​엽​다","​몽​리​니​가 ​잴​귀​엽​다","​크​림​이​가 ​젤​귀​엽​다","​샴​플​이​가 ​젤​귀​엽​다","​샴​샴​이​가 ​젤​귀​엽​다"};
local uv = require("uv");
local circles = {"◜","◝","◞","◟"};
local circlesLen = #circles;
local lastClock = 0;
local lastCircle = 0;

local array = {} for i = 1,max do array[i] = 0 end;
for i = 1,tests do
    --uv.sleep(1);
    local nowClock = os.clock();
    if nowClock-0.18 > lastClock then
        lastClock = nowClock;
        lastCircle = lastCircle + 1;
    end
    io.write("\r","  " .. drawPer.drawPerbar(i/tests,62) .. " " .. circles[lastCircle % circlesLen + 1] .. " ");
    local index = cRandom(min,max);
    array[index] = array[index] + 1;
end
for index,value in ipairs(array) do
    --drawPer.drawPerbarWithFrame(titles[index],value/tests,72);
    drawPer.drawPerbarWithFrame(tostring(index),value/tests,72);
end
