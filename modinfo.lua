name = "Scheme"
version = "2.1.3"
description = "Suspicious, Creepy gaps linking space and space.\n수상하고, 소름돋는, 공간과 공간을 잇는 틈새.\n\n\nVersion : "..version
author = "Yakumo Yukari"
forumthread = ""
api_version = 6
api_version_dst = 10
priority = 2
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true 
icon_atlas = "modicon.xml"
icon = "modicon.tex"

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name.." - Test"
end

server_filter_tags = {
	"utilities",
	"wormhole",
	"tunnel",
	"teleport",
	"scheme",
	"API",
}

local spawncost = {}
for i = 0, 500 do spawncost[i + 1] = { description = ""..i.."", data = i } end
spawncost[1].description = "No cost"

local usecost = {}
for i = 0, 500 do usecost[i + 1] = { description = ""..i.."", data = i } end
usecost[1].description = "No cost"

local alterval = {}
for i = 1, 500 do alterval[i] = { description = ""..i.."", data = i } end

local GPL = {}
for i = 0, 4 do GPL[i + 1] = { description = ""..i.."", data = i } end

configuration_options = {
	{
		name = "language",
		label = "언어(Language)",
		hover = "언어설정\nSet Language",
		options = {
			{ description = "자동(Auto)", data = "AUTO" },
			{ description = "한국어", data = "kr" },
			{ description = "English", data = "en" },
			--{ description = "中文", data = "ch" },
			--{ description = "русский", data = "ru" },
		},
		default = "AUTO",
	},
	{
		name = "spawncost",
		label = "Spawn cost(소환 코스트)",
		hover = "Set sanity cost on creating Scheme Gate.\n스키마 게이트를 소환할 때의 비용을 설정합니다.",
		options = spawncost,
		default = 100,
	},

	{
		name = "usecost",
		label = "Use cost(사용 코스트)",
		hover = "Set sanity cost of using Scheme Gate.\n스키마 게이트를 사용할 때의 비용을 설정합니다.",
		options = usecost,
		default = 50,
	},

	{
		name = "alter",
		label = "Cost alternatives(정신력 대체템)",
		hover = "Set which item should be used for alternatives for the cost of sanity.\n정신력 대신 사용될 아이템을 정합니다.",
		options = {
			{ description = "No alter",			data = "noalter" },
			{ description = "Desert Stone",		data = "townportaltalisman" },
			{ description = "Purple Gem",		data = "purplegem" },
			{ description = "Orange Gem",		data = "orangegem" },
			{ description = "Nightmare Fuel",	data = "nightmarefuel" },
		},
		default = "townportaltalisman",
	},

	{
		name = "alterval",
		label = "Alternatives value(대체템 가치)",
		hover = "Set alternative's value.\n대체템의 가치를 정합니다.",
		options = alterval,
		default = 50,
	},

	{
		name = "ignoredanger",
		label = "Ignore danger(위험 무시)",
		hover = "Should ignore danger nearby on teleporting?\n순간이동 할 때 주변의 위험 요소들을 무시합니까?",
		options = {
			{ description = "no(무시안함)", data = false },
			{ description = "yes(무시함)",	data = true },
		},
		default = false,
	},
	{
		name = "ignoreboss",
		label = "Ignore boss(보스 무시)",
		hover = "Should teleport when a boss is nearby?\n보스가 있을때도 순간이동이 가능합니까?",
		options = {
			{ description = "no(무시안함)", data = false },
			{ description = "yes(무시함)",	data = true },
		},
		default = false,
	},
--	{
--		name = "permission",
--		label = "Global permission level",
--		hover = "0 = Everyone can use or modify.[see mod page for more info]\n1 = Everyone can use, cannot modify.\n2 = Only allowed user can use or modify.\n3 = Only allowed user can use, cannot modify.\n4 = Only original owner can only use.",
--		options = GPL,
--		default = 1,
--	},
}