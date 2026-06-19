local _, addon = ...
local Player = addon.Player
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local UnitIsPlayer = UnitIsPlayer
local UnitRace = UnitRace

local LEVEL_RACE_FORMAT = "%s %s"

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- The race may be a secret value; it is only ever displayed (format /
    -- concatenation), never compared or indexed, so it passes straight through.
    local race = UnitRace(unit)
    if not race then return end

    local fontString, text = Tooltip.GetLine(tooltip, addon._levelLineIndex)
    if not fontString then return end

    local reactionColor = Player.GetReactionColor(unit)
    fontString:SetText(LEVEL_RACE_FORMAT:format(text, reactionColor:WrapTextInColorCode(race)))
end)