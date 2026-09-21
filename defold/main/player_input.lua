local Input = {}
Input.__index = Input

function Input.new()
	return setmetatable({ keys = {} }, Input)
end

function Input:set(action, pressed)
	self.keys[action] = pressed
end

function Input:clear()
	self.keys = {}
end

function Input:direction()
	local keys = self.keys
	local up = keys.up or keys.arrow_up
	local down = keys.down or keys.arrow_down
	local left = keys.left or keys.arrow_left
	local right = keys.right or keys.arrow_right
	return (right and 1 or 0) - (left and 1 or 0), (up and 1 or 0) - (down and 1 or 0)
end

return Input
