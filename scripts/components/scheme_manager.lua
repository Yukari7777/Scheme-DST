local scheme_manager = Class(function(self, inst)
    self.inst = inst
	self.data = {}
	self.index = 1
	self.pairnum = 0
end)

function scheme_manager:Disconnect(index)
	self.inst.components.schemeteleport:Disconnect()
	self.data[index] = nil
	self.pairnum = self.pairnum - 1
	self.index = index
end

function scheme_manager:GetIndex(inst)
	return self.index
end

function scheme_manager:AddIndex(inst, index)
	if index ~= nil then -- force data number
		self.data[index] = inst
	else
		local i = 1
		while self.data[i] ~= nil do
			i = i + 1
		end
		print("self.index = ", i)
		self.index = i
		self.data[i] = inst:GetSaveRecord()
		print(self.data[i] ~= nil)
	end
end

function scheme_manager:TryConnect()
	local numpairs = 0
	for i = 1, #self.data, 2 do
		if self.data[i] ~= nil and self.data[i + 1] ~= nil then
			self.data[i].components.schemeteleport:Target(self.data[i + 1])
			self.data[i + 1].components.schemeteleport:Target(self.data[i])
		end
		numpairs = numpairs + 1
	end
	self.pairnum = numpairs
end

function scheme_manager:InitGate(inst)
	self:AddIndex(inst)
	self:TryConnect()
end

return scheme_manager