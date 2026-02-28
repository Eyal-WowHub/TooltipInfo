local _, addon = ...
local SafeUnit = addon.SafeUnit
local IsSecret = addon.IsSecret

local GameTooltip = GameTooltip
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CanInspect = CanInspect
local GetAverageItemLevel = GetAverageItemLevel
local GetInspectItemLevel = C_PaperDollInfo.GetInspectItemLevel
local NotifyInspect = NotifyInspect
local RoundToSignificantDigits = RoundToSignificantDigits
local GetTime = GetTime
local NewTicker = C_Timer.NewTicker

local ITEM_LEVEL_LABEL = NORMAL_FONT_COLOR:WrapTextInColorCode(STAT_AVERAGE_ITEM_LEVEL .. ":")

local function AddItemLine(avgItemLevel, refresh)
    if avgItemLevel > 0 then
        avgItemLevel = RoundToSignificantDigits(avgItemLevel, 2)
        GameTooltip:AddDoubleLine(ITEM_LEVEL_LABEL, avgItemLevel, nil, nil, nil, 1, 1, 1)
        if refresh then
            GameTooltip:Show()
        end
    end
end

local ItemLevel = {}
do
    local CACHE_EXPIRATION_TIME = 120

    local UNIT_ITEMLEVEL_CACHE = {}
    local UNIT_ITEMLEVEL_TIMESTAMP = {}

    function ItemLevel:Cache(guid, avgItemLevel)
        UNIT_ITEMLEVEL_CACHE[guid] = avgItemLevel
        UNIT_ITEMLEVEL_TIMESTAMP[guid] = GetTime()
    end

    function ItemLevel:Get(guid)
        local avgItemLevel = UNIT_ITEMLEVEL_CACHE[guid]
        local timestamp = UNIT_ITEMLEVEL_TIMESTAMP[guid]
        local elapsed = timestamp and (GetTime() - timestamp) or (CACHE_EXPIRATION_TIME + 1)

        if avgItemLevel and elapsed <= CACHE_EXPIRATION_TIME then
            return avgItemLevel  
        end

        UNIT_ITEMLEVEL_CACHE[guid] = nil
        UNIT_ITEMLEVEL_TIMESTAMP[guid] = nil

        return nil
    end
end

local Player = {}
do
    local INV_SLOTS = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}

    local timerHandle = nil
    local lastInspectedGuid = nil
    local lastInspectedUnit = nil
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event, guid)
        if event == "INSPECT_READY" then
            if lastInspectedUnit and UnitExists(lastInspectedUnit) and lastInspectedGuid == guid then
                local avgItemLevel = GetInspectItemLevel(lastInspectedUnit)
                if avgItemLevel > 0 then
                    ItemLevel:Cache(guid, avgItemLevel)
                    AddItemLine(avgItemLevel, true)
                end
                lastInspectedUnit = nil
                lastInspectedGuid = nil
            end
            self:UnregisterEvent(event)
        end
    end)

    local function IsUnitInspectable(unit)
        return CanInspect(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
    end

    local function StartInspect()
        if lastInspectedUnit and IsUnitInspectable(lastInspectedUnit) then
            frame:RegisterEvent("INSPECT_READY")
            NotifyInspect(lastInspectedUnit)
        end
    end

    local function InspectAsync(unit)
        Player:StopInspection()
        if IsUnitInspectable(unit) then
            timerHandle = NewTicker(0.5, StartInspect, 1)
        end
    end

    function Player:InspectAverageItemLevel(unit)
        lastInspectedUnit = unit

        local guid = UnitGUID(unit)
        local avgItemLevel = ItemLevel:Get(guid) or 0

        if avgItemLevel == 0 and lastInspectedGuid ~= guid then
            lastInspectedGuid = guid
            InspectAsync(unit)
        end

        return avgItemLevel
    end

    function Player:StopInspection()
        if timerHandle then
            timerHandle:Cancel()
            timerHandle = nil
        end
    end

    function Player:GetAverageItemLevel()
        local _, equipped = GetAverageItemLevel()
        return equipped or 0
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local _, unit = tooltip:GetUnit()
    unit = SafeUnit(unit)

    local isPlayer = unit and UnitIsPlayer(unit)
    if not IsSecret(isPlayer) and isPlayer then
        local avgItemLevel = 0

        local isSelf = UnitIsUnit(unit, "player")
        if not IsSecret(isSelf) and isSelf then
            avgItemLevel = Player:GetAverageItemLevel()
        elseif IsShiftKeyDown() then
            avgItemLevel = Player:InspectAverageItemLevel(unit)
        end

        AddItemLine(avgItemLevel)
    else
        Player:StopInspection()
    end
end)