local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local GameTooltip = GameTooltip
local GameTooltipStatusBar = GameTooltipStatusBar

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsPlayer = UnitIsPlayer
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
-- Key insight from TipTac: StatusBar:SetMinMaxValues() and StatusBar:SetValue()
-- accept secret values – the bar fills visually. String operations
-- (string.format, SetFormattedText) also work with secrets.
-- Only arithmetic comparisons (>, <, ==) fail with secrets.
-- For colour we use UnitHealthPercent() which returns a non-secret percentage.

local function UpdateHealthBar(unit)
    unit = SafeUnit(unit)
    if not unit then
        HealthBar:Hide()
        return
    end

    -- Hide bar if unit is dead.
    local isDead = UnitIsDeadOrGhost(unit)
    if not IsSecret(isDead) and isDead then
        HealthBar:Hide()
        return
    end

    local health    = UnitHealth(unit)
    local healthMax = UnitHealthMax(unit)

    local healthIsSecret    = IsSecret(health)
    local healthMaxIsSecret = IsSecret(healthMax)

    -- When values are NOT secret we can perform normal nil / zero checks.
    if not healthIsSecret and not healthMaxIsSecret then
        if not health or not healthMax or healthMax == 0 then
            HealthBar:Hide()
            return
        end
    end

    -- SetMinMaxValues / SetValue accept secret values – the bar fills visually.
    HealthBar:SetMinMaxValues(0, healthMax)
    HealthBar:SetValue(health)

    -- Text ------------------------------------------------------------------
    -- SetFormattedText with %s converts secrets to their string representation.
    -- Health and percentage are secret values in 12.0.0+; arithmetic (%.0f)
    -- fails on secrets, but %s works.  For non-secret values we can format nicely.
    if healthIsSecret or healthMaxIsSecret then
        -- Values are secret – use %s which stringifies secrets correctly.
        -- Try to include percentage from UnitHealthPercent (also secret, but %s handles it).
        if UnitHealthPercent then
            local percent = UnitHealthPercent(unit, nil, CurveConstants and CurveConstants.ScaleTo100)

            if percent then
                HealthBar.Text:SetFormattedText("%s / %s (%.0f%%)", health, healthMax, percent)
            else
                HealthBar.Text:SetFormattedText("%s / %s", health, healthMax)
            end
        else
            HealthBar.Text:SetFormattedText("%s / %s", health, healthMax)
        end
    else
        HealthBar.Text:SetFormattedText(
            "%s / %s (%.0f%%)",
            BreakUpLargeNumbers(health),
            BreakUpLargeNumbers(healthMax),
            health / healthMax * 100
        )
    end

    -- Colour ----------------------------------------------------------------
    -- Gradient is not possible with secret values (12.0.0+) since Lua arithmetic
    -- on secrets is blocked and taint cannot be stripped. Use flat colour instead:
    -- green for NPCs, class colour for players.
    local r, g, b = 0, 1, 0

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local _, classFilename = UnitClass(unit)

        if classFilename and not IsSecret(classFilename) then
            local classColor = RAID_CLASS_COLORS[classFilename]

            if classColor then
                r, g, b = classColor.r, classColor.g, classColor.b
            end
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
    unit = SafeUnit(unit)
    if not unit then
        HealthBar.unit = nil
        HealthBar:Hide()
        return
    end

    HealthBar.unit = unit
    UpdateHealthBar(unit)

    if HealthBar:IsShown() then
        local textWidth = HealthBar.Text:GetStringWidth()

        if textWidth and not IsSecret(textWidth) and textWidth > 0 then
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