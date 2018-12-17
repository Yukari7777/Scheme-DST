local function RemoveScheme(player, target)
	local scheme = target.components.scheme
	if scheme ~= nil then
		if scheme.owner == player.userid or scheme.owner == nil then
			local DELCOST = GetModConfigData("delcost")

			if player ~= nil then
				player.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
		
				if player.components.sanity ~= nil then
					player.components.sanity:DoDelta(-DELCOST)
				end
			end

			target:Remove()
		end
	end
end
AddModRPCHandler("scheme", "remove", RemoveScheme)

local function SetTaggableText(player, target, text)
    local taggable = target.components.taggable
	local scheme = target.components.scheme
    if taggable ~= nil then
		if target.classified.shouldUI:value() then
			taggable:EndAction()
		else
			taggable:DoAction(player, text)
		end
    end

	if scheme ~= nil then
		scheme:SetOwner(player)
	end
end
AddModRPCHandler("scheme", "write", SetTaggableText)

local function SerializeSchemeNetworkData(player, tunnel)
	local list = {}
	local _serialized

	for _, v in pairs(GLOBAL.TUNNELNETWORK) do
		if v.inst ~= nil then
			local index = v.inst.components.scheme.index
			local text = v.inst.components.taggable.text
			if text == nil then
				text = "UNNAMED INDEX #"..v.inst.components.scheme.index
			end
			table.insert(list, index.."\t"..text)
		end
	end

	_serialized = table.concat(list, "\n")
	if tunnel ~= nil then
		tunnel.replica.taggable._serializeddata:set(_serialized) 
	end
end
AddModRPCHandler("scheme", "serialize", SerializeSchemeNetworkData)

local function DoTeleportWithIndex(player, index, inst)
	local taggable = inst.components.taggable
	if taggable ~= nil then
		taggable:DoAction(player, nil, index)
	end
	player.sg:GoToState("jumpin", { teleporter = player })
	player:DoTaskInTime(0.8, function()
		inst.components.scheme:Activate(player, index)
	end)
	player:DoTaskInTime(1.5, function() -- Move entities outside of map border inside
		if not player:IsOnValidGround() then
			local dest = GLOBAL.FindNearbyLand(player:GetPosition(), 8)
			if dest ~= nil then
				if player.Physics ~= nil then
					player.Physics:Teleport(dest:Get())
				elseif act.doer.Transform ~= nil then
					player.Transform:SetPosition(dest:Get())
				end
			end
		end
	end)
end
AddModRPCHandler("scheme", "teleport", DoTeleportWithIndex)