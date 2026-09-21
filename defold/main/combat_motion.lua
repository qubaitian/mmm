local Motion = {}
local IDLE = -0.65

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function smooth(t)
	return t * t * (3 - 2 * t)
end

local function point(radius, angle)
	return { x = math.cos(angle) * radius, y = math.sin(angle) * radius }
end

local function duration(skill)
	if skill == 'overpower' then return 0.16 end
	if skill == 'mortal_strike' then return 0.35 end
	return 0
end

function Motion.pose(skill, age, facing)
	local offset = IDLE
	local trail = 0
	local length = duration(skill)
	local visible = skill ~= nil and age >= 0 and age < length
	if visible then
		local direction = skill == 'overpower' and -1 or 1
		local start = skill == 'overpower' and 0.7 or 1.05
		local finish = skill == 'overpower' and 0.8 or 1.15
		local t = age / length
		offset = lerp(-direction * start, direction * finish, smooth(t))
		trail = math.sin(t * math.pi)
	end
	local angle = facing + offset
	return {
		visible = visible,
		angle = angle,
		sword = point(52, angle),
		hands = { point(20, angle), point(29, angle) },
		trail = trail,
	}
end

return Motion
