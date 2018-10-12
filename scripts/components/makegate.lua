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
	if not (caster.components.sanity and caster.components.sanity:GetCurrent() >= TUNING.SANITY_MEDLARGE) then
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
		if caster ~= nil then
			caster.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")

			if caster.components.sanity ~= nil then
				caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
			end
		end
		local scheme = SpawnPrefab("tunnel")
		scheme.Transform:SetPosition(pt.x, pt.y, pt.z)
	end)
	
	return true
end

function MakeGate:Erase(target, caster)
	if caster ~= nil then
        caster.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
		
        if caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
        end
    end

	target:Remove()
	return true
end

function MakeGate:Index(target, caster)
	target.components.scheme:Connect()
	-- say destination's tag

	return true
end

return MakeGate