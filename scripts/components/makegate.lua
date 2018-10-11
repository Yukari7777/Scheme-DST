local MakeGate = Class(function(self, inst)
    self.inst = inst
	self.onusefn = nil
    self.distance_controller = 7 
end)

function MakeGate:SpawnEffect(inst)
	local pt = inst:GetPosition()
	local fx = SpawnPrefab("small_puff")
	fx.Transform:SetPosition(pt.x, pt.y, pt.z)
end

function MakeGate:CanSpell(caster)
	if caster.components.power and caster.components.power:GetCurrent() >= cost then
		if self.onusefn == nil then
			return false
		end
	else
		return false
	end

	return true
end

function MakeGate:Create(pt, caster)

	caster.SoundEmitter:PlaySound("dontstarve/common/staff_blink")
	if caster.components.health then
		caster.components.health:SetInvincible(true)
	end
	caster:DoTaskInTime(0.5, function() 
		if caster.components.health then
			caster.components.health:SetInvincible(false)
		end
		local scheme = SpawnPrefab("tunnel")
		scheme.Transform:SetPosition(pt.x, pt.y, pt.z)
		TheWorld.components.scheme_manager:InitGate(scheme)
	end)
	
	self.onusefn(self.inst, pt, caster)
	
	return true
end

return MakeGate