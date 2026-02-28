local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local PVP = PVP

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    if not lineData.isGuildLine then
        local leftText = lineData.leftText
        if IsSecret(leftText) then return end

        if leftText == PVP then
            return true
        end
        local isPlayer = UnitIsPlayer(unit)
        if not IsSecret(isPlayer) and isPlayer then
            local _, localizedFaction = UnitFactionGroup(unit)
            if leftText == localizedFaction then
                return true
            end
        end
    end
end)