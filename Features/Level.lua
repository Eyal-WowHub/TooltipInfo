local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local GetContentDifficultyCreatureForPlayer = C_PlayerInfo.GetContentDifficultyCreatureForPlayer
local UnitIsPlayer = UnitIsPlayer
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitLevel = UnitLevel

local LEVEL = LEVEL
local TOOLTIP_UNIT_LEVEL = TOOLTIP_UNIT_LEVEL

local LEVEL_TW_FORMAT = "%d " .. WHITE_FONT_COLOR:WrapTextInColorCode("(%d)")
local LEVEL_LETHAL = RED_FONT_COLOR:WrapTextInColorCode("??")

local DIFFICULTY_COLOR = addon.DIFFICULTY_COLOR

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    if not lineData.isGuildLine then
        if IsSecret(lineData.leftText) then return end
        if lineData.leftText:find(LEVEL) and not lineData.isLevelLine then
            lineData.isLevelLine = true

            local difficulty = GetContentDifficultyCreatureForPlayer(unit)
            local diffColor = DIFFICULTY_COLOR[difficulty]
            local level, realLevel = UnitEffectiveLevel(unit), UnitLevel(unit)
            local levelText = level > 0 and level or LEVEL_LETHAL

            local isPlayer = UnitIsPlayer(unit)
            if not IsSecret(isPlayer) and isPlayer and level < realLevel then
                levelText = LEVEL_TW_FORMAT:format(levelText, realLevel)
            end

            lineData.leftText = diffColor:WrapTextInColorCode(TOOLTIP_UNIT_LEVEL:format(levelText))
        end
    end
end)