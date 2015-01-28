
local ns = select(2, ...)
local debug, safefind = ns.debug, ns.safefind

local filterText
local filterList = {}

-- hook native api
local function MakeGetCategoryNumAchievements(name)
    local old = _G[name]
    _G[name] = function(categoryID)
        local numAchievements, numCompleted, completedOffset = old(categoryID)
        if not filterText then
            return numAchievements, numCompleted, completedOffset
        else
            wipe(filterList)
            for i = 1 + completedOffset, numAchievements + completedOffset do
                local id, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuild, wasEarnedByMe, earnedBy = GetAchievementInfo(categoryID, i)
                if id and (safefind(name, filterText) or safefind(description, filterText) or safefind(rewardText, filterText)) then
                    tinsert(filterList, i)
                end
            end
            local num = #filterList
            if num > 0 then
                debug('achievement found: ' .. num .. ', keyword: ' .. filterText)
            else
                debug('achievement not found, keyword: ' .. filterText)
            end
            return num, 0--[[not used]], 0
        end
    end
end

MakeGetCategoryNumAchievements('AchievementFrame_GetCategoryNumAchievements_All')
MakeGetCategoryNumAchievements('AchievementFrame_GetCategoryNumAchievements_Complete')
MakeGetCategoryNumAchievements('AchievementFrame_GetCategoryNumAchievements_Incomplete')

ACHIEVEMENTUI_SELECTEDFILTER = AchievementFrame_GetCategoryNumAchievements_All
AchievementFrameFilters[1].func = AchievementFrame_GetCategoryNumAchievements_All
AchievementFrameFilters[2].func = AchievementFrame_GetCategoryNumAchievements_Complete
AchievementFrameFilters[3].func = AchievementFrame_GetCategoryNumAchievements_Incomplete

setfenv(AchievementFrameAchievements_Update, setmetatable({
    AchievementButton_DisplayAchievement = function(button, category, achievement, selectionID)
        return AchievementButton_DisplayAchievement(button, category, filterText and filterList[achievement] or achievement, selectionID)
    end
}, {__index = _G}))

-- create search box
local SearchBox = CreateFrame('EditBox', nil, AchievementFrameFilterDropDown, 'SearchBoxTemplate') do
    SearchBox:SetPoint('TOPLEFT', AchievementFrame, 148, 7)
    SearchBox:SetSize(108, 15)
    SearchBox.Left:Hide()
    SearchBox.Right:Hide()
    SearchBox.Middle:Hide()
    SearchBox:HookScript('OnTextChanged', function(SearchBox)
        filterText = SearchBox:GetText()
        filterText = filterText ~= '' and filterText or nil
        AchievementFrameAchievements_Update()
    end)
    SearchBox:SetScript('OnHide', function(SearchBox)
        filterText = nil
        AchievementFrameAchievements_Update()
    end)
    SearchBox:SetScript('OnShow', SearchBox:GetScript('OnTextChanged'))

    local SearchInset = SearchBox.Left do
        SearchInset:Show()
        SearchInset:SetSize(128, 32)
        SearchInset:ClearAllPoints()
        SearchInset:SetPoint('TOPLEFT', AchievementFrameHeader, 'TOPLEFT', 111, -56)
        SearchInset:SetTexture([[Interface\AchievementFrame\UI-Achievement-RightDDLInset]])
        SearchInset:SetTexCoord(0, 1, 0, 1)
    end
end
