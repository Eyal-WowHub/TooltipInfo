local _, addon = ...
local SafeUnit = addon.SafeUnit
local SecretValue = addon.SecretValue

local next = next

local UnitIsPlayer = UnitIsPlayer
local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local GetDungeonScoreRarityColor = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor

local MYTHIC_PLUS_RATING_LABEL = DUNGEON_SCORE .. ":"
local MYTHIC_PLUS_BEST_RUN_LABEL = PLAYER_DIFFICULTY_MYTHIC_PLUS .. " "  .. DUNGEON_SCORE_BEST_AFFIX:gsub(" %%s", ": ")

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit.GetUnit(unit)
    if not unit then return end

    if not SecretValue.IsTrue(UnitIsPlayer(unit)) then return end

    -- The summary table and its fields may be secret under stat restrictions.
    -- They feed comparisons and a rarity-colour lookup, so they must be
    -- non-secret to evaluate; otherwise the section is skipped.
    local info = SecretValue.Usable(GetPlayerMythicPlusRatingSummary(unit))
    if not info then return end

    local score = SecretValue.Usable(info.currentSeasonScore)
    if not score or score <= 0 then return end

    local color = GetDungeonScoreRarityColor and GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR

    tooltip:AddDoubleLine(MYTHIC_PLUS_RATING_LABEL, score, nil, nil, nil, color.r, color.g, color.b)

    local runs = SecretValue.Usable(info.runs)
    if not runs then return end

    local bestRun = 0
    local challengeModeID

    for _, run in next, runs do
        local runLevel = SecretValue.Usable(run.bestRunLevel)
        if SecretValue.IsTrue(run.finishedSuccess) and runLevel and runLevel > bestRun then
            bestRun = runLevel
            challengeModeID = SecretValue.Usable(run.challengeModeID)
        end
    end

    if bestRun > 0 then
        if not IsShiftKeyDown() then
            tooltip:AddDoubleLine(MYTHIC_PLUS_BEST_RUN_LABEL, bestRun, nil, nil, nil, color.r, color.g, color.b)
        elseif challengeModeID then
            tooltip:AddLine(MYTHIC_PLUS_BEST_RUN_LABEL)
            local mapName = C_ChallengeMode.GetMapUIInfo(challengeModeID)
            if mapName then
                tooltip:AddDoubleLine("  " .. mapName, bestRun, color.r, color.g, color.b, color.r, color.g, color.b)
            end
        end
    end
end)

