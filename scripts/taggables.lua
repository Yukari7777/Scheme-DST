local SignGenerator = require"signgenerator"

local taggables = {}

taggables.makescreen = function(inst, doer)
    local data = {
		prompt = STRINGS.SIGNS.MENU.PROMPT,
		animbank = "ui_board_5x1",
		animbuild = "ui_board_5x1",
		menuoffset = Vector3(6, 20, 0),

		cancelbtn = { text = STRINGS.SIGNS.MENU.CANCEL,			cb = nil, control = CONTROL_CANCEL },
		middlebtn = { text = STRINGS.TAGGABLE_REMOVE_BUTTON,	cb = nil, control = CONTROL_MENU_MISC_2 },
		acceptbtn = { text = STRINGS.SIGNS.MENU.ACCEPT,			cb = nil, control = CONTROL_ACCEPT },

		--defaulttext = SignGenerator,
	}

    if doer and doer.HUD then
        return doer.HUD:ShowTaggableWidget(inst, data)
    end
end

return taggables