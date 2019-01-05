local scheme = Class(function(self, inst)
    self.inst = inst
	self.index = nil

	self.owner = nil
	--self.permlevel = 1

	self.pointer = nil
end)

function scheme:OnActivate(other, doer) 
	other.sg:GoToState("open")
	other:DoTaskInTime(1.5, function()
		other.sg:GoToState("closing")
		self.inst.sg:GoToState("closing")
	end)
end

function scheme:CheckConditionAndCost(doer, index)
	if not self:IsConnected(index) then return end
	local numalter, numstat = _G.GetGCost(doer, false)
	if doer:HasTag("yakumoyukari") and doer.components.power ~= nil and doer.components.talker ~= nil and doer.components.power.current < doer.components.upgrader.schemecost then 
		doer.components.talker:Say(GetString(doer.prefab, "DESCRIBE_LOWPOWER"))
		return
	elseif not doer:HasTag("yakumoyukari") and not doer.components.inventory:EquipHasTag("shadowdominance") and (doer.components.sanity ~= nil and doer.components.sanity.current < numstat) then
		doer.components.talker:Say(GetString(doer.prefab, "LOWUSEGSANITY")) 
		return 
	end

	if doer:HasTag("player") then
		doer.SoundEmitter:KillSound("wormhole_travel")
		_G.ConsumeGateCost(doer, numalter, numstat)
	end
	return true
end

function scheme:Activate(doer, index)
	local index = tonumber(index)
	if not self:CheckConditionAndCost(doer, index) then return end

	self:OnActivate(self:GetTarget(index), doer)
	self:Teleport(doer, index)

	if doer.components.leader ~= nil then
		for follower,v in pairs(doer.components.leader.followers) do
			self:Teleport(follower, index)
		end
	end

	local eyebone = nil

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory ~= nil then
		for k,item in pairs(doer.components.inventory.itemslots) do
			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower, index)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k,equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container ~= nil then
				local container = equipped.components.container
				for j,item in pairs(container.slots) do
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower, index)
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader ~= nil then
			for follower,v in pairs(eyebone.components.leader.followers) do
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then
					for j,item in pairs(follower.components.container.slots) do
						if item.components.leader then
							for follower,v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									self:Teleport(follower, index)
								end
							end
						end
					end
				end
			end
		end
	end
end

function scheme:Teleport(obj, index)
	local target = self:GetTarget(index)
	local offset = 2.0
	local angle = math.random() * 360
	local target_x, target_y, target_z = target.Transform:GetWorldPosition()
	
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
end

function scheme:GetTarget(index)
	return _G.TUNNELNETWORK[index] and _G.TUNNELNETWORK[index].inst
end

function scheme:IsConnected(index)
	return self:GetTarget(index) ~= nil
end

function scheme:FindIndex()
	local index = 1
	while _G.TUNNELNETWORK[index] ~= nil do
		index = index + 1
	end
	return index
end

function scheme:SetOwner(player)
	if player.userid ~= nil then
		self.owner = player.userid
	end
end

function scheme:AddToNetwork()
	local index = self.index ~= nil and self.index or self:FindIndex()

	_G.TUNNELNETWORK[index] = {
		inst = self.inst,
	}
	_G.NUMTUNNEL = _G.NUMTUNNEL + 1
	self.index = index
	self.inst.replica.taggable.index:set(index)
end

function scheme:Disconnect(index)
	if _G.TUNNELNETWORK[index] ~= nil then
		_G.TUNNELNETWORK[index] = nil
		_G.NUMTUNNEL = _G.NUMTUNNEL - 1
	end
end

function scheme:SelectDest(player)
	self.inst:PushEvent("select", {user = player})

	return true
end

function scheme:InitGate()
	self:AddToNetwork()
	if _G.NUMTUNNEL > 1 then
		self.inst.islinked:set(true)
	end
end

return scheme