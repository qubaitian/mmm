local Platform = {}

function Platform.move_control(system_name)
	if system_name == 'Android' then
		return 'stick'
	end
	return 'wasd'
end

return Platform
