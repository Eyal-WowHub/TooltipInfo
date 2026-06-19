local _, addon = ...

-- =====================================================================
-- Secret value safety layer
-- =====================================================================
-- Source: Patch 12.0.0 "AddOn security changes / Secret values" --
--   https://warcraft.wiki.gg/wiki/Patch_12.0.0/API_changes#Secret_values
--   (based on Blizzard's "Midnight Addon API Changes" notes; the per-
--   operation lists below are also confirmed empirically against runtime
--   errors). See also the issecretvalue() global used below.
--
-- Blizzard's design intent ("Combat Philosophy and Addon Disarmament in
-- Midnight", Ion Hazzikostas, 2025-11-13):
--   "Information about the current combat state is designated as a 'secret
--    value' that can be displayed by addons, but not 'known' by them.
--    Combat events are in a black box; addons can change the size or shape
--    of the box, and they can paint it a different color, but what they
--    can't do is look inside the box."
--   https://news.blizzard.com/en-us/article/24246290/combat-philosophy-and-addon-disarmament-in-midnight
--
-- WoW 12.0.0+ introduced "secret values": Combat/identity API calls
-- (UnitName, UnitHealth, UnitClass, ...) may return values that tainted
-- addon code is forbidden from operating on. The restrictions only fire
-- on tainted execution paths (all addon code is tainted).
--
-- Operations that ERROR on a secret value:
--   * arithmetic / relational comparison   (a + b, a > b, a == 0)
--   * boolean tests on secret *booleans*   (not v, if v then)   <- numbers/
--     strings are safe to truth-test because the type itself is not secret
--   * the length operator                  (#v)
--   * indexing / method calls              (v.field, v:method(), t[v])
--   * using a secret as a table key        (t[v] = x)
--   * calling a secret as a function       (v())
--
-- Operations that are ALWAYS ALLOWED on a secret value:
--   * storing it in a variable or table field
--   * passing it to a Lua function
--   * string concatenation                 (a .. b)
--   * string.format / string.concat / string.join
--   * widget setters that accept secrets   (FontString:SetText,
--     StatusBar:SetValue, StatusBar:SetMinMaxValues, ...)
--
-- Design rule for this addon: secrets may be *displayed* (concatenate /
-- format / SetText) but must never reach arithmetic, comparisons, boolean
-- tests, table keys, or indexing. The helpers below make that explicit.
-- =====================================================================

local issecretvalue = issecretvalue

local SecretValue = {}
addon.SecretValue = SecretValue

--- Returns true if the value is a secret value.
--- Safe on any client build (returns false when the API is unavailable).
--- @param value any
--- @return boolean
local function IsSecret(value)
    if not issecretvalue then return false end
    return issecretvalue(value)
end
SecretValue.IsSecret = IsSecret

--- Returns the value when it is safe to *operate* on (non-secret), else nil.
--- Use before any arithmetic, comparison, length, table-key, or indexing
--- operation, e.g. `local lvl = Usable(UnitLevel(unit)); if lvl and lvl > 0`.
--- @param value any
--- @return any|nil
local function Usable(value)
    if IsSecret(value) then return nil end
    return value
end
SecretValue.Usable = Usable

--- Safe boolean test for APIs that may return a secret boolean.
--- Returns true only when the value is non-secret AND truthy; a secret value
--- always yields false (we cannot prove it is true without testing it).
--- @param value any
--- @return boolean
local function IsTrue(value)
    if IsSecret(value) then return false end
    return value and true or false
end
SecretValue.IsTrue = IsTrue
