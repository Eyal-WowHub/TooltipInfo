local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    -- Classification only applies to NPCs; players have no entry in the table.
    if SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- classification is a table key, so it must be non-secret.
    local classification = SecretValue.Usable(UnitClassification(unit))
    if not classification then return end

    local classText = CLASSIFICATIONS[classification]
    if not classText then return end

    local fontString, text = Tooltip.GetLine(tooltip, addon._levelLineIndex)
    if not fontString then return end

    fontString:SetText(text .. classText)
end)