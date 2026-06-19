local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue
local Tooltip = addon.Tooltip

local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo
local IsShiftKeyDown = IsShiftKeyDown

local GUILD_FORMAT = GREEN_FONT_COLOR:WrapTextInColorCode("%s <%s>")
local GUILD_FULLNAME_FORMAT = "%s-%s"

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    addon._guildLineIndex = nil

    -- guildName is used as a string.find pattern (FindLine) and as a format
    -- argument, so it must be non-secret; the rank/realm are only formatted.
    local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
    guildName = SecretValue.Usable(guildName)
    if not guildName or not guildRankName then return end

    local fontString, _, i = Tooltip.FindLine(tooltip, guildName)
    if not fontString then return end
    addon._guildLineIndex = i

    local guildFullName = guildName
    guildRealm = SecretValue.Usable(guildRealm)
    if guildRealm and IsShiftKeyDown() then
        guildFullName = GUILD_FULLNAME_FORMAT:format(guildName, guildRealm)
    end

    fontString:SetText(GUILD_FORMAT:format(guildFullName, guildRankName))
end)