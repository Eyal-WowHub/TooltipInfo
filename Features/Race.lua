local _, addon = ...
local Player = addon.Player
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitRace = UnitRace

local LEVEL_RACE_FORMAT = "%s %s"

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer and not lineData.isGuildLine then
        local race = UnitRace(unit)

        if not race or IsSecret(race) then
            return
        end

        if lineData.isLevelLine then
            local reactionColor = Player:GetReactionColor(unit)
            lineData.leftText = LEVEL_RACE_FORMAT:format(lineData.leftText, reactionColor:WrapTextInColorCode(race))
        end
    end
end)