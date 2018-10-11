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
local assert = GLOBAL.assert
require "class"

AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/scheme.xml")

------ Function ------

<<<<<<< HEAD
function AddSchemeManager(inst) -- Add GLOBAL Components
	inst:AddComponent("scheme_manager")
end

=======
function AddSchemeManager(inst)
	inst:AddComponent("scheme_manager")
end

-------------------------------
>>>>>>> parent of a9acc22... 0930
AddPrefabPostInit("cave", AddSchemeManager)
AddPrefabPostInit("forest", AddSchemeManager)