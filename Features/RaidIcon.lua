local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local UnitIsPlayer = UnitIsPlayer
local ICON_LIST = ICON_LIST

local GetRaidTargetIndex = GetRaidTargetIndex

local RAID_ICON_FORMAT = "%s %s"

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- The index is a table key into ICON_LIST, so it must be non-secret.
    local ricon = SecretValue.Usable(GetRaidTargetIndex(unit))
    if ricon then
        local nameLine, nameText = Tooltip.GetNameLine(tooltip)
        if nameLine then
            nameLine:SetText(RAID_ICON_FORMAT:format(ICON_LIST[ricon] .. "18|t", nameText))
        end
    end
end)