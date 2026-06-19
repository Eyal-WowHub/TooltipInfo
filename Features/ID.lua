local select = select

local GameTooltip = GameTooltip
local BattlePetTooltip = BattlePetTooltip
local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local StaticPopup_Visible = StaticPopup_Visible
local StaticPopup_Show = StaticPopup_Show
local GetPetInfoByPetID = C_PetJournal.GetPetInfoByPetID

local _G = _G
local ID = _G.ID

local ITEM_LABEL = "Item ID"
local SPELL_LABEL = "Spell ID"
local AURA_LABEL = "Aura ID"
local BATTLE_PET_LABEL = "Battle Pet ID"
local QUEST_LABEL = "Quest ID"
local MOUNT_LABEL = "Mount ID"
local TOY_LABEL = "Toy ID"
local CURRENCY_LABEL = "Currency ID"
local FACTION_LABEL = "Faction ID"

local ID_FORMAT = "|cffca3c3c<%s>|r %s"

local LINK_PATTERN = ":(%w+)"

local Info = {}
do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:SetScript("OnEvent", function(_, _, key, down)
        if StaticPopup_Visible("TOOLTIPINFO_COPY_ID") then return end
        if key:find("ALT") and down == 1 and Info.id then
            StaticPopup_Show("TOOLTIPINFO_COPY_ID", Info.label, nil, Info)
        end
    end)

    hooksecurefunc(GameTooltip, "Hide", function()
        Info.id = nil
    end)

    function Info:Add(label, id)
        if label and id then
            self.label = label
            self.id = id
        end
    end
end

local function AddIDLine(label, id, tooltip, refresh)
    if label and id and tooltip then
        Info:Add(label, id)
        id = ID_FORMAT:format(ID, id)
        tooltip:AddLine(id)
        if refresh then
            tooltip:Show()
        end
    end
end

TooltipDataProcessor.AddTooltipPostCall(TooltipDataProcessor.AllTypes, function(tooltip, data)
    if not IsControlKeyDown() then return end
    if tooltip:IsForbidden() then return end

    local label = nil
    local id = data and data.id

    if data.type == Enum.TooltipDataType.Item then
        if not id then
            local GetItem = tooltip.GetItem
            if GetItem then
                local _, link = GetItem(tooltip)
                if link then
                    id = link:match(LINK_PATTERN)
                end
            end
        end
        label = ITEM_LABEL
    elseif data.type == Enum.TooltipDataType.Spell then
        if not id then
            id = select(2, tooltip:GetSpell())
        end
        label = SPELL_LABEL
    elseif data.type == Enum.TooltipDataType.UnitAura then
        if not id then
            local info = tooltip:GetPrimaryTooltipInfo()
            if info and info.getterArgs then
                local unit, index, filter = unpack(info.getterArgs)
                local auraData = GetAuraDataByIndex(unit, index, filter)
                if auraData then
                    id = auraData.spellId
                end
            end
        end
        label = AURA_LABEL
    elseif data.type == Enum.TooltipDataType.Mount then
        label = MOUNT_LABEL
    elseif data.type == Enum.TooltipDataType.CompanionPet then
        if not id then
            local info = tooltip:GetPrimaryTooltipInfo()
            if info and info.getterArgs then
                local battlePetGuid = unpack(info.getterArgs)
                id = GetPetInfoByPetID(battlePetGuid)
            end
        end
        label = BATTLE_PET_LABEL
    elseif data.type == Enum.TooltipDataType.Toy then
        label = TOY_LABEL
    elseif data.type == Enum.TooltipDataType.Currency then
        label = CURRENCY_LABEL
    end

    AddIDLine(label, id, tooltip)
end)

hooksecurefunc("BattlePetToolTip_Show", function(battlePetSpeciesID)
    if not IsControlKeyDown() then return end
    if BattlePetTooltip:IsForbidden() then return end

    AddIDLine(BATTLE_PET_LABEL, battlePetSpeciesID, BattlePetTooltip, true)
end)

hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(frame)
    if not IsControlKeyDown() then return end
    if GameTooltip:IsForbidden() then return end

    local questID = frame.questLogIndex and GetQuestIDForLogIndex(frame.questLogIndex)

    AddIDLine(QUEST_LABEL, questID, GameTooltip, true)
end)

hooksecurefunc("TaskPOI_OnEnter", function(frame)
    if not IsControlKeyDown() then return end
    if GameTooltip:IsForbidden() then return end

    local questID = frame.questID

    AddIDLine(QUEST_LABEL, questID, GameTooltip, true)
end)

do
    local function ShowTooltipForReputationType(self)
        if not self or not self.elementData then return end
        if not IsControlKeyDown() then return end
        if GameTooltip:IsForbidden() then return end
  
        AddIDLine(FACTION_LABEL, self.elementData.factionID, GameTooltip, true)
    end

    local function OnInitializedFrame(_, frame)
        if frame.ShowTooltipForReputationType and not frame.__isHooked then
            hooksecurefunc(frame, "ShowTooltipForReputationType", ShowTooltipForReputationType)
            frame.__isHooked = true
        end
    end

    ReputationFrame.ScrollBox.view:RegisterCallback(
        ScrollBoxListViewMixin.Event.OnInitializedFrame, 
        OnInitializedFrame)
end


