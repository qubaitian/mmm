local Hud = {}

local KEY_NODES = {
	up = 'key_w',
	down = 'key_s',
	left = 'key_a',
	right = 'key_d',
	arrow_up = 'key_w',
	arrow_down = 'key_s',
	arrow_left = 'key_a',
	arrow_right = 'key_d',
}

local KEY_LETTERS = {
	key_w = 'w',
	key_a = 'a',
	key_s = 's',
	key_d = 'd',
}

function Hud.move_nodes(move_control)
	return {
		stick = move_control == 'stick',
		wasd = move_control == 'wasd',
	}
end

function Hud.key_node(action)
	return KEY_NODES[action]
end

function Hud.key_animation(letter, pressed)
	if pressed then
		return 'keyboard_' .. letter .. '_outline'
	end
	return 'keyboard_' .. letter
end

function Hud.skill_animation(pressed)
	if pressed then
		return 'generic_button_circle_fill'
	end
	return 'generic_button_circle'
end

function Hud.letter_for_node(node)
	return KEY_LETTERS[node]
end

function Hud.in_move_zone(x, y)
	return x >= 0 and x < 450 and y >= 0 and y < 560
end

return Hud
