local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local UnitIsPlayer = UnitIsPlayer
local UnitHonorLevel = UnitHonorLevel

local HONOR_LEVEL_TOOLTIP = HONOR_LEVEL_TOOLTIP

local HONOR_LEVEL_LABEL = HONOR_LEVEL_TOOLTIP:gsub(" %%d", ":")

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- honorLevel is compared against zero, so it must be non-secret.
    local honorLevel = SecretValue.Usable(UnitHonorLevel(unit))
    if not honorLevel or honorLevel <= 0 then return end

    tooltip:AddDoubleLine(HONOR_LEVEL_LABEL, honorLevel, nil, nil, nil, 1, 1, 1)
end)