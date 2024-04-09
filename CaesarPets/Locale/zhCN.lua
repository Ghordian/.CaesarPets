-- CaesarPets Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/CaesarPets/localization/

--local debug = false
--[==[@debug@
debug = true
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("CaesarPets", "zhCN")
if not L then return end

L.GeneralSettings = "常规选项"
L.GeneralDesc = "CaesarPets 使你可以调整兽栏框体，更改外观，并为每个角色创建单独的配置。"
L.ScaleDesc = "调整框体的缩放比例。"
L.Scale = "缩放"
L.ScaleFrame = "调整框体大小。"
L.HideFrameButton = "隐藏设置按钮"
L.PreviewFrame = "预览"

L.TotalFmt = "总共：%d out of %d\n"
L.Options = "选项..."

L.MinimapHint = "右键打开兽栏\n"
             .. "左键打开设置"

L.HideMinimapButton = "隐藏小地图按钮"

L.PetsFound = "找到：%d"

L.PreviewPetStable = "Preview Pet Stable"

L.ShowPetTalentColorized = "Show Pet Talent colorized"
L.TalentBorder = "Show Color Border"
L.ThicknessBorder = "Border thickness"
L.ThicknessBorderDesc = "Border thickness"

-- specs

L["Tenacity"] = true
L["Cunning"]  =  true
L["Ferocity"] = true
L["Exotic"]   = true
