local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
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

local function GetTargetName(unit)
    local name, color = nil, nil
    local isPlayer = UnitIsUnit(unit, "player")
    if not IsSecret(isPlayer) and isPlayer then
        return PLAYER_LABEL
    end
    isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local classFilename = select(2, UnitClass(unit))
        if classFilename and not IsSecret(classFilename) then
            color = RAID_CLASS_COLORS[classFilename]
        end
    else
        local reaction = UnitReaction(unit, "player")
        if reaction and not IsSecret(reaction) then
            color = FACTION_BAR_COLORS[reaction]
        end
    end
    name = UnitName(unit)
    color = color or WHITE_FONT_COLOR
    if IsSecret(name) then
        return color:WrapTextInColorCode(("%s"):format(name))
    end
    return color:WrapTextInColorCode(name)
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local numLines = tooltip:NumLines()

    for i = 1, numLines do
        local line = _G["GameTooltipTextLeft" .. i]
        local text = line:GetText()
        local unit = unit .. "target"

        if text and not IsSecret(text) and text:find(THE_TARGET_FORMAT:format(".+")) then
            local exists = UnitExists(unit)
            if not IsSecret(exists) and exists then
                line:SetText(THE_TARGET_FORMAT:format(GetTargetName(unit)))
            else
                tooltip:SetUnit("mouseover")
            end
            break
        elseif i == numLines then
            local exists = UnitExists(unit)
            if not IsSecret(exists) and exists then
                tooltip:AddLine(THE_TARGET_FORMAT:format(GetTargetName(unit)))
            end
        end
    end
end)