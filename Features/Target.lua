local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local select = select

local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitName = UnitName
local UnitExists = UnitExists

local _G = _G
local TARGET = TARGET
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local PLAYER_LABEL = WHITE_FONT_COLOR:WrapTextInColorCode("<" .. UNIT_YOU ..">")
local THE_TARGET_FORMAT = NORMAL_FONT_COLOR:WrapTextInColorCode(TARGET .. ": %s")
local TARGET_MATCH = TARGET .. ": "

local function GetTargetName(unit)
    if SecretValue.IsTrue(UnitIsUnit(unit, "player")) then
        return PLAYER_LABEL
    end

    local color
    if SecretValue.IsTrue(UnitIsPlayer(unit)) then
        local classFilename = SecretValue.Usable(select(2, UnitClass(unit)))
        color = classFilename and RAID_CLASS_COLORS[classFilename]
    else
        local reaction = SecretValue.Usable(UnitReaction(unit, "player"))
        color = reaction and FACTION_BAR_COLORS[reaction]
    end
    color = color or WHITE_FONT_COLOR

    -- The name may be secret; WrapTextInColorCode concatenates colour codes,
    -- which is permitted on secret strings, so it is only ever displayed.
    return color:WrapTextInColorCode(UnitName(unit))
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    local targetUnit = unit .. "target"
    if not SecretValue.IsTrue(UnitExists(targetUnit)) then return end

    local targetLabel = THE_TARGET_FORMAT:format(GetTargetName(targetUnit))

    -- If a target line is already present (e.g. a tooltip refresh), update it
    -- in place; otherwise append a new line. Never call tooltip:SetUnit here:
    -- it re-enters every tooltip post-call and recurses.
    for i = 1, tooltip:NumLines() do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line and line:GetText()
        if text and not SecretValue.IsSecret(text) and text:find(TARGET_MATCH, 1, true) then
            line:SetText(targetLabel)
            return
        end
    end

    tooltip:AddLine(targetLabel)
end)