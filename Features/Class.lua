local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer and not lineData.isGuildLine then
        if IsSecret(lineData.leftText) then return end
        local className, classFilename = UnitClass(unit)

        if not className or not classFilename then
            return
        end

        if lineData.leftText:find(className) then
            local classColor = RAID_CLASS_COLORS[classFilename]

            if classColor then
                lineData.leftText = classColor:WrapTextInColorCode(lineData.leftText)
            end
        end
    end
end)