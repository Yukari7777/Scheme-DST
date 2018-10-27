local scheme = Class(function(self, inst)
    self.inst = inst
	self.index = nil
	self.owner = nil
	self.pointer = nil
end)

function scheme:OnActivate(other, doer) 
	other.sg:GoToState("open")
end

function scheme:Activate(doer)
	if not self:IsConnected() then
		return
	end
	
	if doer:HasTag("player") then
		doer.SoundEmitter:KillSound("wormhole_travel")
	end

	self:OnActivate(self:GetTarget(self.pointer), doer)
	self:Teleport(doer)

	if doer.components.leader then
		for follower,v in pairs(doer.components.leader.followers) do
			self:Teleport(follower)
		end
	end

	local eyebone = nil

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower)
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower,v in pairs(eyebone.components.leader.followers) do
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then
					for j,item in pairs(follower.components.container.slots) do
						if item.components.leader then
							for follower,v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									self:Teleport(follower)
								end
							end
						end
					end
				end
			end
		end
	end
end

function scheme:Teleport(obj)
	if self.pointer ~= nil then
		local target = self:GetTarget(self.pointer)
		local offset = 2.0
		local angle = math.random() * 360
		local target_x, target_y, target_z = target.Transform:GetWorldPosition()
		local modname = KnownModIndex:GetModActualName("Scheme")
		local cost = GetModConfigData("usecost", modname) -- GetModConfigData not within modmain must have a modname argument.
		target_x = target_x + math.sin(angle)*offset
		target_z = target_z + math.cos(angle)*offset
		if obj.Physics then
			obj.Physics:Teleport( target_x, target_y, target_z )
		elseif obj.Transform then
			obj.Transform:SetPosition( target_x, target_y, target_z )
		end
		if obj.components.talker ~= nil then
            obj.components.talker:ShutUp()
        end
        if obj.components.sanity ~= nil and cost ~= 0 then
            obj.components.sanity:DoDelta(-cost)
        end
	end
end

function scheme:GetTarget(pointer)
	return _G.TUNNELNETWORK[pointer].inst
end

function scheme:IsConnected()
	return self.pointer ~= nil and self:GetTarget(self.pointer) ~= nil
end

function scheme:FindIndex()
	local index = 1
	while _G.TUNNELNETWORK[index] ~= nil do
		index = index + 1
	end
	return index
end

function scheme:FindFirstKey()
	local index = 1
	while _G.TUNNELNETWORK[index] == nil do
		index = index + 1
	end
	return index
end

function scheme:GetIndex()
	return self.index
end

function scheme:Target(pointer)
	self.pointer = pointer
	self.inst.islinked:set(true)
end

function scheme:AddToNetwork()
	local index = self.index ~= nil and self.index or self:FindIndex()

	_G.TUNNELNETWORK[index] = {
		inst = self.inst,
		owner = self.inst.owner,
	}
	self.index = index
end

function scheme:Disconnect(index)
	for k, v in pairs(_G.TUNNELNETWORK) do
		if v.inst.components.scheme and v.inst.components.scheme.pointer == index then
			v.inst.components.scheme.pointer = nil
			v.inst.islinked:set(false)
			v.inst.sg:GoToState("closing")
		end
	end
	self.index = nil
	self.pointer = nil
	self.inst.islinked:set(false)
	self.inst.sg:GoToState("closing")
	_G.TUNNELNETWORK[index] = nil
end

function scheme:Connect()
	local pointer = next(_G.TUNNELNETWORK, self.pointer)
	if #_G.TUNNELNETWORK == 1 then return end
	if pointer == self.index then pointer = next(_G.TUNNELNETWORK, pointer) end
	if pointer == nil then pointer = self.index ~= 1 and self:FindFirstKey() or next(_G.TUNNELNETWORK, self:FindFirstKey()) end

	self:Target(pointer)
end

function scheme:InitGate()
	self:AddToNetwork()
	if self.pointer ~= nil then
		self:Target(self.pointer)
	end
end

return scheme