name = "Scheme"
description = "Suspicious, Creepy gaps linking two spaces."
author = "Yakumo Yukari"
version = "1.0"
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


configuration_options = {
	{
		name = "spawncost",
		label = "Spawn Cost",
		hover = "Set sanity cost on creating Scheme Gate.",
		options = spawncost,
		default = 30,
	},

	{
		name = "delcost",
		label = "Erase Cost",
		hover = "Set sanity cost on removing Scheme Gate.",
		options = delcost,
		default = 10,
	},

	{
		name = "usecost",
		label = "Use Cost",
		hover = "Set sanity cost of using Scheme Gate.",
		options = usecost,
		default = 5,
	},
}