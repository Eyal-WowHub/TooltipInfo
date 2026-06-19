local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local select = select

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

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    -- Only reformat player names; NPCs keep the Blizzard default line.
    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- The name may be a secret value. It is safe to display (concatenate /
    -- format / SetText) but must never be compared or indexed, so it flows
    -- straight through to SetText untouched.
    local name = UnitName(unit)
    if not name then return end

    if IsShiftKeyDown() then
        local realm
        if unit == "player" then
            realm = GetRealmName()
        else
            realm = select(2, UnitName(unit))
        end
        realm = SecretValue.Usable(realm)
        if realm and realm ~= "" then
            name = NAME_LABEL:format(name, realm)
        end
    else
        local pvpName = UnitPVPName(unit)
        if pvpName then
            name = pvpName
        end

        local relationship = SecretValue.Usable(UnitRealmRelationship(unit))
        if relationship == LE_REALM_RELATION_COALESCED then
            name = name .. FOREIGN_SERVER_LABEL
        elseif relationship == LE_REALM_RELATION_VIRTUAL then
            name = name .. INTERACTIVE_SERVER_LABEL
        end
    end

    -- Class colour requires the class file name as a table key, so it must be
    -- non-secret; if it is secret we display the (possibly secret) name plain.
    local classFilename = SecretValue.Usable(select(2, UnitClass(unit)))
    local classColor = classFilename and RAID_CLASS_COLORS[classFilename]
    if classColor then
        name = classColor:WrapTextInColorCode(name)
    end

    GameTooltipTextLeft1:SetText(name)
end)