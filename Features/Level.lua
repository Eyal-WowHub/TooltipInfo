local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local UnitIsPlayer = UnitIsPlayer
local GetContentDifficultyCreatureForPlayer = C_PlayerInfo.GetContentDifficultyCreatureForPlayer
local UnitEffectiveLevel = UnitEffectiveLevel
local UnitLevel = UnitLevel

local LEVEL = LEVEL
local TOOLTIP_UNIT_LEVEL = TOOLTIP_UNIT_LEVEL

local LEVEL_TW_FORMAT = "%d " .. WHITE_FONT_COLOR:WrapTextInColorCode("(%d)")
local LEVEL_LETHAL = RED_FONT_COLOR:WrapTextInColorCode("??")

local DIFFICULTY_COLOR = addon.DIFFICULTY_COLOR

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    addon._levelLineIndex = nil

    local fontString, _, i = Tooltip.FindLine(tooltip, LEVEL)
    if not fontString then return end
    addon._levelLineIndex = i

    -- difficulty is a table key; it must be non-secret to pick a colour.
    local difficulty = SecretValue.Usable(GetContentDifficultyCreatureForPlayer(unit))
    local diffColor = difficulty and DIFFICULTY_COLOR[difficulty]

    -- Levels feed arithmetic/comparisons, so they must be non-secret to be
    -- evaluated; a secret level is still displayed (format accepts secrets).
    local level = SecretValue.Usable(UnitEffectiveLevel(unit))
    local realLevel = SecretValue.Usable(UnitLevel(unit))

    local levelText
    if level then
        levelText = level > 0 and level or LEVEL_LETHAL
        if SecretValue.IsTrue(UnitIsPlayer(unit)) and realLevel and level > 0 and level < realLevel then
            levelText = LEVEL_TW_FORMAT:format(levelText, realLevel)
        end
    else
        levelText = UnitEffectiveLevel(unit) -- secret value, display only
    end

    local formatted = TOOLTIP_UNIT_LEVEL:format(levelText)
    if diffColor then
        formatted = diffColor:WrapTextInColorCode(formatted)
    end
    fontString:SetText(formatted)
end)