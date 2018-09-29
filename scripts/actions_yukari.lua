local ActionHandler = GLOBAL.ActionHandler
local FRAMES = GLOBAL.FRAMES
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local EventHandler = GLOBAL.EventHandler
local TimeEvent = GLOBAL.TimeEvent
local SpawnPrefab = GLOBAL.SpawnPrefab
local State = GLOBAL.State
local ACTIONS = GLOBAL.ACTIONS
local Action = GLOBAL.Action
local TheWorld = GLOBAL.TheWorld
local TIMEOUT = 2
local Language = GetModConfigData("language")


local SPAWNG = AddAction("SPAWNG", "Spawn Scheme Tunnel", function(act)
	if act.invobject and act.invobject.components.makegate then
        return act.invobject.components.makegate:Create(act.pos, act.doer)
    end
end)

SPAWNG.priority = 7
SPAWNG.distance = 6
SPAWNG.rmb = true
SPAWNG.mount_valid = false

local spawng = State({
    name = "spawng",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
		inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    end,

    timeline = 
    {
        TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
    },

    events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },
})

local spawngc = State({
	name = "spawngc",
    tags = { "doing", "busy", "canrotate" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("staff_pre")
        inst.AnimState:PushAnimation("staff_lag", false)

        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(TIMEOUT)
    end,

    onupdate = function(inst)
        if inst:HasTag("doing") then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end,
})
	
AddStategraphState("wilson", spawng)
AddStategraphState("wilson_client", spawngc)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.SPAWNG, "spawng"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.SPAWNG, "spawngc"))

local function action_umbre(inst, doer, pos, actions, right)
	if right then
		if doer:HasTag("yakumoyukari") and doer.replica.power then
			if inst.isunfolded:value() and doer.replica.power:GetCurrent() >= TUNING.YDEFAULT.SPAWNG_POWER_COST then
				table.insert(actions, ACTIONS.SPAWNG)
			elseif not inst.isunfolded:value() and doer.replica.power:GetCurrent() >= TUNING.YDEFAULT.TELEPORT_POWER_COST then
				table.insert(actions, ACTIONS.UTELE)
			end
		end
	end
end

AddComponentAction("POINT", "makegate", action_umbre)

ACTIONS.JUMPIN.fn = function(act)
	if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "jumpin_pre" then
        if act.target ~= nil and act.target.components.teleporter ~= nil and act.target.components.teleporter:IsActive() then
            act.doer.sg:GoToState("jumpin", { teleporter = act.target })
            return true
		elseif act.target ~= nil and act.target.components.schemeteleport ~= nil and act.target.components.schemeteleport.islinked then
			act.doer.sg:GoToState("jumpin", { teleporter = act.target })
			act.doer:DoTaskInTime(0.8, function()
				act.target.components.schemeteleport:Activate(act.doer)
			end)
			act.doer:DoTaskInTime(1.5, function()
				if not act.doer:IsOnValidGround() then
					local dest = GLOBAL.FindNearbyLand(act.doer:GetPosition(), 8)
					if dest ~= nil then
						if act.doer.Physics ~= nil then
							act.doer.Physics:Teleport(dest:Get())
						elseif act.doer.Transform ~= nil then
							act.doer.Transform:SetPosition(dest:Get())
						end
					end
				end
			end)
			return true
        end
        act.doer.sg:GoToState("idle")
    end
end

local function tunnelfn(inst, doer, actions, right)
	if inst:HasTag("teleporter") and inst.islinked:value() then
		table.insert(actions, ACTIONS.JUMPIN)
    end
end
AddComponentAction("SCENE", "schemeteleport", tunnelfn)