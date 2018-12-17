local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local TEMPLATES = require "widgets/redux/templates"

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

    self.scalingroot = self:AddChild(Widget("schemeuiscalingroot"))
    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())

    self.inst:ListenForEvent("continuefrompause", function() if self.isopen then self.scalingroot:SetScale(TheFrontEnd:GetHUDScale()) end end, TheWorld)
    self.inst:ListenForEvent("refreshhudsize", function(hud, scale) if self.isopen then self.scalingroot:SetScale(scale) end end, owner.HUD.inst)

    self.root = self.scalingroot:AddChild(TEMPLATES.ScreenRoot("root"))

    -- secretly this thing is a modal Screen, it just LOOKS like a widget
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0)
    self.black.OnMouseButton = function() self:OnCancel() end

    self.destspanel = self.root:AddChild(TEMPLATES.RectangleWindow(240, 320))
    self.destspanel:SetPosition(0, 25)

	self.title = self.destspanel:AddChild(Text(BODYTEXTFONT, 32))
	self.title:SetString("Select destination")
	self.title:SetPosition(0, 130)

	self.desttabledirty = {}
	self.destdata = {}
	self.destitem = {}

	self.refresh_button = self.destspanel:AddChild(TEMPLATES.StandardButton(function() self:Refresh() end, "refresh", {120, 40}, {"images/button_icons.xml", "refresh.tex"}))
	self.refresh_button:SetPosition(80, -200)

    self.cancelbutton = self.destspanel:AddChild(TEMPLATES.StandardButton(function() self:OnCancel() end, "Cancel", {120, 40}))
    self.cancelbutton:SetPosition(-80, -200)

	self:Refresh()
    self:Show()
    self.default_focus = self.scroll_list
    self.isopen = true
end)

function SchemeUI:UpdateData()
	local function ScrollWidgetsCtor(context, index)
        local item = Widget("item-"..index)

		item.button = item:AddChild(TEMPLATES.ListItemBackground(340, 30, function() end))
		item.button.move_on_click = true

		item.name = item:AddChild(Text(BODYTEXTFONT, 20))
		item.name:SetVAlign(ANCHOR_MIDDLE)
		item.name:SetHAlign(ANCHOR_LEFT)
		item.name:SetPosition(0, 0, 5)
		item.name:SetRegionSize(220, 30)

		item.focus_forward = item.button

        item:SetOnGainFocus(function() self.scroll_list:OnWidgetFocus(item) end)

        return item
    end

	local function ApplyDataToWidget(context, item, data, index)
		if data ~= nil then
			item.name:SetString(data.text)
			item.name:SetColour(1, 1, 1, 1)
			item.button:SetOnClick(function() self:OnSelected(data.index) end)
		else
			item.button:SetOnClick(nil)
		end
    end

	self.scroll_list = self.destspanel:AddChild(TEMPLATES.ScrollingGrid(self.destdata, {
        context = {},
        widget_width = 250,
        widget_height = 30,
        num_visible_rows = 8,
        num_columns = 1,
        item_ctor_fn = ScrollWidgetsCtor,
        apply_fn = ApplyDataToWidget,
        scrollbar_offset = 10,
        scrollbar_height_offset = -60,
        peek_percent = 0,
        allow_bottom_empty_row = true
	}))
    self.scroll_list:SetPosition(0, -20)
    self.scroll_list:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
    self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.scroll_list)
end

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
	self.desttabledirty = _deserialized
end

function SchemeUI:Refresh()
	SendModRPCToServer(MOD_RPC["scheme"]["serialize"], self.attach)
	self.inst:DoTaskInTime(0.5, function() --wait until serialized data to arrive to replica.
		self:Deserialize()
		local list = {}
		for i, v in ipairs(self.desttabledirty) do 
			local data = {
				index = v["index"],
				text = v["text"]
			}

			table.insert(list, data)
		end
		local taggable = self.attach.replica.taggable
		if taggable ~= nil then -- delete destination itself.
			table.remove(list, taggable.index:value())
		end

		self.destdata = list
		
		self:UpdateData()
	end)
end

function SchemeUI:OnSelected(index)
    if not self.isopen then
        return
    end

	local taggable = self.attach.replica.taggable
    if taggable ~= nil then
        taggable:DoAction(self.owner, nil, index)
    end

    self.owner.HUD:CloseSchemeUI()
end

function SchemeUI:OnCancel()
    if not self.isopen then
        return
    end

	local taggable = self.attach.replica.taggable
    if taggable ~= nil then
        taggable:DoAction(self.owner)
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