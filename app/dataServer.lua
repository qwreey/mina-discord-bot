local corohttp = require 'coro-http';

corohttp.createServer("http://127.0.0.1",25363,function (req, body)
	print(req.method,req.params.name);
	local payload = "testing";

	local header = {
		{"Content-Type","application/json"};
		{"Content-Length",tostring(#payload)};
		{"Connection", "close"};
	};

	header.code = 200;
	header.reason = "OK";

	return header,payload;
end);
