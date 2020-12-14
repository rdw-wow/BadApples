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

local _, L = ...

local EM_ON = "|cffffff00"
local EM_OFF = "|r"
local RED_ON = "|cffff4000"
local RED_OFF = "|r"
local BAD_ON = "|cffff991a"					-- Will be overridden on load
local BAD_OFF = "|r"

L.TITLETEXT = "Badapples List"
L.TAB_TOOLTIP = "View or modify your Badapples list"

L.TAB_LONGNAME = "Badapples"
L.TAB_SHORTNAME = "Bad"

L.COLUMN_NAME = "Name"
L.COLUMN_REASON = "Reason"
L.ADDED_BY_ON = "Added by %s on %s"
L.ADDED_BY = "Added by %s"
L.ADDED_ON = "Added on %s"

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

L.ADD_CONFIRM = EM_ON.."Player "..EM_OFF.."%s"..EM_ON.." added to Badapples list: "..EM_OFF.."%s"
L.UPDATE_CONFIRM = EM_ON.."Player "..EM_OFF.."%s"..EM_ON.." reason updated: "..EM_OFF.."%s"
L.REMOVE_CONFIRM = EM_ON.."Player "..EM_OFF.."%s"..EM_ON.." removed from Badapples list"..EM_OFF
L.REMOVE_NOTFOUND = EM_ON.."Player "..EM_OFF.."%s"..EM_ON.." not in Badapples list"..EM_OFF
L.PLAYERNAME_FAILED = EM_ON.."You must provide a valid player name"..EM_OFF
L.PLAYERNAME_ISSELF = EM_ON.."You can't add yourself to the Badapples list!"..EM_OFF
L.LIST_FORMAT = "   %s"..EM_OFF..": %s"
L.STATUS_GOOD = EM_ON.."Player "..EM_OFF.."%s"..EM_ON.." is NOT on your Badapples list"
L.REMOVEALL_CONFIRM = EM_ON.."All players removed from Badapples list"..EM_OFF

L.PARTY_WARNING = "Party member %s is on your Badapples list: %s"
L.PARTY_WARNING_NO_REASON = "Party member %s is on your Badapples list"
L.PARTY_IGNORE_WARNING = "Party member %s is on your Ignore list"
L.RAID_WARNING = "Raid member %s is on your Badapples list: %s"
L.RAID_WARNING_NO_REASON = "Raid member %s is on your Badapples list"
L.RAID_IGNORE_WARNING = "Raid member %s is on your Ignore list"
L.NOTIFY_BAD = "Player %s is on your Badapples list: %s"
L.NOTIFY_IGNORE = "Player %s is on your Ignore list"

L.NO_REASON = "(no reason)"
L.PARTY_INVITE_TEXT = "Badapple player %s invites you to a group."
L.PARTY_IGNORE_INVITE_TEXT = "Ignored player %s invites you to a group."
L.PARTY_INVITE_BUTTON = "Accept anyway"
L.INVITE_TEXT = "%s is on your Badapples list, invite anyway?"
L.INVITE_IGNORE_TEXT = "%s is on your Ignore list, invite anyway?"
L.PLAYER_ADD_TEXT = "Enter name of player to add to your list:"
L.PLAYER_ADD_CONFIRM_TEXT = "Add %s to your Badapples list?"
L.PLAYER_REMOVE_CONFIRM_TEXT = "Remove %s from your Badapples list?"
L.REMOVEALL_CONFIRM_TEXT = "This will remove all entries from your Badapples list, are you sure you want to proceed?"
L.TOGGLE_TAB = "Toggle"
L.DISABLE_TAB = "Disabled"
L.TAB_CONFIRM = EM_ON.."Badapples social tab is now %s"..EM_OFF

L.DEBUGON_CONFIRM = "Badapples debug is enabled"
L.DEBUGOFF_CONFIRM = "Badapples debug is disabled"

L.REMOVEALL_WARNING = RED_ON.."WARNING: This will remove all entries from Badapples"..RED_OFF.."\n"..EM_ON.."Use "..EM_OFF.."/badapples "..L.COMMAND_REMOVEALL.." "..L.COMMAND_REMOVEALL_CONFIRM..EM_ON.." to proceed"..EM_OFF

L.DESCRIPTION = "Allows you to add player names (and an optional reason) to a list of \"badapples\", or players for whom you want to be reminded of to avoid grouping with them."

L.HELP = {
	EM_ON..L.COMMAND.." "..L.COMMAND_HELP..EM_OFF.." shows this help message",
	EM_ON..L.COMMAND.." "..L.COMMAND_LIST..EM_OFF.." shows the current list in your chat window (may be long)",
	EM_ON..L.COMMAND.." "..L.COMMAND_SHOW..EM_OFF.." shows the Badapples social window",
	EM_ON..L.COMMAND.." "..L.COMMAND_ADD.." <playername> [reason]"..EM_OFF.." adds a player name and optionally a reason",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVE.." <playername>"..EM_OFF.." removes a player name",
	EM_ON..L.COMMAND.." "..L.COMMAND_CHECK.." <playername>"..EM_OFF.." checks the status of a player name",
	EM_ON..L.COMMAND.." "..L.COMMAND_REMOVEALL..EM_OFF.." removes all players",
	EM_ON..L.COMMAND.." "..L.COMMAND_COLOR..EM_OFF.." allows you to set the Badapples highlight color",
	EM_ON..L.COMMAND.." "..L.COMMAND_TOGGLETAB..EM_OFF.." toggles the position of the Badapples social tab button",
	EM_ON..L.COMMAND.." "..L.COMMAND_NOTAB..EM_OFF.." disables the Badapples social tab button",
	"",
	"You can also use "..EM_ON.."/badapples"..EM_OFF.." instead of "..EM_ON.."/bad"..EM_OFF.." for the above slash commands",
}

-- Not localized:

L.MONTHNAME_01 = FULLDATE_MONTH_JANUARY
L.MONTHNAME_02 = FULLDATE_MONTH_FEBRUARY
L.MONTHNAME_03 = FULLDATE_MONTH_MARCH
L.MONTHNAME_04 = FULLDATE_MONTH_APRIL
L.MONTHNAME_05 = FULLDATE_MONTH_MAY
L.MONTHNAME_06 = FULLDATE_MONTH_JUNE
L.MONTHNAME_07 = FULLDATE_MONTH_JULY
L.MONTHNAME_08 = FULLDATE_MONTH_AUGUST
L.MONTHNAME_09 = FULLDATE_MONTH_SEPTEMBER
L.MONTHNAME_10 = FULLDATE_MONTH_OCTOBER
L.MONTHNAME_11 = FULLDATE_MONTH_NOVEMBER
L.MONTHNAME_12 = FULLDATE_MONTH_DECEMBER

L.ENABLE_FRIENDS_TAB = "FriendsEnabled"
L.ENABLE_BOTTOM_TAB = "BottomEnabled"
L.ENABLE_SIDE_TAB = "SideEnabled"

L.SORTBY_NAME = "Name"
L.SORTBY_REASON = "Reason"
L.SORTBY_NAME_REVERSE = "Eman"
L.SORTBY_REASON_REVERSE = "Nosaer"