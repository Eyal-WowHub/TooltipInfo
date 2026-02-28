local _, addon = ...
local Player = addon.Player
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP

local PVP = PVP
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

local PVP_LABEL = " (" .. PVP .. ")"

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local unit = SafeUnit(lineData.unitToken)
    if not unit then return end

    local isPVP = UnitIsPVP(unit)
    if not IsSecret(isPVP) and isPVP then
        local reactionColor
        local isPlayer = UnitIsPlayer(unit)
        if not IsSecret(isPlayer) and isPlayer then
            reactionColor = Player:GetReactionColor(unit)
        else
            local reaction = UnitReaction("player", unit)
            if reaction and not IsSecret(reaction) then
                reactionColor = FACTION_BAR_COLORS[reaction]
            end
        end
        reactionColor = reactionColor or FACTION_BAR_COLORS[5]
        lineData.leftText = lineData.leftText .. reactionColor:WrapTextInColorCode(PVP_LABEL)
    end
end)