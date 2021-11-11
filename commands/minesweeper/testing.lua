---@diagnostic disable
p(args);

local game = require("commands.minesweeper.game");
local gameInstance,clicked,flagged = game.initGame(12,24);

print(game.draw(gameInstance));