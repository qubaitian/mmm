package.path = './?.lua;' .. package.path
local Sfx = require 'main.combat_sfx'
local played = {}
Sfx.hit(function(url) played[#played+1] = url end)
assert(played[1] == '#hit', 'A hit plays the hit sound')
print('Combat sfx tests pass')
