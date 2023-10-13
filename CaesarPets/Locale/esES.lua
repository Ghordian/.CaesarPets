-- CaesarPets Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/CaesarPets/localization/�

--local debug = false
--[==[@debug@
debug = true
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("CaesarPets", "esES")
if not L then return end

L.GeneralSettings = "Opciones Generales"
L.GeneralDesc = "CaesarPets permite controlar varios aspectos de tu Maestro de Establos. Puedes cambiar el estilo de la ventana, y configurar diferentes perfiles para cada uno de tus personajes."
L.ScaleDesc = "Cambia el tamaño de la ventana para que se ajuste a tu gusto."
L.Scale = "Tamaño"
L.ScaleFrame = "Tamaña de la ventana."
L.HideFrameButton = "Ocultar botón de la ventana"
L.PreviewFrame = "Vista Previa"

L.TotalFmt = "Total: %d de %d\n"
L.Options = "Opciones..."

L.MinimapHint = "Clic-Izq. para %sMascotas\n"
			 .. "Clic-Der. para %sOpciones"

L.HideMinimapButton = "Hide minimap button"

L.PetsFound = "Encontradas: %d"
