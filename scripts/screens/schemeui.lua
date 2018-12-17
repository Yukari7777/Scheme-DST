local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

local function MakeImgButton(parent, xPos, yPos, text, onclick, style, image)

    local btn
    if not style or style == "large" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text))
    elseif style == "icon" then
        btn = parent:AddChild(TEMPLATES.IconButton("images/button_icons.xml", image..".tex", text, false, false, onclick, {offset_y = 45}))
    elseif style == "icontext" then
        btn = parent:AddChild(TEMPLATES.StandardButton(onclick, text, {200, 60}, {"images/button_icons.xml", image..".tex"}))
    end

    btn:SetPosition(xPos, yPos)

    return btn
end

local INITIAL_REFRESH_INTERVAL = .5

local SchemeUI = Class(Screen, function(self, owner, attach)
    Screen._ctor(self, "SchemeUI")

    self.owner = owner
    self.attach = attach

    self.isopen = false

    self._scrnw, self._scrnh = TheSim:GetScreenSize()

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetPosition(0, 0, 0)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.scalingroot = self:AddChild(Widget("travelablewidgetscalingroot"))
    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())

    self.inst:ListenForEvent("continuefrompause", function()
        if self.isopen then
            self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
        end
    end, TheWorld)
    self.inst:ListenForEvent("refreshhudsize", function(hud, scale)
        if self.isopen then
            self.scalingroot:SetScale(scale)
        end
    end, owner.HUD.inst)

    self.root = self.scalingroot:AddChild(TEMPLATES.ScreenRoot("root"))

    -- secretly this thing is a modal Screen, it just LOOKS like a widget
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0)
    self.black.OnMouseButton = function()
        self:OnCancel()
    end

	self.time_to_refresh = INITIAL_REFRESH_INTERVAL
    self.destspanel = self.root:AddChild(TEMPLATES.RectangleWindow(350, 550))
    self.destspanel:SetPosition(0, 25)

--    self.current = self.destspanel:AddChild(Text(BODYTEXTFONT, 35))
--    self.current:SetPosition(0, 250, 0)
--    self.current:SetRegionSize(350, 50)
--    self.current:SetHAlign(ANCHOR_MIDDLE)

	self.refresh_button = MakeImgButton(self.root, 185, -315, "Refresh", function() self:Refresh() end, "icontext", "refresh")
	-- 함수 안고치면 병신

    self.cancelbutton = self.destspanel:AddChild(TEMPLATES.StandardButton( function() self:OnCancel() end, "Cancel", {120, 40}))
    self.cancelbutton:SetPosition(0, -250)

	self.desttabledirty = {}
	self.destdata = {}
	self.destitem = {}

	local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus( function() self.scroll_list:OnWidgetFocus(widget) end )

        widget.destitem = widget:AddChild(self:DestListItem())
        local dest = widget.destitem

        widget.focus_forward = dest

        return widget
    end

	local function ApplyDataToWidget(context, widget, data, index)
        widget.data = data
        widget.destitem:Hide()
        if not data then
            widget.focus_forward = nil
            return
        end

        widget.focus_forward = widget.destitem
        widget.destitem:Show()

        local dest = widget.destitem

        dest:SetInfo(data.info)
    end

	self.scroll_list = self.destspanel:AddChild(TEMPLATES.ScrollingGrid(self.destdata, {
        context = {},
        widget_width = 350,
        widget_height = 90,
        num_visible_rows = 5,
        num_columns = 1,
        item_ctor_fn = ScrollWidgetsCtor,
        apply_fn = ApplyDataToWidget,
        scrollbar_offset = 10,
        scrollbar_height_offset = -60,
        peek_percent = 0, -- may init with few clientmods, but have many servermods.
        allow_bottom_empty_row = true -- it's hidden anyway
	}))
    self.scroll_list:SetPosition(0, 0)
    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.scroll_list)

	self:Refresh()
    self:Show()
    self.default_focus = self.scroll_list
    self.isopen = true
end)

function SchemeUI:Deserialize()
	if self.attach == nil then return end
	local taggable = self.attach.replica.taggable
    local _serialized = taggable ~= nil and taggable._serializeddata:value()

	--assert(not(_serialized == nil or _serialized == ""), "TUNNELNETWORK data deserialization failed. No data recieved.")
	local _deserialized = {}
	for i, v in ipairs(string.split(_serialized, "\n")) do
		local elements = string.split(v, "\t")
		--assert(elements[1] ~= tostring(i), "TUNNELNETWORK data deserialization failed. Serialized data has been malformed.")

		local list = {}
		list.index = elements[1]
		list.text = elements[2]
		_deserialized[i] = list
	end
	
	for k, v in pairs(_deserialized) do
		print(k, v)
	end

	self.desttabledirty = _deserialized

end

function SchemeUI:Refresh()
	SendModRPCToServer(MOD_RPC["scheme"]["serialize"], self.attach)
	self.inst:DoTaskInTime(0, function()
		--wait until serialized data to arrive to replica.
		self:Deserialize()

		local list = {}
		for i, v in ipairs(self.desttabledirty) do 
			local data = {
				index = v[1],
				text = v[2]
			}

			table.insert(list, data)
		end
		-- 자기자신은 리스트에서 빼기
		self.destdata = list
	end)
end

function SchemeUI:DestListItem()
    local dest = Widget("destination")

    local item_width, item_height = 340, 20
    dest.backing = dest:AddChild( TEMPLATES.ListItemBackground(item_width, item_height, function() end) )
    dest.backing.move_on_click = true

    dest.name = dest:AddChild(Text(BODYTEXTFONT, 35))
    dest.name:SetVAlign(ANCHOR_MIDDLE)
    dest.name:SetHAlign(ANCHOR_LEFT)
    dest.name:SetPosition(0, 5, 0)
    dest.name:SetRegionSize(300, 10)

    dest.SetInfo = function(src, info)
        dest.name:SetColour(0, 1, 0, 0.6)
        dest.backing:SetOnClick( function() self:Travel(info.index) end )
    end

    dest.focus_forward = dest.backing
    return dest
end

function SchemeUI:Travel(index)
    if not self.isopen then
        return
    end

    local travelable = self.attach.replica.travelable
    if travelable then
        travelable:Travel(self.owner, index)
    end

    self.owner.HUD:CloseSchemeUI()
end

function SchemeUI:OnCancel()
    if not self.isopen then
        return
    end

	local taggable = self.attach.replica.taggable
    if taggable ~= nil then
        taggable:DoneAction(self.owner)
    end

    self.owner.HUD:CloseSchemeUI()
end

function SchemeUI:OnControl(control, down)
    if SchemeUI._base.OnControl(self, control, down) then
        return true
    end

    if not down then
        if control == CONTROL_OPEN_DEBUG_CONSOLE then
            return true
        elseif control == CONTROL_CANCEL then
            self:OnCancel()
        end
    end
end

function SchemeUI:Close()
	if self.isopen then
        self.attach = nil
        self.black:Kill()
		self.refresh_button:Kill()
        self.isopen = false

        self.inst:DoTaskInTime(.3, function() TheFrontEnd:PopScreen(self) end)
    end
end

return SchemeUI