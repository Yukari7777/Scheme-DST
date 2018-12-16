name = "Scheme"
version = "2.0"
description = "Suspicious, Creepy gaps linking two spaces.\nVersion : "..version
author = "Yakumo Yukari"
forumthread = ""
api_version = 6
api_version_dst = 10

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {
	"utilities",
}

local spawncost = {}
for i = 0, 200 do spawncost[i + 1] = { description = ""..i.."", data = i } end
spawncost[1].description = "No cost"

local delcost = {}
for i = 0, 200 do delcost[i + 1] = { description = ""..i.."", data = i } end
delcost[1].description = "No cost"

local usecost = {}
for i = 0, 200 do usecost[i + 1] = { description = ""..i.."", data = i } end
usecost[1].description = "No cost"

local GPL = {}
for i = 0, 4 do GPL[i + 1] = { description = ""..i.."", data = i } end

configuration_options = {
	{
		name = "spawncost",
		label = "Spawn cost",
		hover = "Set sanity cost on creating Scheme Gate.",
		options = spawncost,
		default = 30,
	},

	{
		name = "delcost",
		label = "Remove cost",
		hover = "Set sanity cost on removing Scheme Gate.",
		options = delcost,
		default = 10,
	},

	{
		name = "usecost",
		label = "Use cost",
		hover = "Set sanity cost of using Scheme Gate.",
		options = usecost,
		default = 5,
	},

	{
		name = "permission",
		label = "Global permission level",
		hover = "0 = Everyone can use or modify.[see mod page for more info]\n1 = Everyone can use, cannot modify.\n2 = Only allowed user can use or modify.\n3 = Only allowed user can use, cannot modify.\n4 = Only original owner can only use.",
		options = GPL,
		default = 1,
	},
}