local Motion = require 'main.combat_motion'
local View = {}
local HANDS = { [0] = 'green_hand', 'red_hand', 'yellow_hand', 'purple_hand' }
local atan2 = math.atan2 or math.atan
local TRAIL_COUNT = 10

local function piece(animation, scale, flat)
	local id = factory.create('#combat_factory')
	local sprite_url = msg.url(nil, id, 'sprite')
	sprite.play_flipbook(sprite_url, animation)
	go.set_scale(scale or 1, id)
	if flat then go.set(sprite_url, 'flash', vmath.vector4(1, 0, 0, 0)) end
	return { id = id, sprite = sprite_url }
end

local function tint(item, r, g, b, a)
	go.set(item.sprite, 'tint', vmath.vector4(r, g, b, a))
end

local function place(item, x, y, z, angle)
	go.set_position(vmath.vector3(x, y, z), item.id)
	go.set_rotation(vmath.quat_rotation_z(angle or 0), item.id)
end

function View.new(color)
	local view = {
		sword = piece('weapon_longsword', 1.4),
		hands = { piece(HANDS[color] or HANDS[0], 0.85), piece(HANDS[color] or HANDS[0], 0.85) },
		trail = {}, sparks = {}, age = 1, sequence = 0,
	}
	tint(view.sword, 1, 1, 1, 0)
	for _, hand in ipairs(view.hands) do tint(hand, 1, 1, 1, 0) end
	for i = 1, TRAIL_COUNT do
		view.trail[i] = piece('tile', 1, true)
		tint(view.trail[i], 1, 1, 1, 0)
	end
	for i = 1, 4 do
		view.sparks[i] = piece('tile', 1, true)
		tint(view.sparks[i], 1, 1, 1, 0)
	end
	return view
end

function View.attack(view, attack, radius)
	if attack.sequence <= view.sequence then return false end
	view.sequence = attack.sequence
	view.skill = attack.skill
	view.age = 0
	local angle = atan2(attack.y - attack.targetY, attack.x - attack.targetX)
	view.impact_x = attack.targetX + math.cos(angle) * radius
	view.impact_y = attack.targetY + math.sin(angle) * radius
	view.impact_angle = angle
	return true
end

function View.update(view, dt, x, y, target_x, target_y)
	view.age = view.age + dt
	local facing = atan2(target_y - y, target_x - x)
	local pose = Motion.pose(view.skill, view.age, facing)
	local alpha = pose.visible and 1 or 0
	tint(view.sword, 1, 1, 1, alpha)
	place(view.sword, x + pose.sword.x, y + pose.sword.y, 0.2, pose.angle - math.pi / 2)
	for i, hand in ipairs(view.hands) do
		tint(hand, 1, 1, 1, alpha)
		place(hand, x + pose.hands[i].x, y + pose.hands[i].y, 0.3)
	end
	local direction = view.skill == 'overpower' and -1 or 1
	for i, trail in ipairs(view.trail) do
		local t = (i - 1) / TRAIL_COUNT
		local angle = pose.angle - direction * t * 0.75
		place(trail, x + math.cos(angle) * 77, y + math.sin(angle) * 77, 0.1, angle + math.pi / 2)
		go.set_scale(vmath.vector3(9 / 64, (1 - t) * 6 / 64, 1), trail.id)
		tint(trail, 1, view.skill == 'overpower' and 0.91 or 0.62, 0.35, pose.trail * (1 - t) * 0.8)
	end
	for i, spark in ipairs(view.sparks) do
		local alpha = math.max(0, 1 - view.age / 0.25)
		if alpha > 0 then
			local angle = view.impact_angle + (i - 2.5) * 0.8
			local distance = view.age * 100
			place(spark, view.impact_x + math.cos(angle) * distance, view.impact_y + math.sin(angle) * distance, 0.4, angle)
			go.set_scale(vmath.vector3(8 / 64, 2 / 64, 1), spark.id)
		end
		tint(spark, 1, 0.9, 0.5, alpha)
	end
end

function View.delete(view)
	go.delete(view.sword.id)
	for _, group in ipairs({ view.hands, view.trail, view.sparks }) do
		for _, item in ipairs(group) do go.delete(item.id) end
	end
end

function View.dummy(state)
	local dummy = piece('red_character', state.radius / 22)
	place(dummy, state.x, state.y, 0.02)
	dummy.age = 1
	return dummy
end

function View.flash(dummy)
	dummy.age = 0
end

function View.update_dummy(dummy, dt)
	dummy.age = dummy.age + dt
	go.set(dummy.sprite, 'flash', vmath.vector4(math.max(0, 1 - dummy.age / 0.16), 0, 0, 0))
end

return View
