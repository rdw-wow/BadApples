------------------------------------------------------------------------------
-- Badapples
--
-- Stores the name (and optional description) about players you've encountered
-- or been told about that you want to make sure to remember so as to avoid
-- ever grouping with them (or otherwise).
--
-- Written by Cirk of DoomHammer, April 2005
-- Last updated October 2008
-- Updated by Phanx
------------------------------------------------------------------------------

if GetLocale() ~= "deDE" then return end
local _, L = ...

local EM_ON = "|cffffff00"
local EM_OFF = "|r"
local RED_ON = "|cffff4000"
local RED_OFF = "|r"

L.TITLETEXT = "Badapples-Liste"
L.TAB_TOOLTIP = "Der Badapples-Liste anzeigen oder ändern."

L.COLUMN_NAME = "Name"
L.COLUMN_REASON = "Grund"
L.ADDED_BY_ON = "Hinzugefügt am %2$s von %1$s"
L.ADDED_BY = "Hinzugefügt von %s"
L.ADDED_ON = "Hinzugefügt am %s"

L.BUTTON_ADD = "Hinzufügen"
L.BUTTON_ADD_TITLE = "Spieler hinzufügen"
L.BUTTON_ADD_TOOLTIP = "Einen Spieler auf der Badapples-Liste hinzufügen."
L.BUTTON_REMOVE = "Entfernen"
L.BUTTON_REMOVE_TITLE = "Spieler entfernen"
L.BUTTON_REMOVE_TOOLTIP = "Den ausgewählte Spieiler von der Badapples-Liste entfernen."
L.BUTTON_SETCOLOR = "Farbe"
L.BUTTON_SETCOLOR_TITLE = "Farbe festlegen"
L.BUTTON_SETCOLOR_TOOLTIP = "Die Farbe festlegen, die verwendet wird, um die Namen der Spieler auf der Badapples-Liste zu hervorheben."

L.TOTAL_EMPTY = "Badapples-Liste ist leer!"
L.TOTAL_SINGLE = "1 Badapple"
L.TOTAL_MULTIPLE = "%d Badapples"

L.COMMAND = "/bad"
L.COMMAND_HELP = "hilfe"
L.COMMAND_LIST = "auflisten"
L.COMMAND_SHOW = "anziegen"
L.COMMAND_CHECK = "prüfen"
L.COMMAND_STATUS = "status"
L.COMMAND_ADD = "hinzufügen"
L.COMMAND_REMOVE = "entfernen"
L.COMMAND_REMOVEALL = "entfernenalle"
L.COMMAND_COLOR = "farbe"
L.COMMAND_SETCOLOR = "farbelegen"
L.COMMAND_REMOVEALL_CONFIRM = "bestätigen"
L.COMMAND_NOTAB = "keintab"
L.COMMAND_TOGGLETAB = "tab"
L.COMMAND_DEBUGON = "debugon"
L.COMMAND_DEBUGOFF = "debugoff"

L.ADD_CONFIRM = EM_ON.."Der Spieler "..EM_OFF.."%s"..EM_ON.." auf der Badapples-Liste hinzugefügt: "..EM_OFF.."%s"
L.UPDATE_CONFIRM = EM_ON.."Der Grund des Spieler "..EM_OFF.."%s"..EM_ON.." aktualisiert: "..EM_OFF.."%s"
L.REMOVE_CONFIRM = EM_ON.."Der Spieler "..EM_OFF.."%s"..EM_ON.." von der Badapples-Liste entfernt."..EM_OFF
L.REMOVE_NOTFOUND = EM_ON.."Der Spieler "..EM_OFF.."%s"..EM_ON.." ist nicht auf der Badapples-Liste."..EM_OFF
L.PLAYERNAME_FAILED = EM_ON.."Man muss einen gültigen Namen eingeben."..EM_OFF
L.PLAYERNAME_ISSELF = EM_ON.."Man kann sich nicht selbst auf der Badapples-Liste hinzuzufügen!"..EM_OFF
L.LIST_FORMAT = "   %s"..EM_OFF..": %s"
L.STATUS_GOOD = EM_ON.."Der Spieler "..EM_OFF.."%s"..EM_ON.." ist NICHT auf der Badapples-Liste."
L.REMOVEALL_CONFIRM = EM_ON.."Alle Spieler von der Badapples-Liste entfernt."..EM_OFF

L.PARTY_WARNING = "Gruppenmitglied %s ist auf der Badapples-Liste: %s"
L.PARTY_WARNING_NO_REASON = "Gruppenmitglied %s ist auf der Badapples-Liste."
L.PARTY_IGNORE_WARNING = "Gruppenmitglied %s wird ignoriert."
L.RAID_WARNING = "Schlachtzugsmitglied %s ist auf der Badapples-Liste: %s"
L.RAID_WARNING_NO_REASON = "Schlachtzugsmitglied %s ist auf der Badapples-Liste."
L.RAID_IGNORE_WARNING = "Schlachtzugsmitglied %s wird ignoriert."
L.NOTIFY_BAD = "Der Spieler %s ist auf der Badapples-Liste: %s"
L.NOTIFY_IGNORE = "Der Spieler %s wird ignoriert."

L.NO_REASON = "(keinen Grund)"
L.PARTY_INVITE_TEXT = "Badapple %s hat Euch in eine Gruppe eingeladen."
L.PARTY_IGNORE_INVITE_TEXT = "Der ignorierte Spieler %s hat Euch in eine Gruppe eingeladen."
L.PARTY_INVITE_BUTTON = "Dennoch akzeptieren"
L.INVITE_TEXT = "%s ist auf der Badapples-Liste. Dennoch einladen?"
L.INVITE_IGNORE_TEXT = "%s wird ignoriert. Dennoch einladen?"
L.PLAYER_ADD_TEXT = "Den Namen eines Spielers eingeben, um auf der Badapples-Liste hinzuzufügen:"
L.PLAYER_ADD_CONFIRM_TEXT = "%s auf der Badapples-Liste hinzufügen?"
L.PLAYER_REMOVE_CONFIRM_TEXT = "%s von der Badapples-Liste entfernen?"
L.REMOVEALL_CONFIRM_TEXT = "Das werden alle Spieler von der Badapples-Liste zu entfernen. Fortfahren?"
L.DISABLE_TAB = "Deaktivieren"
L.TOGGLE_TAB = "Tab ein/aus"
L.TAB_CONFIRM = EM_ON.."Badapples-Tab ist %s"..EM_OFF

L.DEBUGON_CONFIRM = "Badapples-Fehlerbeseitigung aktiviert."
L.DEBUGOFF_CONFIRM = "Badapples-Fehlerbeseitigung deaktiviert."

L.REMOVEALL_WARNING = RED_ON.."ACHTUNG: Alle Spieler werden von der Badapples-Liste entfernt."..RED_OFF.."\n"..EM_ON.."Gib "..EM_OFF.."/badapples "..L.COMMAND_REMOVEALL.." "..L.COMMAND_REMOVEALL_CONFIRM..EM_ON.." ein, zu fortfahren."..EM_OFF

L.DESCRIPTION = "Ermöglichen, eine Liste der Namen der Spieler halten, die man lieber nicht mit zu spielen."

L.HELP = {
	EM_ON..L.COMMAND.." "..L.COMMAND_HELP..EM_OFF.." um eine Hilfe-Meldung anziegen",
	EM_ON..L.COMMAND.." "..L.COMMAND_LIST..EM_OFF.." um die Badapples-Liste im Fenster anzeigen (kann lang sein)",
	EM_ON..L.COMMAND.." "..L.COMMAND_SHOW..EM_OFF.." um den Badapples-Fenster anzeigen",
	EM_ON..L.COMMAND.." "..L.COMMAND_ADD.." <Spielername> [Grund]"..EM_OFF.." um einen Namen bei optionalen Grund hinzufügen",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVE.." <Spielername>"..EM_OFF.." um einen Namen entfernen",
	EM_ON..L.COMMAND.." "..L.COMMAND_CHECK.." <Spielername>"..EM_OFF.." um den Status eines Names überprüfen",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVEALL..EM_OFF.." um alle Spieler entfernen",
	EM_ON..L.COMMAND.." "..L.COMMAND_COLOR..EM_OFF.." um die Hervorhebungsfarbe festlegen",
	EM_ON..L.COMMAND.." "..L.COMMAND_TOGGLETAB..EM_OFF.." um die Platzierung des Tab umschalten",
	EM_ON..L.COMMAND.." "..L.COMMAND_NOTAB..EM_OFF.." um den Tab deaktivieren",
	"",
	"Man kann auch "..EM_ON.."/badapples"..EM_OFF.." statt "..EM_ON.."/bad"..EM_OFF.." eingeben, mit diesen Befehlen.",
}