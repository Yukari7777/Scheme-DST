local assets = {    
	Asset("ATLAS", "images/inventoryimages/schemetool.xml"),    
    Asset("ANIM", "anim/swap_schemetool.zip"),
    Asset("ANIM", "anim/schemetool.zip"),
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_schemetool", "swap")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()  

	local inst = CreateEntity() 
	
	inst.entity:AddTransform()    
	inst.entity:AddAnimState()    
	inst.entity:AddNetwork()	
	inst.entity:AddSoundEmitter() 
	inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("schemetool.tex") 

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("schemetool")    
	inst.AnimState:SetBuild("schemetool")    
	inst.AnimState:PlayAnimation("idle")    

	inst:AddTag("scheme")
	inst:AddTag("schemetool")
	inst:AddTag("castontargets")
	inst.canspell = net_bool(inst.GUID, "canspell")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
    end

	inst:AddComponent("makegate")

	inst:AddComponent("inspectable")    
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/schemetool.xml" 

	inst:AddComponent("finiteuses")    
	inst.components.finiteuses:SetMaxUses(TUNING.SCHEMETOOL_USES)
	inst.components.finiteuses:SetUses(TUNING.SCHEMETOOL_USES)

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	
	return inst
end
	
return Prefab("common/inventory/schemetool", fn, assets)