local scheme = Class(function(self, inst)
    self.inst = inst
	self.index = nil
	self.target = nil
end)

function scheme:OnActivate(other, doer) 
	other.sg:GoToState("open")
end

function scheme:Activate(doer)
	if self.target == nil then
		return
	end
	
	if doer:HasTag("player") then
		doer.SoundEmitter:KillSound("wormhole_travel")
		doer.SoundEmitter:PlaySound("tunnel/common/travel")
	end

	self:OnActivate(self.target, doer)
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
	if self.target ~= nil then
		local offset = 2.0
		local angle = math.random() * 360
		local target_x, target_y, target_z = self.target.Transform:GetWorldPosition()
		target_x = target_x + math.sin(angle)*offset
		target_z = target_z + math.cos(angle)*offset
		if obj.Physics then
			obj.Physics:Teleport( target_x, target_y, target_z )
		elseif obj.Transform then
			obj.Transform:SetPosition( target_x, target_y, target_z )
		end
	end
end

function scheme:IsConnected()
	return self.target ~= nil
end

function scheme:FindIndex()
	local index = 1
	while _G.TUNNELNETWORK[index] ~= nil do
		index = index + 1
	end
	return index
end

function scheme:GetIndex()
	return self.index
end

function scheme:Target(target)
	self.target = target
	self.inst.islinked:set(true)
end

function scheme:AddToNetwork(inst)
	local index = inst.tindex == nil and inst.tindex or self:FindIndex()

	_G.TUNNELNETWORK[index] = {
		inst = inst,
		owner = inst.owner,
	}
	self.index = index
	print("index = ", index)
end

function scheme:Disconnect(index)
	self.target = nil
	self.index = nil
	_G.TUNNELNETWORK[index] = nil
end

function scheme:TryConnect()
	local numpairs = 0
	for i = 1, #self.data, 2 do
		if self.data[i] ~= nil and self.data[i + 1] ~= nil then
			self.data[i].components.scheme:Target(self.data[i + 1])
			self.data[i + 1].components.scheme:Target(self.data[i])
		end
		numpairs = numpairs + 1
	end
	self.pairnum = numpairs
end

function scheme:InitGate(inst)
	self:AddToNetwork(inst)
end

return scheme