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

	Asset( "IMAGE", "images/inventoryimages/schemetool.tex" ),
	Asset( "ATLAS", "images/inventoryimages/schemetool.xml" ),
	Asset( "IMAGE", "images/inventoryimages/sanitypanel.tex" ),
	Asset( "ATLAS", "images/inventoryimages/sanitypanel.xml" ),

	Asset( "ANIM" , "anim/ui_board_5x1.zip"),
}

----- GLOBAL & require list -----
local require = GLOBAL.require
local TECH = GLOBAL.TECH
local RECIPETABS = GLOBAL.RECIPETABS
local TheFrontEnd = GLOBAL.TheFrontEnd
local TaggableWidget = require "widgets/taggablewidget"
local SchemeUI = require "screens/schemeui"

require "class"

AddMinimapAtlas("images/map_icons/minimap_tunnel.xml")
AddMinimapAtlas("images/map_icons/schemetool.xml")
AddReplicableComponent("taggable")

------ Functions ------

local Language =  GetModConfigData("language")
GLOBAL.SCHEME_LANGUAGE = "en"
if Language == "AUTO" then
	local KnownModIndex = GLOBAL.KnownModIndex
	for _, moddir in ipairs(KnownModIndex:GetModsToLoad()) do
		local modname = KnownModIndex:GetModInfo(moddir).name
		if modname == "한글 모드 서버 버전" or modname == "한글 모드 클라이언트 버전" then 
			GLOBAL.SCHEME_LANGUAGE = "kr"
--		elseif modname == "Chinese modname Pack" or modname == "Chinese Plus" then
--			GLOBAL.SCHEME_LANGUAGE = "ch"
--		elseif modname == "Russian modname Pack" or modname == "Russification Pack for DST" or modname == "Russian For Mods (Client)" then
--			GLOBAL.SCHEME_LANGUAGE = "ru"
		end 
	end 
else
	GLOBAL.SCHEME_LANGUAGE = Language
end

AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
	self.ShowTaggableWidget = function(self, taggable, config)
		if taggable == nil then
			return
		else
			self.taggablescreen = TaggableWidget(self.owner, taggable, config)
			self:OpenScreenUnderPause(self.taggablescreen)
			if TheFrontEnd ~= nil and TheFrontEnd:GetActiveScreen() == self.taggablescreen then
				-- Have to set editing AFTER pushscreen finishes.
				self.taggablescreen.edit_text:SetEditing(true)
			end
			return self.taggablescreen
		end
	end

	self.CloseTaggableWidget = function()
		if self.taggablescreen then
			self.taggablescreen:Close()
			self.taggablescreen = nil
		end
	end

	self.ShowSchemeUI = function(src, inst)
		if inst == nil then
			return 
		else
			self.schemescreen = SchemeUI(self.owner, inst)
			self:OpenScreenUnderPause(self.schemescreen)
			return self.schemescreen
		end
	end

	self.CloseSchemeUI = function(src)
		if self.schemescreen ~= nil then
			self.schemescreen:Close()
			self.schemescreen = nil
		end
	end
end)

AddRecipe("schemetool", {Ingredient("nightmarefuel", 5), Ingredient("purplegem", 3), Ingredient("orangemooneye", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, nil, nil, nil, nil, nil, "images/inventoryimages/schemetool.xml", "schemetool.tex")

modimport "scripts/strings_scheme.lua"
modimport "scripts/schememanager.lua"
modimport "scripts/actions_scheme.lua" -- actions must be loaded before stategraph loads
modimport "scripts/stategraph_scheme.lua"