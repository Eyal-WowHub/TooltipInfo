if not TooltipDataProcessor.AddTooltipPostCall then return end

local GameTooltip = GameTooltip
local UnitIsPlayer = UnitIsPlayer
local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local CanInspect = CanInspect
local CheckInteractDistance = CheckInteractDistance
local GetInventoryItemLink = GetInventoryItemLink
local GetItemInfo = GetItemInfo
local GetAverageItemLevel = GetAverageItemLevel
local NotifyInspect = NotifyInspect
local ClearInspectPlayer = ClearInspectPlayer
local RoundToSignificantDigits = RoundToSignificantDigits
local GetTime = GetTime

local ITEM_LEVEL_FORMAT = NORMAL_FONT_COLOR:WrapTextInColorCode(STAT_AVERAGE_ITEM_LEVEL .. ":") .. " %d"

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

    local TWO_HANDED_WEAPONS = {
        [Enum.ItemWeaponSubclass.Axe2H] = true,
        [Enum.ItemWeaponSubclass.Mace2H] = true,
        [Enum.ItemWeaponSubclass.Sword2H] = true,
        [Enum.ItemWeaponSubclass.Polearm] = true,
        [Enum.ItemWeaponSubclass.Staff] = true
    }

    local function IsTwoHandedWeapon(classID, subclassID)
        return classID == Enum.ItemClass.Weapon and TWO_HANDED_WEAPONS[subclassID]
    end

    local function GetUnitAverageItemLevel(unit)
        local totalItemLevel, numSlots = 0, 17
        local mainHandKind, offHandKind = 0, 0

        for _, slot in ipairs(INV_SLOTS) do
            local itemLink = GetInventoryItemLink(unit, slot)
            if itemLink then
                local _, _, _, itemLevel, _, _, _, _, _, _, _, classID, subclassID = C_Item.GetItemInfo(itemLink)
                if itemLevel then
                    if slot == 16 then
                        mainHandKind = IsTwoHandedWeapon(classID, subclassID) and 2 or 1
                    elseif slot == 17 then
                        offHandKind = IsTwoHandedWeapon(classID, subclassID) and 2 or 1
                    end
                    totalItemLevel = totalItemLevel + itemLevel
                end
            end
        end

        if mainHandKind == 2 and offHandKind == 0 or mainHandKind == 0 and offHandKind == 0 then
            numSlots = 16
        end

        return totalItemLevel > 0 and totalItemLevel / numSlots or 0
    end

    local timerHandle = nil
    local lastInspectedGuid = nil
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event, guid)
        if event == "INSPECT_READY" then
            if UnitIsPlayer("mouseover") and UnitGUID("mouseover") == guid then
                local avgItemLevel = GetUnitAverageItemLevel("mouseover")
                if avgItemLevel > 0 then
                    ItemLevel:Cache(guid, avgItemLevel)
                    GameTooltip:Show()
                end
            end
            self:UnregisterEvent(event)
        end
    end)

    local function IsUnitInspectable(unit)
        return CanInspect(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit)
    end

    local function StartInspect()
        if IsUnitInspectable("mouseover") then
            frame:RegisterEvent("INSPECT_READY")
            NotifyInspect("mouseover")
        end
    end

    local function InspectAsync(unit)
        Player:ClearInspection()
        if IsUnitInspectable(unit) then
            timerHandle = C_Timer.NewTicker(2, StartInspect, 1)
        end
    end

    function Player:InspectAverageItemLevel(unit)
        local guid = UnitGUID(unit)
        local avgItemLevel = ItemLevel:Get(guid)
        if not avgItemLevel and lastInspectedGuid ~= guid then
            lastInspectedGuid = guid
            InspectAsync(unit)
            avgItemLevel = 0
        end
        return avgItemLevel
    end

    function Player:ClearInspection()
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

    Player:ClearInspection()

    local _, unit = tooltip:GetUnit()

    if unit and UnitIsPlayer(unit) then
        local avgItemLevel = 0
        
        if UnitIsUnit(unit, "player") then
            avgItemLevel = Player:GetAverageItemLevel()
        else
            avgItemLevel = Player:InspectAverageItemLevel(unit)
        end
        
        if avgItemLevel > 0 then
            avgItemLevel = RoundToSignificantDigits(avgItemLevel, 2)
            tooltip:AddLine(ITEM_LEVEL_FORMAT:format(avgItemLevel), 1, 1, 1)
        end
    end
end)