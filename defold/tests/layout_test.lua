package.path = './?.lua;' .. package.path
local Layout = require 'main.layout'

local function nearly(actual, expected, label)
  local delta = math.abs(actual - expected)
  assert(delta < 0.001, (label or 'value') .. ' expected ' .. expected .. ' got ' .. actual)
end

local portrait = Layout.from_window(720, 1280)
nearly(portrait.scale, 1, 'portrait scale')
nearly(portrait.fit_x, 0, 'portrait fit x')
nearly(portrait.fit_y, 0, 'portrait fit y')
nearly(portrait.fit_w, 720, 'portrait fit w')
nearly(portrait.fit_h, 1280, 'portrait fit h')
nearly(portrait.battle_x, 0, 'portrait battle x')
nearly(portrait.battle_y, 560, 'portrait battle y')
nearly(portrait.battle_size, 720, 'portrait battle size')

local retina = Layout.from_window(1440, 2560)
nearly(retina.scale, 2, 'retina scale')
nearly(retina.battle_y, 1120, 'retina battle y')
nearly(retina.battle_size, 1440, 'retina battle size')

local landscape = Layout.from_window(1920, 1080)
nearly(landscape.scale, 1080 / 1280, 'landscape scale')
nearly(landscape.fit_h, 1080, 'landscape fit h')
nearly(landscape.fit_y, 0, 'landscape fit y')
nearly(landscape.fit_w, 720 * 1080 / 1280, 'landscape fit w')
nearly(landscape.fit_x, (1920 - landscape.fit_w) / 2, 'landscape fit x')
nearly(landscape.battle_size, landscape.fit_w, 'landscape battle size')
nearly(landscape.battle_y, landscape.fit_y + 560 * landscape.scale, 'landscape battle y')

local x, y = Layout.to_design(portrait, 360, 920)
nearly(x, 360, 'design x')
nearly(y, 920, 'design y')

local lx, ly = Layout.to_design(landscape, landscape.fit_x + landscape.fit_w / 2, landscape.fit_y)
nearly(lx, 360, 'letterbox design x')
nearly(ly, 0, 'letterbox design y')

nearly(Layout.world_half(), 360, 'world half')

print('Layout tests pass')
