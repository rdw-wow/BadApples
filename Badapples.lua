------------------------------------------------------------------------------
-- Badapples
--
-- Stores the name (and optional description) about players you've encountered
-- or been told about that you want to make sure to remember so as to avoid
-- ever grouping with them (or otherwise).
--
-- For control, the AddOn registers a /badapples slash command (aliased as
-- /badapple and /bad) with the following options:
--     /badapples help (default command, describes available options)
--     /badapples list (lists all badapples currently known to chat window)
--     /badapples show (shows all badapples in social window)
--     /badapples add <playername> [comment] (adds a player to the list)
--     /badapples remove <playername> (removes a player from the list)
--     /badapples check <playername> (shows player status in badapples list)
--     /badapples removeall (removes all players in the badapples list)
--     /badapples color (allows the player to set the color for badapples)
--     /badapples toggletab (allows player to change position of social tab)
--     /badapples notab (allows player to disable social tab)
--     /badapples debugon (turns on Badapples debug)
--     /badapples debugoff (turns off Badapples debug)
--
-- Written by Cirk of DoomHammer, April 2005
-- Last updated October 2008
-- Updated by Phanx
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- AddOn version
------------------------------------------------------------------------------
BADAPPLES_NAME = "Cirk's Badapples"
BADAPPLES_VERSION = "3.2.0"


------------------------------------------------------------------------------
-- Globals
------------------------------------------------------------------------------
Badapples = {}								-- Badapples global function table
BadapplesState = {}						-- Will be overridden when loaded

BADAPPLES_FRAME_SCROLL_HEIGHT = 16
BADAPPLES_DISPLAY_COUNT = 17

local _, L = ...
Badapples.L = L


------------------------------------------------------------------------------
-- Text strings
------------------------------------------------------------------------------
local EM_ON = "|cffffff00"
local EM_OFF = "|r"
local RED_ON = "|cffff4000"
local RED_OFF = "|r"
local BAD_ON = "|cffff991a"					-- Will be overridden on load
local BAD_OFF = "|r"

------------------------------------------------------------------------------
-- Local constants
------------------------------------------------------------------------------
local BADAPPLES_MAXIMUM_REASON_LENGTH = 320
local BADAPPLES_PARTY_CLEANUP_DELAY = 1
local BADAPPLES_RAID_CLEANUP_DELAY = 1
local BADAPPLES_DEFAULT_HIGHLIGHT_R = 0.204
local BADAPPLES_DEFAULT_HIGHLIGHT_G = 0.298
local BADAPPLES_DEFAULT_HIGHLIGHT_B = 0.298
local BADAPPLES_REWARN_DELAY = 10			-- Minimum warning interval for the same badapple

BADAPPLES_TAB_ID = 17 -- Overwritten in BadapplesFix.lua

------------------------------------------------------------------------------
-- Local variables
------------------------------------------------------------------------------
local _original_GetColoredName				-- Original GetColoreName function
local _original_InviteUnit					-- Original InviteUnit function
local _original_GameTooltip_UnitColor		-- Original GameTooltip_UnitColor function

local _thisFrame = BadapplesScriptFrame						-- The frame pointer
local _debugFrame = nil					-- ChatFrame that debug goes to, or nil if debug disabled
local _serverName = nil					-- set to current realm when loaded
local _playerName = nil					-- set to name of player when known
local _listCount = 0						-- current number of entries in list
local _highlightColors = {}				-- RGB colors to use for highlighting Badapples
local _partyMembers = {}					-- List of party members
local _partyMembersTimeout = nil			-- For when to purge old members
local _raidMembers = {}					-- List of raid members
local _raidMembersTimeout = nil			-- For when to purge old members
local _listSortOrder = nil					-- Set to the current sort order
local _listSorted = {}						-- Table of sorted indices by sort order
local _ignoreList = {}						-- Populated with players on your ignore list
local _lastBadappleWarning = nil			-- Text used in last badapple warning
local _lastBadappleWarningExpires = nil	-- Time at which the last badapple warning expires


------------------------------------------------------------------------------
-- Chat events of interest
------------------------------------------------------------------------------
local _chatEventList = {
	["CHAT_MSG_SAY"] = 1,
	["CHAT_MSG_WHISPER"] = 1,
	["CHAT_MSG_WHISPER_INFORM"] = 1,
	["CHAT_MSG_YELL"] = 1,
	["CHAT_MSG_PARTY"] = 1,
	["CHAT_MSG_RAID"] = 1,
	["CHAT_MSG_GUILD"] = 1,
	["CHAT_MSG_CHANNEL"] = 1,
	["CHAT_MSG_AFK"] = 1,
	["CHAT_MSG_DND"] = 1,
}


------------------------------------------------------------------------------
-- StaticPopup definitions
------------------------------------------------------------------------------
local _badapplesInvitePopup = {
	text = L.INVITE_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		_original_InviteUnit(data)
	end,
	sound = "igPlayerInvite",
	timeout = 20,
	showAlert = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

local _badapplesAddPlayerPopup = {
	text = L.PLAYER_ADD_TEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnShow = function(self)
		_G[self:GetName().."EditBox"]:SetFocus()
	end,
	OnHide = function(self)
		if (ChatFrame1EditBox:IsShown()) then
			ChatFrame1EditBox:SetFocus()
		end
		_G[self:GetName().."EditBox"]:SetText("")
	end,
	OnAccept = function(self)
		local editBox = _G[self:GetName().."EditBox"]
		Badapples.Frame_EditBoxAddName(editBox)
	end,
	EditBoxOnEnterPressed = function(self)
		Badapples.Frame_EditBoxAddName(self)
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 60,
	exclusive = 1,
	whileDead = 1,
}

local _badapplesConfirmAddPopup = {
	text = L.PLAYER_ADD_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		Badapples.Add(data)
	end,
	sound = "igCharacterInfoOpen",
	timeout = 60,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

local _badapplesConfirmRemovePopup = {
	text = L.PLAYER_REMOVE_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		Badapples.Remove(data)
	end,
	sound = "igCharacterInfoOpen",
	timeout = 60,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

local _badapplesConfirmRemoveAllPopup = {
	text = L.REMOVEALL_CONFIRM_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		Badapples.RemoveAll(L.COMMAND_REMOVEALL_CONFIRM)
	end,
	sound = "igCharacterInfoOpen",
	timeout = 60,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}


------------------------------------------------------------------------------
-- Utility functions
------------------------------------------------------------------------------
function Badapples.GetNextParam(text)
	-- Extracts the next parameter out of the passed text, and returns it and
	-- the rest of the string
	for param, remain in string.gmatch(text, "([^%s]+)%s+(.*)") do
		return param, remain
	end
	return text
end


function Badapples.FormatName(text)
	-- Formats the indicated name as a player name (only first letter can be
	-- uppercase).  Here we are careful to handle UTF-8 coding (which is what
	-- WoW uses in 2.2) manually since strsub doesn't do this itself.
	local firstChar = strsub(text, 1, 1)
	local remain = strsub(text, 2)

	local firstByte = strbyte(firstChar)
	if firstByte >= 192 and firstByte <= 223 then
		firstChar = strsub(text, 1, 2)
		remain = strsub(text, 3)
	elseif firstByte >= 224 and firstByte <= 239 then
		firstChar = strsub(text, 1, 3)
		remain = strsub(text, 4)
	elseif firstByte >= 240 and firstByte <= 244 then
		firstChar = strsub(text, 1, 4)
		remain = strsub(text, 5)
	end

	return strupper(firstChar)..strlower(remain)
end


function Badapples.NameToLink(name)
	-- Converts the passed name to a player name link (that can be clicked on)
	-- but without showing the usual [..] around the name
	return "|Hplayer:"..name.."|h"..name.."|h"
end


function Badapples.UpdateHighlightText()
	local r = floor((255 * _highlightColors.r) + 0.5)
	local g = floor((255 * _highlightColors.g) + 0.5)
	local b = floor((255 * _highlightColors.b) + 0.5)
	BAD_ON = format("|cff%02x%02x%02x", r, g, b)
end


function Badapples.SetHighLightColor(values)
	if (values) then
		_highlightColors.r = values.r
		_highlightColors.g = values.g
		_highlightColors.b = values.b
	else
		_highlightColors.r, _highlightColors.g, _highlightColors.b = ColorPickerFrame:GetColorRGB()
	end
	Badapples.UpdateHighlightText()
	Badapples.TargetFrame_CheckFaction()
	if (_debugFrame) then
		_debugFrame:AddMessage(format("Highlight color is red %.3f, green %.3f, blue %.3f", _highlightColors.r, _highlightColors.g, _highlightColors.b))
	end
	-- Update the color of the player names in the social screen
	if (BadapplesFrame:IsShown()) then
		Badapples.Frame_ListUpdate()
	end
end


function Badapples.NotifyPlayer(notifyText, name, reason, errorText, frame)
	-- Notify the player about a badapple event by showing a formatted text
	-- message in the current chat frame (notifyText) and/or in the UI error
	-- frame (errorText).
	if (notifyText) then
		local text = format(RED_ON..notifyText..RED_OFF, BAD_ON..name..RED_ON, RED_OFF..(reason or ""))
		local time = GetTime()
		if (not _lastBadappleWarningExpires or (time > _lastBadappleWarningExpires) or (text ~= _lastBadappleWarning) or frame) then
			_lastBadappleWarning = text
			_lastBadappleWarningExpires = time + BADAPPLES_REWARN_DELAY
			if (frame) then
				frame:AddMessage(text)
			else
				for i = 1, NUM_CHAT_WINDOWS do
					local chatFrame = _G["ChatFrame"..i]
					if (chatFrame:IsShown()) then
						chatFrame:AddMessage(text)
						break
					end
				end
			end
		end
	end
	if (errorText) then
		local text = format(RED_ON..errorText..RED_OFF, name)
		UIErrorsFrame:AddMessage(text)
	end
end


function Badapples.UpdateIgnoreList()
	-- Copies the currently ignored player names into the local _ignoreList
	_ignoreList = {}
	for index = 1, C_FriendList.GetNumIgnores() do
		local name = C_FriendList.GetIgnoreName(index)
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			_ignoreList[name] = 1
		end
	end
end


function Badapples.CompareOnNameAtoZ(name1, name2)
	return name1 < name2
end


function Badapples.CompareOnNameZtoA(name1, name2)
	return name2 < name1
end


function Badapples.CompareOnReasonAtoZ(name1, name2)
	local reason1 = BadapplesState.Servers[_serverName].List[name1].Reason
	local reason2 = BadapplesState.Servers[_serverName].List[name2].Reason
	if (not reason1) then
		return false
	end
	if (not reason2) then
		return true
	end
	return reason1 < reason2
end


function Badapples.CompareOnReasonZtoA(name1, name2)
	local reason1 = BadapplesState.Servers[_serverName].List[name1].Reason
	local reason2 = BadapplesState.Servers[_serverName].List[name2].Reason
	if (not reason2) then
		return false
	end
	if (not reason1) then
		return true
	end
	return reason2 < reason1
end


function Badapples.SortList(sortBy)
	-- Creates the _listSorted list that can be used to return the values of
	-- the Badapples list in the appropriate sorted order
	_listSorted = {}
	for name in pairs(BadapplesState.Servers[_serverName].List) do
		tinsert(_listSorted, name)
	end
	if (sortBy == L.SORTBY_NAME) then
		sort(_listSorted, Badapples.CompareOnNameAtoZ)
		_listSortOrder = L.SORTBY_NAME
	elseif (sortBy == L.SORTBY_NAME_REVERSE) then
		sort(_listSorted, Badapples.CompareOnNameZtoA)
		_listSortOrder = L.SORTBY_NAME_REVERSE
	elseif (sortBy == L.SORTBY_REASON) then
		sort(_listSorted, Badapples.CompareOnReasonAtoZ)
		_listSortOrder = L.SORTBY_REASON
	elseif (sortBy == L.SORTBY_REASON_REVERSE) then
		sort(_listSorted, Badapples.CompareOnReasonZtoA)
		_listSortOrder = L.SORTBY_REASON_REVERSE
	else
		_listSortOrder = nil
	end
end


function Badapples.GetTodaysDate()
	-- Gets the current date (from the client machine) and converts it to the
	-- preferred Badapples storage format.
	return date("%m/%d/%y")
end


function Badapples.GetDateAdded(name)
	-- Returns the date when the entry was added for the given player name,
	-- converting it to a format for display to the user.
	if (not name or (name == "")) then
		return nil
	end
	local player = Badapples.FormatName(name)
	if (BadapplesState.Servers[_serverName].List[player]) then
		if (BadapplesState.Servers[_serverName].List[player].Date) then
			for mm, dd, yy in string.gmatch(BadapplesState.Servers[_serverName].List[player].Date, "(%w+)/(%w+)/(%w+)") do
				local month = L["MONTHNAME_"..mm]
				if (strsub(dd, 1, 1) == "0") then
					dd = strsub(dd, 2)
				end
				return dd.." "..month.." "..yy
			end
		end
	end
	return nil
end


------------------------------------------------------------------------------
-- Badapples interface functions
------------------------------------------------------------------------------
function Badapples.List()
	-- Lists the current players on the Badapples list and the reasons they
	-- are there.  This call always resorts the list into by name order.
	if (_listSortOrder ~= L.SORTBY_NAME) then
		Badapples.SortList(L.SORTBY_NAME)
	end
	if (_listCount > 0) then
		if (_listCount == 1) then
			DEFAULT_CHAT_FRAME:AddMessage(EM_ON.."There is 1 player on the Badapples list"..EM_OFF)
		else
			DEFAULT_CHAT_FRAME:AddMessage(EM_ON.."There are ".._listCount.." players on the Badapples list"..EM_OFF)
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage(EM_ON.."There are no players on the Badapples list"..EM_OFF)
		return
	end
	for i = 1, #_listSorted do
		local name = _listSorted[i]
		local reason = BadapplesState.Servers[_serverName].List[name].Reason
		if (not reason) then
			reason = L.NO_REASON
		end
		DEFAULT_CHAT_FRAME:AddMessage(format(L.LIST_FORMAT, BAD_ON..name..BAD_OFF, reason))
	end
end


function Badapples.Status(name, silent)
	-- Queries and displays the status of the indicated player, returning 1 if
	-- the player is in the Badapples list or nil otherwise.  If the silent
	-- parameter is not nil then no output is generated.
	if (not name or (name == "")) then
		if (not silent) then
			DEFAULT_CHAT_FRAME:AddMessage(L.PLAYERNAME_FAILED)
		end
		return nil
	end
	local player = Badapples.FormatName(name)
	if (BadapplesState.Servers[_serverName].List[player]) then
		if (not silent) then
			local reason = BadapplesState.Servers[_serverName].List[player].Reason or L.NO_REASON
			Badapples.NotifyPlayer(L.NOTIFY_BAD, player, reason, nil, DEFAULT_CHAT_FRAME)
		end
		return 1
	else
		if (not silent) then
			DEFAULT_CHAT_FRAME:AddMessage(format(L.STATUS_GOOD, player))
		end
	end
	return nil
end


function Badapples.Add(name_and_reason)
	-- Adds the indicated player (with reason if provided) to the Badapples
	-- list, returning 1 if the player was added successfully (or is already
	-- present) or nil otherwise.
	if (not name_and_reason or (name_and_reason == "")) then
		DEFAULT_CHAT_FRAME:AddMessage(L.PLAYERNAME_FAILED)
		return nil
	end
	local name, reason = Badapples.GetNextParam(name_and_reason)
	local player = Badapples.FormatName(name)
	if (player == _playerName) then
		DEFAULT_CHAT_FRAME:AddMessage(L.PLAYERNAME_ISSELF)
		return nil
	end
	if (reason and (strlen(reason) > BADAPPLES_MAXIMUM_REASON_LENGTH)) then
		reason = strsub(reason, 1, BADAPPLES_MAXIMUM_REASON_LENGTH)
	end
	if (BadapplesState.Servers[_serverName].List[player]) then
		BadapplesState.Servers[_serverName].List[player].Reason = reason
		BadapplesState.Servers[_serverName].List[player].Date = Badapples.GetTodaysDate()
		if (not reason) then
			reason = L.NO_REASON
		end
		DEFAULT_CHAT_FRAME:AddMessage(format(L.UPDATE_CONFIRM, BAD_ON..player..BAD_OFF, reason))
	else
		BadapplesState.Servers[_serverName].List[player] = {}
		BadapplesState.Servers[_serverName].List[player].Reason = reason
		BadapplesState.Servers[_serverName].List[player].Date = Badapples.GetTodaysDate()
		if (_listCount == 0) then
			-- First player added to list, so register events as well
			_listCount = 1
		else
			_listCount = _listCount + 1
		end
		Badapples.SortList(_listSortOrder)
		if (not reason) then
			reason = L.NO_REASON
		end
		DEFAULT_CHAT_FRAME:AddMessage(format(L.ADD_CONFIRM, BAD_ON..player..BAD_OFF, reason))
	end
	-- Update the Badapples frame and target display
	if (BadapplesFrame:IsShown()) then
		BadapplesFrame.SelectedName = player
		Badapples.Frame_ListUpdate()
	end
	Badapples.TargetFrame_CheckFaction()
	return 1
end


function Badapples.Remove(name)
	if (not name or (name == "")) then
		DEFAULT_CHAT_FRAME:AddMessage(L.PLAYERNAME_FAILED)
		return
	end
	local player = Badapples.FormatName(name)
	if (BadapplesState.Servers[_serverName].List[player]) then
		BadapplesState.Servers[_serverName].List[player] = nil
		if (_listCount == 1) then
			-- Last player removed, so unregister events as well
			_listCount = 0
		else
			_listCount = _listCount - 1
		end
		Badapples.SortList(_listSortOrder)
		DEFAULT_CHAT_FRAME:AddMessage(format(L.REMOVE_CONFIRM, player))
		-- Update the Badapples frame and target display
		if (BadapplesFrame:IsShown()) then
			Badapples.Frame_ListUpdate()
		end
		Badapples.TargetFrame_CheckFaction()
	else
		DEFAULT_CHAT_FRAME:AddMessage(format(L.REMOVE_NOTFOUND, player))
	end
end


function Badapples.RemoveAll(confirm)
	-- Removes all the player entries in the list
	if (_listCount > 0) then
		if (not confirm or (confirm ~= L.COMMAND_REMOVEALL_CONFIRM)) then
			StaticPopup_Show("BADAPPLE_REMOVEALL")
			return
		end
		BadapplesState.Servers[_serverName].List = {}
		_listCount = 0
		-- Update the sorted list to be empty to
		Badapples.SortList(_listSortOrder)
		-- Update the Badapples frame and target display
		if (BadapplesFrame:IsShown()) then
			Badapples.Frame_ListUpdate()
		end
		Badapples.TargetFrame_CheckFaction()
	end
	DEFAULT_CHAT_FRAME:AddMessage(L.REMOVEALL_CONFIRM)
end


------------------------------------------------------------------------------
-- Check party and raid functions
------------------------------------------------------------------------------
function Badapples.CheckParty()
	-- Checks all party members as to whether or not they are Badapples,
	-- keeping track of which ones we have already warned the player about.
	-- Note that because the PARTY_MEMBERS_CHANGED event may signal first that
	-- there are no other players (even if there are) and then that there are
	-- other players (if there are) we do not want to remove players from the
	-- _partyMembers list immediately, but set a flag and delete them at a
	-- later time (via Badapples.OnUpdate).  So first we start by setting all
	-- the current members as pending deletion...
	for name in pairs(_partyMembers) do
		_partyMembers[name] = -1
	end
	-- Now process all currently known members
	for i = 1, 4 do
		local name = UnitName("party"..i)
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (not _partyMembers[name]) then
				if (BadapplesState.Servers[_serverName].List[name]) then
					-- Uh oh, new party member is on the Badapples list!
					Badapples.NotifyPlayer(L.PARTY_WARNING, name, BadapplesState.Servers[_serverName].List[name].Reason or L.NO_REASON, L.PARTY_WARNING_NO_REASON)
				elseif (_ignoreList[name]) then
					-- New party member is on the ignore list!
					Badapples.NotifyPlayer(L.PARTY_IGNORE_WARNING, name, nil, L.PARTY_IGNORE_WARNING)
				end
			end
			_partyMembers[name] = 1
		end
	end
	-- Set the pending delete time and enable the OnUpdate hook
	_partyMembersTimeout = GetTime() + BADAPPLES_PARTY_CLEANUP_DELAY
	_thisFrame:SetScript("OnUpdate", Badapples.OnUpdate)
end


function Badapples.CheckRaid()
	-- Checks all raid members as to whether or not they are Badapples using
	-- the same algorithm for cleanup as for party members (although probably
	-- not required in this case)
	for name in pairs(_raidMembers) do
		_raidMembers[name] = -1
	end
	-- Now process all currently known members
	for i = 1, 40 do
		local name = GetRaidRosterInfo(i)
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (not _raidMembers[name]) then
				if (BadapplesState.Servers[_serverName].List[name]) then
					-- Uh oh, new raid member is on the Badapples list!
					Badapples.NotifyPlayer(L.RAID_WARNING, name, BadapplesState.Servers[_serverName].List[name].Reason or L.NO_REASON, L.RAID_WARNING_NO_REASON)
				elseif (_ignoreList[name]) then
					-- New raid member is on the ignore list!
					Badapples.NotifyPlayer(L.RAID_IGNORE_WARNING, name, nil, L.RAID_IGNORE_WARNING)
				end
			end
			_raidMembers[name] = 1
		end
	end
	-- Set the pending delete time and enable the OnUpdate hook
	_raidMembersTimeout = GetTime() + BADAPPLES_RAID_CLEANUP_DELAY
	_thisFrame:SetScript("OnUpdate", Badapples.OnUpdate)
end


------------------------------------------------------------------------------
-- Initialization functions
------------------------------------------------------------------------------
function Badapples.RegisterEvents(register)
	-- If register is set, then register for events, otherwise unregister
	if (register == 1) then
		_thisFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
		_thisFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		_thisFrame:RegisterEvent("IGNORELIST_UPDATE")
	else
		_thisFrame:UnregisterEvent("GROUP_ROSTER_UPDATE")
		_thisFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
		_thisFrame:UnregisterEvent("IGNORELIST_UPDATE")
	end
end


function Badapples.HookNeededFunctions()
	-- Replace GetColoredName function so we can ensure badapples get their
	-- names colored correctly in chat
	_original_GetColoredName = GetColoredName
	GetColoredName = Badapples.GetColoredName

	-- Post-hook ChatEdit_UpdateHeader so we can highlight Badapple player
	-- names if we send them a tell
	hooksecurefunc("ChatEdit_UpdateHeader", Badapples.ChatEdit_UpdateHeader)

	-- Post-hook SetItemRef so we can check player links for Badapples
	hooksecurefunc("SetItemRef", Badapples.SetItemRef)

	-- Post-hook StaticPopup_Show so we can check for party invites from
	-- Badapples and update the dialog text as needed.
	hooksecurefunc("StaticPopup_Show", Badapples.StaticPopup_Show)

	-- Replace InviteUnit so we can check for invitations to Badapples and
	-- Use the "BADAPPLE_INVITE" confirmation popup
	_original_InviteUnit = InviteUnit
	InviteUnit = Badapples.InviteUnit

	-- Post-hook TargetFrame_CheckFaction so we can check player names and
	-- override the frame color if we need
	hooksecurefunc("TargetFrame_CheckFaction", Badapples.TargetFrame_CheckFaction)

	-- Hook GameTooltip_UnitColor so we can introduce our own "faction style"
	-- highlighting for Badapples
	_original_GameTooltip_UnitColor = GameTooltip_UnitColor
	GameTooltip_UnitColor = Badapples.GameTooltip_UnitColor
end


function Badapples.VariablesLoaded()
	if (not BadapplesState) then
		BadapplesState = {}
	end
	if (not BadapplesState.Version) then
		BadapplesState.Version = BADAPPLES_VERSION
	end
	if (not BadapplesState.Colors) then
		BadapplesState.Colors = {}
		BadapplesState.Colors.r = BADAPPLES_DEFAULT_HIGHLIGHT_R
		BadapplesState.Colors.g = BADAPPLES_DEFAULT_HIGHLIGHT_G
		BadapplesState.Colors.b = BADAPPLES_DEFAULT_HIGHLIGHT_B
	end
	_highlightColors = BadapplesState.Colors
	Badapples.UpdateHighlightText()
	if (not BadapplesState.Servers) then
		BadapplesState.Servers = {}
	end
	if (not BadapplesState.Servers[_serverName]) then
		BadapplesState.Servers[_serverName] = {}
	end
	if (not BadapplesState.Servers[_serverName].List) then
		BadapplesState.Servers[_serverName].List = {}
	end
	if (not BadapplesState.Servers[_serverName].Characters) then
		BadapplesState.Servers[_serverName].Characters = {}
	end

	-- Hook all various functions we need
	Badapples.HookNeededFunctions()

	-- Update _listCount
	_listCount = 0
	for name in pairs(BadapplesState.Servers[_serverName].List) do
		_listCount = _listCount + 1
	end
	if (_debugFrame) then
		_debugFrame:AddMessage("Badapples loaded ".._listCount.." entries")
	end

	-- Process any version changes
	if (BadapplesState.Version ~= BADAPPLES_VERSION) then
		if (_debugFrame) then
			_debugFrame:AddMessage("Upgrading from Badapples version "..BadapplesState.Version)
		end
		BadapplesState.Version = BADAPPLES_VERSION
	end
end


function Badapples.PlayerLogin()
	-- Get the user's setting for the social tab
	if (not BadapplesState.Servers[_serverName].Characters[_playerName]) then
		BadapplesState.Servers[_serverName].Characters[_playerName] = {}
	end
	if (not BadapplesState.Servers[_serverName].Characters[_playerName].Tab) then
		BadapplesState.Servers[_serverName].Characters[_playerName].Tab = L.ENABLE_FRIENDS_TAB
	end
end


------------------------------------------------------------------------------
-- Hooked functions for ChatFrame
------------------------------------------------------------------------------
function Badapples.GetColoredName(event, arg1, arg2, ...)
	if (_chatEventList[event]) then
		-- All these events have the player name in arg2
		if (BadapplesState.Servers[_serverName].List[arg2]) then
			return BAD_ON..arg2..BAD_OFF
		end
	end
	return _original_GetColoredName(event, arg1, arg2, ...)
end



------------------------------------------------------------------------------
-- Hook function for SetItemRef
------------------------------------------------------------------------------
function Badapples.SetItemRef(link, text, button)
	-- Warn player if they try whispering a badapple, or if the shift key is
	-- down and Badapple's player add box is open, then add them to it
	if (strsub(link, 1, 6) == "player" ) then
		local name, lineid = strsplit(":", strsub(link, 8))
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (BadapplesState.Servers[_serverName].List[name]) then
				-- Warn user about this badapple
				Badapples.NotifyPlayer(L.NOTIFY_BAD, name, BadapplesState.Servers[_serverName].List[name].Reason or L.NO_REASON)
			elseif (_ignoreList[name]) then
				-- Warn user about this ignored player
				Badapples.NotifyPlayer(L.NOTIFY_IGNORE, name)
			elseif (IsModifiedClick("CHATLINK")) then
				-- Add it to the "add" dialog if it is visible
				local staticPopup = StaticPopup_Visible("BADAPPLE_ADD")
				if (staticPopup) then
					_G[staticPopup.."EditBox"]:SetText(name)
				end
			end
		end
	end
end


------------------------------------------------------------------------------
-- Hook function for StaticPopup_Show
------------------------------------------------------------------------------
function Badapples.StaticPopup_Show(popupName, text_arg1, text_arg2, data)
	-- Called via hooksecurefunc after the original StaticPopup_Show is called
	-- this function looks for the "PARTY_INVITE" request, and checks to see
	-- if this was from a player on the badapples list.  If so, the dialog's
	-- text is changed to reflect this and a warning is shown.
	if ((popupName == "PARTY_INVITE") and text_arg1) then
		local name = Badapples.FormatName(text_arg1)
		if (name and (name ~= "")) then
			local replaceText = nil
			if (BadapplesState.Servers[_serverName].List[name]) then
				-- Warn user about this badapple
				Badapples.NotifyPlayer(L.NOTIFY_BAD, name, BadapplesState.Servers[_serverName].List[name].Reason or L.NO_REASON)
				-- Use our replacement PARTY_INVITE dialog in badapple mode
				replaceText = format(L.PARTY_INVITE_TEXT, BAD_ON..name..BAD_OFF)
			elseif (_ignoreList[name]) then
				-- Warn user about this ignored player
				Badapples.NotifyPlayer(L.NOTIFY_IGNORE, name)
				-- Use our replacement PARTY_INVITE dialog in ignore mode
				replaceText = format(L.PARTY_IGNORE_INVITE_TEXT, name)
			end
			if (replaceText) then
				-- Find the dialog being used and change its text and accept buttons
				for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
					local frame = _G["StaticPopup"..index]
					if (frame:IsShown() and (frame.which == popupName)) then
						local text = _G[frame:GetName().."Text"]
						local button1 = _G[frame:GetName().."Button1"]
						local alertIcon = _G[frame:GetName().."AlertIcon"]
						if (text and text:IsShown()) then
							text:SetText(replaceText)
						end
						if (button1 and button1:IsShown()) then
							button1:SetText(L.PARTY_INVITE_BUTTON)
							local width = button1:GetTextWidth()
							if (width > 120) then
								button1:SetWidth(width + 20)
							end
						end
						-- Call StaticPopup_Resize before we show the alert
						-- icon since the resize function will ignore it
						-- and would reduce the width again
						StaticPopup_Resize(frame, popupName)
						if (alertIcon) then
							alertIcon:Show()
							frame:SetWidth(420)
						end
						break
					end
				end
			end
		end
	end
end


------------------------------------------------------------------------------
-- Hook function for InviteUnit
------------------------------------------------------------------------------
function Badapples.InviteUnit(name)
	if (name and (name ~= "")) then
		local playerName = Badapples.FormatName(name)
		if (BadapplesState.Servers[_serverName].List[playerName]) then
			-- Warn user about this badapple in Chat
			Badapples.NotifyPlayer(L.NOTIFY_BAD, playerName, BadapplesState.Servers[_serverName].List[playerName].Reason or L.NO_REASON)
			-- Warn user about inviting player by dialog box in badapple mode
			_badapplesInvitePopup.text = L.INVITE_TEXT
			local dialogFrame = StaticPopup_Show("BADAPPLE_INVITE", BAD_ON..playerName..BAD_OFF)
			if (dialogFrame) then
				dialogFrame.data = playerName
			end
		elseif (_ignoreList[playerName]) then
			-- Warn user about this ignored player in Chat
			Badapples.NotifyPlayer(L.NOTIFY_IGNORE, playerName)
			-- Warn user about inviting player by dialog box in ignore mode
			_badapplesInvitePopup.text = L.INVITE_IGNORE_TEXT
			local dialogFrame = StaticPopup_Show("BADAPPLE_INVITE", playerName)
			if (dialogFrame) then
				dialogFrame.data = playerName
			end
		else
			return _original_InviteUnit(name)
		end
	else
		return _original_InviteUnit(name)
	end
end


------------------------------------------------------------------------------
-- Hook function for TargetFrame_CheckFaction
------------------------------------------------------------------------------
function Badapples.TargetFrame_CheckFaction(self)
	-- Sets the color of the target's name background if the target is a
	-- player on the Badapples list.
	if (UnitIsPlayer("target")) then
		local name = UnitName("target")
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (BadapplesState.Servers[_serverName].List[name]) then
				-- We have a Badapple in the target, so we change the color
				-- only if the player is not attackable by us (i.e., they are
				-- not yet flagged) so as to leave the normal color clues for
				-- PvP combat.
				if (not UnitCanAttack("player", "target")) then
					TargetFrameNameBackground:SetVertexColor(0.9*_highlightColors.r, 0.9*_highlightColors.g, 0.9*_highlightColors.b)
				end
			end
		end
	end
end


------------------------------------------------------------------------------
-- Hook function for GameTooltip_UnitColor
------------------------------------------------------------------------------
function Badapples.GameTooltip_UnitColor(unit)
	-- Determines the color to set the player's name in the Game tooltip
	-- display.  In this case if we don't set the color ourselves we drop
	-- through and call the original function.
	if (UnitIsPlayer(unit)) then
		local name = UnitName(unit)
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (BadapplesState.Servers[_serverName].List[name]) then
				-- We have a Badapple in the target, so we change the color
				-- only if the player is not attackable by us (i.e., they are
				-- not yet flagged) so as to leave the normal color clues for
				-- PvP combat.
				if (not UnitCanAttack("player", unit)) then
					return _highlightColors.r, _highlightColors.g, _highlightColors.b
				end
			end
		end
	end
	return _original_GameTooltip_UnitColor(unit)
end


------------------------------------------------------------------------------
-- Hook function for ChatEdit_UpdateHeader
------------------------------------------------------------------------------
function Badapples.ChatEdit_UpdateHeader(editBox)
	-- Called after ChatEdit_UpdateHeader is called by hooksecurefunc, this
	-- function checks to see if the editbox header was updated for a new tell
	-- target and if this target is a player in our Badapples list then modify
	-- the format string before calling the original update function.
	local chatType = editBox:GetAttribute("chatType")
	if (chatType == "WHISPER") then
		local name = Badapples.FormatName(editBox:GetAttribute("tellTarget") or "")
		if (BadapplesState.Servers[_serverName].List[name]) then
			-- Update header color and warn user about this badapple
			local header = _G[editBox:GetName().."Header"]
			if (header) then
				header:SetText(format(CHAT_WHISPER_SEND, BAD_ON..name..BAD_OFF))
			end
			Badapples.NotifyPlayer(L.NOTIFY_BAD, name, BadapplesState.Servers[_serverName].List[name].Reason or L.NO_REASON)
		elseif (_ignoreList[name]) then
			-- Warn user about this ignored player
			Badapples.NotifyPlayer(L.NOTIFY_IGNORE, name)
		end
	end
end


------------------------------------------------------------------------------
-- Frame and Button management functions
------------------------------------------------------------------------------
function Badapples.Frame_ListUpdate()
	-- Start with inits
	if (not BadapplesFrame.SortBy) then
		BadapplesFrame.SortBy = L.SORTBY_NAME
	end
	if (BadapplesFrame.SelectedName) then
		if (not BadapplesState.Servers[_serverName].List[BadapplesFrame.SelectedName]) then
			BadapplesFrame.SelectedName = nil
		end
	end
	if (BadapplesFrame.SortBy ~= _listSortOrder) then
		Badapples.SortList(BadapplesFrame.SortBy)
	end

	-- Format string for the total players text
	if (_listCount > 0) then
		if (_listCount == 1) then
			BadapplesFrameTotals:SetText(L.TOTAL_SINGLE)
		else
			BadapplesFrameTotals:SetFormattedText(L.TOTAL_MULTIPLE, _listCount)
		end
	else
		BadapplesFrameTotals:SetText(L.TOTAL_EMPTY)
	end

	-- Now get parameters for what to display
	local offset = FauxScrollFrame_GetOffset(BadapplesListScrollFrame)
	local name, reason
	local nameText, reasonText
	for i = 1, BADAPPLES_DISPLAY_COUNT do
		button = _G["BadapplesFrameButton"..i]
		nameText = _G["BadapplesFrameButton"..i.."Name"]
		reasonText = _G["BadapplesFrameButton"..i.."Reason"]
		index = i + offset
		if (index <= _listCount) then
			name = _listSorted[index]
			button.Name = name
			nameText:SetText(name)
			nameText:SetTextColor(_highlightColors.r, _highlightColors.g, _highlightColors.b)
			reason = BadapplesState.Servers[_serverName].List[name].Reason
			if (reason) then
				reasonText:SetText(reason)
			else
				reasonText:SetText("")
			end
			if (button.hasCursor) then
				button:OnEnterFunction()
			end
			if (BadapplesFrame.SelectedName == name) then
				button:LockHighlight()
			else
				button:UnlockHighlight()
			end
			button:Show()
		else
			nameText:SetText("")
			reasonText:SetText("")
			button:Hide()
		end
	end

	-- Update buttons and edit box for selected player
	if (BadapplesFrame.SelectedName) then
		BadapplesFrameRemoveButton:Enable()
		BadapplesFrameEditBox:SetMaxLetters(BADAPPLES_MAXIMUM_REASON_LENGTH)
		BadapplesFrameEditBox:ClearFocus()
		BadapplesFrameEditBox:Show()
		-- Use the non-printing character "\032" to force a
		-- text update of the editbox, and store the actual text we want
		-- displayed in the object to be handled when the OnTextChanged event
		-- fires.  This is simply to force the editbox to show all the text
		-- when a new text string is shorter than the previous one (see
		-- corresponding code in Badapples.xml).
		BadapplesFrameEditBox:SetText("\032")
		reason = BadapplesState.Servers[_serverName].List[BadapplesFrame.SelectedName].Reason
		if (reason) then
			BadapplesFrameEditBox.newText = reason
		else
			BadapplesFrameEditBox.newText = ""
		end
	else
		BadapplesFrameRemoveButton:Disable()
		BadapplesFrameEditBox:SetText("")
		BadapplesFrameEditBox:Hide()
	end

	-- Control state of Add button based on what is targetted
	if (UnitIsPlayer("target")) then
		local name = UnitName("target")
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (BadapplesState.Servers[_serverName].List[name]) then
				BadapplesFrameAddButton:Disable()
			else
				BadapplesFrameAddButton:Enable()
			end
		else
			BadapplesFrameAddButton:Enable()
		end
	else
		BadapplesFrameAddButton:Enable()
	end

	-- Update scrollbar
	FauxScrollFrame_Update(BadapplesListScrollFrame, _listCount, BADAPPLES_DISPLAY_COUNT, BADAPPLES_FRAME_SCROLL_HEIGHT)
end


function Badapples.Frame_DropDownOnClick(self)
	-- Called when a dropdown item is selected
	if (self.value == "WHO") then
		SendWho("n-"..BadapplesDropDown.name)
	elseif (self.value == "EDIT") then
		BadapplesFrameEditBox:SetFocus()
	elseif (self.value == "REMOVE") then
		-- We don't confirm removes done via right-click
		Badapples.Remove(BadapplesDropDown.name)
	end
end


function Badapples.Frame_DropdownInitialize(self)
	local info
	local date = Badapples.GetDateAdded(BadapplesDropDown.name)
	-- First do title using Player name and entry date (if known)
	info = UIDropDownMenu_CreateInfo()
	if (date) then
		info.text = BadapplesDropDown.name.."  ("..date..")"
	else
		info.text = BadapplesDropDown.name
	end
	info.isTitle = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info)

	-- Add button for Who command
	info = UIDropDownMenu_CreateInfo()
	info.text = "Who"
	info.notCheckable = 1
	info.value = "WHO"
	info.owner = self
	info.func = Badapples.Frame_DropDownOnClick
	UIDropDownMenu_AddButton(info)

	-- Add button for Editing reason
	info = UIDropDownMenu_CreateInfo()
	info.text = "Edit"
	info.notCheckable = 1
	info.value = "EDIT"
	info.owner = self
	info.func = Badapples.Frame_DropDownOnClick
	UIDropDownMenu_AddButton(info)

	-- Add button for removing Player
	info = UIDropDownMenu_CreateInfo()
	info.text = "Remove"
	info.notCheckable = 1
	info.value = "REMOVE"
	info.func = Badapples.Frame_DropDownOnClick
	UIDropDownMenu_AddButton(info)

	-- Finally add button for Cancel
	info = UIDropDownMenu_CreateInfo()
	info.text = "Cancel"
	info.notCheckable = 1
	info.func = Badapples.Frame_DropDownOnClick
	UIDropDownMenu_AddButton(info)
end


function Badapples.Frame_ToggleSortBy(sortBy)
	if (sortBy == L.SORTBY_NAME) then
		if (_listSortOrder == L.SORTBY_NAME) then
			BadapplesFrame.SortBy = L.SORTBY_NAME_REVERSE
		else
			BadapplesFrame.SortBy = L.SORTBY_NAME
		end
	elseif (sortBy == L.SORTBY_REASON) then
		if (_listSortOrder == L.SORTBY_REASON) then
			BadapplesFrame.SortBy = L.SORTBY_REASON_REVERSE
		else
			BadapplesFrame.SortBy = L.SORTBY_REASON
		end
	end
	Badapples.Frame_ListUpdate()
end


function Badapples.FrameButton_OnClick(self, button)
	if (button == "LeftButton") then
		HideDropDownMenu(1)
		BadapplesFrame.SelectedName = _G["BadapplesFrameButton"..self:GetID()].Name
		Badapples.Frame_ListUpdate()
	else
		HideDropDownMenu(1)
		BadapplesFrame.SelectedName = _G["BadapplesFrameButton"..self:GetID()].Name
		Badapples.Frame_ListUpdate()
		BadapplesDropDown.name = BadapplesFrame.SelectedName
		BadapplesDropDown.initialize = Badapples.Frame_DropdownInitialize
		BadapplesDropDown.displayMode = "MENU"
		ToggleDropDownMenu(1, nil, BadapplesDropDown, "cursor")
	end
end


function Badapples.ShowColorPicker()
	-- Open the ColorPickerFrame, making sure to close all other menus first
	CloseMenus()
	ColorPickerFrame.func = Badapples.SetHighLightColor
	ColorPickerFrame.hasOpacity = nil
	ColorPickerFrame.opacityFunc = nil
	ColorPickerFrame.opacity = 0
	ColorPickerFrame:SetColorRGB(_highlightColors.r, _highlightColors.g, _highlightColors.b)
	ColorPickerFrame.previousValues = {r = _highlightColors.r, g = _highlightColors.g, b = _highlightColors.b}
	ColorPickerFrame.cancelFunc = Badapples.SetHighLightColor
	ShowUIPanel(ColorPickerFrame)
end


function Badapples.Frame_Add()
	-- If the current target is a suitable candidate, then prompt for
	-- confirmation, otherwise prompt for a player name.
	if (UnitIsPlayer("target")) then
		local name = UnitName("target")
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (not BadapplesState.Servers[_serverName].List[name]) then
				-- Request confirmation before we add the targetted player
				local dialogFrame = StaticPopup_Show("BADAPPLE_ADD_CONFIRM", name)
				if (dialogFrame) then
					dialogFrame.data = name
				end
				return
			end
		end
	end
	StaticPopup_Show("BADAPPLE_ADD")
end


function Badapples.Frame_Remove()
	if (BadapplesFrame.SelectedName) then
		local dialogFrame = StaticPopup_Show("BADAPPLE_REMOVE_CONFIRM", BadapplesFrame.SelectedName)
		if (dialogFrame) then
			dialogFrame.data = BadapplesFrame.SelectedName
		end
	end
end


function Badapples.Frame_EditReason()
	if (BadapplesFrame.SelectedName and BadapplesState.Servers[_serverName].List[BadapplesFrame.SelectedName]) then
		local reason = BadapplesState.Servers[_serverName].List[BadapplesFrame.SelectedName].Reason
		if (reason ~= BadapplesFrameEditBox:GetText()) then
			Badapples.Add(BadapplesFrame.SelectedName.." "..BadapplesFrameEditBox:GetText())
		end
	end
	BadapplesFrameEditBox:ClearFocus()
end


function Badapples.Frame_EditBoxAddName(editBox)
	-- Called by the static popup dialog on accept or enter
	local name = editBox:GetText()
	if (name and (name ~= "")) then
		if (Badapples.Status(name, 1)) then
			BadapplesFrame.SelectedName = Badapples.FormatName(name)
			Badapples.Status(name)
		else
			Badapples.Add(name)
		end
	end
end


function Badapples.Show()
	-- Forces the social window to show the Badapples list (if it isn't
	-- already visible)
	if not BadapplesFrame:IsShown() then
		if not FriendsFrame:IsShown() then
			ShowUIPanel(FriendsFrame)
		end

		FriendsFrame.selectedTab = 1
		PanelTemplates_UpdateTabs(FriendsFrame)

		FriendsTabHeader.selectedTab = BADAPPLES_TAB_ID
		if FriendsFrame:IsShown() then
			FriendsFrame_Update()
		end
	end
end


------------------------------------------------------------------------------
-- OnLoad function
------------------------------------------------------------------------------
function Badapples.OnLoad(self)
	-- Record our frame pointer for later
	_thisFrame = self

	-- Register slash command handler
	SLASH_BADAPPLES1 = "/badapples"
	SLASH_BADAPPLES2 = "/badapple"
	SLASH_BADAPPLES3 = "/bad"
		SlashCmdList["BADAPPLES"] = function(text)
		Badapples.SlashCommand(text)
	end

	-- Register for basic events
	_thisFrame:RegisterEvent("PLAYER_LOGIN")
	_thisFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	_thisFrame:RegisterEvent("PLAYER_LEAVING_WORLD")

	-- Add our Badapples frame to the FriendsFrame subframe list for if the
	-- Badapples social tab is enabled.
	tinsert(FRIENDSFRAME_SUBFRAMES, "BadapplesFrame")

	-- Create a new BADAPPLE_INVITE popup for if we try and invite a Badapple
	StaticPopupDialogs["BADAPPLE_INVITE"] = _badapplesInvitePopup

	-- Create a new BADAPPLE_ADD popup for asking the name of a player to add
	-- to the Badapples list, based on the ADD_IGNORE one
	StaticPopupDialogs["BADAPPLE_ADD"] = _badapplesAddPlayerPopup

	-- Create new BADAPPLE_ADD_CONFIRM and BADAPPLE_REMOVE_CONFIRM popups for
	-- confirming adding or removing a player to or from the Badapples list
	StaticPopupDialogs["BADAPPLE_ADD_CONFIRM"] = _badapplesConfirmAddPopup
	StaticPopupDialogs["BADAPPLE_REMOVE_CONFIRM"] = _badapplesConfirmRemovePopup

	-- Create a new BADAPPLE_REMOVEALL popup for confirming deletion of all
	-- Badapple entries
	StaticPopupDialogs["BADAPPLE_REMOVEALL"] = _badapplesConfirmRemoveAllPopup

	-- Register with Blizzard interface options
	Badapples.RegisterOptions(BADAPPLES_NAME, BADAPPLES_NAME.." v"..BADAPPLES_VERSION, L.DESCRIPTION, L.HELP)
end


function BadapplesTab_OnLoad(frame)
	-- Called for each tab frame as they are loaded, this function sets the
	-- tabs's appropriate text (long or short)
	frame:SetText(L.TAB_SHORTNAME)
end


------------------------------------------------------------------------------
-- OnEvent and OnUpdate functions
------------------------------------------------------------------------------
function Badapples.OnEvent(event)
	if (event == "PLAYER_TARGET_CHANGED") then
		if (BadapplesFrame:IsShown()) then
			Badapples.Frame_ListUpdate()
		end

	elseif (event == "GROUP_ROSTER_UPDATE") then
		if IsInRaid() then
			Badapples.CheckRaid()
		elseif IsInGroup() then
			Badapples.CheckParty()
		end

	elseif (event == "PLAYER_ENTERING_WORLD") then
		Badapples.RegisterEvents(1)
		Badapples.UpdateIgnoreList()
		if (_listCount > 0) then
			if IsInRaid() then
				Badapples.CheckRaid()
			elseif IsInGroup() then
				Badapples.CheckParty()
			end
		end

	elseif (event == "PLAYER_LEAVING_WORLD") then
		Badapples.RegisterEvents(0)
		_thisFrame:SetScript("OnUpdate", nil)

	elseif (event == "IGNORELIST_UPDATE") then
		Badapples.UpdateIgnoreList()

	elseif (event == "PLAYER_LOGIN") then
		_playerName = UnitName("player")
		_serverName = GetRealmName()
		Badapples.VariablesLoaded()
		if (_serverName and _playerName) then
			Badapples.PlayerLogin()
		end

	end
end


function Badapples.OnUpdate()
	-- We only need this for knowing when to purge the party and raid data
	if (_partyMembersTimeout) then
		if (GetTime() > _partyMembersTimeout) then
			for name in pairs(_partyMembers) do
				if (_partyMembers[name] < 0) then
					_partyMembers[name] = nil
				end
			end
			_partyMembersTimeout = nil
		end
	end
	if (_raidMembersTimeout) then
		if (GetTime() > _raidMembersTimeout) then
			for name in pairs(_raidMembers) do
				if (_raidMembers[name] < 0) then
					_raidMembers[name] = nil
				end
			end
			_raidMembersTimeout = nil
		end
	end
	if (not _partyMembersTimeout and not _raidMembersTimeout) then
		_thisFrame:SetScript("OnUpdate", nil)
	end
end


------------------------------------------------------------------------------
-- Slash command function
------------------------------------------------------------------------------
function Badapples.SlashCommand(text)
	if (text) then
		local command, param = Badapples.GetNextParam(text)
		if (command == L.COMMAND_LIST) then
			Badapples.List()

		elseif (command == L.COMMAND_SHOW) then
			Badapples.Show()

		elseif ((command == L.COMMAND_CHECK) or (command == L.COMMAND_STATUS)) then
			Badapples.Status(param)

		elseif (command == L.COMMAND_ADD) then
			Badapples.Add(param)

		elseif (command == L.COMMAND_REMOVE) then
			Badapples.Remove(param)

		elseif (command == L.COMMAND_REMOVEALL) then
			Badapples.RemoveAll()

		elseif ((command == L.COMMAND_COLOR) or (command == L.COMMAND_SETCOLOR)) then
			Badapples.ShowColorPicker()

		elseif (command == L.COMMAND_DEBUGON) then
			_debugFrame = nil
			local frameNum = tonumber(param or "")
			if (frameNum and (frameNum >= 1) and (frameNum <= 7)) then
				_debugFrame = _G["ChatFrame"..frameNum]
			end
			if (not _debugFrame) then
				_debugFrame = DEFAULT_CHAT_FRAME
			end
			DEFAULT_CHAT_FRAME:AddMessage(L.DEBUGON_CONFIRM)

		elseif (command == L.COMMAND_DEBUGOFF) then
			_debugFrame = nil
			DEFAULT_CHAT_FRAME:AddMessage(L.DEBUGOFF_CONFIRM)

		else
			DEFAULT_CHAT_FRAME:AddMessage(EM_ON..BADAPPLES_NAME.." v"..BADAPPLES_VERSION..EM_OFF)
			DEFAULT_CHAT_FRAME:AddMessage(L.DESCRIPTION)
			for i = 1, #L.HELP do
				DEFAULT_CHAT_FRAME:AddMessage(L.HELP[i])
			end
		end
	end
end


------------------------------------------------------------------------------
-- Exported functions
------------------------------------------------------------------------------
function Badapples.CheckName(name)
	-- Returns the reason text, or L.NO_REASON if the provided
	-- name is on the player's badapples list, or nil otherwise.
	if (_serverName and BadapplesState.Servers and BadapplesState.Servers[_serverName]) then
		if (name and (name ~= "")) then
			name = Badapples.FormatName(name)
			if (BadapplesState.Servers[_serverName].List[name]) then
				local reason = BadapplesState.Servers[_serverName].List[name].Reason
				if (not reason) then
					reason = L.NO_REASON
				end
				return reason
			end
		end
	end
end


function Badapples.GetColor()
	-- Returns the color used for indicating badapple names in the form:
	--   r, g, b, hex
	-- Where the hex parameter is the fully qualified color string (i.e., it
	-- starts with "|c").
	return _highlightColors.r, _highlightColors.g, _highlightColors.b, BAD_ON
end


------------------------------------------------------------------------------
-- Whoami functions
------------------------------------------------------------------------------
function Badapples:GetName()
	return "Badapples"
end


function Badapples:GetTitle()
	return BADAPPLES_NAME
end


function Badapples:GetVersion()
	return BADAPPLES_VERSION
end


------------------------------------------------------------------------------
-- Blizzard options panel functions
------------------------------------------------------------------------------
function Badapples.RegisterOptions(name, titleText, descriptionText, helpText)
	local panel = CreateFrame("Frame", nil)
	panel.name = name

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -15)
	title:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -15, -15)
	title:SetJustifyH("LEFT")
	title:SetJustifyV("TOP")
	title:SetText(titleText)
	local last = title
	local spacing = 10

	if (descriptionText) then
		local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
		description:SetWidth(380)
		description:SetJustifyH("LEFT")
		description:SetJustifyV("TOP")
		description:SetNonSpaceWrap(1)
		description:SetText(descriptionText)
		last = description
	end

	if (helpText) then
		local helpTextList = helpText
		if (type(helpText) == "string") then
			helpTextList = {helpText}
		end
		for _, text in ipairs(helpTextList) do
			local line = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			line:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -(1 + spacing))
			line:SetWidth(380)
			line:SetJustifyH("LEFT")
			line:SetJustifyV("TOP")
			line:SetNonSpaceWrap(1)
			local uncolored = string.gsub(text, "(|c%x%x%x%x%x%x%x%x)", "")
			if (strsub(uncolored, 1, 1) == "/") then
				line:SetWordWrap(true)
			else
				line:SetWordWrap(false)
			end
			line:SetSpacing(1)
			if (text ~= "") then
				line:SetText(text)
			else
				line:SetText(" ")
			end
			last = line
			spacing = 0
		end
	end

	InterfaceOptions_AddCategory(panel)
end