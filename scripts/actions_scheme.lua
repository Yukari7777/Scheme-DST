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

local SPAWNG = AddAction("SPAWNG", "Spawn Scheme Tunnel", function(act)
	if act.invobject and act.invobject.components.makegate then
        return act.invobject.components.makegate:Create(act.pos, act.doer)
    end
end)

SPAWNG.priority = 7
SPAWNG.distance = 2
SPAWNG.rmb = true

local spawng = State({
    name = "spawng",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
		inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    end,

    timeline = {
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

local function action_scheme(inst, doer, pos, actions, right)
	if right then
		table.insert(actions, ACTIONS.SPAWNG)
	end
end


local CONFIGG = AddAction("CONFIGG", "Configurate", function(act)
	local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if staff and staff.components.makegate then
		return staff.components.makegate:Configurate(act.target, act.doer)
	end
end)

CONFIGG.priority = 8
CONFIGG.distance = 2

local INDEXG = AddAction("INDEXG", "Jump In", function(act)
	if act.target ~= nil and act.target.components.scheme ~= nil then
		return act.target.components.scheme:SelectDest(act.doer)
	end
end)

INDEXG.priority = 8
INDEXG.distance = 1

local configg = State({
    name = "configg",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
		inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
    end,

    timeline = {
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

local configgc = State({
	name = "configgc",
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
	
AddStategraphState("wilson", configg)
AddStategraphState("wilson_client", configgc)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CONFIGG, "configg"))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.INDEXG, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.CONFIGG, "configgc"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.INDEXG, "doshortaction"))

local function scheme(inst, doer, target, actions, right)
	if right then
		if target:HasTag("tunnel") then
			table.insert(actions, ACTIONS.CONFIGG)
		end
	end
end

AddComponentAction("EQUIPPED", "makegate", scheme)
AddComponentAction("POINT", "makegate", action_scheme)

ACTIONS.JUMPIN.fn = function(act)
	if act.doer ~= nil and
        act.doer.sg ~= nil and
        act.doer.sg.currentstate.name == "jumpin_pre" then
        if act.target ~= nil and act.target.components.teleporter ~= nil and act.target.components.teleporter:IsActive() then
            act.doer.sg:GoToState("jumpin", { teleporter = act.target })
            return true
		elseif act.target ~= nil and act.target.components.scheme ~= nil and act.target.components.scheme:IsConnected() then
			act.doer.sg:GoToState("jumpin", { teleporter = act.target })
			act.doer:DoTaskInTime(0.8, function()
				act.target.components.scheme:Activate(act.doer)
			end)
			act.doer:DoTaskInTime(1.5, function() -- Move entities outside of map border inside
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

local function select(inst, doer, actions, right)
	if inst:HasTag("teleporter") then-- and inst.islinked:value() then
		--table.insert(actions, ACTIONS.JUMPIN)
		table.insert(actions, ACTIONS.INDEXG)
    end
end

AddComponentAction("SCENE", "scheme", select)