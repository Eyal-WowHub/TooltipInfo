local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo

local GUILD_FORMAT = "|cff00ff10%s|r |cff00ff10<%s>|r"
local GUILD_FULLNAME_FORMAT = "%s-%s"

local lineNumber = 2

TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tooltip, lineData)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()

    lineNumber = lineNumber > tooltip:NumLines() and 2 or lineNumber + 1

    if unit and UnitIsPlayer(unit) and lineNumber == 2 then
        local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
        if not guildName then
            return
        end
        if lineData.leftText:find(guildName) then
            local guildFullName = guildName

            if guildRealm and IsShiftKeyDown() then
                guildFullName = GUILD_FULLNAME_FORMAT:format(guildName, guildRealm)
            end

            lineData.leftText = GUILD_FORMAT:format(guildFullName, guildRankName)
        end
    end
end)