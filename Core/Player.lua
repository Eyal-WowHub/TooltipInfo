local _, addon = ...
local SecretValue = addon.SecretValue

local Player = {}
addon.Player = Player

local UnitIsEnemy = UnitIsEnemy
local UnitCanAttack = UnitCanAttack

local FACTION_BAR_COLORS = FACTION_BAR_COLORS

--- Returns a faction bar colour for the unit, defaulting to friendly green.
--- Reaction APIs may return secret booleans, so they are tested with IsTrue.
--- @param unit string
--- @return table ColorMixin
function Player.GetReactionColor(unit)
    if SecretValue.IsTrue(UnitIsEnemy("player", unit)) then
        return FACTION_BAR_COLORS[1] -- Red (hostile)
    elseif SecretValue.IsTrue(UnitCanAttack("player", unit)) then
        return FACTION_BAR_COLORS[4] -- Yellow (neutral)
    end
    return FACTION_BAR_COLORS[5] -- Green (friendly)
end