hash = function(value) return value end
local marker = { visible = false, enabled = true }
gui = {
  get_node = function(name) assert(name == 'you'); return marker end,
  set_enabled = function(node, value) node.enabled = value end,
  set_visible = function(node, value) node.visible = value end,
}
dofile('main/hud.gui_script')
on_message({}, 'local_player', { visible = true })
assert(marker.visible and marker.enabled, 'The local player marker must be visible')
on_message({}, 'local_player', { visible = false })
assert(not marker.visible, 'The local player marker must hide after leaving')
print('HUD tests pass')
