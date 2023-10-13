
local CaesarPets = LibStub("AceAddon-3.0"):NewAddon("CaesarPets", "AceEvent-3.0", "AceHook-3.0")

local LibWindow = LibStub("LibWindow-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("CaesarPets")

local clientVersion = select(4, GetBuildInfo())
local wow_900 = clientVersion >= 90000
local wow_800 = clientVersion >= 80000
local wow_503 = clientVersion >= 50300

local maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS
-- NUM_PET_STABLE_SLOTS : 10
-- NUM_PET_STABLE_PAGES : 20
--print("Slots; "..NUM_PET_STABLE_SLOTS.."Pages; "..NUM_PET_STABLE_PAGES);

local nPetCount = 0;
local prevPage = -1;

local NumPets = {};
local Pet1Scale = 0;

-- /tinspect PetStableFrame

local ShowPanelOnLeft = not true;

local searchInfo = nil;
local infoPanel = nil;
local searchInput = nil;

local NUM_PER_ROW, heightChange
if wow_900 then
	NUM_PER_ROW = 10
elseif wow_800 then
	NUM_PER_ROW = 10
	heightChange = 65
elseif wow_503 then
	NUM_PER_ROW = 10
	heightChange = 36
else
	NUM_PER_ROW = 7
	heightChange = 17
end

local bExpanded = false;
local widthDelta = 315 + 1
local heightDelta = 204 + 20 + 4

function CaesarPets:ToggleExpandFrame()
	--print("CaesarPets:ToggleExpandFrame");

	if not bExpanded then
		CaesarPets:SinglePageMasterStable();
		CaesarPetsFrame_UpdateInfo();
	else
		if ( CaesarPetsFrameSlots:IsShown() and CaesarPetsFrameSlots:IsVisible() ) then
			HideUIPanel(CaesarPetsFrameSlots);
		end 
		CaesarPets:BasicMasterStable();
	end

	if CaesarPets.expandButton then
		if bExpanded then
			CaesarPets.expandButton:SetText(">>")
		else
			CaesarPets.expandButton:SetText("<<")
		end
	end
	bExpanded  = not bExpanded ;
end

function CaesarPets:BasicMasterStable()

	-- RESTABLECER DIMENSIONES "ORIGINALES"
	NUM_PET_STABLE_SLOTS = 10
	NUM_PET_STABLE_PAGES = 20
	PetStableFrame.page = prevPage

	-- RESTABLECER TAMAÑO "ORIGINAL"
	PetStableFrame:SetWidth(PetStableFrame:GetWidth() - widthDelta)
	PetStableFrame:SetHeight(PetStableFrame:GetHeight() - heightDelta)

	--RESTABLECER ALTURA "ORIGINAL"
	PetStableFrameModelBg:SetHeight(PetStableFrameModelBg:GetHeight() - heightDelta)

	--RESTABLECER POSICION "ORIGINAL"
	if (ShowPanelOnLeft) then
		PetStableFrame.Inset:SetPoint("TOPLEFT", PetStableFrame, 91, -26)
		PetStableBottomInset:SetPoint("TOPLEFT", PetStableFrameInset, "BOTTOMLEFT")
	end

	-- OCULTAR CAPA DE RESULTADO DE BUSQUEDA
	for i = 1, maxSlots do
		local frame = _G["PetStableStabledPet"..i]
		frame:SetScale(Pet1Scale);
		if (frame.dimOverlay) then
			frame.dimOverlay:Hide();
		end
	end

	-- OCULTAR BOTONES DE PAGINAS NO VISIBLES
	for i = NUM_PER_ROW+1, maxSlots do
		local frame = _G["PetStableStabledPet"..i]
		frame:Hide();
	end

	-- RESTEBLECER POSICION "ORIGNAL", PRIMER SLOT PRIMERA FILA
	PetStableStabledPet1:ClearAllPoints()
	PetStableStabledPet1:SetPoint("TOPLEFT", PetStableBottomInset, 50, -5)
	-- RESTEBLECER POSICION "ORIGNAL", PRIMER SLOT SEGUNDA FILA
	PetStableStabledPet6:ClearAllPoints()
	PetStableStabledPet6:SetPoint("TOPLEFT", PetStableStabledPet1, "BOTTOMLEFT", 0, -5)

	-- RESTEBLECER VISIBILIDAD BOTONES DE NAVEGACION 
	PetStableNextPageButton:Show();
	PetStablePrevPageButton:Show();

	-- OCULTAR PANEL DE INFORMACION
	if (infoPanel) then
		infoPanel:SetText("");
		infoPanel:Hide();
	end

	PetStable_Update(true);
end

function CaesarPets:SetupSinglePageMasterStable()

	--print("SetupSinglePageMasterStable");
	--print("Setup; Begin; Slots; "..NUM_PET_STABLE_SLOTS.."; Pages; "..NUM_PET_STABLE_PAGES);

	local nCount = 0;
	for i = NUM_PET_STABLE_SLOTS + 1, maxSlots do 
		local frame = _G["PetStableStabledPet"..i];
		if not frame then
			CreateFrame("Button", "PetStableStabledPet"..i, PetStableFrame, "PetStableSlotTemplate", i)
			nCount = nCount + 1
		end
	end

	if (nCount > 0) then
		--print("SetupSinglePageMasterStable; "..nCount);
	end

	for i = 1, maxSlots do
		local frame = _G["PetStableStabledPet"..i]
		if not frame.dimOverlay then
			frame.dimOverlay = frame:CreateTexture(nil, "OVERLAY");
		end
		frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
		frame.dimOverlay:SetAllPoints();
		frame.dimOverlay:Hide();
	end

end

function CaesarPets:SinglePageMasterStable()

	Pet1Scale = PetStableStabledPet1:GetScale();
	--print("Pet1Scale; "..Pet1Scale);

	for i = 1, maxSlots do
		local frame = _G["PetStableStabledPet"..i]
		if i > 1 then
			frame:ClearAllPoints()
			frame:SetPoint("LEFT", _G["PetStableStabledPet"..i-1], "RIGHT", 7.3, 0)
		end
		frame:SetFrameLevel(PetStableFrame:GetFrameLevel() + 1)
		frame:SetScale(7/NUM_PER_ROW)
		if frame.dimOverlay then
			frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
			frame.dimOverlay:SetAllPoints();
			frame.dimOverlay:Hide();
		end
		-- Set slot statuseses
		local petSlot = NUM_PET_ACTIVE_SLOTS + i;
		PetStable_UpdateSlot(frame, petSlot);
		frame:Show();
	end

	for i = NUM_PER_ROW+1, maxSlots, NUM_PER_ROW do
		_G["PetStableStabledPet"..i]:ClearAllPoints()
		_G["PetStableStabledPet"..i]:SetPoint("TOPLEFT", _G["PetStableStabledPet"..i-NUM_PER_ROW], "BOTTOMLEFT", 0, -5)
	end

	PetStableNextPageButton:Hide()
	PetStablePrevPageButton:Hide()

	if wow_900 then

		if not PetStableFrame.CaesarPetsFrameSlots then
			PetStableFrame.CaesarPetsFrameSlots = CreateFrame("Frame", "CaesarPetsFrameSlots", PetStableFrame, "InsetFrameTemplate")
		end
		local f = PetStableFrame.CaesarPetsFrameSlots
		f:ClearAllPoints()
		f:SetSize(widthDelta, PetStableFrame:GetHeight() + heightDelta - 28 -5)
		-- f:SetPoint("BOTTOMRIGHT", _G["PetStableStabledPet"..maxSlots], 5, -5)

		if (ShowPanelOnLeft) then
			f:SetPoint(PetStableFrame.Inset:GetPoint(1))
			-- move original-Inset to the right
			PetStableFrame.Inset:SetPoint("TOPLEFT", f, "TOPRIGHT")
		else
			-- Move new frame to the right of PetStableFrameModelBg
			f:SetPoint("TOPLEFT", PetStableFrameModelBg, "TOPRIGHT")
		end
		PetStableFrame:SetWidth(PetStableFrame:GetWidth() + widthDelta)
		PetStableFrame:SetHeight(PetStableFrame:GetHeight() + heightDelta)

		local h = PetStableFrameModelBg:GetHeight();
		--print("PetStableFrameModelBg; "..h);
		PetStableFrameModelBg:SetHeight(h + heightDelta)

		-- v10.1.7 PetStableModel => PetStableModelScene
		local p, r, rp, x, y = PetStableModelScene:GetPoint(1)
		PetStableModelScene:SetPoint(p, r, rp, x, y - 32)

		PetStableStabledPet1:ClearAllPoints()
		PetStableStabledPet1:SetPoint("TOPLEFT", f, 8, -36 - 24)

		-- Mostrar en PetStableBottomInset el sumario de estadísticas
		if infoPanel == nil then
			infoPanel = CreateFrame("SimpleHTML", "LabelInfoPanel", PetStableBottomInset)
			PetStableBottomInset.infoPanel = infoPanel;
		end
		infoPanel:SetPoint("TOPLEFT", 50, -9)
		infoPanel:SetPoint("RIGHT", -3, 0)
		infoPanel:SetHeight(60)
		infoPanel:SetFontObject("p", "GameFontNormal")
		infoPanel:SetText("")
		infoPanel:Show();

		if searchInput == nil then
			searchInput = CreateFrame("EditBox", "CaesarPets_SearchInput", f, "SearchBoxTemplate")
			CaesarPetsFrameSlots.searchInput = searchInput;
		end
		searchInput:SetPoint("TOPLEFT", 9, -4)
		searchInput:SetPoint("RIGHT", -3, 0)
		searchInput:SetHeight(22)
		searchInput:HookScript("OnTextChanged", CaesarPetsFrame_OnTextChanged)
		searchInput.Instructions:SetText(SEARCH .. " (" .. NAME .. ", " .. PET_FAMILIES .. ", " .. PET_TALENTS  .. ")")

		if searchInfo == nil then
			searchInfo = CreateFrame("SimpleHTML", "searchInfoPanel", f)
			CaesarPetsFrameSlots.searchInfo = searchInfo;
		end
		searchInfo:SetPoint("TOPLEFT", f, 9, -28)
		searchInfo:SetPoint("RIGHT", -3, 0)
		searchInfo:SetHeight(20)
		searchInfo:SetFontObject("p", "GameFontHighlightSmallOutline")
		searchInfo:SetText("")

		f:Show();

	else
		PetStableStabledPet1:ClearAllPoints()
		PetStableStabledPet1:SetPoint("TOPLEFT", PetStableBottomInset, 9, -9)

		PetStableFrameModelBg:SetHeight(281 - heightChange)
		PetStableFrameModelBg:SetTexCoord(0.16406250, 0.77734375, 0.00195313, 0.55078125 - heightChange/512)

		PetStableFrameInset:SetPoint("BOTTOMRIGHT", PetStableFrame, "BOTTOMRIGHT", -6, 126 + heightChange)

		PetStableFrameStableBg:SetHeight(116 + heightChange)
	end

	NUM_PET_STABLE_SLOTS = maxSlots
	NUM_PET_STABLE_PAGES = 1
	prevPage = PetStableFrame.page;
	PetStableFrame.page = 1

	--print("Setup; End; Slots; "..NUM_PET_STABLE_SLOTS.."; Pages; "..NUM_PET_STABLE_PAGES);

end

function CaesarPetsFrame_UpdateInfo()

	nPetCount = 0;
	NumPets = {};
	numSlots = maxSlots + NUM_PET_ACTIVE_SLOTS;
	
	for i = 1, numSlots do
		local icon, name, level, family, talent = GetStablePetInfo(i);
		if icon then
			nPetCount = nPetCount + 1;
			if NumPets[talent] ~= nil then
			  NumPets[talent] = NumPets[talent] + 1;
			else
			  NumPets[talent] = 1
			end
		end
	end

	local msg = ""
	for k,v in pairs(NumPets) do
		msg = msg .. "\n" .. k .. " (" .. v ..")"
	end
	local sInfo = string.format(L.TotalFmt, nPetCount, numSlots);
	if (infoPanel) then
		infoPanel:SetText(sInfo..msg);
	end
end

local input = "";
function CaesarPetsFrame_OnTextChanged(sender)
	-- CaesarPets_SearchInput
	--print("CaesarPetsFrame_OnTextChanged");
	input = sender:GetText();
	CaesarPetsFrame_Update();
end

function CaesarPetsFrame_Update()
	--if not bExpanded then
	--	return
	--end
	--print("CaesarPetsFrame_Update");

	--local input = CaesarPets.searchInput:GetText();
	if not input or input:trim() == "" then
		for i = 1, maxSlots do
			local button = _G["PetStableStabledPet"..i];
			if (button and button.dimOverlay) then
				button.dimOverlay:Hide();
			end
		end
		CaesarPetsFrame_UpdateInfo();
		if (searchInfo) then
			searchInfo:SetText("");
		end
		return
	end

	local NumFound = 0;

	for i = 1, maxSlots do
		local icon, name, level, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i);
		local button = _G["PetStableStabledPet"..i];
		
		button.dimOverlay:Show();
		if icon then		
			local matched, expected = 0, 0
			for str in input:gmatch("([^%s]+)") do
				expected = expected + 1
				str = str:trim():lower()

				if name:lower():find(str)
				or family:lower():find(str)
				or talent:lower():find(str)
				then
					matched = matched + 1
				end
			end
			if matched == expected then
				button.dimOverlay:Hide();
				NumFound = NumFound + 1
			end
		end
	end

	searchInfo:SetText(string.format(L.PetsFound, NumFound))
end

local defaults = {
	profile = {
		hideFrameButton = false,
		modules = {
			['*'] = true,
		},
		scale = 1,
		-- position defaults for LibWindow
		x = 40,
		y = 40,
		point = "LEFT",
		-- v4
		minimap = {
			hide = false,
		},
	}
}

-- Prerequsities: LibDataBroker and LibDBIcon
-- Set up DataBroker for minimap button
local LDBo = LibStub("LibDataBroker-1.1"):NewDataObject("CaesarPets", {
  type = "data source",
  text = "CaesarPets",
  label = "CaesarPets by |cff69CCF0Ghordian",
  icon = "Interface\\AddOns\\CaesarPets\\Logo.png",
  OnClick = function(self, button)
	if button == "RightButton" then
		CaesarPets:OpenOptions()
	elseif button == "LeftButton" then
		if PetStableFrame then
			PetStableFrame:Show()
		end
	end
  end,
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("CaesarPets by |cff69CCF0Ghordian")
    tooltip:AddLine(" ")
	tooltip:AddLine(L.MinimapHint, 0.2, 1, 0.2, 1)
  end
})

local ldbi = LibStub("LibDBIcon-1.0")

function CaesarPets:OpenOptions()
	-- open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(CaesarPets.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(CaesarPets.optionsFrames.CaesarPets)
	if InterfaceOptionsFrame then
		InterfaceOptionsFrame:Raise()
	end
end

function CaesarPets:ToggleMinimapButton()
	-- for the slash command
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide;
	self:UpdateMinimapButton()
end

function CaesarPets:UpdateMinimapButton()
	--print("UpdateMinimapButton")
	if (self.db.profile.minimap.hide) then
		ldbi:Hide("CaesarPets")
	--print("UpdateMinimapButton.Hide")
	else
		ldbi:Show("CaesarPets")
	--print("UpdateMinimapButton.Show")
	end
end

local PetStableFrameStartMoving, PetStableFrameStopMoving
local db

function CaesarPets:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("CaesarPetsDB", defaults, true)
	db = self.db.profile

	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")

	self.elementsToHide = {}

	self:SetupOptions()
	
	-- Standard minimap button
	ldbi:Register("CaesarPets", LDBo, self.db.profile.minimap)
	self:UpdateMinimapButton()
	
	-- Single Page Master Stable
	self:SetupSinglePageMasterStable()

	--if (not self.db.profile.ShowExpanded) then
	----self:SinglePageMasterStable()
	--	self:ToggleExpandFrame();
	--end

	hooksecurefunc("PetStable_Update", CaesarPetsFrame_Update)
end

local function purgeKey(t, k)
	t[k] = nil
	local c = 42
	repeat
		if t[c] == nil then
			t[c] = nil
		end
		c = c + 1
	until issecurevariable(t, k)
end

function CaesarPets:OnEnable()

	LibWindow.RegisterConfig(PetStableFrame, db)

	-- remove from UI panel system
	purgeKey(UIPanelWindows, "PetStableFrame")
	PetStableFrame:SetAttribute("UIPanelLayout-area", nil)
	PetStableFrame:SetAttribute("UIPanelLayout-enabled", false)

	-- make the frame movable
	PetStableFrame:SetMovable(true)
	PetStableFrame:RegisterForDrag("LeftButton")
	PetStableFrame:SetScript("OnDragStart", PetStableFrameStartMoving)
	PetStableFrame:SetScript("OnDragStop", PetStableFrameStopMoving)

	-- hook Show events for fading
	self:SecureHookScript(PetStableFrame, "OnShow", "PetStableFrame_OnShow")

	-- hooks for scale
	if HelpPlate_Show then
		self:SecureHook("HelpPlate_Show")
		self:SecureHook("HelpPlate_Hide")
		self:SecureHook("HelpPlate_Button_AnimGroup_Show_OnFinished")
	end

	-- close the frame on escape
	table.insert(UISpecialFrames, "PetStableFrame")

	self:SetScale()
	self:SetPosition()
	
	--print("OnEnable; hideFrameButton")
	if not db.hideFrameButton then
		self:SetupFrameButton()
	end

	self:SetupExpandButton();

end

function CaesarPets:Refresh()

	db = self.db.profile

	for k,v in self:IterateModules() do
		if self:GetModuleEnabled(k) and not v:IsEnabled() then
			self:EnableModule(k)
		elseif not self:GetModuleEnabled(k) and v:IsEnabled() then
			self:DisableModule(k)
		end
		if type(v.Refresh) == "function" then
			v:Refresh()
		end
	end

	-- apply new settings
	self:SetScale()
	self:SetPosition()

	--print("Refresh; hideFrameButton")
	if db.hideFrameButton then
		if self.optionsButton then
			self.optionsButton:Hide()
		end
	else
		if not self.optionsButton then
			self:SetupFrameButton()
		end
		self.optionsButton:Show()
	end

	--print("Refresh; UpdateMinimapButton")
	self:UpdateMinimapButton()
end

function PetStableFrameStartMoving(frame)
	PetStableFrame:StartMoving()
end

function PetStableFrameStopMoving(frame)
	PetStableFrame:StopMovingOrSizing()
	LibWindow.SavePosition(PetStableFrame)
end

function CaesarPets:SetPosition()
	LibWindow.RestorePosition(PetStableFrame)
end

function CaesarPets:PetStableFrame_OnShow()
	PlayerMovementFrameFader.RemoveFrame(PetStableFrame)
end

function CaesarPets:SetScale(force)
	if (PetStableFrame:GetScale() ~= db.scale or force) then
		PetStableFrame:SetScale(db.scale)
	end
end

function CaesarPets:PetStableFrame_SynchronizeDisplayState()
	self:SetScale()
	self:SetPosition()
end

function CaesarPets:HelpPlate_Show(plate, frame)
	if frame == PetStableFrame then
		HelpPlate:SetScale(db.scale)
		HelpPlate.__CaesarPets = true
	end
end

function CaesarPets:HelpPlate_Hide(userToggled)
	if HelpPlate.__CaesarPets and not userToggled then
		HelpPlate:SetScale(1.0)
		HelpPlate.__CaesarPets = nil
	end
end

function CaesarPets:HelpPlate_Button_AnimGroup_Show_OnFinished()
	if HelpPlate.__CaesarPets then
		HelpPlate:SetScale(1.0)
		HelpPlate.__CaesarPets = nil
	end
end

function CaesarPets:EncounterJournalPin_OnAcquired(pin)
	pin:SetSize(50 * db.ejScale, 49 * db.ejScale)
	pin.Background:SetScale(db.ejScale)
end

function CaesarPets:SetEJScale()
	-- EncounterJournal
	for pin in PetStableFrame:EnumeratePinsByTemplate("EncounterJournalPinTemplate") do
		--self:EncounterJournalPin_OnAcquired(pin)
	end
end

function CaesarPets:ShowUIPanelHook(frame)
	if frame == PetStableFrame and InCombatLockdown() and not frame:IsShown() then
		frame:Show()
	end
end

function CaesarPets:GetModuleEnabled(module)
	return db.modules[module]
end

function CaesarPets:SetModuleEnabled(module, value)
	local old = db.modules[module]
	db.modules[module] = value
	if old ~= value then
		if value then
			self:EnableModule(module)
		else
			self:DisableModule(module)
		end
	end
end
