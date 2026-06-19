local _, addon = ...
local Player = addon.Player
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitReaction = UnitReaction

local PVP = PVP
local FACTION_BAR_COLORS = FACTION_BAR_COLORS

local PVP_LABEL = " (" .. PVP .. ")"

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPVP(unit)) then return end

    local reactionColor
    if SecretValue.IsTrue(UnitIsPlayer(unit)) then
        reactionColor = Player.GetReactionColor(unit)
    else
        local reaction = SecretValue.Usable(UnitReaction("player", unit))
        reactionColor = reaction and FACTION_BAR_COLORS[reaction]
    end
    reactionColor = reactionColor or FACTION_BAR_COLORS[5]

    local nameLine, nameText = Tooltip.GetNameLine(tooltip)
    if nameLine then
        nameLine:SetText(nameText .. reactionColor:WrapTextInColorCode(PVP_LABEL))
    end
end)