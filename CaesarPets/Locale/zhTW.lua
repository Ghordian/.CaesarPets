-- CaesarPets Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/CaesarPets/localization/

local debug = false
--[==[@debug@
debug = true
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("CaesarPets", "zhTW")
if not L then return end

L.GeneralSettings = "一般選項"
L.GeneralDesc = "CaesarPets 使你可以調整獸欄框體，更改外觀，並為每個角色創建單獨的設定檔。"
L.ScaleDesc = "調整框體的縮放比例。"
L.Scale = "縮放"
L.ScaleFrame = "調整框體大小。"
L.HideFrameButton = "隱藏設定按鈕"
L.PreviewFrame = "預覽"

L.TotalFmt = "總共：%d out of %d\n"
L.Options = "選項..."

L.MinimapHint = "右鍵打開獸欄\n"
			 .. "左鍵打開設定"

L.HideMinimapButton = "隱藏小地圖按鈕"

L.PetsFound = "找到：%d"
