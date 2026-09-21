package.path = './?.lua;' .. package.path
local Joystick = require 'main.joystick'

local function nearly(actual, expected, label)
  local delta = math.abs(actual - expected)
  assert(delta < 0.001, (label or 'value') .. ' expected ' .. expected .. ' got ' .. actual)
end

local function expect(stick, x, y, label)
  local actual_x, actual_y = stick:vector()
  assert(actual_x == x and actual_y == y, (label or 'direction') .. ' expected ' .. x .. ',' .. y .. ' got ' .. actual_x .. ',' .. actual_y)
end

local stick = Joystick.new(140, 180, 90, 0.2)
assert(stick:press(1, 200, 250), 'A press sets the origin at the finger')
expect(stick, 0, 0, 'press origin')
nearly(stick.cx, 200, 'origin x')
nearly(stick.cy, 250, 'origin y')
nearly(stick.nub_x, 200, 'nub stays on the finger at press')
nearly(stick.nub_y, 250, 'nub y at press')

stick:move(1, 210, 250)
expect(stick, 0, 0, 'deadzone')

stick:move(1, 290, 250)
expect(stick, 1, 0, 'right')
nearly(stick.nub_x, 290, 'right nub x')
nearly(stick.nub_y, 250, 'right nub y')

stick:move(1, 290, 260)
expect(stick, 1, 0, 'near-right stays cardinal')

stick:move(1, 200, 340)
expect(stick, 0, 1, 'up')

stick:move(1, 210, 340)
expect(stick, 0, 1, 'near-up stays cardinal')

stick:move(1, 263, 313)
expect(stick, 1, 1, 'up-right')

stick:move(1, 110, 250)
expect(stick, -1, 0, 'left')

stick:move(1, 200, 160)
expect(stick, 0, -1, 'down')

stick:move(1, 137, 187)
expect(stick, -1, -1, 'down-left')

stick:move(2, 400, 400)
expect(stick, -1, -1, 'other finger ignored')

stick:release(1)
expect(stick, 0, 0, 'released')
nearly(stick.cx, 140, 'rest origin x')
nearly(stick.cy, 180, 'rest origin y')
nearly(stick.nub_x, 140, 'rest nub x')
nearly(stick.nub_y, 180, 'rest nub y')

assert(stick:press(1, 80, 100), 'A new press can start after release')
assert(not stick:press(2, 300, 300), 'A second press does not steal the stick')
stick:release(1)

print('Joystick tests pass')
