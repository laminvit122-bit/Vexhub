--[[ VexHub | Prison Life Edition ]]
if getgenv and getgenv().VexHub_Loaded then return end
if getgenv then getgenv().VexHub_Loaded = true end

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")

local player    = Players.LocalPlayer
local parentGui = (gethui and gethui()) or CoreGui
if parentGui:FindFirstChild("VexHubUI") then parentGui.VexHubUI:Destroy() end

local C = {
    bg        = Color3.fromRGB(14, 14, 14),
    sidebar   = Color3.fromRGB(11, 11, 11),
    row       = Color3.fromRGB(22, 22, 22),
    line      = Color3.fromRGB(35, 35, 35),
    accent    = Color3.fromRGB(139, 92, 246),
    toggleOff = Color3.fromRGB(55, 55, 55),
    toggleOn  = Color3.fromRGB(255, 255, 255),
    text      = Color3.fromRGB(235, 235, 235),
    textDim   = Color3.fromRGB(120, 120, 120),
}

local T_FAST = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local T_SOFT = TweenInfo.new(0.26, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function corner(i, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = i; return c
end
local function tween(i, info, props) local t = TweenService:Create(i, info, props); t:Play(); return t end

local function getHum()
    local ch = player.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end

-- ═══════════ SCREEN ═══════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VexHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentGui

-- ═══════════ УВЕДОМЛЕНИЯ (справа сверху) ═══════════
local notifEnabled  = true
local notifDuration = 3

local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 340, 1, -20)
notifHolder.Position = UDim2.new(1, -360, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = ScreenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Top
notifList.Padding = UDim.new(0, 8)
notifList.Parent = notifHolder

local function notify(title, desc)
    if not notifEnabled then return end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 66)
    f.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    f.BorderSizePixel = 0
    f.Position = UDim2.new(1, 380, 0, 0)
    f.BackgroundTransparency = 1
    f.Parent = notifHolder
    corner(f, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -22)
    bar.Position = UDim2.new(0, 12, 0, 11)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    bar.Parent = f
    corner(bar, 2)

    local t1 = Instance.new("TextLabel")
    t1.Size = UDim2.new(1, -40, 0, 20)
    t1.Position = UDim2.new(0, 26, 0, 12)
    t1.BackgroundTransparency = 1
    t1.Text = title
    t1.TextColor3 = C.text
    t1.TextSize = 15
    t1.Font = Enum.Font.GothamBold
    t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextTransparency = 1
    t1.Parent = f

    local t2 = Instance.new("TextLabel")
    t2.Size = UDim2.new(1, -40, 0, 18)
    t2.Position = UDim2.new(0, 26, 0, 36)
    t2.BackgroundTransparency = 1
    t2.Text = desc or ""
    t2.TextColor3 = C.textDim
    t2.TextSize = 13
    t2.Font = Enum.Font.GothamMedium
    t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextTransparency = 1
    t2.Parent = f

    tween(f, T_SOFT, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0})
    tween(bar, T_SOFT, {BackgroundTransparency = 0})
    tween(t1, T_SOFT, {TextTransparency = 0})
    tween(t2, T_SOFT, {TextTransparency = 0})

    task.delay(notifDuration, function()
        tween(f, T_SOFT, {Position = UDim2.new(1, 380, 0, 0), BackgroundTransparency = 1})
        tween(bar, T_SOFT, {BackgroundTransparency = 1})
        tween(t1, T_SOFT, {TextTransparency = 1})
        tween(t2, T_SOFT, {TextTransparency = 1})
        task.wait(0.3)
        if f.Parent then f:Destroy() end
    end)
end

-- ═══════════ ПЛАВАЮЩАЯ КНОПКА ═══════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = C.bg
ToggleBtn.Text = "≡"
ToggleBtn.TextColor3 = C.text
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
corner(ToggleBtn, 22)

-- ═══════════ ОКНО ═══════════
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 620, 0, 380)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 12)

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = C.bg
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = C.bg
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

local LogoName = Instance.new("TextLabel")
LogoName.Size = UDim2.new(0, 300, 0, 16)
LogoName.Position = UDim2.new(0, 16, 0, 6)
LogoName.BackgroundTransparency = 1
LogoName.Text = "VexHub"
LogoName.TextColor3 = C.text
LogoName.TextSize = 14
LogoName.Font = Enum.Font.GothamBold
LogoName.TextXAlignment = Enum.TextXAlignment.Left
LogoName.Parent = TopBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(0, 300, 0, 12)
LogoSub.Position = UDim2.new(0, 16, 0, 22)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "Prison Life Edition"
LogoSub.TextColor3 = C.textDim
LogoSub.TextSize = 10
LogoSub.Font = Enum.Font.GothamMedium
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = TopBar

-- Круглая скорость
local SpeedCircle = Instance.new("Frame")
SpeedCircle.Size = UDim2.new(0, 30, 0, 30)
SpeedCircle.Position = UDim2.new(0.5, -15, 0.5, -15)
SpeedCircle.BackgroundColor3 = C.bg
SpeedCircle.BorderSizePixel = 0
SpeedCircle.Parent = TopBar
corner(SpeedCircle, 15)

local scStroke = Instance.new("UIStroke")
scStroke.Color = Color3.fromRGB(60, 60, 60)
scStroke.Thickness = 1
scStroke.Parent = SpeedCircle

local SpeedText = Instance.new("TextLabel")
SpeedText.Size = UDim2.new(1, 0, 1, 0)
SpeedText.BackgroundTransparency = 1
SpeedText.Text = "3.9x"
SpeedText.TextColor3 = C.text
SpeedText.TextSize = 11
SpeedText.Font = Enum.Font.GothamMedium
SpeedText.Parent = SpeedCircle

task.spawn(function()
    while SpeedCircle.Parent do
        local ch = player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            SpeedText.Text = string.format("%.1fx", math.max(hrp.Velocity.Magnitude / 16, 1))
        end
        task.wait(0.2)
    end
end)

-- Кнопки справа
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 26, 0, 26)
Minimize.Position = UDim2.new(1, -66, 0.5, -13)
Minimize.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Minimize.Text = "—"
Minimize.TextColor3 = C.text
Minimize.TextSize = 14
Minimize.Font = Enum.Font.GothamBold
Minimize.BorderSizePixel = 0
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar
corner(Minimize, 6)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 26, 0, 26)
Close.Position = UDim2.new(1, -36, 0.5, -13)
Close.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
Close.Text = "✕"
Close.TextColor3 = C.text
Close.TextSize = 12
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Parent = TopBar
corner(Close, 6)

for _, b in ipairs({Minimize, Close}) do
    b.MouseEnter:Connect(function() tween(b, T_FAST, {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}) end)
    b.MouseLeave:Connect(function() tween(b, T_FAST, {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}) end)
end

-- Разделитель
local Div = Instance.new("Frame")
Div.Size = UDim2.new(1, 0, 0, 1)
Div.Position = UDim2.new(0, 0, 0, 42)
Div.BackgroundColor3 = C.line
Div.BorderSizePixel = 0
Div.Parent = Main

-- ═══════════ САЙДБАР ═══════════
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -43)
Sidebar.Position = UDim2.new(0, 0, 0, 43)
Sidebar.BackgroundTransparency = 1
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 2)
SideLayout.Parent = Sidebar

-- Контент
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -43)
Content.Position = UDim2.new(0, 150, 0, 43)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ═══════════ TOGGLE (плоский, тонкий, как KerryHub) ═══════════
local function createToggle(parent, label, default, callback)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, -20, 0, 34)
    row.BackgroundColor3 = C.bg
    row.Text = ""
    row.AutoButtonColor = false
    row.BorderSizePixel = 0
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local switch = Instance.new("Frame")
    switch.Size = UDim2.new(0, 40, 0, 22)
    switch.Position = UDim2.new(1, -46, 0.5, -11)
    switch.BackgroundColor3 = C.toggleOff
    switch.BorderSizePixel = 0
    switch.Parent = row
    corner(switch, 11)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 9)

    local state = default or false

    local function update(anim)
        local info = anim and T_FAST or TweenInfo.new(0)
        if state then
            tween(switch, info, {BackgroundColor3 = C.toggleOn})
            tween(knob, info, {Position = UDim2.new(1, -20, 0.5, -9)})
        else
            tween(switch, info, {BackgroundColor3 = C.toggleOff})
            tween(knob, info, {Position = UDim2.new(0, 2, 0.5, -9)})
        end
    end
    update(false)

    row.MouseButton1Click:Connect(function()
        state = not state
        update(true)
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then notify("Error", tostring(err)) end
        end
    end)

    row.MouseEnter:Connect(function() tween(row, T_FAST, {BackgroundColor3 = C.row}) end)
    row.MouseLeave:Connect(function() tween(row, T_FAST, {BackgroundColor3 = C.bg}) end)

    return row
end

-- ═══════════ ТАБЫ ═══════════
local tabs = {}
local currentTab

local function clearContent()
    for _, c in ipairs(Content:GetChildren()) do c:Destroy() end
end

local function setTab(name)
    if currentTab == name then return end
    currentTab = name

    -- Сайдбар
    for tabName, data in pairs(tabs) do
        local active = (tabName == name)
        tween(data.btn, T_FAST, {TextColor3 = active and C.text or C.textDim})
        tween(data.underline, T_FAST, {BackgroundTransparency = active and 0 or 1})
    end

    -- Контент
    clearContent()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.GroupTransparency = 1
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    tween(page, T_SOFT, {GroupTransparency = 0})

    for _, item in ipairs(tabs[name].items) do
        createToggle(page, item.label, item.default, item.callback)
    end
end

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.BackgroundColor3 = C.sidebar
    btn.Text = "  " .. name
    btn.TextColor3 = C.textDim
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    corner(btn, 6)

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8)
    pad.Parent = btn

    local underline = Instance.new("Frame")
    underline.Size = UDim2.new(0, 2, 0, 16)
    underline.Position = UDim2.new(0, 0, 0.5, -8)
    underline.BackgroundColor3 = C.accent
    underline.BorderSizePixel = 0
    underline.BackgroundTransparency = 1
    underline.Parent = btn
    corner(underline, 1)

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then tween(btn, T_FAST, {BackgroundColor3 = C.row}) end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then tween(btn, T_FAST, {BackgroundColor3 = C.sidebar}) end
    end)
    btn.MouseButton1Click:Connect(function() setTab(name) end)

    return btn, underline
end

-- ═══════════ ФУНКЦИИ (состояния) ═══════════
local State = {
    infStamina = false, speedBoost = false, fastPunch = false, autoEscape = false, noclip = false,
    autoArrest = false, weaponESP = false, godMode = false, fastReload = false, instantKill = false,
    espPrisoners = false, espGuards = false, fullBright = false,
    antiAFK = false, antiArrest = false,
}

-- ESP Highlights
local highlights = {}
local function clearHL()
    for _, h in pairs(highlights) do if h and h.Parent then h:Destroy() end end
    highlights = {}
end
local function addHL(char, color)
    if not char or highlights[char] then return end
    local h = Instance.new("Highlight")
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.55
    h.OutlineTransparency = 0.2
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Adornee = char
    h.Parent = char
    highlights[char] = h
end
local function refreshESP()
    clearHL()
    if not (State.espPrisoners or State.espGuards) then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local tn = p.Team and p.Team.Name or ""
            if State.espPrisoners and (tn == "Prisoners" or tn == "Inmates" or tn == "Criminals" or tn == "") then
                addHL(p.Character, Color3.fromRGB(255, 165, 0))
            elseif State.espGuards and (tn == "Guards" or tn == "Police" or tn == "Cops") then
                addHL(p.Character, Color3.fromRGB(0, 170, 255))
            end
        end
    end
end

-- ═══════════ ВКЛАДКИ ═══════════
tabs["Main"] = {
    items = {
        {label = "Inf Stamina", default = false, callback = function(v) State.infStamina = v; notify("Player", "Inf Stamina " .. (v and "enabled" or "disabled")) end},
        {label = "Speed Boost", default = false, callback = function(v)
            State.speedBoost = v
            local h = getHum(); if h then h.WalkSpeed = v and 32 or 16 end
            notify("Player", "Speed Boost " .. (v and "enabled" or "disabled"))
        end},
        {label = "Fast Punch",  default = false, callback = function(v) State.fastPunch = v; notify("Player", "Fast Punch " .. (v and "enabled" or "disabled")) end},
        {label = "Auto Escape", default = false, callback = function(v) State.autoEscape = v; notify("Player", "Auto Escape " .. (v and "enabled" or "disabled")) end},
        {label = "Noclip",      default = false, callback = function(v) State.noclip = v; notify("Player", "Noclip " .. (v and "enabled" or "disabled")) end},
        {label = "God Mode",    default = false, callback = function(v) State.godMode = v; notify("Player", "God Mode " .. (v and "enabled" or "disabled")) end},
    },
}

tabs["Visuals"] = {
    items = {
        {label = "ESP Prisoners", default = false, callback = function(v) State.espPrisoners = v; refreshESP(); notify("Visuals", "ESP Prisoners " .. (v and "enabled" or "disabled")) end},
        {label = "ESP Guards",    default = false, callback = function(v) State.espGuards = v; refreshESP(); notify("Visuals", "ESP Guards " .. (v and "enabled" or "disabled")) end},
        {label = "Full Bright",   default = false, callback = function(v)
            State.fullBright = v
            if v then
                Lighting.Ambient = Color3.fromRGB(178,178,178)
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(178,178,178)
                Lighting.FogEnd = 1e5
            else
                Lighting.Ambient = Color3.fromRGB(70,70,70)
                Lighting.Brightness = 1
                Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
            end
            notify("Visuals", "Full Bright " .. (v and "enabled" or "disabled"))
        end},
    },
}

tabs["Settings"] = {
    items = {
        {label = "Notifications", default = true, callback = function(v)
            notifEnabled = v
            if v then notify("VexHub", "Notifications enabled") end
        end},
    },
}

-- Авто-создание кнопок табов (порядок как на скрине)
for _, name in ipairs({"Main", "Visuals", "Settings"}) do
    local btn, under = createTabButton(name)
    tabs[name].btn = btn
    tabs[name].underline = under
end

-- ═══════════ ОТКРЫТИЕ / ЗАКРЫТИЕ ═══════════
local function openUI()
    Main.Visible = true
    Main.BackgroundTransparency = 1
    tween(Main, T_SOFT, {BackgroundTransparency = 0})
    if not currentTab then setTab("Main") end
end

local function closeUI()
    tween(Main, T_SOFT, {BackgroundTransparency = 1})
    task.wait(0.28)
    Main.Visible = false
    Main.BackgroundTransparency = 0
end

-- Плавающая кнопка: перетаскивание + клик
local btnDrag, btnDidMove = false, false
local btnStart, btnPos

ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDrag = true; btnDidMove = false
        btnStart = i.Position; btnPos = ToggleBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if btnDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - btnStart
        if d.Magnitude > 4 then btnDidMove = true end
        ToggleBtn.Position = UDim2.new(btnPos.X.Scale, btnPos.X.Offset + d.X, btnPos.Y.Scale, btnPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDrag = false
    end
end)
ToggleBtn.MouseButton1Click:Connect(function()
    if btnDidMove then return end
    if Main.Visible then closeUI() else openUI() end
end)

-- Перетаскивание окна
local wDrag, wStart, wPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        wDrag = true; wStart = i.Position; wPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if wDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - wStart
        Main.Position = UDim2.new(wPos.X.Scale, wPos.X.Offset + d.X, wPos.Y.Scale, wPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        wDrag = false
    end
end)

Minimize.MouseButton1Click:Connect(closeUI)
Close.MouseButton1Click:Connect(function()
    closeUI()
    task.wait(0.32)
    ScreenGui.Enabled = false
end)

-- Хоткей
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then closeUI() else openUI() end
    end
end)

-- Приветствие
task.wait(0.5)
notify("VexHub", "Successfully loaded. Press RightShift to toggle")
