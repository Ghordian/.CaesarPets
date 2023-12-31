--[[
Copyright (c) 2009-2018, Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >
All rights reserved.

Initial implementation provided by yssaril
]]

local CaesarPets = LibStub("AceAddon-3.0"):GetAddon("CaesarPets")

local MODNAME = "Scale"
local Scale = CaesarPets:NewModule(MODNAME)

local LibWindow = LibStub("LibWindow-1.1")

local scaler, mousetracker
local SOS = { --Scaler Original State
	dist = 0,
	x = 0,
	y = 0,
	left = 0,
	top = 0,
	scale = 1,
}

local GetScaleDistance, OnUpdate

function Scale:OnInitialize()
	self:SetEnabledState(CaesarPets:GetModuleEnabled(MODNAME))
end

function Scale:OnEnable()
	if not scaler then
		scaler = CreateFrame("Frame", "CaesarPetsScaler", PetStableFrame)
		scaler:SetWidth(15)
		scaler:SetHeight(15)
--		scaler:SetFrameStrata((PetStableFrame.BorderFrame.NineSlice or PetStableFrame):GetFrameStrata())
--		scaler:SetFrameLevel((PetStableFrame.BorderFrame.NineSlice or PetStableFrame):GetFrameLevel() + 15)
		scaler:SetFrameStrata((PetStableFrame.NineSlice or PetStableFrame):GetFrameStrata())
		scaler:SetFrameLevel((PetStableFrame.NineSlice or PetStableFrame):GetFrameLevel() + 15)
		scaler.tex = scaler:CreateTexture(nil, "OVERLAY")
		scaler.tex:SetAllPoints(scaler)
		scaler.tex:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
		scaler.tex:SetTexCoord(0.619, 0.760, 0.612, 0.762)
		scaler.tex:SetDesaturated(true)

		if PetStableFrame.NineSlice then
			scaler:SetPoint("BOTTOMRIGHT", PetStableFrame, "BOTTOMRIGHT", 0, 0)
		else
			scaler:SetPoint("BOTTOMRIGHT", PetStableFrame, "BOTTOMRIGHT", 0, -2)
		end

		mousetracker = CreateFrame("Frame", nil, PetStableFrame)
		mousetracker:SetFrameStrata(scaler:GetFrameStrata())
		mousetracker:SetFrameLevel(scaler:GetFrameLevel() + 5)
		mousetracker:SetAllPoints(scaler)
		mousetracker:EnableMouse(true)
		mousetracker:SetScript("OnEnter", function()
			scaler.tex:SetDesaturated(false)
		end)
		mousetracker:SetScript("OnLeave", function()
			scaler.tex:SetDesaturated(true)
		end)
		mousetracker:SetScript("OnMouseUp", function(t)
			LibWindow.SavePosition(PetStableFrame)
			t:SetScript("OnUpdate", nil)
			t:SetAllPoints(scaler)
			CaesarPets.db.profile.scale = PetStableFrame:GetScale()
			CaesarPets:SetScale(true)
		end)
		mousetracker:SetScript("OnMouseDown",function(t)
			SOS.left, SOS.top = PetStableFrame:GetLeft(), PetStableFrame:GetTop()
			SOS.scale = PetStableFrame:GetScale()
			SOS.x, SOS.y = SOS.left, SOS.top-(UIParent:GetHeight()/SOS.scale)
			SOS.EFscale = PetStableFrame:GetEffectiveScale()
			SOS.dist = GetScaleDistance()
			t:SetScript("OnUpdate", OnUpdate)
			t:SetAllPoints(UIParent)
		end)
		tinsert(CaesarPets.elementsToHide, scaler)
	end
	scaler:Show()
	mousetracker:Show()
end

function Scale:OnDisable()
	if scaler then
		scaler:Hide()
		mousetracker:Hide()
	end
end

function GetScaleDistance() -- distance from cursor to TopLeft :)
	local left, top = SOS.left, SOS.top
	local scale = SOS.EFscale

	local x, y = GetCursorPosition()
	x = x/scale - left
	y = top - y/scale

	return sqrt(x*x+y*y)
end

function OnUpdate(self)
	local scale = GetScaleDistance()/SOS.dist*SOS.scale
	if scale < .2 then -- clamp min and max scale
		scale = .2
	elseif scale > 2 then
		scale = 2
	end
	PetStableFrame:SetScale(scale)

	local s = SOS.scale/PetStableFrame:GetScale()
	local x = SOS.x*s
	local y = SOS.y*s
	PetStableFrame:ClearAllPoints()
	PetStableFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
end
