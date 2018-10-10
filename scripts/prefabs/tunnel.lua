local assets =
{
	Asset("ANIM", "anim/tunnel.zip" ),
}

local function onpreload(inst, data)
	if data then
		inst.components.scheme_manager.record = data.index or {}
	end
end

local function onsave(inst, data)
	data.index = inst.components.scheme_manager.record
end

local function onerased(inst, doer)
	if inst.components.lootdropper then
		inst.components.lootdropper:DropLoot()
	end
	inst.components.scheme_manager:Disconnect(inst.index)
    inst:Remove()
end
local function GetDesc(inst, viewer)
	return string.format( "Index is "..inst.index.." pair number is #"..(math.floor(inst.index / 2) + 1) )
end

local function fn()

	local inst = CreateEntity()    
	
	inst.entity:AddTransform()    
	inst.entity:AddAnimState()    
	inst.entity:AddSoundEmitter()  
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()	
    
    inst.MiniMapEntity:SetIcon("minimap_tunnel.tex")
   
    inst.AnimState:SetBank("tunnel")
    inst.AnimState:SetBuild("tunnel")
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
	inst.AnimState:SetRayTestOnBB(true)

	inst:AddTag("tunnel") 
	inst:AddTag("teleporter")
	inst.islinked = net_bool(inst.GUID, "islinked")
	
	if not TheWorld.ismastersim then
		return inst
    end

	inst.entity:SetPristine()

	inst:SetStateGraph("SGtunnel")
    inst:AddComponent("inspectable")
	inst.components.inspectable.getspecialdescription = GetDesc

	inst:AddComponent("scheme_manager")
	inst.components.scheme_manager:InitGate(inst)
	inst.index = inst.components.scheme_manager:GetIndex(inst)

	inst:AddComponent("schemeteleport")

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(5,5)
	inst.components.playerprox.onnear = function()
		if inst.components.schemeteleport.target and not (inst.sg.currentstate.name == ("open" or "opening")) then
			inst.sg:GoToState("opening")
		end
	end
	inst.components.playerprox.onfar = function()
		if inst.sg.currentstate.name == ("open" or "opening") then
			inst.sg:GoToState("closing")
		end
	end
	
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- scheme as a breaker
    inst.components.workable:SetWorkLeft(20)
    inst.components.workable:SetOnFinishCallback(onerased)
	
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload

    return inst
end

return Prefab( "common/objects/tunnel", fn, assets)