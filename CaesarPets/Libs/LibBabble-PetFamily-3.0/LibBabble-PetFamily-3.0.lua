--[[
Name: LibBabble-PetFamily-3.0
Revision: $Rev: 1 $
Maintainers: 
Website: 
Dependencies: None
License: MIT
]]

local MAJOR_VERSION = "LibBabble-PetFamily-3.0"
local MINOR_VERSION = 90000 + tonumber(("$Rev: 1 $"):match("%d+"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local GAME_LOCALE = GetLocale()

lib:SetBaseTranslations {
	["Aqiri"] = "Aqiri",
	["Basilisk"] = "Basilisk",
	["Bat"] = "Bat",
	["Bear"] = "Bear",
	["Beetle"] = "Beetle",
	["Bird of Prey"] = "Bird of Prey",
	["Blood Beast"] = "Blood Beast",
	["Boar"] = "Boar",
	["Camel"] = "Camel",
	["Carapid"] = "Carapid",
	["Carrion Bird"] = "Carrion Bird",
	["Cat"] = "Cat",
	["Chimaera"] = "Chimaera",
	["Clefthoof"] = "Clefthoof",
	["Core Hound"] = "Core Hound",
	["Courser"] = "Courser",
	["Crab"] = "Crab",
	["Crocolisk"] = "Crocolisk",
	["Devilsaur"] = "Devilsaur",
	["Direhorn"] = "Direhorn",
	["Dragonhawk"] = "Dragonhawk",
	["Feathermane"] = "Feathermane",
	["Fox"] = "Fox",
	["Gorilla"] = "Gorilla",
	["Gruffhorn"] = "Gruffhorn",
	["Hound"] = "Hound",
	["Hydra"] = "Hydra",
	["Hyena"] = "Hyena",
	["Lesser Dragonkin"] = "Lesser Dragonkin",
	["Lizard"] = "Lizard",
	["Mammoth"] = "Mammoth",
	["Mechanical"] = "Mechanical",
	["Monkey"] = "Monkey",
	["Moth"] = "Moth",
	["Oxen"] = "Oxen",
	["Pterrordax"] = "Pterrordax",
	["Raptor"] = "Raptor",
	["Ravager"] = "Ravager",
	["Ray"] = "Ray",
	["Riverbeast"] = "Riverbeast",
	["Rodent"] = "Rodent",
	["Scalehide"] = "Scalehide",
	["Scorpid"] = "Scorpid",
	["Serpent"] = "Serpent",
	["Shale Beast"] = "Shale Beast",
	["Spider"] = "Spider",
	["Spirit Beast"] = "Spirit Beast",
	["Sporebat"] = "Sporebat",
	["Stag"] = "Stag",
	["Stone Hound"] = "Stone Hound",
	["Tallstrider"] = "Tallstrider",
	["Toad"] = "Toad",
	["Turtle"] = "Turtle",
	["Warp Stalker"] = "Warp Stalker",
	["Wasp"] = "Wasp",
	["Water Strider"] = "Water Strider",
	["Waterfowl"] = "Waterfowl",
	["Wind Serpent"] = "Wind Serpent",
	["Wolf"] = "Wolf",
	["Worm"] = "Worm",
}

if GAME_LOCALE == "enUS" then
	lib:SetCurrentTranslations(true)

elseif GAME_LOCALE == "esES" then
	lib:SetCurrentTranslations {
	["Aqiri"] = "Aqir",
	["Basilisk"] = "Basilisco",
	["Bat"] = "Murciélago",
	["Bear"] = "Oso",
	["Beetle"] = "Alfazaque",
	["Bird of Prey"] = "Ave rapaz",
	["Blood Beast"] = "Bestia de sangre",
	["Boar"] = "Jabal�",
	["Camel"] = "Camello",
	["Carapid"] = "Carápido",
	["Carrion Bird"] = "Carroñero",
	["Cat"] = "Felino",
	["Chimaera"] = "Quimera",
	["Clefthoof"] = "Uñagrieta",
	["Core Hound"] = "Can del Núcleo",
	["Courser"] = "Trotador",
	["Crab"] = "Cangrejo",
	["Crocolisk"] = "Crocolisco",
	["Devilsaur"] = "Demosaurio",
	["Direhorn"] = "Cuernoatroz",
	["Dragonhawk"] = "Dracohalcón",
	["Feathermane"] = "Cuellipluma",
	["Fox"] = "Zorro",
	["Gorilla"] = "Gorila",
	["Gruffhorn"] = "Broncocuerno",
	["Hound"] = "Can",
	["Hydra"] = "Hidra",
	["Hyena"] = "Hiena",
	["Lesser Dragonkin"] = "Dragonante inferior",
	["Lizard"] = "Lagarto",
	["Mammoth"] = "Mamut",
	["Mechanical"] = "Máquina",
	["Monkey"] = "Mono",
	["Moth"] = "Palomilla",
	["Oxen"] = "Buey",
	["Pterrordax"] = "Pterrordáctilo",
	["Raptor"] = "Raptor",
	["Ravager"] = "Devastador",
	["Ray"] = "Raya",
	["Riverbeast"] = "Bestia fluvial",
	["Rodent"] = "Roedor",
	["Scalehide"] = "Pielescama",
	["Scorpid"] = "Escórpido",
	["Serpent"] = "Serpiente",
	["Shale Beast"] = "Bestia de esquisto",
	["Spider"] = "Ara�a",
	["Spirit Beast"] = "Bestia espíritu",
	["Sporebat"] = "Esporiélago",
	["Stag"] = "Venado",
	["Stone Hound"] = "Can de piedra",
	["Tallstrider"] = "Zancaalta",
	["Toad"] = "Sapo",
	["Turtle"] = "Tortuga",
	["Warp Stalker"] = "Acechador deformado",
	["Wasp"] = "Avispa",
	["Water Strider"] = "Zancudo acuático",
	["Waterfowl"] = "Ave fluvial",
	["Wind Serpent"] = "Dragón alado",
	["Wolf"] = "Lobo",
	["Worm"] = "Gusano",
}
elseif GAME_LOCALE == "deDE" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "frFR" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "koKR" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "esMX" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "ptBR" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "itIT" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "ruRU" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "zhCN" then
	lib:SetCurrentTranslations {
}
elseif GAME_LOCALE == "zhTW" then
	lib:SetCurrentTranslations {
}
else
	error(("%s: Locale %q not supported"):format(MAJOR_VERSION, GAME_LOCALE))
end
