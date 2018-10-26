PrefabFiles = {
	"tunnel",
	"scheme",
	"taggable_classified",
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

AddReplicableComponent("taggable")

SetTaggableText = function(player, target, text)
    --[[if not (checkentity(target) and
            optstring(text)) then
        printinvalid("SetWriteableText", player)
        return
    end]]--
    local taggable = target.components.taggable
    if taggable ~= nil then
        taggable:Write(player, text)
    end
end
AddModRPCHandler("scheme", "write", SetTaggableText)

------ GLOBAL ------

STRINGS.NAMES.TUNNEL = "Scheme Gate"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TUNNEL = "Creepy."
STRINGS.NAMES.SCHEME = "Scheme"

------ Mod Imports ------

modimport "scripts/actions_scheme.lua"