local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local select = select

local UnitIsPlayer = UnitIsPlayer
local UnitClass = UnitClass

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- className is used as a string.find pattern and classFilename as a table
    -- key; both must be non-secret for this feature to run.
    local className = SecretValue.Usable(UnitClass(unit))
    local classFilename = SecretValue.Usable(select(2, UnitClass(unit)))
    if not className or not classFilename then return end

    local classColor = RAID_CLASS_COLORS[classFilename]
    if not classColor then return end

    for i = 2, tooltip:NumLines() do
        if i ~= addon._guildLineIndex then
            local fontString, text = Tooltip.GetLine(tooltip, i)
            if fontString and text:find(className, 1, true) then
                fontString:SetText(classColor:WrapTextInColorCode(text))
            end
        end
    end
end)