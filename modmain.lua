PrefabFiles = {
	"tunnel",
	--"scheme",
}

Assets = {
	Asset( "IMAGE", "images/map_icons/minimap_tunnel.tex"),
	Asset( "ATLAS", "images/map_icons/minimap_tunnel.xml"),
	Asset( "IMAGE", "images/map_icons/scheme.tex" ),
	Asset( "ATLAS", "images/map_icons/scheme.xml" ),
}

----- GLOBAL & require list -----
local require = GLOBAL.require
require "class"
GLOBAL.TUNNELNETWORK = {}

AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/scheme.xml")

------ Function ------

--AddReplicableComponent("taggable")