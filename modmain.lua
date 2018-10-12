PrefabFiles = {
	"tunnel",
	"scheme",
}

Assets = {
	Asset( "IMAGE", "images/map_icons/minimap_tunnel.tex"),
	Asset( "ATLAS", "images/map_icons/minimap_tunnel.xml"),
	Asset( "IMAGE", "images/map_icons/scheme.tex" ),
	Asset( "ATLAS", "images/map_icons/scheme.xml" ),
}

----- GLOBAL & require list -----
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
require "class"
GLOBAL.TUNNELNETWORK = {}

AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/scheme.xml")

------ Functions ------

--AddReplicableComponent("taggable")
modimport "scripts/actions_scheme.lua"

------ Strings ------
STRINGS.NAMES.TUNNEL = "Scheme Gate"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TUNNEL = "Creepy."
STRINGS.NAMES.SCHEME = "Scheme"