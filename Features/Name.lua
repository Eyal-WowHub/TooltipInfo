local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local UnitName = UnitName
local UnitClass = UnitClass
local UnitRealmRelationship = UnitRealmRelationship
local UnitPVPName = UnitPVPName
local GetRealmName = GetRealmName
local IsShiftKeyDown = IsShiftKeyDown

local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local LE_REALM_RELATION_COALESCED = LE_REALM_RELATION_COALESCED
local FOREIGN_SERVER_LABEL = " *"
local LE_REALM_RELATION_VIRTUAL = LE_REALM_RELATION_VIRTUAL
local INTERACTIVE_SERVER_LABEL = " #"

local NAME_LABEL = "%s-%s"

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.UnitName, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local unit = SafeUnit(lineData.unitToken)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local name, realm = UnitName(unit)
        local relationship = UnitRealmRelationship(unit)
        local _, classFilename = UnitClass(unit)

        if IsShiftKeyDown() then
            if unit == "player" then
                realm = GetRealmName()
            end
            if realm and realm ~= '' then
                name = NAME_LABEL:format(name, realm)
            end
        else
            name = UnitPVPName(unit) or name
            if relationship == LE_REALM_RELATION_COALESCED then
                name = name .. FOREIGN_SERVER_LABEL
            elseif relationship == LE_REALM_RELATION_VIRTUAL then
                name = name .. INTERACTIVE_SERVER_LABEL
            end
        end

        lineData.leftText = name

        if classFilename then
            local classColor = RAID_CLASS_COLORS[classFilename]
            if classColor then
                lineData.leftText = classColor:WrapTextInColorCode(lineData.leftText)
            end
        end
    end
end)