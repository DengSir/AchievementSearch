
local ns = select(2, ...)
local debug, safefind = ns.debug, ns.safefind

local filterText

local achievementNames = setmetatable({}, {__index = function(t, id)
    t[id] = select(2, GetAchievementInfo(id)) or false
    return t[id]
end})

setfenv(AchievementFrameStats_Update, setmetatable({
    GetStatistic = function(...)
        local quantity, skip, id = GetStatistic(...)
        if filterText then
            local name = achievementNames[id]
            if name and not safefind(name, filterText) then
                skip = true
            end
        end
        return quantity, skip, id
    end
}, {__index = _G}))

local SearchBox = CreateFrame('EditBox', nil, AchievementFrameStats, 'SearchBoxTemplate') do
    SearchBox:SetPoint('TOPLEFT', AchievementFrame, 148, 7)
    SearchBox:SetSize(108, 15)
    SearchBox.Left:Hide()
    SearchBox.Right:Hide()
    SearchBox.Middle:Hide()
    SearchBox:HookScript('OnTextChanged', function(SearchBox)
        filterText = SearchBox:GetText()
        filterText = filterText ~= '' and filterText or nil
        STAT_FUNCTIONS.lastCategory = nil
        AchievementFrameStats_Update()
    end)

    local SearchInset = SearchBox.Left do
        SearchInset:Show()
        SearchInset:SetSize(128, 32)
        SearchInset:ClearAllPoints()
        SearchInset:SetPoint('TOPLEFT', AchievementFrameHeader, 'TOPLEFT', 111, -56)
        SearchInset:SetTexture([[Interface\AchievementFrame\UI-Achievement-RightDDLInset]])
        SearchInset:SetTexCoord(0, 1, 0, 1)
    end
end
