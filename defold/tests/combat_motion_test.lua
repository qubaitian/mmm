package.path = './?.lua;' .. package.path
local Motion = require 'main.combat_motion'
local function close(a, b) assert(math.abs(a - b) < 0.0001, tostring(a) .. ' != ' .. tostring(b)) end

local function test_swing(skill, direction, duration, start, finish)
  local facing = math.pi / 2
  local first = Motion.pose(skill, 0, 0)
  assert(first.visible)
  close(first.angle, -direction * start)
  local before = Motion.pose(skill, duration * 0.45, facing)
  local after = Motion.pose(skill, duration * 0.9, facing)
  assert(before.visible and after.visible)
  assert((after.angle - before.angle) * direction > 0, 'Skills swing in opposite directions')
  for _, age in ipairs({ 0, 0.1, 0.25, 0.4, 0.6, 2 }) do
    local pose = Motion.pose(skill, age, facing)
    assert(pose.visible == (age < duration), 'The weapon only appears during the swing')
    for i, hand in ipairs(pose.hands) do
      close(hand.x * math.sin(pose.angle) - hand.y * math.cos(pose.angle), 0)
      close(math.sqrt(hand.x * hand.x + hand.y * hand.y), i == 1 and 20 or 29)
    end
    assert(pose.trail >= 0 and pose.trail <= 1)
  end
  local last = Motion.pose(skill, duration - 0.00001, 0)
  assert(last.visible)
  assert(last.angle * direction > finish * 0.99, 'Strike ends at the far side, not back at idle')
  local ended = Motion.pose(skill, duration, 0)
  assert(ended.visible == false, 'The weapon hides when the strike ends')
  close(ended.trail, 0)
end

local function arc(skill, duration)
  return math.abs(Motion.pose(skill, duration - 0.00001, 0).angle - Motion.pose(skill, 0, 0).angle)
end

test_swing('overpower', -1, 0.16, 0.7, 0.8)
test_swing('mortal_strike', 1, 0.35, 1.05, 1.15)
assert(arc('overpower', 0.16) < arc('mortal_strike', 0.35) - 0.4, 'Overpower sweeps a smaller arc')
local idle = Motion.pose(nil, 0, 0)
assert(idle.visible == false, 'Idle characters do not carry a weapon')
local ended = Motion.pose('overpower', 0.16, 0)
close(idle.angle, ended.angle)
close(ended.trail, 0)
local rotated = Motion.pose('overpower', 0.08, math.pi / 2)
local normal = Motion.pose('overpower', 0.08, 0)
close(rotated.sword.x, -normal.sword.y)
close(rotated.sword.y, normal.sword.x)
print('Combat motion tests pass')
