--[[
]]

local CaesarPets = LibStub("AceAddon-3.0"):GetAddon("CaesarPets")
local L = LibStub("AceLocale-3.0"):GetLocale("CaesarPets")

local WoWRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
local WoWClassic = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE)

local optGetter, optSetter
do
	function optGetter(info)
		local key = info[#info]
		return CaesarPets.db.profile[key]
	end

	function optSetter(info, value)
		local key = info[#info]
		CaesarPets.db.profile[key] = value
		CaesarPets:Refresh()
	end
end

local options, moduleOptions = nil, {}
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = "CaesarPets",
			args = {
				general = {
					order = 1,
					type = "group",
					name = L.GeneralSettings,
					get = optGetter,
					set = optSetter,
					args = {
						intro = {
							order = 1,
							type = "description",
							name = L.GeneralDesc,
						},
						scaledesc = {
							order = 2,
							type = "description",
							name = L.ScaleDesc,
						},
						scale = {
							order = 3,
							name = L.Scale,
							desc = L.ScaleDesc,
							type = "range",
							min = 0.1, max = 2, bigStep = 0.01,
							isPercent = true,
						},
						nl_scale = {
							order = 4,
							type = "description",
							name = "",
							hidden = not WoWRetail,
						},
						nl2 = {
							order = 5,
							type = "description",
							name = "",
						},
						hideFrameButton = {
							order = 6,
							type = "toggle",
							name = L.HideFrameButton,
							width = "double",
						},
						nl3 = {
							order = 7,
							type = "description",
							name = "",
							width = "double",
						},
						previewFrame = {
							order = 8,
							type = "execute",
							name = L.PreviewFrame,
							func = function()
								PetStableFrame:Show()
							end,
						},
						hideMinimap = {
							order = 9,
							type = "toggle",
							name = L.HideMinimapButton,
							width = "double",
							get = function(info) return CaesarPets.db.profile.minimap.hide; end,
							set = function(info, v) 
								CaesarPets.db.profile.minimap.hide = v; 
								CaesarPets:Refresh();
							end,
						},
						nl4 = {
							order = 10,
							type = "description",
							name = "",
							width = "double",
						},
					},
				},
			},
		}
		for k,v in pairs(moduleOptions) do
			options.args[k] = (type(v) == "function") and v() or v
		end
	end

	return options
end

local function optFunc()
	-- open the profiles tab before, so the menu expands
	InterfaceOptionsFrame_OpenToCategory(CaesarPets.optionsFrames.Profiles)
	InterfaceOptionsFrame_OpenToCategory(CaesarPets.optionsFrames.CaesarPets)
	if InterfaceOptionsFrame then
		InterfaceOptionsFrame:Raise()
	end
end

function CaesarPets:SetupOptions()
	self.optionsFrames = {}

	-- setup options table
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("CaesarPets", getOptions)
	self.optionsFrames.CaesarPets = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CaesarPets", nil, nil, "general")

	self:RegisterModuleOptions("Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), "Profiles")

	LibStub("AceConsole-3.0"):RegisterChatCommand( "CaesarPets", optFunc)
end

function CaesarPets:RegisterModuleOptions(name, optionTbl, displayName)
	moduleOptions[name] = optionTbl
	self.optionsFrames[name] = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("CaesarPets", displayName, "CaesarPets", name)
end

function CaesarPets:SetupFrameButton()
	print("SetupFrameButton")
	-- create button on the frame to toggle the options
	self.optionsButton = CreateFrame("Button", "StableOptionsButton", PetStableFrame.TitleContainer or PetStableFrame, "UIPanelButtonTemplate")
	self.optionsButton:SetWidth(95)
	self.optionsButton:SetHeight(18)
	self.optionsButton:SetText(L.Options)
	self.optionsButton:ClearAllPoints()
	-- UIPanelCloseButton
	if WoWClassic then
		self.optionsButton:SetParent(PetStableFrame)
		self.optionsButton:SetPoint("LEFT", PetStableFrameCloseButton, "RIGHT", 5, 0)
		self.optionsButton:SetWidth(110)
		self.optionsButton:SetHeight(22)
	else
		self.optionsButton:SetPoint("TOPRIGHT", PetStableFrame.TitleContainer, "TOPRIGHT", -20, -1)
	end

	if self.db.profile.hideFrameButton then
		self.optionsButton:Hide()
	else
		self.optionsButton:Show()
	end

	self.optionsButton:SetScript("OnClick", optFunc)
end

local function optExpandFunc()
	--print("optExpandFunc")
	CaesarPets:ToggleExpandFrame()
end

-- WorldMapFrame.SidePanelToggle.CloseButton
-- WorldMapFrame.SidePanelToggle.OpenButton
	-- [ ] QuestMapFrame
		-- [ ] DetailsFrame

function  CaesarPets:SetupExpandButton()
	--print("SetupExpandButton")
	-- create button on the frame to expand/collapse
	self.expandButton = CreateFrame("Button", "StableExpandButton", PetStableFrame.TitleContainer or PetStableFrame, "UIPanelButtonTemplate")
	self.expandButton:SetWidth(22)
	self.expandButton:SetHeight(18)
	self.expandButton:SetText(">>")
	self.expandButton:ClearAllPoints()
	-- UIPanelCloseButton
	if WoWClassic then
		self.expandButton:SetParent(PetStableFrame)
		self.expandButton:SetPoint("LEFT", PetStableFrameCloseButton, "RIGHT", 5, 0)
		self.expandButton:SetWidth(22)
		self.expandButton:SetHeight(22)
	else
		self.expandButton:SetPoint("TOPRIGHT", PetStableFrame.TitleContainer, "TOPRIGHT", -1, -1)
	end

	self.expandButton:Show()

	self.expandButton:SetScript("OnClick", optExpandFunc)
end
