local Joystick = {}
Joystick.__index = Joystick

local CARDINAL = math.tan(math.pi / 8)

function Joystick.new(cx, cy, radius, deadzone)
	return setmetatable({
		rest_x = cx,
		rest_y = cy,
		cx = cx,
		cy = cy,
		radius = radius,
		deadzone = deadzone or 0.2,
		id = nil,
		x = 0,
		y = 0,
		nub_x = cx,
		nub_y = cy,
	}, Joystick)
end

local function length(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end

local function snap8(nx, ny)
	local ax, ay = math.abs(nx), math.abs(ny)
	local x, y = 0, 0
	if ax >= ay * CARDINAL then
		x = nx > 0 and 1 or -1
	end
	if ay >= ax * CARDINAL then
		y = ny > 0 and 1 or -1
	end
	return x, y
end

local function nub_offset(x, y, radius)
	if x == 0 and y == 0 then
		return 0, 0
	end
	local scale = radius
	if x ~= 0 and y ~= 0 then
		scale = radius * math.sqrt(0.5)
	end
	return x * scale, y * scale
end

function Joystick:press(id, x, y)
	if self.id then
		return false
	end
	self.id = id
	self.cx, self.cy = x, y
	self.x, self.y = 0, 0
	self.nub_x, self.nub_y = x, y
	return true
end

function Joystick:move(id, x, y)
	if self.id ~= id then
		return
	end
	local dx = x - self.cx
	local dy = y - self.cy
	local len = length(dx, dy)
	if len > self.radius and len > 0 then
		dx = dx / len * self.radius
		dy = dy / len * self.radius
		len = self.radius
	end
	local nx = self.radius == 0 and 0 or dx / self.radius
	local ny = self.radius == 0 and 0 or dy / self.radius
	if length(nx, ny) < self.deadzone then
		self.x, self.y = 0, 0
	else
		self.x, self.y = snap8(nx, ny)
	end
	local ox, oy = nub_offset(self.x, self.y, self.radius)
	self.nub_x = self.cx + ox
	self.nub_y = self.cy + oy
end

function Joystick:release(id)
	if self.id ~= id then
		return
	end
	self.id = nil
	self.x, self.y = 0, 0
	self.cx, self.cy = self.rest_x, self.rest_y
	self.nub_x, self.nub_y = self.rest_x, self.rest_y
end

function Joystick:vector()
	return self.x, self.y
end

return Joystick
