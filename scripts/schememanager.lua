local function SerializeSchemeNetworkData(src, tunnel)
	local list = {}
	local _serialized

	for _, v in pairs(GLOBAL.TUNNELNETWORK) do
		if v.inst ~= nil then
			local index = v.inst.components.scheme.index
			local text = v.inst.components.taggable.text
			if text == nil then
				text = "UNNAMED INDEX #"..v.inst.components.scheme.index
			end
			table.insert(list, index.."\t"..text)
		end
	end

	_serialized = table.concat(list, "\n")
	print(_serialized)
	if tunnel ~= nil then
		tunnel.replica.taggable._serializeddata:set(_serialized)
	end
end
AddModRPCHandler("scheme", "serialize", SerializeSchemeNetworkData)