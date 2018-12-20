GLOBAL.TUNNELNETWORK = {}
GLOBAL.NUMTUNNEL = 0
local alterprefab = GetModConfigData("alter")
local altervalue = GetModConfigData("alterval")

local function FindItemInSlots(TheSlot, num)
	for k, v in pairs(TheSlot) do
		if v.prefab == alterprefab then
			num = num + (v.components.stackable ~= nil and v.components.stackable:StackSize() or 1)
		end
	end
	return num
end

local function ConsumeItemInSlots(TheSlot, num)
	for k, v in pairs(TheSlot) do
		if v.prefab == alterprefab then
			local stacksize = v.components.stackable ~= nil and v.components.stackable:StackSize() or 1
			local numtoremove = math.min(stacksize, num)
			if numtoremove > 0 then
				v.components.stackable:Get(numtoremove):Remove()
			end
			num = num - numtoremove
		end
	end
	return num
end

GLOBAL.GetGCost = function(player, isspawn, inst)
	local _COST = isspawn and GetModConfigData("spawncost") or GetModConfigData("usecost")
	local maxuse = math.floor(_COST / altervalue)
	local numalter = 0
	local numtouse = 0
	local leftover = _COST

	if player.prefab == "yakumoyukari" then --temp
		numalter = 0
		leftover = isspawn and 75 or 0
	elseif alterprefab ~= "noalter" then
		numalter = FindItemInSlots(player.replica.inventory:GetItems(), numalter)
		for k, v in pairs(player.replica.inventory:GetEquips()) do
			if type(v) == "table" and v.components.container ~= nil then
				numalter = FindItemInSlots(player.replica.inventory:GetEquippedItem(k).components.container.slots, numalter)
			end
		end
		numtouse = math.min(maxuse, numalter)
		leftover = leftover - numtouse * altervalue
	end
	if inst ~= nil then --If this called by RPC,
		inst.replica.taggable.numalter:set(numtouse)
		inst.replica.taggable.numstat:set(leftover)
	else
		return numtouse, leftover
	end
end
AddModRPCHandler("scheme", "getcost", GLOBAL.GetGCost)

GLOBAL.ConsumeGateCost = function(player, numitem, numstat)
	local leftoveritem = numitem
	if leftoveritem ~= 0 then
		leftoveritem = ConsumeItemInSlots(player.replica.inventory:GetItems(), leftoveritem)
		for k, v in pairs(player.replica.inventory:GetEquips()) do
			if type(v) == "table" and v.components.container ~= nil then
				leftoveritem = ConsumeItemInSlots(player.replica.inventory:GetEquippedItem(k).components.container.slots, leftoveritem)
			end
		end
	end

	if player.components.power ~= nil then
		player.components.power:DoDelta(-numstat)
	elseif player.components.sanity ~= nil then
		player.components.sanity:DoDelta(-numstat)
	end
end

local function RemoveScheme(player, target)
	local scheme = target.components.scheme
	if scheme ~= nil then
		if scheme.owner == player.userid or scheme.owner == nil then
			if player ~= nil then
				player.SoundEmitter:PlaySound("dontstarve/common/staff_dissassemble")
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
				text = "#"..v.inst.components.scheme.index
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
end
AddModRPCHandler("scheme", "teleport", DoTeleportWithIndex)