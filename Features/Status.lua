local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitIsConnected = UnitIsConnected

local AFK = AFK
local DND = DND
local PLAYER_OFFLINE = PLAYER_OFFLINE

local PLAYER_STATUS_FORMAT = " <%s>" 
local PLAYER_STATUS_LABEL = {
    ["AFK"] = GREEN_FONT_COLOR:WrapTextInColorCode(PLAYER_STATUS_FORMAT:format(AFK)),
    ["DND"] = RED_FONT_COLOR:WrapTextInColorCode(PLAYER_STATUS_FORMAT:format(DND)),
    ["OFFLINE"] = GRAY_FONT_COLOR:WrapTextInColorCode(PLAYER_STATUS_FORMAT:format(PLAYER_OFFLINE))
}

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local unit = SafeUnit(lineData.unitToken)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local isAFK = UnitIsAFK(unit)
        local isDND = UnitIsDND(unit)
        local isConnected = UnitIsConnected(unit)

        local afk = not IsSecret(isAFK) and isAFK and PLAYER_STATUS_LABEL["AFK"]
        local dnd = not IsSecret(isDND) and isDND and PLAYER_STATUS_LABEL["DND"]
        local dc  = not IsSecret(isConnected) and not isConnected and PLAYER_STATUS_LABEL["OFFLINE"]

        lineData.leftText = lineData.leftText .. (afk or dnd or dc or "")
    end
end)