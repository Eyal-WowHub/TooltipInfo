local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitClassification = UnitClassification

local CLASSIFICATIONS_FORMAT = " (%s)"
local CLASSIFICATIONS = {
    elite = ARTIFACT_GOLD_COLOR:WrapTextInColorCode(CLASSIFICATIONS_FORMAT:format(ELITE)),
    rareelite = HEIRLOOM_BLUE_COLOR:WrapTextInColorCode(CLASSIFICATIONS_FORMAT:format(MAP_LEGEND_RAREELITE)),
    rare = RARE_BLUE_COLOR:WrapTextInColorCode(CLASSIFICATIONS_FORMAT:format(MAP_LEGEND_RARE)),
    worldboss = LEGENDARY_ORANGE_COLOR:WrapTextInColorCode(CLASSIFICATIONS_FORMAT:format(BOSS)),
    minus = COMMON_GRAY_COLOR:WrapTextInColorCode(CLASSIFICATIONS_FORMAT:format(UNIT_NAMEPLATES_SHOW_ENEMY_MINUS)),
}

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and not isPlayer then
        local classification = UnitClassification(unit)

        if not classification or IsSecret(classification) then
            return
        end

        if lineData.isLevelLine then
            local classText = CLASSIFICATIONS[classification]

            if classText then
                lineData.leftText = lineData.leftText .. classText
            end
        end
    end
end)