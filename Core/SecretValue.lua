local _, addon = ...

local issecretvalue = issecretvalue

--- Resolves a unit token, falling back to "mouseover" if it is a secret value.
--- @param unit any Unit token (possibly secret)
--- @return string|nil  Resolved unit token or nil
function addon.SafeUnit(unit)
    if issecretvalue and issecretvalue(unit) then
        unit = "mouseover"
    end
    return unit
end

--- Returns true if the given value is a secret value.
--- Safe to call on any WoW version (returns false if issecretvalue is unavailable).
--- @param val any
--- @return boolean
function addon.IsSecret(val)
    return issecretvalue and issecretvalue(val) or false
end
