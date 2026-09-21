local Status = {}
Status.__index = Status

function Status.new()
	return setmetatable({ sequence = 0, age = 1, skill = nil, refreshed = false }, Status)
end

function Status:receive(attack)
	if attack.sequence <= self.sequence then return false end
	self.sequence = attack.sequence
	self.age = 0
	self.skill = attack.skill
	self.refreshed = attack.refreshed
	return true
end

function Status:update(dt, state)
	self.age = self.age + dt
	local flash = math.max(0, 1 - self.age / 0.6)
	local charges = state.charges or 2
	return {
		charges = charges,
		progress = charges == 2 and 1 or math.max(0, math.min(1, 1 - (state.rechargeRemaining or 4.5) / 4.5)),
		remaining = state.rechargeRemaining or 0,
		mortal_progress = math.max(0, math.min(1, 1 - (state.mortalRemaining or 0) / 4.5)),
		mortal_remaining = state.mortalRemaining or 0,
		overpower_flash = self.skill == 'overpower' and flash or 0,
		mortal_flash = self.skill == 'mortal_strike' and flash or 0,
		refresh_flash = self.refreshed and flash or 0,
	}
end

return Status
