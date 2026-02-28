local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo

local GUILD_FORMAT = GREEN_FONT_COLOR:WrapTextInColorCode("%s <%s>")
local GUILD_FULLNAME_FORMAT = "%s-%s"

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)

        if not guildName then
            return
        end

        if IsSecret(lineData.leftText) then return end
        if lineData.leftText:find(guildName) and not lineData.isGuildLine then
            lineData.isGuildLine = true

            local guildFullName = guildName

            if guildRealm and IsShiftKeyDown() then
                guildFullName = GUILD_FULLNAME_FORMAT:format(guildName, guildRealm)
            end

            lineData.leftText = GUILD_FORMAT:format(guildFullName, guildRankName)
        end
    end
end)