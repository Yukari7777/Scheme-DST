local Spellcard = Class(function(self, inst)
	self.inst = inst
	self.onfinish = nil
	self.othercondition = nil
	
	self.action = ACTIONS.CASTTOHO
end)

function Spellcard:SetSpellFn(fn)
	self.spell = fn
end

function Spellcard:SetOnFinish(fn)
	self.onfinish = fn
end

function Spellcard:SetCondition(fn)
	self.othercondition = fn
end

function Spellcard:CastSpell(doer, target)
	if self.spell then
		self.spell(self.inst, doer, target)
		
		if self.onfinish then
			self.onfinish(self.inst, doer)
		end
	end
end

function Spellcard:AddDesc(script)
	if self.inst.components.inspectable ~= nil then 
		local desc = self.inst.components.inspectable:GetDescription(self.inst.components.inventoryitem.owner)
		if not string.find(desc, script) then
			self.inst.components.inspectable:SetDescription( desc.."\n"..script )
		end
	end
end

function Spellcard:CanCast(doer)

	if self.othercondition ~= nil then
		return self.othercondition
	end
	
	return self.spell ~= nil

end

return Spellcard