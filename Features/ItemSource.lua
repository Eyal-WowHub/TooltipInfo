local _, addon = ...
local SecretValue = addon.SecretValue

local GetDisplayedItem = TooltipUtil and TooltipUtil.GetDisplayedItem
local GetItemInfo = GetItemInfo

local _G = _G

local EXPAC_LABEL = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(SOURCE) .. " %s"

local LINK_PATTERN = ":(%w+)"

local ITEMS_CACHE = {}

do
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    frame:SetScript("OnEvent", function(_, _, itemID, success)
        if success and not ITEMS_CACHE[itemID] then
            local expacID = select(15, GetItemInfo(itemID))
            if expacID then
                ITEMS_CACHE[itemID] = _G["EXPANSION_NAME" .. expacID]
            end
        end
    end)
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if tooltip:IsForbidden() then return end
    if tooltip ~= GameTooltip then return end

    local itemID = data and data.id

    if not itemID then
        local GetItem = GetDisplayedItem or tooltip.GetItem
        if GetItem then
            -- A secret or missing link cannot be indexed via :match.
            local link = SecretValue.Usable(select(2, GetItem(tooltip)))
            if link then
                itemID = link:match(LINK_PATTERN)
            end
        end
    end

    -- itemID is used as a table key, so it must be non-secret.
    itemID = SecretValue.Usable(itemID)
    local itemExpacSourceName = itemID and ITEMS_CACHE[itemID]

    if itemExpacSourceName then
        tooltip:AddLine(" ")
        tooltip:AddLine(EXPAC_LABEL:format(itemExpacSourceName))
    end
end)