local taggables = require"taggables"

local function gettext(inst, viewer)
    local text = inst.components.taggable:GetText()
    return text and string.format('"%s"', text) or GetDescription(viewer, inst, "UNWRITTEN")
end

local function onbuilt(inst, data)
    inst.components.taggable:BeginWriting(data.spawner)
end

local function onselect(inst, data)
    inst.components.taggable:SelectPopup(data.user)
end

--V2C: NOTE: do not add "writeable" tag to pristine state because it is more
--           likely for players to encounter signs that are already written.
local function ontextchange(self, text)
    if text ~= nil then
        self.inst:RemoveTag("writeable")
        self.inst.AnimState:Show("WRITING")
    else
        self.inst:AddTag("writeable")
        self.inst.AnimState:Hide("WRITING")
    end
end

local function onwriter(self, writer)
    self.inst.replica.taggable:SetWriter(writer)
end

local Taggable = Class(function(self, inst)
    self.inst = inst
    self.text = nil

    self.writer = nil
    self.screen = nil
	
    self.onclosepopups = function(doer)
        if doer == self.writer then
            self:EndAction()
        end
    end

    self.generatorfn = nil

    self.inst:ListenForEvent("tag", onbuilt)
    self.inst:ListenForEvent("select", onselect)
end,
nil,
{
    text = ontextchange,
    writer = onwriter,
})


function Taggable:OnSave()
    local data = {}

    data.text = self.text
	if IsXB1() then
		data.netid = self.netid
	end

    return data

end

function Taggable:OnLoad(data)
	if IsRail() then
    	self.text = TheSim:ApplyWordFilter(data.text)
	else
    	self.text = data.text
	end
	if IsXB1() then
		self.netid = data.netid
	end
end

function Taggable:GetText(viewer)
	if IsXB1() then
		if self.text and self.netid then
			return "\1"..self.text.."\1"..self.netid
		end
	end
    return self.text
end

function Taggable:SetText(text)
    self.text = text
end

function Taggable:BeginWriting(doer)
    if self.writer == nil then
		self.inst.classified.shouldUI:set(false)
        self.inst:StartUpdatingComponent(self)

        self.writer = doer
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, doer)
        self.inst:ListenForEvent("onremove", self.onclosepopups, doer)

        if doer.HUD ~= nil then -- Non-deicated-No-cave server host
            self.screen = taggables.makescreen(self.inst, doer)
        end
	else
		if doer.components.talker ~= nil then
			doer.components.talker:Say(GetString(doer.prefab, "ACTIONFAIL_GENERIC"))
		end
    end
end

local function IsNearDanger(inst)
    local hounded = TheWorld.components.hounded
    if hounded ~= nil and (hounded:GetWarning() or hounded:GetAttacking()) then
        return true
    end
    local burnable = inst.components.burnable
    if burnable ~= nil and (burnable:IsBurning() or burnable:IsSmoldering()) then
        return true
    end
    -- See entityreplica.lua (for _combat tag usage)
    if inst:HasTag("spiderwhisperer") and not inst:HasTag("realyoukai") then
        --Danger if:
        -- being targetted
        -- OR near monster or pig that is neither player nor spider
        -- ignore shadow monsters when not insane
        return FindEntity(inst, 10,
            function(target)
                return (target.components.combat ~= nil and target.components.combat.target == inst)
                    or ((target:HasTag("monster") or target:HasTag("pig")) and
                        not (target:HasTag("player") or target:HasTag("spider")) and
                        not (inst.components.sanity:IsSane() and target:HasTag("shadowcreature")))
            end,
            nil, nil, { "monster", "pig", "_combat" }) ~= nil
    end
    --Danger if:
    -- being targetted
    -- OR near monster that is not player
    -- ignore shadow monsters when not insane
    return FindEntity(inst, 10,
        function(target)
            return (target.components.combat ~= nil and target.components.combat.target == inst)
                or (target:HasTag("monster") and
                    not target:HasTag("player") and
                    not (inst.components.sanity:IsSane() and target:HasTag("shadowcreature")))
        end,
        nil, nil, { "monster", "_combat" }) ~= nil
end

function Taggable:SelectPopup(doer)
	if IsNearDanger(doer) then 
		doer.components.talker:Say(GetString(doer.prefab, "NODANGERSCHEME"))
		return 
	end
    if self.writer == nil then
		self.inst.sg:GoToState("opening")
		self.inst.classified.shouldUI:set(true)
        self.inst:StartUpdatingComponent(self)

        self.writer = doer
        self.inst:ListenForEvent("ms_closepopups", self.onclosepopups, doer)
        self.inst:ListenForEvent("onremove", self.onclosepopups, doer)

        if doer.HUD ~= nil then -- Non-deicated-No-cave server host
            self.screen = doer.HUD:ShowSchemeUI(self.inst)
        end
	else
		if doer.components.talker ~= nil then
			doer.components.talker:Say(GetString(doer.prefab, "ACTIONFAIL_GENERIC"))
		end
    end
end

function Taggable:IsWritten()
    return self.text ~= nil
end

function Taggable:IsBeingWritten()
    return self.writer ~= nil
end

function Taggable:DoAction(doer, _text, index) --Some.. bad example of implementing overload
	if index ~= nil then
		doer.sg:GoToState("jumpin", { teleporter = doer })
		doer:DoTaskInTime(0.8, function()
			self.inst.components.scheme:Activate(doer, index)
		end)
		doer:DoTaskInTime(3, function() -- Move entities outside of map border inside
			if not doer:IsOnValidGround() then
				local dest = FindNearbyLand(doer:GetPosition(), 8)
				if dest ~= nil then
					if doer.Physics ~= nil then
						doer.Physics:Teleport(dest:Get())
					elseif act.doer.Transform ~= nil then
						doer.Transform:SetPosition(dest:Get())
					end
				end
			end
		end)
	else
		local text = _text or self.text
		if text == nil or text == "" then --set default text
			local index = self.inst.components.scheme.index
			if index ~= nil then
				text = "#"..index
			end
		end

		if self.writer == doer and doer ~= nil and
			--NOTE: text may be network data, so enforcing length is
			--NOT redundant in order for rendering to be safe.
			(text == nil or text:utf8len() <= MAX_WRITEABLE_LENGTH / 4) then
			if IsRail() then
				text = TheSim:ApplyWordFilter(text)
			end
			self:SetText(text)
		end
	end

	self:EndAction()
end

function Taggable:EndAction()
    if self.writer ~= nil then
        self.inst:StopUpdatingComponent(self)

        if self.screen ~= nil then
            self.writer.HUD:CloseTaggableWidget()
            self.writer.HUD:CloseSchemeUI()
            self.screen = nil
        end

        self.inst:RemoveEventCallback("ms_closepopups", self.onclosepopups, self.writer)
        self.inst:RemoveEventCallback("onremove", self.onclosepopups, self.writer)

		if IsXB1() then
			if self.writer:HasTag("player") and self.writer:GetDisplayName() then
				local ClientObjs = TheNet:GetClientTable()
				if ClientObjs ~= nil and #ClientObjs > 0 then
					for i, v in ipairs(ClientObjs) do
						if self.writer:GetDisplayName() == v.name then
							self.netid = v.netid
							break
						end
					end
				end
			end
		end

        self.writer = nil
    elseif self.screen ~= nil then
        --Should not have screen and no writer, but just in case...
        if self.screen.inst:IsValid() then
            self.screen:Kill()
        end
        self.screen = nil
    end
	self.inst:DoTaskInTime(1, function()
		self.inst.sg:GoToState("closing")
	end)
end

--------------------------------------------------------------------------
--Check for auto-closing conditions
--------------------------------------------------------------------------

function Taggable:OnUpdate(dt)
    if self.writer == nil then
        self.inst:StopUpdatingComponent(self)
    elseif (self.writer.components.rider ~= nil and
        self.writer.components.rider:IsRiding())
        or not (self.writer:IsNear(self.inst, 3) and
		CanEntitySeeTarget(self.writer, self.inst)) then
			self:EndAction()
    end
end

--------------------------------------------------------------------------

function Taggable:OnRemoveFromEntity()
    self:EndAction()
    self.inst:RemoveTag("writeable")
    self.inst:RemoveEventCallback("tag", onbuilt)
	self.inst:RemoveEventCallback("select", onselect)
end

Taggable.OnRemoveEntity = Taggable.EndAction

return Taggable
