local STRINGS = GLOBAL.STRINGS
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local ACTIONS = GLOBAL.ACTIONS


local SPAWNG = AddAction("SPAWNG", STRINGS.ACTION_SPAWNG, function(act)
	if act.invobject and act.invobject.components.makegate then
        return act.invobject.components.makegate:Create(act.pos, act.doer)
    end
end)
SPAWNG.priority = 7
SPAWNG.distance = 2
SPAWNG.rmb = true

local CONFIGG = AddAction("CONFIGG", STRINGS.ACTION_CONFIGG, function(act)
	local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if staff and staff.components.makegate then
		return staff.components.makegate:Configurate(act.target, act.doer)
	end
end)
CONFIGG.priority = 8
CONFIGG.distance = 2

local SELECTG = AddAction("SELECTG",  STRINGS.ACTION_SELECTG, function(act)
	if act.target ~= nil and act.target.components.scheme ~= nil then
		return act.target.components.scheme:SelectDest(act.doer)
	end
end)
SELECTG.priority = 8

local function action_scheme(inst, doer, pos, actions, right)
	if right then
		if inst.prefab == "yukariumbre" and doer.prefab == "yakumoyukari" and doer.replica.power ~= nil then
			if inst.isunfolded:value() and doer.replica.power:GetCurrent() >= TUNING.YUKARI.SPAWNG_POWER_COST then
				table.insert(actions, ACTIONS.SPAWNG)
			elseif not inst.isunfolded:value() and doer.replica.power:GetCurrent() >= TUNING.YUKARI.TELEPORT_POWER_COST then
				table.insert(actions, ACTIONS.YTELE)
			end
		else
			table.insert(actions, ACTIONS.SPAWNG)
		end
	end
end

local function scheme(inst, doer, target, actions, right)
	if right then
		if target:HasTag("tunnel") then
			table.insert(actions, ACTIONS.CONFIGG)
		end
	end
end

AddComponentAction("EQUIPPED", "makegate", scheme)
AddComponentAction("POINT", "makegate", action_scheme)

local function select(inst, doer, actions, right)
	if inst:HasTag("teleporter") then--and inst.islinked:value() then
		table.insert(actions, ACTIONS.SELECTG)
    end
end

AddComponentAction("SCENE", "scheme", select)