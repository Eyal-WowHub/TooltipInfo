local _, addon = ...
local IsSecret = addon.IsSecret

local Player = {}
addon.Player = Player

local UnitIsEnemy = UnitIsEnemy
local UnitCanAttack = UnitCanAttack

local FACTION_BAR_COLORS = FACTION_BAR_COLORS

function Player:GetReactionColor(unit)
    local reactionColor = FACTION_BAR_COLORS[5] -- Green (friendly)
    local isEnemy = UnitIsEnemy("player", unit)
    if not IsSecret(isEnemy) and isEnemy then
        reactionColor = FACTION_BAR_COLORS[1] -- Red (hostile)
    else
        local canAttack = UnitCanAttack("player", unit)
        if not IsSecret(canAttack) and canAttack then
            reactionColor = FACTION_BAR_COLORS[4] -- Yellow (neutral)
        end
    end
    return reactionColor
end