local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local select = select

local UnitIsPlayer = UnitIsPlayer
local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitExists = UnitExists
local UnitClass = UnitClass

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local STATUSBAR_TEXTURE = "Interface\\TargetingFrame\\UI-TargetingFrame-BarFill"
local STATUSBAR_HEIGHT = 12

-- Hide Blizzard's default health bar to avoid all taint / secret-value issues.
-- We create our own StatusBar that reads health exclusively from UnitHealth().
GameTooltipStatusBar:Hide()
GameTooltipStatusBar:HookScript("OnShow", GameTooltipStatusBar.Hide)

------------------------------------------------------------
-- Custom Health Bar
------------------------------------------------------------

local HealthBar = CreateFrame("StatusBar", nil, GameTooltip)
HealthBar:SetHeight(STATUSBAR_HEIGHT)
HealthBar:SetStatusBarTexture(STATUSBAR_TEXTURE)
HealthBar:SetPoint("TOPLEFT", GameTooltip, "BOTTOMLEFT", 2, -1)
HealthBar:SetPoint("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -2, -1)
HealthBar:Hide()

do
    local bg = HealthBar:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture(STATUSBAR_TEXTURE)
    bg:SetAllPoints()
    bg:SetVertexColor(0.33, 0.33, 0.33, 0.5)
    HealthBar.Background = bg
end

do
    local text = HealthBar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    text:SetPoint("CENTER")
    HealthBar.Text = text
end

------------------------------------------------------------
-- Update
------------------------------------------------------------
-- StatusBar:SetMinMaxValues() and StatusBar:SetValue() accept secret values,
-- so the bar always fills visually even in restricted content. Only arithmetic
-- and comparisons (>, <, ==, /, %.0f) fail on secrets, so those are gated
-- behind Usable(); the secret fallback formats with %s, the only specifier
-- permitted on secret numbers.

local function UpdateHealthBar(unit)
    unit = SafeUnit.GetUnit(unit)
    if not unit then
        HealthBar:Hide()
        return
    end

    if SecretValue.IsTrue(UnitIsDeadOrGhost(unit)) then
        HealthBar:Hide()
        return
    end

    local health    = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)

    local usableHealth = SecretValue.Usable(health)
    local usableHealthMax = SecretValue.Usable(healthMax)

    if usableHealth and usableHealthMax then
        if usableHealthMax == 0 then
            HealthBar:Hide()
            return
        end

        HealthBar:SetMinMaxValues(0, usableHealthMax)
        HealthBar:SetValue(usableHealth)
        HealthBar.Text:SetFormattedText(
            "%s / %s (%.0f%%)",
            BreakUpLargeNumbers(usableHealth),
            BreakUpLargeNumbers(usableHealthMax),
            usableHealth / usableHealthMax * 100
        )
    else
        -- Health is secret: the setters still accept it (the bar fills), and
        -- %s is the only format specifier allowed on a secret number.
        HealthBar:SetMinMaxValues(0, healthMax)
        HealthBar:SetValue(health)
        HealthBar.Text:SetFormattedText("%s / %s", health, healthMax)
    end

    -- Colour: flat green for NPCs, class colour for players.
    local r, g, b = 0, 1, 0
    if SecretValue.IsTrue(UnitIsPlayer(unit)) then
        local classFilename = SecretValue.Usable(select(2, UnitClass(unit)))
        local classColor = classFilename and RAID_CLASS_COLORS[classFilename]
        if classColor then
            r, g, b = classColor.r, classColor.g, classColor.b
        end
    end

    HealthBar:SetStatusBarColor(r, g, b)
    HealthBar:Show()
end

------------------------------------------------------------
-- Real-time update
------------------------------------------------------------

local UPDATE_INTERVAL = 0.1
local timeSinceLastUpdate = 0

HealthBar:SetScript("OnUpdate", function(self, elapsed)
    if not self.unit then return end
    if not UnitExists(self.unit) then return end

    timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    if timeSinceLastUpdate < UPDATE_INTERVAL then return end
    timeSinceLastUpdate = 0

    UpdateHealthBar(self.unit)
end)

------------------------------------------------------------
-- Tooltip events
------------------------------------------------------------

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then
        HealthBar.unit = nil
        HealthBar:Hide()
        return
    end

    HealthBar.unit = unit
    UpdateHealthBar(unit)

    if HealthBar:IsShown() then
        local textWidth = HealthBar.Text:GetStringWidth()

        if textWidth and not SecretValue.IsSecret(textWidth) and textWidth > 0 then
            tooltip:SetMinimumWidth(textWidth)
        end
    end
end)

GameTooltip:HookScript("OnTooltipCleared", function()
    HealthBar.unit = nil
    HealthBar:Hide()
end)

GameTooltip:HookScript("OnHide", function()
    HealthBar.unit = nil
    HealthBar:Hide()
end)