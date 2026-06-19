local _, addon = ...

local SecretValue = addon.SecretValue

local SafeUnit = {}
addon.SafeUnit = SafeUnit

--- Resolves the unit token returned by `tooltip:GetUnit()`.
--- A secret unit token cannot be used for indexing or comparisons, so it is
--- replaced with the plain "mouseover" token the tooltip is describing.
--- @param unit any Unit token (possibly secret)
--- @return string|nil
function SafeUnit.GetUnit(unit)
    if SecretValue.IsSecret(unit) then
        return "mouseover"
    end
    return unit
end
