package.path = './?.lua;' .. package.path
local Input = require 'main.player_input'
local input = Input.new()
local function expect(x, y)
  local actual_x, actual_y = input:direction()
  assert(actual_x == x and actual_y == y, 'Unexpected movement direction')
end
input:set('up', true)
input:set('right', true)
expect(1, 1)
input:set('arrow_up', true)
input:set('up', false)
expect(1, 1)
input:set('down', true)
expect(1, 0)
input:clear()
expect(0, 0)
for _, up in ipairs({-1, 0, 1}) do
  for _, right in ipairs({-1, 0, 1}) do
    input:clear()
    input:set('up', up == 1)
    input:set('down', up == -1)
    input:set('right', right == 1)
    input:set('left', right == -1)
    expect(right, up)
  end
end
input:clear()
expect(0, 0)
input:set_stick(1, 0)
expect(1, 0)
input:set_stick(0.4, -0.9)
expect(1, -1)
input:set('left', true)
expect(-1, -1)
input:clear()
expect(0, 0)
print('Input tests pass')
