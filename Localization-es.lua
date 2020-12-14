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

if strsub(GetLocale(), 1, 2) ~= "es" then return end
local _, L = ...

local EM_ON = "|cffffff00"
local EM_OFF = "|r"
local RED_ON = "|cffff4000"
local RED_OFF = "|r"

L.TITLETEXT = "Lista de Badapples"
L.TAB_TOOLTIP = "Ver o modificar la lista de Badapples."

L.COLUMN_NAME = "Nombre"
L.COLUMN_REASON = "Rázon"
L.ADDED_BY_ON = "Añadido el %s por %s"
L.ADDED_BY = "Added por %s"
L.ADDED_ON = "Added el %s"

L.BUTTON_ADD = "Add"
L.BUTTON_ADD_TITLE = "Add Player"
L.BUTTON_ADD_TOOLTIP = "Adds a player to your Badapples list."
L.BUTTON_REMOVE = "Remove"
L.BUTTON_REMOVE_TITLE = "Remove Player"
L.BUTTON_REMOVE_TOOLTIP = "Removes the selected player from your Badapples list."
L.BUTTON_SETCOLOR = "Set Color"
L.BUTTON_SETCOLOR_TITLE = "Set Color"
L.BUTTON_SETCOLOR_TOOLTIP = "Change the color that is used to highlight Badapple players in chat, target, and tooltip."

L.TOTAL_EMPTY = "Badapples list is empty!"
L.TOTAL_SINGLE = "1 Badapple"
L.TOTAL_MULTIPLE = "%d Badapples"

L.BUTTON_ADD = "Añadir"
L.BUTTON_ADD_TITLE = "Añadir un jugador"
L.BUTTON_ADD_TOOLTIP = "Añadir un jugador a la lista de Badapples."
L.BUTTON_REMOVE = "Eliminar"
L.BUTTON_REMOVE_TITLE = "Eliminar un jugador"
L.BUTTON_REMOVE_TOOLTIP = "Eliminar el jugador seleccionado de la lista de Badapples."
L.BUTTON_SETCOLOR = "Color"
L.BUTTON_SETCOLOR_TITLE = "Cambiar el color"
L.BUTTON_SETCOLOR_TOOLTIP = "Cambiar el color utilizado para resaltar los nombres de los jugadores en la lista de los jugadores en la lista de Badapples."

L.COMMAND = "/bad"
L.COMMAND_HELP = "ayuda"
L.COMMAND_LIST = "lista"
L.COMMAND_SHOW = "mostra"
L.COMMAND_CHECK = "prueba"
L.COMMAND_STATUS = "estado"
L.COMMAND_ADD = "añade"
L.COMMAND_REMOVE = "quite"
L.COMMAND_REMOVEALL = "quitetodos"
L.COMMAND_COLOR = "color"
L.COMMAND_SETCOLOR = "cambiacolor"
L.COMMAND_REMOVEALL_CONFIRM = "confirma"
L.COMMAND_NOTAB = "nopestaña"
L.COMMAND_TOGGLETAB = "pestaña"
L.COMMAND_DEBUGON = "debugon"
L.COMMAND_DEBUGOFF = "debugoff"

L.ADD_CONFIRM = EM_ON.."Jugador "..EM_OFF.."%s"..EM_ON.." añadido a la lista de Badapples: "..EM_OFF.."%s"
L.UPDATE_CONFIRM = EM_ON.."Jugador "..EM_OFF.."%s"..EM_ON.." rázon actualizado: "..EM_OFF.."%s"
L.REMOVE_CONFIRM = EM_ON.."Jugador "..EM_OFF.."%s"..EM_ON.." eliminado de la lista de Badapples."..EM_OFF
L.REMOVE_NOTFOUND = EM_ON.."Jugador "..EM_OFF.."%s"..EM_ON.." no está en la lista de Badapples."..EM_OFF
L.PLAYERNAME_FAILED = EM_ON.."Debes introducir un nombre válido."..EM_OFF
L.PLAYERNAME_ISSELF = EM_ON.."¡No puedes añadir ti mismo a la lista!"..EM_OFF
L.LIST_FORMAT = "   %s"..EM_OFF..": %s"
L.STATUS_GOOD = EM_ON.."Jugador "..EM_OFF.."%s"..EM_ON.." NO ESTÁ en la lista de Badapples."
L.REMOVEALL_CONFIRM = EM_ON.."Todos jugadores eliminado de la lista de Badapples."..EM_OFF

L.PARTY_WARNING = "El miembro del grupo %s está en la lista de Badapples: %s"
L.PARTY_WARNING_NO_REASON = "El miembro del grupo %s está en la lista de Badapples."
L.PARTY_IGNORE_WARNING = "El miembro del grupo %s está en la lista de ignorados."
L.RAID_WARNING = "El miembro de la banda %s está en la lista de Badapples: %s"
L.RAID_WARNING_NO_REASON = "El miembro de la banda %s está en la lista de Badapples."
L.RAID_IGNORE_WARNING = "El miembro de la banda %s está en la lista de ignorados."
L.NOTIFY_BAD = "Jugador %s está en la lista de Badapples: %s"
L.NOTIFY_IGNORE = "Jugador %s está en la lista de ignorados."

L.NO_REASON = "(sin rázon)"
L.PARTY_INVITE_TEXT = "El jugador Badapple %s te ha invitado a un grupo."
L.PARTY_IGNORE_INVITE_TEXT = "El jugador ignorado %s te ha invitado a un grupo."
L.PARTY_INVITE_BUTTON = "Acceptar"
L.INVITE_TEXT = "%s está en la lista de Badapples. ¿Invitar anyway?"
L.INVITE_IGNORE_TEXT = "%s está en la lista de ignorados. ¿Invitar anyway?"
L.PLAYER_ADD_TEXT = "Introducir el nombre de un jugador para añadir a la lista:"
L.PLAYER_ADD_CONFIRM_TEXT = "¿Añadir %s a la lista de Badapples?"
L.PLAYER_REMOVE_CONFIRM_TEXT = "¿Eliminar %s de la lista de Badapples?"
L.REMOVEALL_CONFIRM_TEXT = "Todos los jugadores serán removidos de la lista de Badapples. ¿Estás seguro que deseas continuar?"
L.DISABLE_TAB = "Desactivado"
L.TOGGLE_TAB = "Alternar"
L.TAB_CONFIRM = EM_ON.."Badapples pestaña está %s"..EM_OFF

L.DEBUGON_CONFIRM = "Depuración de Badapples está activado."
L.DEBUGOFF_CONFIRM = "Depuración de Badapples está desactivado."

L.REMOVEALL_WARNING = RED_ON.."AVISO: Todos los jugadores serán removidos de la lista de Badapples."..RED_OFF.."\n"..EM_ON.."Usa "..EM_OFF.."/badapples "..L.COMMAND_REMOVEALL.." "..L.COMMAND_REMOVEALL_CONFIRM..EM_ON.." para continuar"..EM_OFF

L.DESCRIPTION = "Te permite añadir los nombres (con razones opcional) a una lista de \"manzanas malas\", o jugadores con los que deseas recordar a evitar."

L.HELP = {
	EM_ON..L.COMMAND.." "..L.COMMAND_HELP..EM_OFF.." para mostrar esta mensaje de ayuda",
	EM_ON..L.COMMAND.." "..L.COMMAND_LIST..EM_OFF.." para mostrar la lista de Badapples en la ventana de chat (puede ser largo)",
	EM_ON..L.COMMAND.." "..L.COMMAND_SHOW..EM_OFF.." para mostrar el marco de la lista de Badapples",
	EM_ON..L.COMMAND.." "..L.COMMAND_ADD.." <nombre> [rázon]"..EM_OFF.." para añadir un jugador y una rázon opcional",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVE.." <nombre>"..EM_OFF.." para eliminar un jugador",
	EM_ON..L.COMMAND.." "..L.COMMAND_CHECK.." <nombre>"..EM_OFF.." para probar el estado de un jugador",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVEALL..EM_OFF.." para eliminar todos jugadores",
	EM_ON..L.COMMAND.." "..L.COMMAND_COLOR..EM_OFF.." para establecer el color de resaltado de Badapples",
	EM_ON..L.COMMAND.." "..L.COMMAND_TOGGLETAB..EM_OFF.." para mover la pestaña de Badapples",
	EM_ON..L.COMMAND.." "..L.COMMAND_NOTAB..EM_OFF.." para desactivar la pestaña de Badapples",
	"",
	"También puedes utilizar "..EM_ON.."/badapples"..EM_OFF.." en lugar de "..EM_ON.."/bad"..EM_OFF.." para los comandos enumerados anteriormente.",
}