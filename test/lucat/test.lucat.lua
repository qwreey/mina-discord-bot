
let discordia:discordia = require("discordia");
let client:client = discordia.Client;

client.on("messageCreate",(this) ->
    print(this.content);
end);

let test:boolean = true;
local class = {};

class.new = (key) =>
    print(self[key]);
end;
