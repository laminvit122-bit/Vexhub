--[[
    VexHub - Prison Life Edition (Fixed & Updated)
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
    WallCheck = true,
    TargetCriminals = true, -- Красные
    TargetGuards = true,    -- Синие
    TargetInmates = true,   -- Оранжевые
    EspEnabled = false,
    InfStamina = false,
    SpeedBoost = false,
    SpeedValue = 24,
    Noclip = false,
    FastPunch = false,
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

-- FOV Circle
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
NotifContainer.Size = UDim2.new(0, 340, 0, 180)
NotifContainer.Position = UDim2.new(1, -360, 1, -190)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Parent = NotifContainer

local notifEnabled = true
local notifDuration = 3

local function notify(title, msg)
    if not notifEnabled then return end

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.Position = UDim2.new(1, 100, 0, 0)
    card.BackgroundColor3 = C_CARD
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.Parent = NotifContainer
    createCorner(card, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = C_ACCENT
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -20, 0, 20)
    tLabel.Position = UDim2.new(0, 12, 0, 8)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 14
    tLabel.TextColor3 = C_TEXT
    tLabel.TextTransparency = 1
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Text = title
    tLabel.Parent = card

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -20, 0, 18)
    mLabel.Position = UDim2.new(0, 12, 0, 28)
    mLabel.BackgroundTransparency = 1
    mLabel.Font = Enum.Font.GothamMedium
    mLabel.TextSize = 12
    mLabel.TextColor3 = C_MUTED
    mLabel.TextTransparency = 1
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Text = msg
    mLabel.Parent = card

    local tweenInfoIn = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(card, tweenInfoIn, {BackgroundTransparency = 0.15, Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(bar, tweenInfoIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(tLabel, tweenInfoIn, {TextTransparency = 0}):Play()
    TweenService:Create(mLabel, tweenInfoIn, {TextTransparency = 0}):Play()

    task.delay(notifDuration, function()
        if card and card.Parent then
            local tweenInfoOut = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            TweenService:Create(card, tweenInfoOut, {BackgroundTransparency = 1, Position = UDim2.new(1, 50, 0, 0)}):Play()
            TweenService:Create(bar, tweenInfoOut, {BackgroundTransparency = 1}):Play()
            TweenService:Create(tLabel, tweenInfoOut, {TextTransparency = 1}):Play()
            local lastTween = TweenService:Create(mLabel, tweenInfoOut, {TextTransparency = 1})
            lastTween:Play()
            
            lastTween.Completed:Connect(function()
                card:Destroy()
            end)
        end
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

local LogoIcon = Instance.new("ImageLabel")
LogoIcon.Size = UDim2.new(0, 24, 0, 24)
LogoIcon.Position = UDim2.new(0, 14, 0, 18)
LogoIcon.BackgroundTransparency = 1
LogoIcon.Image = "rbxassetid://92044950923835"
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

-- Profile
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

-- Controls Builder
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
    sf.Size = UDim2.new(1, -30, 1, -70)
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
        notify(title, state and "Включено" or "Выключено")
        pcall(callback, state)
    end)

    return row
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

-- TAB BUILDERS
local function buildMainTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Aimbot", FeatureState.AimEnabled, function(v)
        FeatureState.AimEnabled = v
        FovCircle.Visible = v
    end)

    createToggle(sf, "Target Criminals (Красные)", FeatureState.TargetCriminals, function(v)
        FeatureState.TargetCriminals = v
    end)

    createToggle(sf, "Target Guards (Синие)", FeatureState.TargetGuards, function(v)
        FeatureState.TargetGuards = v
    end)

    createToggle(sf, "Target Inmates (Оранжевые)", FeatureState.TargetInmates, function(v)
        FeatureState.TargetInmates = v
    end)

    createToggle(sf, "Wall Check", FeatureState.WallCheck, function(v)
        FeatureState.WallCheck = v
    end)

    createSlider(sf, "FOV Radius", 30, 400, FeatureState.FovRadius, function(v)
        FeatureState.FovRadius = v
        FovCircle.Radius = v
    end)

    createToggle(sf, "Inf Stamina", FeatureState.InfStamina, function(v)
        FeatureState.InfStamina = v
    end)

    createToggle(sf, "Speed Boost", FeatureState.SpeedBoost, function(v)
        FeatureState.SpeedBoost = v
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

    createToggle(sf, "Esp", FeatureState.EspEnabled, function(v)
        FeatureState.EspEnabled = v
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

local function buildHomeTab()
    local sf = makeScrollingFrame()

    local card1 = Instance.new("Frame")
    card1.Size = UDim2.new(1, 0, 0, 100)
    card1.BackgroundColor3 = C_CARD
    card1.BackgroundTransparency = 0.1
    card1.Parent = sf
    createCorner(card1, 10)

    local wbName = Instance.new("TextLabel")
    wbName.Size = UDim2.new(1, -20, 0, 30)
    wbName.Position = UDim2.new(0, 16, 0, 20)
    wbName.BackgroundTransparency = 1
    wbName.Text = "Welcome to VexHub"
    wbName.TextColor3 = C_TEXT
    wbName.Font = Enum.Font.GothamBold
    wbName.TextSize = 20
    wbName.TextXAlignment = Enum.TextXAlignment.Left
    wbName.Parent = card1

    local wbUser = Instance.new("TextLabel")
    wbUser.Size = UDim2.new(1, -20, 0, 20)
    wbUser.Position = UDim2.new(0, 16, 0, 50)
    wbUser.BackgroundTransparency = 1
    wbUser.Text = "Prison Life Edition - Loaded Successfully"
    wbUser.TextColor3 = C_MUTED
    wbUser.Font = Enum.Font.GothamMedium
    wbUser.TextSize = 13
    wbUser.TextXAlignment = Enum.TextXAlignment.Left
    wbUser.Parent = card1
end

local function buildSettingsTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Notifications", notifEnabled, function(v) notifEnabled = v end)

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

selectTab("Main")

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

-- UI Toggle Toggle
local uiVisible = true
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
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        MainFrame.Visible = uiVisible
    end
end)

-- Wall Check
local function isTargetVisible(targetPart)
    if not FeatureState.WallCheck then return true end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.IgnoreWater = true

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local result = Workspace:Raycast(origin, direction, raycastParams)

    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- Fast Punch Logic
local mainRemotes = ReplicatedStorage:FindFirstChild("meleeEvent")
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and FeatureState.FastPunch and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if mainRemotes then
            mainRemotes:FireServer(LocalPlayer)
        end
    end
end)

-- NOCLIP LOOP (Работает 100%)
RunService.Stepped:Connect(function()
    if FeatureState.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- MAIN CORE LOOP (Aimbot, ESP, Speed)
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = centerScreen

    -- Speed Boost
    if FeatureState.SpeedBoost and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 26
    end

    -- AIMBOT LOGIC
    if FeatureState.AimEnabled then
        local closestPlayer = nil
        local shortestDistance = FeatureState.FovRadius

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                
                local teamName = tostring(plr.Team)
                local canTarget = false

                if teamName == "Criminals" and FeatureState.TargetCriminals then canTarget = true end
                if teamName == "Guards" and FeatureState.TargetGuards then canTarget = true end
                if teamName == "Inmates" and FeatureState.TargetInmates then canTarget = true end

                if canTarget then
                    local head = plr.Character.Head
                    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(headPos.X, headPos.Y) - centerScreen).Magnitude
                        if dist < shortestDistance and isTargetVisible(head) then
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

    -- ESP LOGIC
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
end)

-- INF STAMINA HOOK
local rawmt = getrawmetatable(game)
local oldIndex = rawmt.__index
setreadonly(rawmt, false)

rawmt.__index = newcclosure(function(self, idx)
    if FeatureState.InfStamina and tostring(idx) == "Stamina" then
        return 100
    end
    return oldIndex(self, idx)
end)
setreadonly(rawmt, true)

notify("VexHub", "Загружено успешно! Были внесены исправления.")
