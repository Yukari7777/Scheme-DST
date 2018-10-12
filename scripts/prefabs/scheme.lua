local assets=
{   
	Asset("ANIM", "anim/spell.zip"),    
	Asset("ATLAS", "images/inventoryimages/scheme.xml"),    

	Asset("ANIM", "anim/staffs.zip"),
    Asset("ANIM", "anim/swap_staffs.zip"),
}

local function OnFinish(inst, owner)
	
end

local function GetDesc(inst, viewer)
	return string.format(  )
end

local function SetState(inst, data)
	local condition = GetCanpell(data.owner)
	inst.components.spellcard:SetCondition(condition)
	inst.canspell:set(condition)
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_purplestaff")
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
    inst.MiniMapEntity:SetIcon("scheme.tex") 

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("spell")    
	inst.AnimState:SetBuild("spell")    
	inst.AnimState:PlayAnimation("idle")    

	inst:AddTag("scheme")
	inst:AddTag("castontargets")
	inst.canspell = net_bool(inst.GUID, "canspell")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
    end

	inst:AddComponent("makegate")

	inst:AddComponent("inspectable")    
	inst.components.inspectable.getspecialdescription = GetDesc
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/scheme.xml" 

	inst:AddComponent("equippable")  
	inst.components.equippable:SetOnEquip( onequip )    
	inst.components.equippable:SetOnUnequip( onunequip )
	
	return inst
end
	
return Prefab("common/inventory/scheme", fn, assets)