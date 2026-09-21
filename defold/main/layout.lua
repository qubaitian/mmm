local Layout = {}

Layout.DESIGN_WIDTH = 720
Layout.DESIGN_HEIGHT = 1280
Layout.CONTROL_HEIGHT = 560
Layout.BATTLE_SIZE = 720

function Layout.from_window(window_width, window_height)
	local scale = math.min(window_width / Layout.DESIGN_WIDTH, window_height / Layout.DESIGN_HEIGHT)
	local fit_w = Layout.DESIGN_WIDTH * scale
	local fit_h = Layout.DESIGN_HEIGHT * scale
	local fit_x = (window_width - fit_w) / 2
	local fit_y = (window_height - fit_h) / 2
	return {
		scale = scale,
		fit_x = fit_x,
		fit_y = fit_y,
		fit_w = fit_w,
		fit_h = fit_h,
		battle_x = fit_x,
		battle_y = fit_y + Layout.CONTROL_HEIGHT * scale,
		battle_size = Layout.BATTLE_SIZE * scale,
	}
end

function Layout.to_design(layout, window_x, window_y)
	return (window_x - layout.fit_x) / layout.scale, (window_y - layout.fit_y) / layout.scale
end

function Layout.world_half()
	return Layout.BATTLE_SIZE / 2
end

return Layout
