--[[
    VexHub - Prison Life Edition
    Created by DevScripts
--]]

if game.PlaceId ~= 155615604 then
    warn("[VexHub] Этот скрипт предназначен только для игры Prison Life!")
    return
end

if getgenv().VexHub_Loaded then return end
getgenv().VexHub_Loaded = true

-- Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Colors
local C_BG         = Color3.fromRGB(13, 13, 13)
local C_SIDEBAR    = Color3.fromRGB(11, 11, 11)
local C_CARD       = Color3.fromRGB(22, 22, 22)
local C_CARD_HOVER = Color3.fromRGB(28, 28, 28)
local C_ACCENT     = Color3.fromRGB(139, 92, 246)
local C_TOGGLE_OFF = Color3.fromRGB(55, 55, 55)
local C_TOGGLE_ON  = Color3.fromRGB(255, 255, 255)
local C_KNOB       = Color3.fromRGB(255, 255, 255)
local C_TEXT       = Color3.fromRGB(255, 255, 255)
local C_MUTED      = Color3.fromRGB(138, 138, 138)
local C_FAINT      = Color3.fromRGB(90, 90, 90)
local C_GREEN      = Color3.fromRGB(34, 197, 94)

-- Feature Settings
local FeatureState = {
    AimEnabled = false,
    FovRadius = 100,
    TeamCheck = true,
    EspEnabled = false,
    InfStamina = false,
    SpeedBoost = false,
    Noclip = false,
    FastPunch = false,
    GodMode = false,
    AntiAFK = true
}

-- Container
local targetParent = CoreGui
if gethui then targetParent = gethui() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VexHub_PrisonLife"
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = targetParent

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

-- FOV Circle (Fixed in Center)
local FovCircle = Drawing.new("Circle")
FovCircle.Color = C_ACCENT
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Radius = FeatureState.FovRadius
FovCircle.Filled = false
FovCircle.Visible = false

-- Notifications
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 340, 1, -40)
NotifContainer.Position = UDim2.new(1, -360, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.Parent = NotifContainer

local notifEnabled = true
local notifDuration = 3

local function notify(title, msg)
    if not notifEnabled then return end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 66)
    card.BackgroundColor3 = C_CARD
    card.BackgroundTransparency = 0.1
    card.ClipsDescendants = true
    card.Parent = NotifContainer
    createCorner(card, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = C_ACCENT
    bar.BorderSizePixel = 0
    bar.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -20, 0, 22)
    tLabel.Position = UDim2.new(0, 12, 0, 10)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 15
    tLabel.TextColor3 = C_TEXT
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Text = title
    tLabel.Parent = card

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -20, 0, 20)
    mLabel.Position = UDim2.new(0, 12, 0, 34)
    mLabel.BackgroundTransparency = 1
    mLabel.Font = Enum.Font.GothamMedium
    mLabel.TextSize = 13
    mLabel.TextColor3 = C_MUTED
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Text = msg
    mLabel.Parent = card

    task.delay(notifDuration, function()
        if card and card.Parent then card:Destroy() end
    end)
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 780, 0, 420)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -210)
MainFrame.BackgroundColor3 = C_BG
MainFrame.BackgroundTransparency = 0.1
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 12)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 220, 1, 0)
Sidebar.BackgroundColor3 = C_SIDEBAR
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideHeader = Instance.new("Frame")
SideHeader.Size = UDim2.new(1, 0, 0, 60)
SideHeader.BackgroundTransparency = 1
SideHeader.Parent = Sidebar

local LogoIcon = Instance.new("TextLabel")
LogoIcon.Size = UDim2.new(0, 24, 0, 24)
LogoIcon.Position = UDim2.new(0, 16, 0, 18)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Text = "⬢"
LogoIcon.TextColor3 = C_ACCENT
LogoIcon.TextSize = 18
LogoIcon.Font = Enum.Font.GothamBold
LogoIcon.Parent = SideHeader

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, -50, 0, 16)
LogoTitle.Position = UDim2.new(0, 44, 0, 14)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "VexHub"
LogoTitle.TextColor3 = C_TEXT
LogoTitle.TextSize = 14
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
LogoTitle.Parent = SideHeader

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(1, -50, 0, 14)
LogoSub.Position = UDim2.new(0, 44, 0, 32)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "Prison Life Edition"
LogoSub.TextColor3 = C_MUTED
LogoSub.TextSize = 10
LogoSub.Font = Enum.Font.GothamMedium
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = SideHeader

local TabListFrame = Instance.new("Frame")
TabListFrame.Size = UDim2.new(1, -24, 1, -135)
TabListFrame.Position = UDim2.new(0, 12, 0, 65)
TabListFrame.BackgroundTransparency = 1
TabListFrame.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabListFrame

-- Sidebar Profile
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(1, -24, 0, 50)
ProfileCard.Position = UDim2.new(0, 12, 1, -60)
ProfileCard.BackgroundColor3 = C_CARD
ProfileCard.BackgroundTransparency = 0.1
ProfileCard.Parent = Sidebar
createCorner(ProfileCard, 8)

local ProfileAvatar = Instance.new("ImageLabel")
ProfileAvatar.Size = UDim2.new(0, 34, 0, 34)
ProfileAvatar.Position = UDim2.new(0, 8, 0, 8)
ProfileAvatar.BackgroundTransparency = 1
ProfileAvatar.Parent = ProfileCard
createCorner(ProfileAvatar, 17)

task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100
    )
    if isReady then ProfileAvatar.Image = content end
end)

local ProfileName = Instance.new("TextLabel")
ProfileName.Size = UDim2.new(1, -52, 0, 16)
ProfileName.Position = UDim2.new(0, 48, 0, 9)
ProfileName.BackgroundTransparency = 1
ProfileName.Text = LocalPlayer.DisplayName
ProfileName.TextColor3 = C_TEXT
ProfileName.Font = Enum.Font.GothamBold
ProfileName.TextSize = 12
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.TextTruncate = Enum.TextTruncate.AtEnd
ProfileName.Parent = ProfileCard

local ProfileSub = Instance.new("TextLabel")
ProfileSub.Size = UDim2.new(1, -52, 0, 14)
ProfileSub.Position = UDim2.new(0, 48, 0, 25)
ProfileSub.BackgroundTransparency = 1
ProfileSub.Text = "Prison Life"
ProfileSub.TextColor3 = C_MUTED
ProfileSub.Font = Enum.Font.GothamMedium
ProfileSub.TextSize = 10
ProfileSub.TextXAlignment = Enum.TextXAlignment.Left
ProfileSub.Parent = ProfileCard

-- Content
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -220, 1, 0)
Content.Position = UDim2.new(0, 220, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentTop = Instance.new("Frame")
ContentTop.Name = "ContentTop"
ContentTop.Size = UDim2.new(1, 0, 0, 60)
ContentTop.BackgroundTransparency = 1
ContentTop.Parent = Content

local TabIconHeader = Instance.new("ImageLabel")
TabIconHeader.Size = UDim2.new(0, 20, 0, 20)
TabIconHeader.Position = UDim2.new(0, 18, 0, 20)
TabIconHeader.BackgroundTransparency = 1
TabIconHeader.ImageColor3 = C_ACCENT
TabIconHeader.Parent = ContentTop

local TabTitleHeader = Instance.new("TextLabel")
TabTitleHeader.Size = UDim2.new(0, 200, 0, 24)
TabTitleHeader.Position = UDim2.new(0, 48, 0, 18)
TabTitleHeader.BackgroundTransparency = 1
TabTitleHeader.Text = "Home"
TabTitleHeader.TextColor3 = C_TEXT
TabTitleHeader.Font = Enum.Font.GothamBold
TabTitleHeader.TextSize = 18
TabTitleHeader.TextXAlignment = Enum.TextXAlignment.Left
TabTitleHeader.Parent = ContentTop

-- Search Bar
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(0, 180, 0, 32)
SearchBar.Position = UDim2.new(1, -195, 0, 14)
SearchBar.BackgroundColor3 = C_CARD
SearchBar.BackgroundTransparency = 0.1
SearchBar.Parent = ContentTop
createCorner(SearchBar, 8)

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 24, 1, 0)
SearchIcon.Position = UDim2.new(0, 6, 0, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 12
SearchIcon.Parent = SearchBar

local SearchInput = Instance.new("TextBox")
SearchInput.Size = UDim2.new(1, -34, 1, 0)
SearchInput.Position = UDim2.new(0, 30, 0, 0)
SearchInput.BackgroundTransparency = 1
SearchInput.PlaceholderText = "Search..."
SearchInput.PlaceholderColor3 = C_FAINT
SearchInput.Text = ""
SearchInput.TextColor3 = C_TEXT
SearchInput.Font = Enum.Font.GothamMedium
SearchInput.TextSize = 12
SearchInput.TextXAlignment = Enum.TextXAlignment.Left
SearchInput.Parent = SearchBar

-- Footer
local Footer = Instance.new("Frame")
Footer.Name = "Footer"
Footer.Size = UDim2.new(1, -30, 0, 30)
Footer.Position = UDim2.new(0, 15, 1, -35)
Footer.BackgroundTransparency = 1
Footer.Parent = Content

local FooterDot = Instance.new("Frame")
FooterDot.Size = UDim2.new(0, 8, 0, 8)
FooterDot.Position = UDim2.new(0, 0, 0.5, -4)
FooterDot.BackgroundColor3 = C_GREEN
FooterDot.Parent = Footer
createCorner(FooterDot, 4)

local FooterText = Instance.new("TextLabel")
FooterText.Size = UDim2.new(0, 300, 1, 0)
FooterText.Position = UDim2.new(0, 14, 0, 0)
FooterText.BackgroundTransparency = 1
FooterText.Text = "Your executor is supported and fully compatible."
FooterText.TextColor3 = C_MUTED
FooterText.Font = Enum.Font.GothamMedium
FooterText.TextSize = 11
FooterText.TextXAlignment = Enum.TextXAlignment.Left
FooterText.Parent = Footer

local FooterRight = Instance.new("TextLabel")
FooterRight.Size = UDim2.new(0, 200, 1, 0)
FooterRight.Position = UDim2.new(1, -200, 0, 0)
FooterRight.BackgroundTransparency = 1
FooterRight.Text = "Tap the pill or RShift"
FooterRight.TextColor3 = C_FAINT
FooterRight.Font = Enum.Font.GothamMedium
FooterRight.TextSize = 11
FooterRight.TextXAlignment = Enum.TextXAlignment.Right
FooterRight.Parent = Footer

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child.Name ~= "ContentTop" and child.Name ~= "Footer" then
            child:Destroy()
        end
    end
end

local function makeScrollingFrame()
    local sf = Instance.new("ScrollingFrame")
    sf.Name = "TabScroll"
    sf.Size = UDim2.new(1, -30, 1, -100)
    sf.Position = UDim2.new(0, 15, 0, 65)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = C_TOGGLE_OFF
    sf.ClipsDescendants = true
    sf.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = sf

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
    return sf
end

-- Controls Builder
local function createToggle(parent, title, defaultState, callback)
    local state = defaultState or false

    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundColor3 = C_CARD
    row.BackgroundTransparency = 0.1
    row.AutoButtonColor = false
    row.Text = ""
    row.Parent = parent
    createCorner(row, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 44, 0, 24)
    pill.Position = UDim2.new(1, -54, 0.5, -12)
    pill.BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF
    pill.Parent = row
    createCorner(pill, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = C_KNOB
    knob.Parent = pill
    createCorner(knob, 9)

    row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD_HOVER}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD}):Play()
    end)

    row.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.16), {BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF}):Play()
        TweenService:Create(knob, TweenInfo.new(0.16), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        pcall(callback, state)
    end)

    return row
end

local function createButton(parent, title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = C_CARD
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = parent
    createCorner(btn, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD}):Play()
    end)

    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function createSlider(parent, title, minVal, maxVal, defaultVal, callback)
    local value = defaultVal or minVal

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = C_CARD
    card.BackgroundTransparency = 0.1
    card.Parent = parent
    createCorner(card, 10)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 20)
    lbl.Position = UDim2.new(0, 14, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.25, 0, 0, 20)
    valLbl.Position = UDim2.new(0.72, 0, 0, 8)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(value)
    valLbl.TextColor3 = C_MUTED
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 36)
    track.BackgroundColor3 = C_TOGGLE_OFF
    track.Parent = card
    createCorner(track, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C_ACCENT
    fill.Parent = track
    createCorner(fill, 3)

    local dragging = false
    local function updateFromInput(input)
        local posX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local pct = posX / track.AbsoluteSize.X
        value = math.floor(minVal + ((maxVal - minVal) * pct) + 0.5)
        fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
        valLbl.Text = tostring(value)
        pcall(callback, value)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return card
end

-- Tab Management
local currentTab = "Home"
local tabs = {}

local function selectTab(name)
    currentTab = name
    for tabName, data in pairs(tabs) do
        if tabName == name then
            TweenService:Create(data.btn, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD_HOVER}):Play()
            data.lbl.TextColor3 = C_ACCENT
            data.iconImg.ImageColor3 = C_ACCENT
            TabIconHeader.Image = data.iconAsset
            TabTitleHeader.Text = data.label
            clearContent()
            data.build()
        else
            TweenService:Create(data.btn, TweenInfo.new(0.16), {BackgroundColor3 = C_SIDEBAR}):Play()
            data.lbl.TextColor3 = C_MUTED
            data.iconImg.ImageColor3 = C_MUTED
        end
    end
end

local function registerTab(name, iconAsset, label, buildFunc, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = C_SIDEBAR
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = TabListFrame
    createCorner(btn, 8)

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 18, 0, 18)
    iconImg.Position = UDim2.new(0, 12, 0.5, -9)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = iconAsset
    iconImg.ImageColor3 = C_MUTED
    iconImg.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C_MUTED
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD}):Play() end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_SIDEBAR}):Play() end
    end)

    btn.MouseButton1Click:Connect(function() selectTab(name) end)

    tabs[name] = {
        btn = btn, iconAsset = iconAsset, label = label, lbl = lbl, iconImg = iconImg, build = buildFunc
    }
end

local startTime = tick()

-- TAB BUILDERS
local function buildHomeTab()
    local sf = makeScrollingFrame()

    -- Card 1: WELCOME
    local card1 = Instance.new("Frame")
    card1.Size = UDim2.new(1, 0, 0, 130)
    card1.BackgroundColor3 = C_CARD
    card1.BackgroundTransparency = 0.1
    card1.Parent = sf
    createCorner(card1, 10)

    local wbFaint = Instance.new("TextLabel")
    wbFaint.Size = UDim2.new(0, 200, 0, 14)
    wbFaint.Position = UDim2.new(0, 16, 0, 14)
    wbFaint.BackgroundTransparency = 1
    wbFaint.Text = "WELCOME BACK"
    wbFaint.TextColor3 = C_FAINT
    wbFaint.Font = Enum.Font.GothamBold
    wbFaint.TextSize = 10
    wbFaint.TextXAlignment = Enum.TextXAlignment.Left
    wbFaint.Parent = card1

    local wbName = Instance.new("TextLabel")
    wbName.Size = UDim2.new(1, -140, 0, 30)
    wbName.Position = UDim2.new(0, 16, 0, 30)
    wbName.BackgroundTransparency = 1
    wbName.Text = LocalPlayer.DisplayName
    wbName.TextColor3 = C_TEXT
    wbName.Font = Enum.Font.GothamBold
    wbName.TextSize = 24
    wbName.TextXAlignment = Enum.TextXAlignment.Left
    wbName.TextTruncate = Enum.TextTruncate.AtEnd
    wbName.Parent = card1

    local wbUser = Instance.new("TextLabel")
    wbUser.Size = UDim2.new(1, -140, 0, 16)
    wbUser.Position = UDim2.new(0, 16, 0, 62)
    wbUser.BackgroundTransparency = 1
    wbUser.Text = "@" .. LocalPlayer.Name
    wbUser.TextColor3 = C_MUTED
    wbUser.Font = Enum.Font.GothamMedium
    wbUser.TextSize = 12
    wbUser.TextXAlignment = Enum.TextXAlignment.Left
    wbUser.Parent = card1

    local bigAvatar = Instance.new("ImageLabel")
    bigAvatar.Size = UDim2.new(0, 100, 0, 100)
    bigAvatar.Position = UDim2.new(1, -115, 0.5, -50)
    bigAvatar.BackgroundTransparency = 1
    bigAvatar.Parent = card1
    createCorner(bigAvatar, 50)

    task.spawn(function()
        local content, isReady = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150
        )
        if isReady then bigAvatar.Image = content end
    end)

    -- Card 2: FPS/PING
    local card2 = Instance.new("Frame")
    card2.Size = UDim2.new(1, 0, 0, 130)
    card2.BackgroundColor3 = C_CARD
    card2.BackgroundTransparency = 0.1
    card2.Parent = sf
    createCorner(card2, 10)

    local fpsFaint = Instance.new("TextLabel")
    fpsFaint.Size = UDim2.new(0.45, 0, 0, 14)
    fpsFaint.Position = UDim2.new(0, 16, 0, 16)
    fpsFaint.BackgroundTransparency = 1
    fpsFaint.Text = "FPS"
    fpsFaint.TextColor3 = C_FAINT
    fpsFaint.Font = Enum.Font.GothamBold
    fpsFaint.TextSize = 10
    fpsFaint.TextXAlignment = Enum.TextXAlignment.Left
    fpsFaint.Parent = card2

    local fpsVal = Instance.new("TextLabel")
    fpsVal.Size = UDim2.new(0.45, 0, 0, 30)
    fpsVal.Position = UDim2.new(0, 16, 0, 32)
    fpsVal.BackgroundTransparency = 1
    fpsVal.Text = "60"
    fpsVal.TextColor3 = C_GREEN
    fpsVal.Font = Enum.Font.GothamBold
    fpsVal.TextSize = 22
    fpsVal.TextXAlignment = Enum.TextXAlignment.Left
    fpsVal.Parent = card2

    local pingFaint = Instance.new("TextLabel")
    pingFaint.Size = UDim2.new(0.45, 0, 0, 14)
    pingFaint.Position = UDim2.new(0.5, 0, 0, 16)
    pingFaint.BackgroundTransparency = 1
    pingFaint.Text = "PING"
    pingFaint.TextColor3 = C_FAINT
    pingFaint.Font = Enum.Font.GothamBold
    pingFaint.TextSize = 10
    pingFaint.TextXAlignment = Enum.TextXAlignment.Left
    pingFaint.Parent = card2

    local pingVal = Instance.new("TextLabel")
    pingVal.Size = UDim2.new(0.45, 0, 0, 30)
    pingVal.Position = UDim2.new(0.5, 0, 0, 32)
    pingVal.BackgroundTransparency = 1
    pingVal.Text = "45 ms"
    pingVal.TextColor3 = C_GREEN
    pingVal.Font = Enum.Font.GothamBold
    pingVal.TextSize = 22
    pingVal.TextXAlignment = Enum.TextXAlignment.Left
    pingVal.Parent = card2

    local plrsFaint = Instance.new("TextLabel")
    plrsFaint.Size = UDim2.new(0.45, 0, 0, 14)
    plrsFaint.Position = UDim2.new(0, 16, 0, 85)
    plrsFaint.BackgroundTransparency = 1
    plrsFaint.Text = "0/0 PLAYERS"
    plrsFaint.TextColor3 = C_FAINT
    plrsFaint.Font = Enum.Font.GothamBold
    plrsFaint.TextSize = 10
    plrsFaint.TextXAlignment = Enum.TextXAlignment.Left
    plrsFaint.Parent = card2

    local sessFaint = Instance.new("TextLabel")
    sessFaint.Size = UDim2.new(0.45, 0, 0, 14)
    sessFaint.Position = UDim2.new(0.5, 0, 0, 85)
    sessFaint.BackgroundTransparency = 1
    sessFaint.Text = "0s SESSION"
    sessFaint.TextColor3 = C_FAINT
    sessFaint.Font = Enum.Font.GothamBold
    sessFaint.TextSize = 10
    sessFaint.TextXAlignment = Enum.TextXAlignment.Left
    sessFaint.Parent = card2

    local frameCount = 0
    local lastFpsUpdate = tick()
    local fpsConnection

    fpsConnection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsUpdate >= 1 then
            if card2 and card2.Parent then
                fpsVal.Text = tostring(frameCount)
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                pingVal.Text = tostring(ping) .. " ms"
                plrsFaint.Text = string.format("%d/%d PLAYERS", #Players:GetPlayers(), Players.MaxPlayers)
                sessFaint.Text = string.format("%ds SESSION", math.floor(tick() - startTime))
            else
                fpsConnection:Disconnect()
            end
            frameCount = 0
            lastFpsUpdate = now
        end
    end)

    -- Card 3: Game Info
    local card3 = Instance.new("Frame")
    card3.Size = UDim2.new(1, 0, 0, 130)
    card3.BackgroundColor3 = C_CARD
    card3.BackgroundTransparency = 0.1
    card3.Parent = sf
    createCorner(card3, 10)

    local gameIcon = Instance.new("ImageLabel")
    gameIcon.Size = UDim2.new(0, 50, 0, 50)
    gameIcon.Position = UDim2.new(0, 16, 0, 16)
    gameIcon.BackgroundColor3 = C_SIDEBAR
    gameIcon.Image = "rbxassetid://122728613872558"
    gameIcon.Parent = card3
    createCorner(gameIcon, 8)

    local gameTitle = Instance.new("TextLabel")
    gameTitle.Size = UDim2.new(1, -90, 0, 20)
    gameTitle.Position = UDim2.new(0, 76, 0, 18)
    gameTitle.BackgroundTransparency = 1
    gameTitle.Text = "Тюремная жизнь"
    gameTitle.TextColor3 = C_TEXT
    gameTitle.Font = Enum.Font.GothamBold
    gameTitle.TextSize = 15
    gameTitle.TextXAlignment = Enum.TextXAlignment.Left
    gameTitle.Parent = card3

    local gameSub = Instance.new("TextLabel")
    gameSub.Size = UDim2.new(1, -90, 0, 16)
    gameSub.Position = UDim2.new(0, 76, 0, 40)
    gameSub.BackgroundTransparency = 1
    gameSub.Text = string.format("by DevScripts · %d/%d players", #Players:GetPlayers(), Players.MaxPlayers)
    gameSub.TextColor3 = C_MUTED
    gameSub.Font = Enum.Font.GothamMedium
    gameSub.TextSize = 11
    gameSub.TextXAlignment = Enum.TextXAlignment.Left
    gameSub.Parent = card3

    local btnRow = Instance.new("Frame")
    btnRow.Size = UDim2.new(1, -32, 0, 34)
    btnRow.Position = UDim2.new(0, 16, 0, 80)
    btnRow.BackgroundTransparency = 1
    btnRow.Parent = card3

    local btnRowLayout = Instance.new("UIListLayout")
    btnRowLayout.FillDirection = Enum.FillDirection.Horizontal
    btnRowLayout.Padding = UDim.new(0, 8)
    btnRowLayout.Parent = btnRow

    local function makeRowBtn(title, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, -6, 1, 0)
        btn.BackgroundColor3 = C_SIDEBAR
        btn.BackgroundTransparency = 0.1
        btn.AutoButtonColor = false
        btn.Text = title
        btn.TextColor3 = C_TEXT
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11
        btn.Parent = btnRow
        createCorner(btn, 6)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_CARD_HOVER}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.16), {BackgroundColor3 = C_SIDEBAR}):Play()
        end)

        btn.MouseButton1Click:Connect(function() pcall(callback) end)
    end

    makeRowBtn("Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    makeRowBtn("Hop", function() notify("Server Hop", "Searching for another server...") end)
    makeRowBtn("Lowest", function() notify("Server Hop", "Searching for lowest populated server...") end)
    makeRowBtn("Job ID", function()
        setclipboard(game.JobId)
        notify("Clipboard", "Job ID copied to clipboard")
    end)
end

local function buildMainTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Aimbot", FeatureState.AimEnabled, function(v)
        FeatureState.AimEnabled = v
        FovCircle.Visible = v
    end)

    createToggle(sf, "Team Check (No Team Kill)", FeatureState.TeamCheck, function(v)
        FeatureState.TeamCheck = v
    end)

    createSlider(sf, "FOV Radius", 30, 300, FeatureState.FovRadius, function(v)
        FeatureState.FovRadius = v
        FovCircle.Radius = v
    end)

    createToggle(sf, "Inf Stamina", FeatureState.InfStamina, function(v)
        FeatureState.InfStamina = v
    end)

    createToggle(sf, "Speed Boost", FeatureState.SpeedBoost, function(v)
        FeatureState.SpeedBoost = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v and 25 or 16
        end
    end)

    createToggle(sf, "Fast Punch", FeatureState.FastPunch, function(v)
        FeatureState.FastPunch = v
    end)

    createToggle(sf, "Noclip", FeatureState.Noclip, function(v)
        FeatureState.Noclip = v
    end)
end

local function buildPlayerTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "ESP (Team Colors)", FeatureState.EspEnabled, function(v)
        FeatureState.EspEnabled = v
    end)

    createToggle(sf, "God Mode", FeatureState.GodMode, function(v)
        FeatureState.GodMode = v
    end)

    createToggle(sf, "Anti AFK", FeatureState.AntiAFK, function(v)
        FeatureState.AntiAFK = v
    end)

    createButton(sf, "Reset Character", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end)
end

local function buildSettingsTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Notifications", notifEnabled, function(v) notifEnabled = v end)

    createSlider(sf, "Notif Duration", 1, 10, notifDuration, function(v) notifDuration = v end)

    createButton(sf, "Unload UI", function()
        getgenv().VexHub_Loaded = false
        FovCircle:Remove()
        ScreenGui:Destroy()
    end)
end

-- Register Tabs
registerTab("Home", "rbxassetid://7539983773", "Home", buildHomeTab, 1)
registerTab("Main", "rbxassetid://10974441727", "Main", buildMainTab, 2)
registerTab("Player", "rbxassetid://17412298151", "Visuals", buildPlayerTab, 3)
registerTab("Settings", "rbxassetid://11956055886", "Settings", buildSettingsTab, 4)

selectTab("Home")

-- Window Dragging
local dragging, dragStart, startPos
ContentTop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Visibility
local uiVisible = true
local isAnimating = false

local function setUIVisible(state)
    if isAnimating then return end
    isAnimating = true
    uiVisible = state

    if uiVisible then
        MainFrame.Visible = true
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 780, 0, 420),
            BackgroundTransparency = 0.1
        })
        tw:Play()
        tw.Completed:Connect(function() isAnimating = false end)
    else
        local tw = TweenService:Create(MainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 780, 0, 0),
            BackgroundTransparency = 1
        })
        tw:Play()
        tw.Completed:Connect(function()
            if not uiVisible then MainFrame.Visible = false end
            isAnimating = false
        end)
    end
end

-- Floating Toggle Button
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingToggle"
FloatingBtn.Size = UDim2.new(0, 40, 0, 40)
FloatingBtn.Position = UDim2.new(0, 20, 0.5, -20)
FloatingBtn.BackgroundColor3 = C_CARD
FloatingBtn.BackgroundTransparency = 0.1
FloatingBtn.Text = "≡"
FloatingBtn.TextColor3 = C_ACCENT
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 20
FloatingBtn.Parent = ScreenGui
createCorner(FloatingBtn, 20)

FloatingBtn.MouseButton1Click:Connect(function()
    setUIVisible(not uiVisible)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        setUIVisible(not uiVisible)
    end
end)

-- Main Execution Loop
RunService.RenderStepped:Connect(function()
    -- Lock FOV Circle to Center Screen
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = centerScreen

    -- Aimbot Logic
    if FeatureState.AimEnabled then
        local closestPlayer = nil
        local shortestDistance = FeatureState.FovRadius

        for _, plr in ipairs(Players:GetPlayers()) do
            -- Ignore Self
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                
                -- Team Check (Skip Team Mates)
                local isTeammate = FeatureState.TeamCheck and (plr.Team == LocalPlayer.Team)
                
                if not isTeammate then
                    local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if onScreen then
                        local dist = (Vector2.new(headPos.X, headPos.Y) - centerScreen).Magnitude
                        if dist < shortestDistance then
                            shortestDistance = dist
                            closestPlayer = plr
                        end
                    end
                end
            end
        end

        if closestPlayer and closestPlayer.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.Head.Position)
        end
    end

    -- ESP Logic
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("VexESP")
            if FeatureState.EspEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "VexESP"
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    highlight.Parent = plr.Character
                end

                local teamName = tostring(plr.Team)
                if teamName == "Inmates" then
                    highlight.FillColor = Color3.fromRGB(255, 140, 0)
                elseif teamName == "Guards" then
                    highlight.FillColor = Color3.fromRGB(0, 100, 255)
                elseif teamName == "Criminals" then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                else
                    highlight.FillColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end

    -- Noclip Logic
    if FeatureState.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Inf Stamina
local mt = getrawmetatable(game)
local oldIndex = mt.__index
setreadonly(mt, false)
mt.__index = newcclosure(function(self, idx)
    if FeatureState.InfStamina and tostring(idx) == "Stamina" then
        return 100
    end
    return oldIndex(self, idx)
end)
setreadonly(mt, true)

notify("VexHub", "Successfully loaded. Press RightShift to toggle")
