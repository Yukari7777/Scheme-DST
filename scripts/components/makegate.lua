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
	return true
end

function MakeGate:Configurate(target, caster)
	target:PushEvent("tag", {spawner = caster})

	return true
end

function MakeGate:Create(pt, caster)
	local modname = KnownModIndex:GetModActualName("Scheme")
	local SPAWNCOST = GetModConfigData("spawncost", modname)

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
				caster.components.sanity:DoDelta(-SPAWNCOST)
			end
		end
		local scheme = SpawnPrefab("tunnel")
		scheme.components.scheme:InitGate()
		scheme.Transform:SetPosition(pt.x, pt.y, pt.z)
		self:Configurate(scheme, caster)
	end)
	
	return true
end

function MakeGate:Erase(target, caster)
	local modname = KnownModIndex:GetModActualName("Scheme")
	local DELCOST = GetModConfigData("delcost", modname)

	if caster ~= nil then
        caster.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
		
        if caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-DELCOST)
        end
    end

	target:Remove()
	return true
end

function MakeGate:Index(target, caster)
	target.components.scheme:Connect()

	if target.components.scheme.pointer == nil then return false end
	local dest = _G.TUNNELNETWORK[target.components.scheme.pointer].inst.components.taggable:GetText() or "#"..target.components.scheme.pointer
	target.sg:GoToState("opening")

	caster.components.talker:Say("Set to "..dest)

	return true
end

return MakeGate