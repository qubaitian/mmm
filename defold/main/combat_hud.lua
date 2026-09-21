local Status = require 'main.combat_status'
local CombatHud = {}

local function box(x, y, w, h, color)
	local node = gui.new_box_node(vmath.vector3(x, y, 0), vmath.vector3(w, h, 0))
	gui.set_color(node, color)
	return node
end

local function label(x, y, text, size, left)
	local node = gui.new_text_node(vmath.vector3(x, y, 0), text)
	gui.set_font(node, 'combat')
	gui.set_scale(node, vmath.vector3(size / 28, size / 28, 1))
	gui.set_color(node, vmath.vector4(0.9, 0.93, 0.96, 1))
	if left then gui.set_pivot(node, gui.PIVOT_W) end
	return node
end

function CombatHud.new()
	local self = { status = Status.new(), state = {}, active = false }
	label(360, 454, 'Move near the dummy to attack automatically.', 22)
	label(360, 424, 'Keep moving while you attack.', 22)
	label(140, 348, 'Move', 24)
	label(556, 348, 'Arms Warrior - Auto Combat', 19)
	self.overpower = box(556, 270, 276, 94, vmath.vector4(0.13, 0.17, 0.21, 1))
	self.mortal = box(556, 157, 276, 94, vmath.vector4(0.13, 0.17, 0.21, 1))
	label(438, 284, 'Overpower', 24, true)
	label(438, 181, 'Mortal Strike', 24, true)
	label(438, 153, '30% chance: +1 Overpower', 17, true)
	self.charges = {}
	for i = 1, 2 do
		box(620 + (i - 1) * 32, 283, 27, 21, vmath.vector4(0.3, 0.35, 0.4, 1))
		self.charges[i] = box(620 + (i - 1) * 32, 283, 23, 17, vmath.vector4(1, 0.75, 0.26, 1))
	end
	box(518, 243, 160, 6, vmath.vector4(0.06, 0.09, 0.12, 1))
	self.progress = box(438, 243, 160, 6, vmath.vector4(0.95, 0.7, 0.25, 1))
	gui.set_pivot(self.progress, gui.PIVOT_W)
	self.timer = label(644, 243, 'Ready', 18)
	box(518, 125, 160, 6, vmath.vector4(0.06, 0.09, 0.12, 1))
	self.mortal_progress = box(438, 125, 160, 6, vmath.vector4(0.95, 0.48, 0.3, 1))
	gui.set_pivot(self.mortal_progress, gui.PIVOT_W)
	self.mortal_timer = label(644, 125, 'Ready', 18)
	self.refresh = label(556, 86, 'Overpower charge +1', 21)
	gui.set_enabled(self.refresh, false)
	return self
end

function CombatHud.attack(self, attack)
	self.status:receive(attack)
end

function CombatHud.set_active(self, active)
	self.active = active
	if not active then
		self.status = Status.new()
		self.state = {}
	end
end

function CombatHud.update(self, dt)
	local view = self.status:update(dt, self.state)
	local op = view.overpower_flash
	local ms = view.mortal_flash
	gui.set_color(self.overpower, vmath.vector4(0.13 + op * 0.32, 0.17 + op * 0.19, 0.21, 1))
	gui.set_color(self.mortal, vmath.vector4(0.13 + ms * 0.35, 0.17 + ms * 0.1, 0.21, 1))
	for i, node in ipairs(self.charges) do
		local filled = self.active and i <= view.charges
		gui.set_color(node, filled
			and vmath.vector4(1, 0.75 + view.refresh_flash * 0.25, 0.26 + view.refresh_flash * 0.74, 1)
			or vmath.vector4(0.1, 0.13, 0.17, 1))
	end
	gui.set_size(self.progress, vmath.vector3(self.active and 160 * view.progress or 0, 6, 0))
	gui.set_text(self.timer, not self.active and '--' or (view.charges == 2 and 'Ready' or string.format('%.1fs', view.remaining)))
	gui.set_size(self.mortal_progress, vmath.vector3(self.active and 160 * view.mortal_progress or 0, 6, 0))
	gui.set_text(self.mortal_timer, not self.active and '--' or (view.mortal_remaining <= 0 and 'Ready' or string.format('%.1fs', view.mortal_remaining)))
	gui.set_enabled(self.refresh, self.active and view.refresh_flash > 0)
	gui.set_color(self.refresh, vmath.vector4(1, 0.82, 0.37, view.refresh_flash))
end

return CombatHud
