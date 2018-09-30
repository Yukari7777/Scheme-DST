local assets=
{   
	Asset("ANIM", "anim/spell.zip"),    
	Asset("ATLAS", "images/inventoryimages/scheme.xml"),    
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
	inst.canspell = net_bool(inst.GUID, "canspell")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
    end

	inst:AddComponent("inspectable")    
	inst.components.inspectable.getspecialdescription = GetDesc
	
	inst:AddComponent("inventoryitem")   
	inst.components.inventoryitem.atlasname = "images/inventoryimages/scheme.xml" 
	
	inst:AddComponent("spellcard")
	inst.components.spellcard.name = "scheme"
	inst.components.spellcard:SetSpellFn( DoUpgrade )
	inst.components.spellcard:SetOnFinish( OnFinish )
	inst.components.spellcard:SetCondition( false )
	
	inst:ListenForEvent("onitemupdate", SetState)
	
	return inst
end
	
return Prefab("common/inventory/scheme", fn, assets)