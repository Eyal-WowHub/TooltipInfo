local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitHonorLevel = UnitHonorLevel

local HONOR_LEVEL_TOOLTIP = HONOR_LEVEL_TOOLTIP

local HONOR_LEVEL_LABEL = HONOR_LEVEL_TOOLTIP:gsub(" %%d", ":")

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local honorLevel = UnitHonorLevel(unit)

        if IsSecret(honorLevel) or honorLevel <= 0 then
            return
        end

        tooltip:AddDoubleLine(HONOR_LEVEL_LABEL, honorLevel, nil, nil, nil, 1, 1, 1)
    end
end)