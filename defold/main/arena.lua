local Arena = {}

local function tile(animation, x, y, angle, color)
	local id = factory.create('#tile_factory', vmath.vector3(x, y, -0.5), vmath.quat_rotation_z(angle or 0))
	local sprite_url = msg.url(nil, id, 'sprite')
	sprite.play_flipbook(sprite_url, animation)
	go.set(sprite_url, 'tint', color)
end

function Arena.build(tiles, size)
	local floor_color = vmath.vector4(0.36, 0.40, 0.44, 1)
	local wall_color = vmath.vector4(0.72, 0.76, 0.80, 1)
	for y = 0, tiles - 1 do
		for x = 0, tiles - 1 do
			tile('tile', (x + 0.5) * size, (y + 0.5) * size, 0, floor_color)
		end
	end
	local edge = tiles * size
	for i = 0, tiles - 1 do
		local center = (i + 0.5) * size
		tile('wall', center, -size / 2, 0, wall_color)
		tile('wall', center, edge + size / 2, math.pi, wall_color)
		tile('wall', -size / 2, center, -math.pi / 2, wall_color)
		tile('wall', edge + size / 2, center, math.pi / 2, wall_color)
	end
	for _, corner in ipairs({
		{ -size / 2, -size / 2, -math.pi / 2 },
		{ edge + size / 2, -size / 2, 0 },
		{ edge + size / 2, edge + size / 2, math.pi / 2 },
		{ -size / 2, edge + size / 2, math.pi },
	}) do
		tile('inner_diagonal', corner[1], corner[2], corner[3], wall_color)
	end
end

return Arena
