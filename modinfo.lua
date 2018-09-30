name = "Scheme"
description = "Suspicious, Creepy gaps linking two spaces."
author = "Yakumo Yukari"
version = "0.1"
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

configuration_options = {
	{
		name = "type",
		label = "Spawning Type",
		options =
		{
			{ description = "buildable", data = "build" },
			{ description = "spawnable", data = "spawn" },
		},
		default = "spawn",
	},

}