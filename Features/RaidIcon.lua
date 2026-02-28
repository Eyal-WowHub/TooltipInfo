local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local ICON_LIST = ICON_LIST

local GetRaidTargetIndex = GetRaidTargetIndex

local RAID_ICON_FORMAT = "%s %s"

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local unit = SafeUnit(lineData.unitToken)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local ricon = GetRaidTargetIndex(unit)

        if ricon and not IsSecret(ricon) then
            lineData.leftText = RAID_ICON_FORMAT:format(ICON_LIST[ricon] .. "18|t", lineData.leftText)
        end
    end
end)