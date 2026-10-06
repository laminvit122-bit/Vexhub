--[[
    VexHub - Prison Life Edition (Fixed & Compact)
    Created by DevScripts
--]]

-- Check Game (Prison Life PlaceId: 155615604)
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

-- Palette (10% Transparency applied)
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
    EspEnabled = false,
    InfStamina = false,
    SpeedBoost = false,
    Noclip = false,
    FastPunch = false
}

-- Target Parent Container
local targetParent = CoreGui
if gethui then targetParent = gethui() end

-- ScreenGui Setup
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

-- FOV Circle Drawing
local FovCircle = Drawing.new("Circle")
FovCircle.Color = Color3.fromRGB(139, 92, 246)
FovCircle.Thickness = 1.5
FovCircle.NumSides = 64
FovCircle.Radius = FeatureState.FovRadius
FovCircle.Filled = false
FovCircle.Visible = false

-- Notification System
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 300, 1, -40)
NotifContainer.Position = UDim2.new(1, -320, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

local function notify(title, msg)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = C_CARD
    card.BackgroundTransparency = 0.1
    card.Parent = NotifContainer
    createCorner(card, 8)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = C_ACCENT
    bar.BorderSizePixel = 0
    bar.Parent = card

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -15, 0, 20)
    tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 13
    tLabel.TextColor3 = C_TEXT
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Text = title
    tLabel.Parent = card

    local mLabel = Instance.new("TextLabel")
    mLabel.Size = UDim2.new(1, -15, 0, 20)
    mLabel.Position = UDim2.new(0, 10, 0, 25)
    mLabel.BackgroundTransparency = 1
    mLabel.Font = Enum.Font.GothamMedium
    mLabel.TextSize = 11
    mLabel.TextColor3 = C_MUTED
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.Text = msg
    mLabel.Parent = card

    task.delay(3, function()
        if card and card.Parent then card:Destroy() end
    end)
end

-- Main Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 720, 0, 400)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -200)
MainFrame.BackgroundColor3 = C_BG
MainFrame.BackgroundTransparency = 0.1
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
createCorner(MainFrame, 12)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 200, 1, 0)
Sidebar.BackgroundColor3 = C_SIDEBAR
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideHeader = Instance.new("Frame")
SideHeader.Size = UDim2.new(1, 0, 0, 50)
SideHeader.BackgroundTransparency = 1
SideHeader.Parent = Sidebar

local LogoTitle = Instance.new("TextLabel")
LogoTitle.Size = UDim2.new(1, -20, 0, 20)
LogoTitle.Position = UDim2.new(0, 15, 0, 15)
LogoTitle.BackgroundTransparency = 1
LogoTitle.Text = "VexHub"
LogoTitle.TextColor3 = C_TEXT
LogoTitle.TextSize = 16
LogoTitle.Font = Enum.Font.GothamBold
LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
LogoTitle.Parent = SideHeader

local TabListFrame = Instance.new("Frame")
TabListFrame.Size = UDim2.new(1, -20, 1, -120)
TabListFrame.Position = UDim2.new(0, 10, 0, 55)
TabListFrame.BackgroundTransparency = 1
TabListFrame.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabListFrame

-- Right Content Panel
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -200, 1, 0)
Content.Position = UDim2.new(0, 200, 0, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local ContentTop = Instance.new("Frame")
ContentTop.Size = UDim2.new(1, 0, 0, 50)
ContentTop.BackgroundTransparency = 1
ContentTop.Parent = Content

local TabIconHeader = Instance.new("ImageLabel")
TabIconHeader.Size = UDim2.new(0, 18, 0, 18)
TabIconHeader.Position = UDim2.new(0, 15, 0, 16)
TabIconHeader.BackgroundTransparency = 1
TabIconHeader.ImageColor3 = C_ACCENT
TabIconHeader.Parent = ContentTop

local TabTitleHeader = Instance.new("TextLabel")
TabTitleHeader.Size = UDim2.new(0, 200, 0, 20)
TabTitleHeader.Position = UDim2.new(0, 40, 0, 15)
TabTitleHeader.BackgroundTransparency = 1
TabTitleHeader.Text = "Home"
TabTitleHeader.TextColor3 = C_TEXT
TabTitleHeader.Font = Enum.Font.GothamBold
TabTitleHeader.TextSize = 16
TabTitleHeader.TextXAlignment = Enum.TextXAlignment.Left
TabTitleHeader.Parent = ContentTop

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child.Name ~= "ContentTop" then child:Destroy() end
    end
end

local function makeScrollingFrame()
    local sf = Instance.new("ScrollingFrame")
    sf.Size = UDim2.new(1, -30, 1, -60)
    sf.Position = UDim2.new(0, 15, 0, 50)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2
    sf.ScrollBarImageColor3 = C_TOGGLE_OFF
    sf.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = sf

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)
    return sf
end

-- UI Builder Elements
local function createToggle(parent, title, defaultState, callback)
    local state = defaultState or false
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = C_CARD
    row.BackgroundTransparency = 0.1
    row.AutoButtonColor = false
    row.Text = ""
    row.Parent = parent
    createCorner(row, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0, 36, 0, 20)
    pill.Position = UDim2.new(1, -44, 0.5, -10)
    pill.BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF
    pill.Parent = row
    createCorner(pill, 10)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = C_KNOB
    knob.Parent = pill
    createCorner(knob, 7)

    row.MouseButton1Click:Connect(function()
        state = not state
        pill.BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF
        knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        pcall(callback, state)
    end)
    return row
end

local function createButton(parent, title, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = C_CARD
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = title
    btn.TextColor3 = C_TEXT
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = parent
    createCorner(btn, 8)

    btn.MouseButton1Click:Connect(function() pcall(callback) end)
    return btn
end

local function createSlider(parent, title, minVal, maxVal, defaultVal, callback)
    local value = defaultVal or minVal
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 50)
    card.BackgroundColor3 = C_CARD
    card.BackgroundTransparency = 0.1
    card.Parent = parent
    createCorner(card, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.7, 0, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = card

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.25, 0, 0, 20)
    valLbl.Position = UDim2.new(0.72, 0, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(value)
    valLbl.TextColor3 = C_MUTED
    valLbl.Font = Enum.Font.GothamMedium
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 4)
    track.Position = UDim2.new(0, 12, 0, 32)
    track.BackgroundColor3 = C_TOGGLE_OFF
    track.Parent = card
    createCorner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = C_ACCENT
    fill.Parent = track
    createCorner(fill, 2)

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
            data.btn.BackgroundColor3 = C_CARD_HOVER
            data.lbl.TextColor3 = C_ACCENT
            data.iconImg.ImageColor3 = C_ACCENT
            TabIconHeader.Image = data.iconAsset
            TabTitleHeader.Text = data.label
            clearContent()
            data.build()
        else
            data.btn.BackgroundColor3 = C_SIDEBAR
            data.lbl.TextColor3 = C_MUTED
            data.iconImg.ImageColor3 = C_MUTED
        end
    end
end

local function registerTab(name, iconAsset, label, buildFunc, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C_SIDEBAR
    btn.BackgroundTransparency = 0.1
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    btn.Parent = TabListFrame
    createCorner(btn, 6)

    local iconImg = Instance.new("ImageLabel")
    iconImg.Size = UDim2.new(0, 16, 0, 16)
    iconImg.Position = UDim2.new(0, 10, 0.5, -8)
    iconImg.BackgroundTransparency = 1
    iconImg.Image = iconAsset
    iconImg.ImageColor3 = C_MUTED
    iconImg.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -35, 1, 0)
    lbl.Position = UDim2.new(0, 32, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C_MUTED
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    btn.MouseButton1Click:Connect(function() selectTab(name) end)

    tabs[name] = {
        btn = btn, iconAsset = iconAsset, label = label, lbl = lbl, iconImg = iconImg, build = buildFunc
    }
end

local startTime = tick()

-- TAB BUILDERS
local function buildHomeTab()
    local sf = makeScrollingFrame()

    -- FPS / PING Card
    local card1 = Instance.new("Frame")
    card1.Size = UDim2.new(1, 0, 0, 70)
    card1.BackgroundColor3 = C_CARD
    card1.BackgroundTransparency = 0.1
    card1.Parent = sf
    createCorner(card1, 8)

    local fpsVal = Instance.new("TextLabel")
    fpsVal.Size = UDim2.new(0.45, 0, 0, 30)
    fpsVal.Position = UDim2.new(0, 12, 0, 10)
    fpsVal.BackgroundTransparency = 1
    fpsVal.Text = "FPS: --"
    fpsVal.TextColor3 = C_GREEN
    fpsVal.Font = Enum.Font.GothamBold
    fpsVal.TextSize = 18
    fpsVal.TextXAlignment = Enum.TextXAlignment.Left
    fpsVal.Parent = card1

    local pingVal = Instance.new("TextLabel")
    pingVal.Size = UDim2.new(0.45, 0, 0, 30)
    pingVal.Position = UDim2.new(0.5, 0, 0, 10)
    pingVal.BackgroundTransparency = 1
    pingVal.Text = "PING: -- ms"
    pingVal.TextColor3 = C_GREEN
    pingVal.Font = Enum.Font.GothamBold
    pingVal.TextSize = 18
    pingVal.TextXAlignment = Enum.TextXAlignment.Left
    pingVal.Parent = card1

    local plrsFaint = Instance.new("TextLabel")
    plrsFaint.Size = UDim2.new(0.9, 0, 0, 15)
    plrsFaint.Position = UDim2.new(0, 12, 0, 45)
    plrsFaint.BackgroundTransparency = 1
    plrsFaint.Text = "PLAYERS: 0/0"
    plrsFaint.TextColor3 = C_FAINT
    plrsFaint.Font = Enum.Font.GothamBold
    plrsFaint.TextSize = 10
    plrsFaint.TextXAlignment = Enum.TextXAlignment.Left
    plrsFaint.Parent = card1

    -- Accurate FPS Counter Fix
    local frameCount = 0
    local lastFpsUpdate = tick()
    local fpsConnection

    fpsConnection = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastFpsUpdate >= 1 then
            if card1 and card1.Parent then
                fpsVal.Text = "FPS: " .. tostring(frameCount)
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                pingVal.Text = "PING: " .. tostring(ping) .. " ms"
                plrsFaint.Text = string.format("PLAYERS: %d/%d", #Players:GetPlayers(), Players.MaxPlayers)
            else
                fpsConnection:Disconnect()
            end
            frameCount = 0
            lastFpsUpdate = now
        end
    end)

    -- Game Info Card
    local card2 = Instance.new("Frame")
    card2.Size = UDim2.new(1, 0, 0, 80)
    card2.BackgroundColor3 = C_CARD
    card2.BackgroundTransparency = 0.1
    card2.Parent = sf
    createCorner(card2, 8)

    local gameIcon = Instance.new("ImageLabel")
    gameIcon.Size = UDim2.new(0, 50, 0, 50)
    gameIcon.Position = UDim2.new(0, 12, 0, 15)
    gameIcon.BackgroundColor3 = C_SIDEBAR
    gameIcon.Image = "rbxassetid://122728613872558"
    gameIcon.Parent = card2
    createCorner(gameIcon, 6)

    local gameTitle = Instance.new("TextLabel")
    gameTitle.Size = UDim2.new(1, -75, 0, 20)
    gameTitle.Position = UDim2.new(0, 70, 0, 18)
    gameTitle.BackgroundTransparency = 1
    gameTitle.Text = "Тюремная жизнь"
    gameTitle.TextColor3 = C_TEXT
    gameTitle.Font = Enum.Font.GothamBold
    gameTitle.TextSize = 14
    gameTitle.TextXAlignment = Enum.TextXAlignment.Left
    gameTitle.Parent = card2

    local gameSub = Instance.new("TextLabel")
    gameSub.Size = UDim2.new(1, -75, 0, 16)
    gameSub.Position = UDim2.new(0, 70, 0, 40)
    gameSub.BackgroundTransparency = 1
    gameSub.Text = "by DevScripts"
    gameSub.TextColor3 = C_MUTED
    gameSub.Font = Enum.Font.GothamMedium
    gameSub.TextSize = 11
    gameSub.TextXAlignment = Enum.TextXAlignment.Left
    gameSub.Parent = card2
end

local function buildMainTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Aimbot", FeatureState.AimEnabled, function(v)
        FeatureState.AimEnabled = v
        FovCircle.Visible = v
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

    createButton(sf, "Reset Character", function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Health = 0
        end
    end)
end

local function buildSettingsTab()
    local sf = makeScrollingFrame()

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

-- Floating Toggle Button
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 36, 0, 36)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -18)
FloatingBtn.BackgroundColor3 = C_CARD
FloatingBtn.BackgroundTransparency = 0.1
FloatingBtn.Text = "≡"
FloatingBtn.TextColor3 = C_ACCENT
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.TextSize = 18
FloatingBtn.Parent = ScreenGui
createCorner(FloatingBtn, 18)

local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- Window Dragging Logic
local dragging, dragStart, startPos
ContentTop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Main Functions Loop (Aimbot, ESP, Features)
RunService.RenderStepped:Connect(function()
    -- FOV Circle Position Update
    local mousePos = UserInputService:GetMouseLocation()
    FovCircle.Position = mousePos

    -- Aimbot Logic
    if FeatureState.AimEnabled then
        local closestPlayer = nil
        local shortestDistance = FeatureState.FovRadius

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                local headPos, onScreen = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestPlayer = plr
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

                -- Team Colors
                local teamName = tostring(plr.Team)
                if teamName == "Inmates" then
                    highlight.FillColor = Color3.fromRGB(255, 140, 0) -- Orange
                elseif teamName == "Guards" then
                    highlight.FillColor = Color3.fromRGB(0, 100, 255) -- Blue
                elseif teamName == "Criminals" then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red
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

-- Inf Stamina Hook
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

notify("VexHub", "Loaded for Prison Life! Created by DevScripts")
