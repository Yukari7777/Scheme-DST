PrefabFiles = {
	"tunnel",
	"schemetool",
	"taggable_classified",
}

Assets = {
	Asset( "IMAGE", "images/map_icons/minimap_tunnel.tex"),
	Asset( "ATLAS", "images/map_icons/minimap_tunnel.xml"),
	Asset( "IMAGE", "images/map_icons/schemetool.tex" ),
	Asset( "ATLAS", "images/map_icons/schemetool.xml" ),
}

----- GLOBAL & require list -----
local require = GLOBAL.require
local TECH = GLOBAL.TECH
local RECIPETABS = GLOBAL.RECIPETABS
require "class"
GLOBAL.TUNNELNETWORK = {}
GLOBAL.TUNNELFIRSTINDEX = nil
GLOBAL.TUNNELLASTINDEX = nil
GLOBAL.NUMTUNNEL = 0


AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/schemetool.xml")

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

AddRecipe("schemetool", {Ingredient("nightmarefuel", 10), Ingredient("livinglog", 5), Ingredient("purplegem", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, nil, nil, nil, nil, nil, "images/inventoryimages/schemetool.xml", "schemetool.tex")

------ Mod Imports ------

modimport "scripts/actions_scheme.lua"
modimport "scripts/strings_scheme.lua"