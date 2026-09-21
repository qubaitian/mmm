package.path = './?.lua;' .. package.path
local Platform = require 'main.platform'
local Hud = require 'main.hud'

assert(Platform.move_control('Android') == 'stick', 'Android uses the stick')
assert(Platform.move_control('HTML5') == 'wasd', 'Web uses WASD')
assert(Platform.move_control('Darwin') == 'wasd', 'Desktop uses WASD')
assert(Platform.move_control('Windows') == 'wasd', 'Windows uses WASD')

local android = Hud.move_nodes('stick')
assert(android.stick and not android.wasd, 'Android shows the stick')
local web = Hud.move_nodes('wasd')
assert(web.wasd and not web.stick, 'Web shows WASD')

assert(Hud.key_animation('w', false) == 'keyboard_w')
assert(Hud.key_animation('w', true) == 'keyboard_w_outline')
assert(Hud.key_animation('a', true) == 'keyboard_a_outline')
assert(Hud.skill_animation(false) == 'generic_button_circle')
assert(Hud.skill_animation(true) == 'generic_button_circle_fill')
assert(Hud.key_node('up') == 'key_w')
assert(Hud.key_node('arrow_left') == 'key_a')
assert(Hud.in_move_zone(140, 180), 'The rest stick sits in the move zone')
assert(Hud.in_move_zone(200, 250), 'A left-bottom press can start the stick')
assert(not Hud.in_move_zone(600, 180), 'Skill buttons are outside the move zone')
assert(not Hud.in_move_zone(140, 800), 'The battle area is outside the move zone')

print('Platform tests pass')
