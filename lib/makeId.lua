local WORD = {
	"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
	"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
	"1","2","3","4","5","6","7","8","9","0"
};
return function ()
	local ID = "";
	for i = 1,18 do
        math.randomseed(math.floor(((os.clock()+os.time())*1111) + ((i^2)*math.pi*10000)));
		ID = ID .. WORD[math.random(1,#WORD)];
	end
	return ID;
end