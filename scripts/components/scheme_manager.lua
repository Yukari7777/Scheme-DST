--------------------------------------------------------------------------
--[[ Class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _record = {}
local _index = 1
local _pairnum = 0

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function AddRecord(inst, force, owner)
	if force ~= nil then -- force index
		_record[force] = {
			inst = inst,
			owner = owner,
		}
	else
		local i = 1
		while _record[i] ~= nil do
			i = i + 1
		end
		_index = i
		_record[i] = {
			inst = inst,
			owner = owner,
		}
	end
end

local function GetInstElement(index)
	return _record[index]
end

local function Disconnect(index)
	_record[index] = nil
	_index = index
	_pairnum = _pairnum - 1
end

function scheme_manager:GetIndex(inst)
	return self.index
end

function scheme_manager:MakeRecord(inst)
	local record = {}

	if inst.Transform then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        
        --Qnan hunting
        x = x ~= x and 0 or x
        y = y ~= y and 0 or y
        z = z ~= z and 0 or z

        record.x = x and math.floor(x*1000)/1000 or 0
        record.z = z and math.floor(z*1000)/1000 or 0
        --y is often 0 in our game, so be selective.
        if y ~= 0 then
            record.y = y and math.floor(y*1000)/1000 or 0
        end
    end
	
	record.index = self.index

	return record
end

function scheme_manager:TryConnect()
	local numpairs = 0
	for i = 1, #self.record, 2 do
		if self.record[i] ~= nil and self.record[i + 1] ~= nil then
			self.record[i].components.schemeteleport:Target(self.record[i + 1])
			self.record[i + 1].components.schemeteleport:Target(self.record[i])
		end
		numpairs = numpairs + 1
	end
	self.pairnum = numpairs
end

function scheme_manager:InitGate(inst)
	self:AddIndex(inst)
	self:TryConnect()
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------



end)