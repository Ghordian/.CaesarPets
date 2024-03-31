
local CaesarPets = LibStub("AceAddon-3.0"):NewAddon("CaesarPets", "AceEvent-3.0", "AceHook-3.0")

local LibWindow = LibStub("LibWindow-1.1")
local L = LibStub("AceLocale-3.0"):GetLocale("CaesarPets")

local TENACITY   = L["Tenacity"];
local CUNNING    = L["Cunning"];
local FEROCITY   = L["Ferocity"];
local EXOTICPET  = L["Exotic"];

local clientVersion = select(4, GetBuildInfo())
local wow_900 = clientVersion >= 90000
local wow_800 = clientVersion >= 80000
local wow_503 = clientVersion >= 50300
local def_thickness = 2.0;

local maxSlots = NUM_PET_STABLE_PAGES * NUM_PET_STABLE_SLOTS
-- NUM_PET_STABLE_SLOTS : 10
-- NUM_PET_STABLE_PAGES : 20
--print("Slots; "..NUM_PET_STABLE_SLOTS.."Pages; "..NUM_PET_STABLE_PAGES);

local nPetCount = 0;
local prevPage = -1;

local NumPets = {};
local Pet1Scale = 0;

-- https://warcraft.wiki.gg/wiki/Hunter_pet
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

CaesarPets.bExpanded = false;

local widthDelta = 315 + 1
local heightDelta = 204 + 20 + 4

function CaesarPets:ToggleExpandFrame()
	--print("CaesarPets:ToggleExpandFrame");

	if not self.bExpanded then
		self:SinglePageMasterStable();
		CaesarPetsFrame_UpdateInfo();
	else
		if ( CaesarPetsFrameSlots:IsShown() and CaesarPetsFrameSlots:IsVisible() ) then
			HideUIPanel(CaesarPetsFrameSlots);
		end
		self:BasicMasterStable();
	end

	if self.expandButton then
		if self.bExpanded then
			CaesarPets.expandButton:SetText(">>")
		else
			CaesarPets.expandButton:SetText("<<")
		end
	end
	self.bExpanded = not self.bExpanded;

	CaesarPetsFrame_Update();
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

	if (nCount >= 0) then
		--print("SetupSinglePageMasterStable; "..nCount);
	end

	for i = 1, maxSlots do
		local frame = _G["PetStableStabledPet"..i]
		self:CreateOverlay(frame)
		self:CreateBorder(frame)
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
		frame:SetScale(7 / NUM_PER_ROW)
		--
		if frame.dimOverlay then
			frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
			frame.dimOverlay:SetAllPoints();
			frame.dimOverlay:Hide();
		end
		-- Set slot status
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
			local isExotic = GetPetIsExotic(family, talent);
			if isExotic then
				if NumPets[EXOTICPET] ~= nil then
					NumPets[EXOTICPET] = NumPets[EXOTICPET] + 1
				else
					NumPets[EXOTICPET] = 1
				end
			end
		end
	end

	local msg = ""
	for k,v in pairs(NumPets) do
		local color = GetPetTalentColor(k)
		local talent = WrapTextInColor(k, color)
		msg = msg .. "\n" .. talent .. " (" .. v ..")"
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

-- drag'n'drop actions
function CaesarPetsFrame_PetStable_UpdateSlot(button, petSlot)
	--print("CaesarPetsFrame_PetStable_UpdateSlot; "..petSlot);
	local icon, name, level, family, talent = GetStablePetInfo(petSlot);
	CaesarPets:SetMetaData(button, name, level, family, talent)
	if (family ~= nil) then
		if GetCaesarPets_ShowTalentBorder() then
			local is_exotic = GetPetIsExotic(family, talent);
			local thickness = GetCaesarPets_BorderThickness();
			local talent_color = GetPetTalentColor(talent, is_exotic);
			CaesarPets:UpdateBorder(button, thickness, talent_color);
		else
			CaesarPets:RemoveBorder(button);
		end
	else
		CaesarPets:RemoveBorder(button);
		if (button.dimOverlay) then
			button.dimOverlay:Hide();
		end
	end
end

function CaesarPetsFrame_Update()

	local bExpanded = CaesarPets.bExpanded;
	local showBorder = GetCaesarPets_ShowTalentBorder();
	--print("CaesarPetsFrame_Update; showBorder; "..tostring(showBorder));

	--local input = CaesarPets.searchInput:GetText();
	if not input or input:trim() == "" or not bExpanded then
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
		UpdateTalentBorder();
		return
	end

	local NumFound = 0;

	for i = 1, maxSlots do
		local icon, name, level, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i);
		local button = _G["PetStableStabledPet"..i];

		button.dimOverlay:Show();
		CaesarPets:RemoveBorder(button);
		if icon then
			local matched, expected = 0, 0
			for str in input:gmatch("([^%s]+)") do
				expected = expected + 1
				str = str:trim():lower()

				if name:lower():find(str)
					or family:lower():find(str)
						or talent:lower():find(str)
					then
						matched = matched + 1;
					end
			end
			if (matched == expected) then
				NumFound = NumFound + 1
				button.dimOverlay:Hide();
				if GetCaesarPets_ShowTalentBorder() then
					local isExotic = GetPetIsExotic(family, talent);
					local thickness = GetCaesarPets_BorderThickness();
					local talent_color = GetPetTalentColor(talent, isExotic);
					CaesarPets:UpdateBorder(button, thickness, talent_color);
				end
			end
		end
	end

	if (searchInfo) then
		searchInfo:SetText(string.format(L.PetsFound, NumFound))
	end
end

function UpdateTalentBorder()
	for i = 1, maxSlots do
		local icon, name, level, family, talent = GetStablePetInfo(NUM_PET_ACTIVE_SLOTS + i);
		local button = _G["PetStableStabledPet"..i];

		CaesarPets:RemoveBorder(button);
		if icon then
			if GetCaesarPets_ShowTalentBorder() then
				local isExotic = GetPetIsExotic(family, talent);
				local thickness = GetCaesarPets_BorderThickness();
				local talent_color = GetPetTalentColor(talent, isExotic);
				CaesarPets:UpdateBorder(button, thickness, talent_color);
			end
		end
	end
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
		-- v5
		talentBorder = {
			show = true,
			thickness = def_thickness,
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
	if (self.db.profile.minimap.hide) then
		ldbi:Hide("CaesarPets")
	else
		ldbi:Show("CaesarPets")
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
	--CaesarPetsFrame_Update()

	--if (not self.db.profile.ShowExpanded) then
	----self:SinglePageMasterStable()
	--	self:ToggleExpandFrame();
	--end

	hooksecurefunc("PetStable_UpdateSlot", CaesarPetsFrame_PetStable_UpdateSlot);
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

  --if db.showHunterBooks then
  --  self:SetupHunterBooksButton();
  --end
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

	CaesarPetsFrame_Update();
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

function GetCaesarPets_ShowTalentBorder()
	local db = CaesarPets.db;
	if (db.profile.talentBorder) then
		local value = db.profile.talentBorder.show;
		return value
	else
		return false
	end
end

function GetCaesarPets_BorderThickness()
	local db = CaesarPets.db;
	if (db.profile.talentBorder) then
		return db.profile.talentBorder.thickness
	else
		return def_thickness
	end
end

function CaesarPets:SetMetaData(frame, name, level, family, talent)
	if (family ~= nil) then
		frame.ID = family;
		frame.NAME = name;
		frame.LEVEL = level
		frame.PETCLASS = talent;
	else
		frame.ID = "ZZX1234"
		frame.PETCLASS = "ZZX1234";
	end
end

function CaesarPets:CreateOverlay(frame)
	if not frame.dimOverlay then
		frame.dimOverlay = frame:CreateTexture(nil, "OVERLAY");
	end
	frame.dimOverlay:SetColorTexture(0, 0, 0, 0.8);
	frame.dimOverlay:SetAllPoints();
	frame.dimOverlay:Hide();
end

function CaesarPets:CreateBorder(frame)
  local thickness = GetCaesarPets_BorderThickness();
	local clr = CreateColor(0, 0, 0, 0);
  return self:UpdateBorder(frame, thickness, clr)
end

function CaesarPets:UpdateBorder(frame, thickness, color)
	if not frame.border then
		frame.border = {}
	end
	local offset = thickness / 2

	for i = 0, 3 do
		if not frame.border[i] then
		--frame.border[i] = frame:CreateLine(nil, "BACKGROUND", nil, 0)
			frame.border[i] = frame:CreateLine(nil, "BORDER", nil, 0)
		end

		frame.border[i]:SetColorTexture(color.r, color.g, color.b, color.a)
		frame.border[i]:SetThickness(thickness)

		if i == 0 then
			frame.border[i]:SetStartPoint("TOPLEFT", -offset, 0)
			frame.border[i]:SetEndPoint("TOPRIGHT", offset, 0)
		elseif i == 1 then
			frame.border[i]:SetStartPoint("TOPRIGHT", 0, offset)
			frame.border[i]:SetEndPoint("BOTTOMRIGHT", 0, -offset)
		elseif i == 2 then
			frame.border[i]:SetStartPoint("BOTTOMRIGHT", offset, 0)
			frame.border[i]:SetEndPoint("BOTTOMLEFT", -offset, 0)
		else
			frame.border[i]:SetStartPoint("BOTTOMLEFT", 0, -offset)
			frame.border[i]:SetEndPoint("TOPLEFT", 0, offset)
		end
	end

	return frame.border
end

function CaesarPets:RemoveBorder(button)
	if button.border then
		for i = 0, 3 do
			local aBorder = button.border[i];
			button.border[i] = nil;
			if aBorder then
				aBorder:Hide();
			end;
		end
		button.border = nil
	end
end

-- https://www.wowace.com/projects/libbabble-creaturetype-3-0
-- creatureFamily = UnitCreatureFamily(unit)
-- https://warcraft.wiki.gg/wiki/Pet_talents

-- https://warcraft.wiki.gg/wiki/ColorMixin
-- {r=1, g=1, b=0, a=1}
local grayColor = COMMON_GRAY_COLOR
local redColor = RED_FONT_COLOR
local blueColor = BLUE_FONT_COLOR
local greenColor = GREEN_FONT_COLOR
local yellowColor = YELLOW_FONT_COLOR

local PetTalentColor = {
  [TENACITY] = greenColor,
  [CUNNING] =  redColor,
  [FEROCITY] = blueColor,
	[EXOTICPET] = yellowColor,
}
local UPetTalentColor = {
	[0] = redColor,
	[1] = blueColor,
	[2] = greenColor,
}

local NOT_EXOTIC = false;
local IS_EXOTIC  = true;

-- https://www.wow-petopia.com/abilities.php
-- https://www.wowhead.com/es/hunter-pets

local BL = {}
if true then
	local B = LibStub("LibBabble-PetFamily-3.0")
	BL = B:GetLookupTable()
end

CaesarPets.families = {
	-- WOW CLASSIC
	{BL["Bat"]             ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Bear"]            ,TENACITY,NOT_EXOTIC},	-- WOW
	{BL["Bird of Prey"]    ,CUNNING ,NOT_EXOTIC},	-- WOW
	{BL["Boar"]            ,CUNNING ,NOT_EXOTIC},	-- WOW
	{BL["Carrion Bird"]    ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Cat"]             ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Crab"]            ,TENACITY,NOT_EXOTIC},	-- WOW
	{BL["Crocolisk"]       ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Gorilla"]         ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Hyena"]           ,CUNNING ,NOT_EXOTIC},	-- WOW
	{BL["Raptor"]          ,CUNNING ,NOT_EXOTIC},	-- WOW
	{BL["Scorpid"]         ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Serpent"]         ,CUNNING ,NOT_EXOTIC},	-- WOW
	{BL["Spider"]          ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Tallstrider"]     ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Turtle"]          ,TENACITY,NOT_EXOTIC},	-- WOW
	{BL["Wind Serpent"]    ,FEROCITY,NOT_EXOTIC},	-- WOW
	{BL["Wolf"]            ,FEROCITY,NOT_EXOTIC},	-- WOW
	-- The Burning Crusade
	{BL["Dragonhawk"]      ,TENACITY,NOT_EXOTIC},	-- BC
	{BL["Ravager"]         ,FEROCITY,NOT_EXOTIC},	-- BC
	{BL["Ray"]             ,FEROCITY,NOT_EXOTIC},	-- BC
	{BL["Sporebat"]        ,CUNNING ,NOT_EXOTIC},	-- BC
	{BL["Warp Stalker"]    ,CUNNING ,NOT_EXOTIC},	-- BC
	-- Wrath of the Lich King
	{BL["Aqiri"]           ,CUNNING ,IS_EXOTIC },	-- WoLK - zancudo
	{BL["Chimaera"]        ,FEROCITY,IS_EXOTIC },	-- WoLK - Quimera
	{BL["Clefthoof"]       ,FEROCITY,IS_EXOTIC },	-- WoLK - Uñagrieta
	{BL["Core Hound"]      ,FEROCITY,IS_EXOTIC },	-- WoLK - Can del Núcleo
	{BL["Devilsaur"]       ,FEROCITY,IS_EXOTIC },	-- WoLK - Demonsaurio
	{BL["Moth"]            ,CUNNING ,NOT_EXOTIC},	-- WoLK
	{BL["Spirit Beast"]    ,TENACITY,IS_EXOTIC },	-- WoLK - Bestia espíritu
	{BL["Wasp"]            ,FEROCITY,NOT_EXOTIC},	-- WoLK
	{BL["Worm"]            ,TENACITY,IS_EXOTIC },	-- WoLK - Gusano
	-- Cataclysm
	{BL["Beetle"]          ,TENACITY,NOT_EXOTIC},	-- CATA
	{BL["Fox"]             ,CUNNING ,NOT_EXOTIC},	-- CATA
	{BL["Hound"]           ,CUNNING ,NOT_EXOTIC},	-- CATA
	{BL["Monkey"]          ,CUNNING ,NOT_EXOTIC},	-- CATA
	{BL["Shale Beast"]     ,CUNNING ,IS_EXOTIC },	-- CATA - Bestias de esquisto
	-- Mists of Pandaria
	{BL["Basilisk"]        ,CUNNING ,NOT_EXOTIC},	-- MISTS
	{BL["Direhorn"]        ,TENACITY,NOT_EXOTIC},	-- MISTS
	{BL["Gruffhorn"]       ,CUNNING ,NOT_EXOTIC},	-- MISTS
	{BL["Rodent"]          ,CUNNING ,NOT_EXOTIC},	-- MISTS
	{BL["Stone Hound"]     ,TENACITY,IS_EXOTIC },	-- MISTS - Sabuesos de piedra
	{BL["Water Strider"]   ,CUNNING ,IS_EXOTIC },	-- MISTS - Zancudo de agua
	{BL["Waterfowl"]       ,FEROCITY,NOT_EXOTIC},	-- MISTS - aves acuáticas
	-- Warlords of Draenor
	{BL["Hydra"]           ,TENACITY,NOT_EXOTIC},	-- WoD
	{BL["Riverbeast"]      ,TENACITY,NOT_EXOTIC},	-- WoD
	{BL["Stag"]            ,TENACITY,NOT_EXOTIC},	-- WoD
	-- Legion
	{BL["Feathermane"]     ,TENACITY,NOT_EXOTIC},	-- LEGION
	{BL["Mechanical"]      ,CUNNING ,NOT_EXOTIC},	-- LEGION
	{BL["Oxen"]            ,TENACITY,NOT_EXOTIC},	-- LEGION
	{BL["Scalehide"]       ,FEROCITY,NOT_EXOTIC},	-- LEGION
	-- Battle for Azeroth
	{BL["Blood Beast"]     ,TENACITY,NOT_EXOTIC},	-- BfA
	{BL["Carapid"]         ,TENACITY,IS_EXOTIC },	-- BfA -- caparazón
	{BL["Lizard"]          ,TENACITY,NOT_EXOTIC},	-- BfA
	{BL["Pterrordax"]      ,CUNNING ,IS_EXOTIC },	-- BfA - Pterrordáctilos
	{BL["Toad"]            ,TENACITY,NOT_EXOTIC},	-- BfA
	-- Shadowlands
	{BL["Camel"]           ,CUNNING ,NOT_EXOTIC},	-- SL
	{BL["Courser"]         ,FEROCITY,NOT_EXOTIC},	-- SL
	{BL["Mammoth"]         ,TENACITY,NOT_EXOTIC},	-- SL
	-- Dragonflight
	{BL["Lesser Dragonkin"],TENACITY,NOT_EXOTIC},	-- DF

--{"Unclassified"        ,"n"     ,NOT_EXOTIC}

}

local index = 0;
function GetPetTalentColor(talent, isExotic)
	--  Cunning, Ferocity, or Tenacity.
	if isExotic then
		talent = EXOTICPET
		--print("GetPetTalentColor; "..tostring(isExotic))
	end
	local clr = PetTalentColor[talent]
	if clr == nil then
		-- exotic pet??
		clr = UPetTalentColor[index]
		index = (index + 1) % 3;
	end
	return clr;
end

function GetPetIsExotic(family, talent)
	--print("GetPetIsExotic; "..family.."; "..talent)
	local petinfo = CaesarPets.families;
	local value = false
	for i = 1, #petinfo do
		local petfamily = petinfo[i][1];
		if (petfamily:lower() == family:lower()) then
			value = petinfo[i][3];
			if value then
				--print("GetPetIsExotic; "..family.."; "..talent.."; true")
			end
			break;
		end
	end
	return value;
end

function SetTexture(frame)
    
    if (frame.PETCLASS == "Cunning") then
        frame.Background:SetColorTexture(0.2, 0.58, 0, 0.5)
    elseif (frame.PETCLASS == "Ferocity") then
        frame.Background:SetColorTexture(0.64, 0, 0, 0.5)
    elseif (frame.PETCLASS == "Tenacity") then
        frame.Background:SetColorTexture(0.2, 0.43, 1, 0.5)
    end

end

--[[

	local creatureType = UnitCreatureType(unit)
	-- Rarity:Debug("Creature type: "..(creatureType or "nil").." (translation: "..(lbct[creatureType] or "nil")..")")

local tab = LibStub('SecureTabs-2.0'):Add(CollectionsJournal)

	tab:SetText(L["ADDON_NAME"])
	--tab.frame = self
	tab.OnSelect = function()
	end
	tab.OnDeselect = function()
	end
	self.Tab = tab
    
	--self:RegisterEvent("HEIRLOOMS_UPDATED");
	--self:RegisterEvent("HEIRLOOM_UPGRADE_TARGETING_CHANGED");

		GameTooltip:AddLine(L["EXOTIC"]);
		GameTooltip:AddTexture("Interface\\MINIMAP\\Minimap_shield_elite.blp");
		GameTooltip:AddLine(" ");

--]]
