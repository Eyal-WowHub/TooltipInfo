local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local select = select

local UnitIsPlayer = UnitIsPlayer
local UnitFactionGroup = UnitFactionGroup
local PVP = PVP

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    local leftText = lineData.leftText
    if not leftText or SecretValue.IsSecret(leftText) then return end

    if leftText == PVP then
        return true
    end

    if SecretValue.IsTrue(UnitIsPlayer(unit)) then
        local localizedFaction = SecretValue.Usable(select(2, UnitFactionGroup(unit)))
        if localizedFaction and leftText == localizedFaction then
            return true
        end
    end
end)