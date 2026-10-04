--[[ ⬢ VEXHUB ⬢ | Prison Life Edition | v1.0 ]]
if getgenv and getgenv().VexHub_Loaded then return end
if getgenv then getgenv().VexHub_Loaded = true end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local parentGui = (gethui and gethui()) or CoreGui
if parentGui:FindFirstChild("VexHubUI") then parentGui.VexHubUI:Destroy() end

-- ═══════════ ПАЛИТРА ═══════════
local C = {
    window  = Color3.fromRGB(13, 13, 13),
    panel   = Color3.fromRGB(20, 20, 20),
    hover   = Color3.fromRGB(28, 28, 28),
    line    = Color3.fromRGB(31, 31, 31),
    accent  = Color3.fromRGB(139, 92, 246),
    toggleOn  = Color3.fromRGB(255, 255, 255),
    toggleOff = Color3.fromRGB(42, 42, 42),
    knob    = Color3.fromRGB(255, 255, 255),
    text    = Color3.fromRGB(255, 255, 255),
    textDim = Color3.fromRGB(138, 138, 138),
    textFaint = Color3.fromRGB(90, 90, 90),
}

-- ═══════════ УТИЛЫ ═══════════
local function corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = i
    return c
end

local function tween(i, time, props, style, dir)
    local t = TweenService:Create(i,
        TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ═══════════ СКРИН ═══════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VexHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentGui

-- ═══════════ УВЕДОМЛЕНИЯ ═══════════
local notifEnabled = true
local notifDuration = 3

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 400, 1, -20)
notifHolder.Position = UDim2.new(0, 20, 0, 10)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = ScreenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.Padding = UDim.new(0, 8)
notifList.Parent = notifHolder

local function notify(title, desc)
    if not notifEnabled then return end
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 72)
    frame.BackgroundColor3 = C.panel
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(-1, -50, 0, 0)
    frame.Parent = notifHolder
    corner(frame, 12)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, -24)
    bar.Position = UDim2.new(0, 14, 0, 12)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.Parent = frame
    corner(bar, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 22)
    titleLabel.Position = UDim2.new(0, 34, 0, 14)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = C.text
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -50, 0, 20)
    descLabel.Position = UDim2.new(0, 34, 0, 38)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc or ""
    descLabel.TextColor3 = C.textDim
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    frame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    descLabel.TextTransparency = 1

    tween(frame, 0.35, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(titleLabel, 0.25, {TextTransparency = 0})
    tween(descLabel, 0.25, {TextTransparency = 0})

    task.delay(notifDuration, function()
        tween(frame, 0.3, {Position = UDim2.new(-1, -50, 0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        tween(titleLabel, 0.3, {TextTransparency = 1})
        tween(descLabel, 0.3, {TextTransparency = 1})
        task.wait(0.35)
        frame:Destroy()
    end)
end

-- ═══════════ ГЛАВНОЕ ОКНО ═══════════
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 580, 0, 360)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.window
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
corner(Main, 14)

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = C.window
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
corner(TopBar, 14)

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 15)
topFix.Position = UDim2.new(0, 0, 1, -15)
topFix.BackgroundColor3 = C.window
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local LogoName = Instance.new("TextLabel")
LogoName.Size = UDim2.new(0, 200, 0, 18)
LogoName.Position = UDim2.new(0, 18, 0, 9)
LogoName.BackgroundTransparency = 1
LogoName.Text = "VEXHUB"
LogoName.TextColor3 = C.text
LogoName.TextSize = 15
LogoName.Font = Enum.Font.GothamBold
LogoName.TextXAlignment = Enum.TextXAlignment.Left
LogoName.Parent = TopBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(0, 200, 0, 12)
LogoSub.Position = UDim2.new(0, 18, 0, 27)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "Prison Life Edition"
LogoSub.TextColor3 = C.textFaint
LogoSub.TextSize = 10
LogoSub.Font = Enum.Font.GothamMedium
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = TopBar

local SpeedCircle = Instance.new("Frame")
SpeedCircle.Size = UDim2.new(0, 34, 0, 34)
SpeedCircle.Position = UDim2.new(0.5, -17, 0.5, -17)
SpeedCircle.BackgroundColor3 = C.window
SpeedCircle.BorderSizePixel = 0
SpeedCircle.Parent = TopBar
corner(SpeedCircle, 17)

local scStroke = Instance.new("UIStroke")
scStroke.Color = Color3.fromRGB(60, 60, 60)
scStroke.Thickness = 1
scStroke.Parent = SpeedCircle

local SpeedText = Instance.new("TextLabel")
SpeedText.Size = UDim2.new(1, 0, 1, 0)
SpeedText.BackgroundTransparency = 1
SpeedText.Text = "1.0x"
SpeedText.TextColor3 = C.text
SpeedText.TextSize = 12
SpeedText.Font = Enum.Font.GothamMedium
SpeedText.Parent = SpeedCircle

task.spawn(function()
    while SpeedCircle.Parent do
        local hrp = getHRP()
        if hrp then
            SpeedText.Text = string.format("%.1fx", math.max(hrp.Velocity.Magnitude / 16, 1))
        end
        task.wait(0.2)
    end
end)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -42, 0.5, -15)
Close.BackgroundColor3 = C.window
Close.Text = "✕"
Close.TextColor3 = C.textDim
Close.TextSize = 14
Close.Font = Enum.Font.GothamMedium
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Parent = TopBar
corner(Close, 6)

Close.MouseEnter:Connect(function() tween(Close, 0.15, {BackgroundColor3 = C.hover, TextColor3 = C.text}) end)
Close.MouseLeave:Connect(function() tween(Close, 0.15, {BackgroundColor3 = C.window, TextColor3 = C.textDim}) end)
Close.MouseButton1Click:Connect(function()
    tween(Main, 0.2, {BackgroundTransparency = 1})
    task.wait(0.2)
    Main.Visible = false
    Main.BackgroundTransparency = 0
end)

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, 0, 0, 1)
divider.Position = UDim2.new(0, 0, 0, 50)
divider.BackgroundColor3 = C.line
divider.BorderSizePixel = 0
divider.Parent = Main

-- Перетаскивание
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ═══════════ БОКОВОЕ МЕНЮ ═══════════
local SideMenu = Instance.new("Frame")
SideMenu.Size = UDim2.new(0, 155, 1, -51)
SideMenu.Position = UDim2.new(0, 0, 0, 51)
SideMenu.BackgroundTransparency = 1
SideMenu.Parent = Main

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 2)
sideLayout.Parent = SideMenu

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -155, 1, -51)
Content.Position = UDim2.new(0, 155, 0, 51)
Content.BackgroundTransparency = 1
Content.Parent = Main

local pages = {}
local activeTab

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 34)
    btn.BackgroundColor3 = C.window
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = SideMenu
    corner(btn, 6)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 20, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = C.textDim
    iconLabel.TextSize = 13
    iconLabel.Font = Enum.Font.GothamMedium
    iconLabel.TextXAlignment = Enum.TextXAlignment.Left
    iconLabel.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -40, 1, 0)
    nameLabel.Position = UDim2.new(0, 34, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = C.textDim
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -6)
    page.Position = UDim2.new(0, 6, 0, 3)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C.textFaint
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    pages[name] = {btn = btn, page = page, icon = iconLabel, label = nameLabel}

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.page.Visible = false
            tween(p.btn, 0.15, {BackgroundColor3 = C.window})
            p.icon.TextColor3 = C.textDim
            p.label.TextColor3 = C.textDim
        end
        page.Visible = true
        tween(btn, 0.15, {BackgroundColor3 = C.hover})
        iconLabel.TextColor3 = C.text
        nameLabel.TextColor3 = C.text
        activeTab = name
    end)

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then tween(btn, 0.15, {BackgroundColor3 = C.panel}) end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then tween(btn, 0.15, {BackgroundColor3 = C.window}) end
    end)

    return page
end

-- ═══════════ TOGGLE ═══════════
local function createToggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 40)
    f.BackgroundColor3 = C.window
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 44, 0, 26)
    switch.Position = UDim2.new(1, -56, 0.5, -13)
    switch.BackgroundColor3 = C.toggleOff
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.BorderSizePixel = 0
    switch.Parent = f
    corner(switch, 13)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = C.knob
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 11)

    local state = default or false

    local function update()
        if state then
            tween(switch, 0.2, {BackgroundColor3 = C.toggleOn})
            tween(knob, 0.2, {Position = UDim2.new(1, -24, 0.5, -11)})
        else
            tween(switch, 0.2, {BackgroundColor3 = C.toggleOff})
            tween(knob, 0.2, {Position = UDim2.new(0, 2, 0.5, -11)})
        end
    end
    update()

    switch.MouseButton1Click:Connect(function()
        state = not state
        update()
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then notify("Error", tostring(err)) end
        end
    end)

    return {set = function(v) state = v; update() end}
end

-- ═══════════ BUTTON ═══════════
local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 40)
    btn.BackgroundColor3 = C.window
    btn.Text = text
    btn.TextColor3 = C.text
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    corner(btn, 8)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 14)
    pad.Parent = btn

    btn.MouseEnter:Connect(function() tween(btn, 0.15, {BackgroundColor3 = C.panel}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, {BackgroundColor3 = C.window}) end)
    btn.MouseButton1Click:Connect(function()
        if callback then
            local ok, err = pcall(callback)
            if not ok then notify("Error", tostring(err)) end
        end
    end)
    return btn
end

-- ═══════════ SLIDER ═══════════
local function createSlider(parent, text, min, max, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 60)
    f.BackgroundColor3 = C.window
    f.BorderSizePixel = 0
    f.Parent = parent
    corner(f, 8)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0, 60, 0, 20)
    valLabel.Position = UDim2.new(1, -74, 0, 8)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = C.textDim
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamMedium
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = f

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 4)
    track.Position = UDim2.new(0, 14, 1, -18)
    track.BackgroundColor3 = C.toggleOff
    track.BorderSizePixel = 0
    track.Parent = f
    corner(track, 2)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.text
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 2)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.BackgroundColor3 = C.text
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 7)

    local dragging = false
    local value = default

    local function setValue(v)
        value = math.clamp(v, min, max)
        local alpha = (value - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valLabel.Text = tostring(math.floor(value * 10) / 10)
        if callback then pcall(callback, value) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            setValue(min + rel * (max - min))
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            setValue(min + rel * (max - min))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    return {set = setValue, get = function() return value end}
end

-- ═══════════ СОЗДАЁМ ВКЛАДКИ ═══════════
local prisonerPage = createTab("Prisoner", "🔒")
local guardPage    = createTab("Guard",    "🛡")
local visualsPage  = createTab("Visuals",  "◉")
local playerPage   = createTab("Player",   "●")
local settingsPage = createTab("Settings", "⚙")

-- ═══════════ СОСТОЯНИЕ ═══════════
local State = {
    infStamina   = false,
    speedBoost   = false,
    fastPunch    = false,
    noclip       = false,
    autoArrest   = false,
    weaponESP    = false,
    godMode      = false,
    fastReload   = false,
    instantKill  = false,
    espPrisoners = false,
    espGuards    = false,
    fullBright   = false,
    antiAFK      = false,
    antiArrest   = false,
}

-- ═══════════ ESP ═══════════
local highlights = {}

local function clearHighlights()
    for _, h in pairs(highlights) do
        if h and h.Parent then h:Destroy() end
    end
    highlights = {}
end

local function addHighlight(char, color)
    if not char or highlights[char] then return end
    local h = Instance.new("Highlight")
    h.Name = "VexHub_HL"
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = char
    h.Parent = char
    highlights[char] = h
end

local function refreshESP()
    clearHighlights()
    if not (State.espPrisoners or State.espGuards) then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local team = plr.Team and plr.Team.Name or ""
            if State.espPrisoners and (team == "Prisoners" or team == "Inmates" or team == "Criminals" or team == "") then
                addHighlight(plr.Character, Color3.fromRGB(255, 165, 0))
            elseif State.espGuards and (team == "Guards" or team == "Police" or team == "Cops") then
                addHighlight(plr.Character, Color3.fromRGB(0, 170, 255))
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        refreshESP()
    end)
end)

-- ═══════════ ЛУПЫ ═══════════

-- Inf Stamina (просто держим Stamina высокой, если есть)
task.spawn(function()
    while ScreenGui.Parent do
        if State.infStamina then
            local char = player.Character
            if char then
                for _, v in ipairs(char:GetChildren()) do
                    if v:IsA("NumberValue") and (v.Name:lower():find("stamina")) then
                        v.Value = 100
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Speed Boost
task.spawn(function()
    while ScreenGui.Parent do
        if State.speedBoost then
            local hum = getHum()
            if hum then hum.WalkSpeed = 32 end
        end
        task.wait(0.2)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if State.noclip then
        local char = player.Character
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end
end)

-- God Mode
task.spawn(function()
    while ScreenGui.Parent do
        if State.godMode then
            local hum = getHum()
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end
        end
        task.wait(0.3)
    end
end)

-- Auto Arrest (для охранников — клик по заключённым рядом)
task.spawn(function()
    while ScreenGui.Parent do
        if State.autoArrest then
            local hrp = getHRP()
            if hrp then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= player and plr.Character then
                        local tHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                        local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if tHRP and tHum and tHum.Health > 0 then
                            if (tHRP.Position - hrp.Position).Magnitude < 10 then
                                local tool = player.Character:FindFirstChildOfClass("Tool")
                                if tool and tool.Name:lower():find("handcuff") then
                                    tool:Activate()
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Instant Kill (для охранников/заключённых с оружием)
task.spawn(function()
    while ScreenGui.Parent do
        if State.instantKill then
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Damage") then
                    pcall(function() tool.Damage.Value = 100 end)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Fast Reload
task.spawn(function()
    while ScreenGui.Parent do
        if State.fastReload then
            local char = player.Character
            if char then
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") and (v.Name:lower():find("reload") or v.Name:lower():find("cooldown")) then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- Anti AFK
task.spawn(function()
    while ScreenGui.Parent do
        if State.antiAFK then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
        task.wait(60)
    end
end)

-- Anti Arrest
task.spawn(function()
    while ScreenGui.Parent do
        if State.antiArrest then
            local char = player.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("BoolValue") and (v.Name:lower():find("cuff") or v.Name:lower():find("arrest")) then
                        v.Value = false
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- Full Bright
task.spawn(function()
    while ScreenGui.Parent do
        if State.fullBright then
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.Brightness = 3
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.FogEnd = 100000
        end
        task.wait(0.5)
    end
end)

-- Weapon ESP — подсветка оружия рядом
task.spawn(function()
    while ScreenGui.Parent do
        if State.weaponESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    for _, tool in ipairs(plr.Character:GetChildren()) do
                        if tool:IsA("Tool") and not tool:FindFirstChild("VexHub_WeaponHL") then
                            local h = Instance.new("Highlight")
                            h.Name = "VexHub_WeaponHL"
                            h.FillColor = Color3.fromRGB(255, 50, 50)
                            h.OutlineColor = Color3.fromRGB(255, 0, 0)
                            h.FillTransparency = 0.5
                            h.Adornee = tool
                            h.Parent = tool
                        end
                    end
                end
            end
        else
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then
                    for _, tool in ipairs(plr.Character:GetChildren()) do
                        local h = tool:FindFirstChild("VexHub_WeaponHL")
                        if h then h:Destroy() end
                    end
                end
            end
        end
        task.wait(1)
    end
end)

-- ═══════════ НАПОЛНЕНИЕ ВКЛАДОК ═══════════

-- ─── PRISONER ───
createToggle(prisonerPage, "Inf Stamina", false, function(on)
    State.infStamina = on
    notify("Prisoner", "Inf Stamina " .. (on and "enabled" or "disabled"))
end)
createToggle(prisonerPage, "Speed Boost", false, function(on)
    State.speedBoost = on
    if not on then
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 end
    end
    notify("Prisoner", "Speed Boost " .. (on and "enabled" or "disabled"))
end)
createToggle(prisonerPage, "Fast Punch", false, function(on)
    State.fastPunch = on
    notify("Prisoner", "Fast Punch " .. (on and "enabled" or "disabled"))
end)
createToggle(prisonerPage, "Noclip", false, function(on)
    State.noclip = on
    notify("Prisoner", "Noclip " .. (on and "enabled" or "disabled"))
end)

-- ─── GUARD ───
createToggle(guardPage, "Auto Arrest", false, function(on)
    State.autoArrest = on
    notify("Guard", "Auto Arrest " .. (on and "enabled" or "disabled"))
end)
createToggle(guardPage, "Weapon ESP", false, function(on)
    State.weaponESP = on
    notify("Guard", "Weapon ESP " .. (on and "enabled" or "disabled"))
end)
createToggle(guardPage, "Fast Reload", false, function(on)
    State.fastReload = on
    notify("Guard", "Fast Reload " .. (on and "enabled" or "disabled"))
end)
createToggle(guardPage, "Instant Kill", false, function(on)
    State.instantKill = on
    notify("Guard", "Instant Kill " .. (on and "enabled" or "disabled"))
end)

-- ─── VISUALS ───
createToggle(visualsPage, "ESP Prisoners", false, function(on)
    State.espPrisoners = on
    refreshESP()
    notify("Visuals", "ESP Prisoners " .. (on and "enabled" or "disabled"))
end)
createToggle(visualsPage, "ESP Guards", false, function(on)
    State.espGuards = on
    refreshESP()
    notify("Visuals", "ESP Guards " .. (on and "enabled" or "disabled"))
end)
createToggle(visualsPage, "Full Bright", false, function(on)
    State.fullBright = on
    if not on then
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 1
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    notify("Visuals", "Full Bright " .. (on and "enabled" or "disabled"))
end)

-- ─── PLAYER ───
createToggle(playerPage, "God Mode", false, function(on)
    State.godMode = on
    if not on then
        local hum = getHum()
        if hum then
            hum.MaxHealth = 100
            hum.Health = 100
        end
    end
    notify("Player", "God Mode " .. (on and "enabled" or "disabled"))
end)
createToggle(playerPage, "Anti AFK", false, function(on)
    State.antiAFK = on
    notify("Player", "Anti AFK " .. (on and "enabled" or "disabled"))
end)
createToggle(playerPage, "Anti Arrest", false, function(on)
    State.antiArrest = on
    notify("Player", "Anti Arrest " .. (on and "enabled" or "disabled"))
end)
createButton(playerPage, "Reset Character", function()
    local hum = getHum()
    if hum then hum.Health = 0 end
    notify("Player", "Character reset")
end)

-- ─── SETTINGS ───
createToggle(settingsPage, "Notifications", true, function(on)
    notifEnabled = on
    if on then notify("VEXHUB", "Notifications enabled") end
end)
createSlider(settingsPage, "Notif Duration", 1, 10, 3, function(v)
    notifDuration = v
end)
createButton(settingsPage, "Reset Config", function()
    notify("VEXHUB", "Config reset")
end)
createButton(settingsPage, "Unload UI", function()
    notify("VEXHUB", "Unloading...")
    task.wait(0.5)
    clearHighlights()
    if getgenv then getgenv().VexHub_Loaded = false end
    ScreenGui:Destroy()
end)

-- Активируем первую вкладку
for _, p in pairs(pages) do p.page.Visible = false end
pages["Prisoner"].page.Visible = true
pages["Prisoner"].btn.BackgroundColor3 = C.hover
pages["Prisoner"].icon.TextColor3 = C.text
pages["Prisoner"].label.TextColor3 = C.text
activeTab = "Prisoner"

-- ═══════════ ПЛАВАЮЩАЯ КНОПКА ═══════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 90, 0, 36)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -18)
ToggleBtn.BackgroundColor3 = C.panel
ToggleBtn.Text = "VEXHUB"
ToggleBtn.TextColor3 = C.text
ToggleBtn.TextSize = 13
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
corner(ToggleBtn, 8)

local tbStroke = Instance.new("UIStroke")
tbStroke.Color = Color3.fromRGB(60, 60, 60)
tbStroke.Thickness = 1
tbStroke.Parent = ToggleBtn

do
    local dragging, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

ToggleBtn.MouseEnter:Connect(function() tween(ToggleBtn, 0.15, {BackgroundColor3 = C.hover}) end)
ToggleBtn.MouseLeave:Connect(function() tween(ToggleBtn, 0.15, {BackgroundColor3 = C.panel}) end)

local wasDragged = false
ToggleBtn.MouseButton1Down:Connect(function() wasDragged = false end)
UserInputService.InputChanged:Connect(function(i)
    if ToggleBtn:IsHovered and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        if i.Position.Magnitude > 0 then wasDragged = true end
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if Main.Visible then
        local t = tween(Main, 0.2, {Size = UDim2.new(0, 0, 0, 0)})
        t.Completed:Connect(function() Main.Visible = false; Main.Size = UDim2.new(0, 580, 0, 360) end)
    else
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        tween(Main, 0.3, {Size = UDim2.new(0, 580, 0, 360)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- Хоткей RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleBtn.MouseButton1Click:Fire()
    end
end)

-- Приветствие
task.wait(0.5)
notify("VEXHUB", "Prison Life Edition loaded. Press RightShift to toggle")
