-- CaesarPets Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/CaesarPets/localization/

local debug = false
--[==[@debug@
debug = true
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("CaesarPets", "enUS", true, debug)
if not L then return end

L.GeneralSettings = "General Settings"
L.GeneralDesc = "CaesarPets allows you to control various aspects of your Stable Master frame. You can change the style of the frame, and configure different profiles for every of your characters."
L.ScaleDesc = "Change the scale of the Stable Master frame to adjust it as you like."
L.Scale = "Scale"
L.ScaleFrame = "Scale of the frame."
L.HideFrameButton = "Hide Frame Button"
L.PreviewFrame = "Preview"

L.TotalFmt = "Total: %d out of %d\n"
L.Options = "Options..."

L.MinimapHint = "Left-click to open Stable\n"
			 .. "Right-click to open Options"

L.HideMinimapButton = "Hide minimap button"
L.PreviewPetStable = "Preview Pet Stable"

L.PetsFound = "Found: %d"

L.ShowPetTalentColorized = "Show Pet Talent colorized";
L.TalentBorder = "Show Color Border";
L.ThicknessBorder = "Border thickness";
L.ThicknessBorderDesc = "Border thickness";

-- specs

L["Tenacity"] = true;
L["Cunning"]  =  true;
L["Ferocity"] = true;
L["Exotic"]   = true;

--[[

*deDE*
L["Tenacity"] = "Hartnäckigkeit";
L["Cunning"]  =  "Gerissenheit";
L["Ferocity"] = "Wildheit";

*frFR*
L["Tenacity"] = "Ténacité";
L["Cunning"]  =  "Ruse";
L["Ferocity"] = "Férocité";

--]]
