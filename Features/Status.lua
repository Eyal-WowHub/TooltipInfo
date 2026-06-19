local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    local afk = SecretValue.IsTrue(UnitIsAFK(unit)) and PLAYER_STATUS_LABEL["AFK"]
    local dnd = SecretValue.IsTrue(UnitIsDND(unit)) and PLAYER_STATUS_LABEL["DND"]
    -- Offline only when we can prove the unit is disconnected (non-secret false).
    local dc  = SecretValue.Usable(UnitIsConnected(unit)) == false and PLAYER_STATUS_LABEL["OFFLINE"]

    local status = afk or dnd or dc
    if status then
        local nameLine, nameText = Tooltip.GetNameLine(tooltip)
        if nameLine then
            nameLine:SetText(nameText .. status)
        end
    end
end)