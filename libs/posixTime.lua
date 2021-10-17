local time = os.time;
local diff = time() - time(os.date("!*t"));

return {now = function ()
    return time - diff;
end};
