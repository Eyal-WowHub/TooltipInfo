local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local UnitIsPlayer = UnitIsPlayer
local GetPlayerMythicPlusRatingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary
local GetDungeonScoreRarityColor = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor

local MYTHIC_PLUS_RATING_LABEL = DUNGEON_SCORE .. ":"
local MYTHIC_PLUS_BEST_RUN_LABEL = PLAYER_DIFFICULTY_MYTHIC_PLUS .. " "  .. DUNGEON_SCORE_BEST_AFFIX:gsub(" %%s", ": ")

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)
    if not unit then return end

    local isPlayer = UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local info = GetPlayerMythicPlusRatingSummary(unit)
        local score = info and info.currentSeasonScore

        if score and score > 0 then
            local color

            if GetDungeonScoreRarityColor then
                color = GetDungeonScoreRarityColor(score)
            end

            if not color then
                color = HIGHLIGHT_FONT_COLOR
            end

            tooltip:AddDoubleLine(MYTHIC_PLUS_RATING_LABEL, score, nil, nil, nil, color.r, color.g, color.b)

            local bestRun = 0
            local challengeModeID = 0

            for _, run in next, info.runs do
                if run.finishedSuccess and run.bestRunLevel > bestRun then
                    bestRun = run.bestRunLevel
                    challengeModeID = run.challengeModeID
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
        end
    end
end)

