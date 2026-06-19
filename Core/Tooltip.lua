local _, addon = ...
local SecretValue = addon.SecretValue

local Tooltip = {}
addon.Tooltip = Tooltip

--- Returns the name line (first left fontString) and its text.
--- Returns nothing when the line text is secret (it cannot be safely
--- read back or appended to once another feature has set a secret value).
--- @param tooltip table
--- @return table|nil fontString
--- @return string|nil text
function Tooltip.GetNameLine(tooltip)
    local fontString = GameTooltipTextLeft1
    local text = fontString:GetText()
    if not text or SecretValue.IsSecret(text) then return end
    return fontString, text
end

--- Returns the left fontString at `index` and its text, or nothing when the
--- index is missing or the text is secret.
--- @param tooltip table
--- @param index number|nil
--- @return table|nil fontString
--- @return string|nil text
function Tooltip.GetLine(tooltip, index)
    if not index then return end
    local fontString = _G["GameTooltipTextLeft" .. index]
    if not fontString then return end
    local text = fontString:GetText()
    if not text or SecretValue.IsSecret(text) then return end
    return fontString, text
end

--- Finds the first left line whose text contains `search`.
--- Bails when `search` is secret (a secret search term cannot be used as a
--- `string.find` argument) and skips any line whose text is secret.
--- @param tooltip table
--- @param search string
--- @param startIndex number|nil
--- @return table|nil fontString
--- @return string|nil text
--- @return number|nil index
function Tooltip.FindLine(tooltip, search, startIndex)
    if not search or SecretValue.IsSecret(search) then return end
    for i = (startIndex or 2), tooltip:NumLines() do
        local fontString = _G["GameTooltipTextLeft" .. i]
        local text = fontString and fontString:GetText()
        if text and not SecretValue.IsSecret(text) and text:find(search, 1, true) then
            return fontString, text, i
        end
    end
end
