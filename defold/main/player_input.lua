local Input = {}
Input.__index = Input

function Input.new()
	return setmetatable({ keys = {}, stick_x = 0, stick_y = 0 }, Input)
end

function Input:set(action, pressed)
	self.keys[action] = pressed
end

function Input:set_stick(x, y)
	self.stick_x = x
	self.stick_y = y
end

function Input:clear()
	self.keys = {}
	self.stick_x, self.stick_y = 0, 0
end

local function axis(positive, negative)
	return (positive and 1 or 0) - (negative and 1 or 0)
end

local function sign(value)
	if value > 0 then return 1 end
	if value < 0 then return -1 end
	return 0
end

function Input:direction()
	local keys = self.keys
	local up = keys.up or keys.arrow_up
	local down = keys.down or keys.arrow_down
	local left = keys.left or keys.arrow_left
	local right = keys.right or keys.arrow_right
	local x = axis(right, left)
	local y = axis(up, down)
	if x == 0 then x = sign(self.stick_x) end
	if y == 0 then y = sign(self.stick_y) end
	return x, y
end

return Input
