local _, addon = ...
local SecretValue = addon.SecretValue

local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit

local GameTooltip = GameTooltip

local frame = CreateFrame("Frame")
frame:RegisterEvent("MODIFIER_STATE_CHANGED")
frame:SetScript("OnEvent", function(self, event, key, down)
    if not key:find("SHIFT") then return end
    if GameTooltip:IsForbidden() or not GameTooltip:IsShown() then return end

    -- The identity APIs may return secret booleans in restricted content, so
    -- they are tested with IsTrue. A secret self-check resolves to "not self",
    -- which only triggers a harmless re-render.
    if SecretValue.IsTrue(UnitIsPlayer("mouseover")) and not SecretValue.IsTrue(UnitIsUnit("mouseover", "player")) then
        GameTooltip:RefreshData()
    end
end)