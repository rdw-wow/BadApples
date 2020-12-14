------------------------------------------------------------------------------
-- Badapples
-- 
-- The file of the Russian language for add-on Badapples.
-- File version 1.0
-- Translated Вулстан - Король-Лич RU
------------------------------------------------------------------------------

if GetLocale() ~= "ruRU" then return end
local _, L = ...

local EM_ON = "|cffffff00"
local EM_OFF = "|r"
local RED_ON = "|cffff4000"
local RED_OFF = "|r"

L.TITLETEXT = "Cписок Badapples"
L.TAB_TOOLTIP = "Der Badapples-Liste anzeigen oder ändern."

L.COLUMN_NAME = "Имя"
L.COLUMN_REASON = "Причина"
L.ADDED_BY_ON = "Добавил %s на %s"
L.ADDED_BY = "Добавил %s"
L.ADDED_ON = "Добавлен: %s"

L.BUTTON_ADD = "Добавить"
L.BUTTON_ADD_TITLE = "Добавить игрока"
L.BUTTON_ADD_TOOLTIP = "Добавляет игрока в ваш список Badapples."
L.BUTTON_REMOVE = "Удалить"
L.BUTTON_REMOVE_TITLE = "Удалить игрока"
L.BUTTON_REMOVE_TOOLTIP = "Удаляет выбранного игрока из вашего списока Badapples."
L.BUTTON_SETCOLOR = "Изменить цвет"
L.BUTTON_SETCOLOR_TITLE = "Установить цвет"
L.BUTTON_SETCOLOR_TOOLTIP = "Изменить цвет, который используется для выделения игроков списка Badapple в чате и подсказке."

L.TOTAL_EMPTY = "Список Badapples пуст!"
L.TOTAL_SINGLE = "1 Badapple"
L.TOTAL_MULTIPLE = "%d Badapples"

L.COMMAND = "/bad"
L.COMMAND_HELP = "help"
L.COMMAND_LIST = "list"
L.COMMAND_SHOW = "show"
L.COMMAND_CHECK = "check"
L.COMMAND_STATUS = "status"
L.COMMAND_ADD = "add"
L.COMMAND_REMOVE = "remove"
L.COMMAND_REMOVEALL = "removeall"
L.COMMAND_COLOR = "color"
L.COMMAND_SETCOLOR = "setcolor"
L.COMMAND_REMOVEALL_CONFIRM = "confirm"
L.COMMAND_NOTAB = "notab"
L.COMMAND_TOGGLETAB = "toggletab"
L.COMMAND_DEBUGON = "debugon"
L.COMMAND_DEBUGOFF = "debugoff"

L.ADD_CONFIRM = EM_ON.."Игрок "..EM_OFF.."%s"..EM_ON.." добавлен в список Badapples: "..EM_OFF.."%s"
L.UPDATE_CONFIRM = EM_ON.."Игрок "..EM_OFF.."%s"..EM_ON.." причина обновлена: "..EM_OFF.."%s"
L.REMOVE_CONFIRM = EM_ON.."Игрок "..EM_OFF.."%s"..EM_ON.." удален из списка Badapples."..EM_OFF
L.REMOVE_NOTFOUND = EM_ON.."Игрок "..EM_OFF.."%s"..EM_ON.." не в списке Badapples."..EM_OFF
L.PLAYERNAME_FAILED = EM_ON.."Вы должны предоставить действительные имя игрока."..EM_OFF
L.PLAYERNAME_ISSELF = EM_ON.."Вы не можете добавить себя в список Badapples!"..EM_OFF
L.LIST_FORMAT = "   %s"..EM_OFF..": %s"
L.STATUS_GOOD = EM_ON.."Игрок "..EM_OFF.."%s"..EM_ON.."не в вашем списке Badapples."
L.REMOVEALL_CONFIRM = EM_ON.."Все игроки удалены из списка Badapples."..EM_OFF

L.PARTY_WARNING = "Член группы %s находится на вашем списке Badapples: %s"
L.PARTY_WARNING_NO_REASON = "Член группы %s находится на вашем списке Badapples."
L.PARTY_IGNORE_WARNING = "Член группы %s в списке игнирируемых."
L.RAID_WARNING = "Член рейда %s находится на вашем списке Badapples: %s"
L.RAID_WARNING_NO_REASON = "Член рейда %s находится на вашем списке Badapples."
L.RAID_IGNORE_WARNING = "Член рейда %s в списке игнирируемых."
L.NOTIFY_BAD = "Игрок %s находится на вашем списке Badapples: %s"
L.NOTIFY_IGNORE = "Игрок %s в списке игнирируемых."

L.NO_REASON = "(нет причины)"
L.PARTY_INVITE_TEXT = "Badapple игрок %s приглашает Вас в группу."
L.PARTY_IGNORE_INVITE_TEXT = "Игнорируемый игрок %s приглашает Вас в группу."
L.PARTY_INVITE_BUTTON = "Всеравно принять"
L.INVITE_TEXT = "%s в вашем списке Badapple, всервно пригласить?"
L.INVITE_IGNORE_TEXT = "%s в вашем списке игнорируемых, всервно пригласить?"
L.PLAYER_ADD_TEXT = "Введите имя игрока, чтобы добавить в ваш список:"
L.PLAYER_ADD_CONFIRM_TEXT = "Добавить %s в ваш список Badapple?"
L.PLAYER_REMOVE_CONFIRM_TEXT = "Удалить %s из вашего списока Badapple?"
L.REMOVEALL_CONFIRM_TEXT = "Это действие удалит все записи из вашего списока Badapples, Вы уверены, что хотите продолжить?"
L.DISABLE_TAB = "включено"
L.TOGGLE_TAB = "выключено"
L.TAB_CONFIRM = EM_ON.."Badapples во вкладке общение теперь %s"..EM_OFF

L.DEBUGON_CONFIRM = "Badapples отладка включена."
L.DEBUGOFF_CONFIRM = "Badapples отладка выключена."

L.REMOVEALL_WARNING = RED_ON.."Предупреждение: это приведет к удалению всех записей из Badapples"..RED_OFF.."\n"..EM_ON.."использовать "..EM_OFF.."/badapples "..L.COMMAND_REMOVEALL.." "..L.COMMAND_REMOVEALL_CONFIRM..EM_ON.." для продолжения."..EM_OFF

L.DESCRIPTION = "Позволяет добавлять имена игроков (причина необязательна) в список \"badapples\", или игроков, о которых напомнить, чтобы избежать групп с ними."

L.HELP = {
	EM_ON..L.COMMAND.." "..L.COMMAND_HELP..EM_OFF.." показывает справку",
	EM_ON..L.COMMAND.." "..L.COMMAND_LIST..EM_OFF.." показывает текущий список в окне чата (может занять много времени)",
	EM_ON..L.COMMAND.." "..L.COMMAND_SHOW..EM_OFF.." показывает список Badapples в окне общения",
	EM_ON..L.COMMAND.." "..L.COMMAND_ADD.." <Имя игрока> [причина]"..EM_OFF.." добавляет игрока и при необходимости, причину",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVE.." <Имя игрока>"..EM_OFF.." удаляет игока",
	EM_ON..L.COMMAND.." "..L.COMMAND_CHECK.." <Имя игрока>"..EM_OFF.." проверяет статус игрока",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVEALL..EM_OFF.." удаляет всех игроков",
	EM_ON..L.COMMAND.." "..L.COMMAND_COLOR..EM_OFF.." позволяет установить цвет выделения Badapples",
	EM_ON..L.COMMAND.." "..L.COMMAND_TOGGLETAB..EM_OFF.." показать колонку Badapples в окне общения",
	EM_ON..L.COMMAND.." "..L.COMMAND_NOTAB..EM_OFF.." скрыть колонку Badapples в окне общения",
	"",
	"Вы можете также использовать "..EM_ON.."/badapples"..EM_OFF.." вместо "..EM_ON.."/bad"..EM_OFF.." с вышеперечисленными коммандами.",
	"",
	"Перевод на Русский язык: Вулстан - Король-Лич.",
}