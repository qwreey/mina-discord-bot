-- print("Data server")

local res_payload = "Hello!"
local res_headers = {
   {"Content-Length", tostring(#res_payload)}, -- Must always be set if a payload is returned
   {"Content-Type", "text/plain"}, -- Type of the response's payload (res_payload)
   {"Connection", "close"}, -- Whether to keep the connection alive, or close it
   code = 200,
   reason = "OK",
}

local corohttp = require "coro-http";
corohttp.createServer("127.0.0.1",21456,function(this)
    return res_headers,res_payload;
end);
