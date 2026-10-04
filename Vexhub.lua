--[[ ⬢ VEXHUB | Prison Life Edition | v1.1 ]]
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

-- ═══════════ ПАЛИТРА (плоская, как на скрине) ═══════════
local C = {
    bg        = Color3.fromRGB(15, 15, 15),
    rowBg     = Color3.fromRGB(22, 22, 22),
    rowHover  = Color3.fromRGB(30, 30, 30),
    iconBg    = Color3.fromRGB(25, 25, 25),
    topBg     = Color3.fromRGB(18, 18, 18),
    accent    = Color3.fromRGB(0, 170, 255),
    toggleOff = Color3.fromRGB(60, 60, 60),
    toggleOn  = Color3.fromRGB(255, 255, 255),
    text      = Color3.fromRGB(240, 240, 240),
    textDim   = Color3.fromRGB(140, 140, 140),
    textFaint = Color3.fromRGB(90, 90, 90),
}

local TWEEN_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SOFT = TweenInfo.new(0.28, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

local function corner(i, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = i
    return c
end

local function tween(i, info, props)
    local t = TweenService:Create(i, info, props)
    t:Play()
    return t
end

local function getHum()
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getHRP()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ═══════════ СКРИН ═══════════
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
notifHolder.Name = "Notifs"
notifHolder.Size = UDim2.new(0, 360, 1, -20)
notifHolder.Position = UDim2.new(1, -380, 0, 20)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = ScreenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Top
notifList.Padding = UDim.new(0, 8)
notifList.Parent = notifHolder

local function notify(title, desc)
    if not notifEnabled then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = C.rowBg
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, 400, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = notifHolder
    corner(frame, 12)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, -24)
    bar.Position = UDim2.new(0, 12, 0, 12)
    bar.BackgroundColor3 = C.accent
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    bar.Parent = frame
    corner(bar, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 0, 22)
    titleLabel.Position = UDim2.new(0, 30, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = C.text
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTransparency = 1
    titleLabel.Parent = frame

    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -50, 0, 20)
    descLabel.Position = UDim2.new(0, 30, 0, 36)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc or ""
    descLabel.TextColor3 = C.textDim
    descLabel.TextSize = 13
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextTransparency = 1
    descLabel.Parent = frame

    -- Плавное появление
    tween(frame, TWEEN_SOFT, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0,
    })
    tween(bar, TWEEN_SOFT, {BackgroundTransparency = 0})
    tween(titleLabel, TWEEN_SOFT, {TextTransparency = 0})
    tween(descLabel, TWEEN_SOFT, {TextTransparency = 0})

    task.delay(notifDuration, function()
        tween(frame, TWEEN_SOFT, {
            Position = UDim2.new(1, 400, 0, 0),
            BackgroundTransparency = 1,
        })
        tween(bar, TWEEN_SOFT, {BackgroundTransparency = 1})
        tween(titleLabel, TWEEN_SOFT, {TextTransparency = 1})
        tween(descLabel, TWEEN_SOFT, {TextTransparency = 1})
        task.wait(0.35)
        if frame.Parent then frame:Destroy() end
    end)
end

-- ═══════════ ПЛАВАЮЩАЯ КНОПКА (открыть/закрыть) ═══════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleBtn.BackgroundColor3 = C.bg
ToggleBtn.Text = "⬢"
ToggleBtn.TextColor3 = C.text
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
corner(ToggleBtn, 22)

-- ═══════════ ГЛАВНОЕ ОКНО ═══════════
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 600, 0, 380)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 14)

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = C.bg
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
corner(TopBar, 14)

local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 15)
topFix.Position = UDim2.new(0, 0, 1, -15)
topFix.BackgroundColor3 = C.bg
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

-- Иконка-лого (левая)
local LogoIcon = Instance.new("Frame")
LogoIcon.Size = UDim2.new(0, 34, 0, 34)
LogoIcon.Position = UDim2.new(0, 14, 0.5, -17)
LogoIcon.BackgroundColor3 = C.iconBg
LogoIcon.BorderSizePixel = 0
LogoIcon.Parent = TopBar
corner(LogoIcon, 8)

local LogoIconStroke = Instance.new("UIStroke")
LogoIconStroke.Color = C.accent
LogoIconStroke.Thickness = 1.5
LogoIconStroke.Transparency = 0.2
LogoIconStroke.Parent = LogoIcon

local LogoEmoji = Instance.new("TextLabel")
LogoEmoji.Size = UDim2.new(1, 0, 1, 0)
LogoEmoji.BackgroundTransparency = 1
LogoEmoji.Text = "⬢"
LogoEmoji.TextColor3 = C.text
LogoEmoji.TextSize = 16
LogoEmoji.Font = Enum.Font.GothamBold
LogoEmoji.Parent = LogoIcon

-- Иконка-меню (три полоски)
local MenuIcon = Instance.new("Frame")
MenuIcon.Size = UDim2.new(0, 34, 0, 34)
MenuIcon.Position = UDim2.new(0, 56, 0.5, -17)
MenuIcon.BackgroundTransparency = 1
MenuIcon.Parent = TopBar

for i = 1, 3 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 20, 0, 2)
    line.Position = UDim2.new(0, 7, 0, 9 + (i - 1) * 6)
    line.BackgroundColor3 = C.text
    line.BorderSizePixel = 0
    line.Parent = MenuIcon
    corner(line, 1)
end

-- Заголовок
local LogoName = Instance.new("TextLabel")
LogoName.Size = UDim2.new(0, 240, 0, 18)
LogoName.Position = UDim2.new(0, 100, 0, 8)
LogoName.BackgroundTransparency = 1
LogoName.Text = "VEXHUB"
LogoName.TextColor3 = C.text
LogoName.TextSize = 15
LogoName.Font = Enum.Font.GothamBold
LogoName.TextXAlignment = Enum.TextXAlignment.Left
LogoName.Parent = TopBar

local LogoSub = Instance.new("TextLabel")
LogoSub.Size = UDim2.new(0, 240, 0, 14)
LogoSub.Position = UDim2.new(0, 100, 0, 26)
LogoSub.BackgroundTransparency = 1
LogoSub.Text = "Prison Life Edition"
LogoSub.TextColor3 = C.textDim
LogoSub.TextSize = 11
LogoSub.Font = Enum.Font.GothamMedium
LogoSub.TextXAlignment = Enum.TextXAlignment.Left
LogoSub.Parent = TopBar

-- Кнопка свернуть
local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 32, 0, 32)
Minimize.Position = UDim2.new(1, -84, 0.5, -16)
Minimize.BackgroundColor3 = C.iconBg
Minimize.Text = "—"
Minimize.TextColor3 = C.text
Minimize.TextSize = 16
Minimize.Font = Enum.Font.GothamBold
Minimize.BorderSizePixel = 0
Minimize.AutoButtonColor = false
Minimize.Parent = TopBar
corner(Minimize, 8)

-- Кнопка закрыть
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -46, 0.5, -16)
Close.BackgroundColor3 = C.iconBg
Close.Text = "✕"
Close.TextColor3 = C.text
Close.TextSize = 14
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.AutoButtonColor = false
Close.Parent = TopBar
corner(Close, 8)

for _, btn in ipairs({Minimize, Close}) do
    btn.MouseEnter:Connect(function()
        tween(btn, TWEEN_FAST, {BackgroundColor3 = C.rowHover})
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, TWEEN_FAST, {BackgroundColor3 = C.iconBg})
    end)
end

-- Разделитель
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 50)
Divider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Divider.BorderSizePixel = 0
Divider.Parent = Main

-- ═══════════ КОНТЕНТ ═══════════
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -28, 1, -80)
Content.Position = UDim2.new(0, 14, 0, 66)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Большая иконка слева (как на скрине)
local BigIcon = Instance.new("Frame")
BigIcon.Size = UDim2.new(0, 90, 0, 90)
BigIcon.Position = UDim2.new(0, 0, 0, 0)
BigIcon.BackgroundColor3 = C.iconBg
BigIcon.BorderSizePixel = 0
BigIcon.Parent = Content
corner(BigIcon, 14)

local BigIconStroke = Instance.new("UIStroke")
BigIconStroke.Color = C.accent
BigIconStroke.Thickness = 2
BigIconStroke.Transparency = 0.15
BigIconStroke.Parent = BigIcon

local BigEmoji = Instance.new("TextLabel")
BigEmoji.Size = UDim2.new(1, 0, 1, 0)
BigEmoji.BackgroundTransparency = 1
BigEmoji.Text = "🔒"
BigEmoji.TextSize = 42
BigEmoji.Parent = BigIcon

-- Заголовок вкладки
local PageTitle = Instance.new("TextLabel")
PageTitle.Size = UDim2.new(0, 200, 0, 24)
PageTitle.Position = UDim2.new(0, 110, 0, 24)
PageTitle.BackgroundTransparency = 1
PageTitle.Text = "PRISONER"
PageTitle.TextColor3 = C.text
PageTitle.TextSize = 17
PageTitle.Font = Enum.Font.GothamBold
PageTitle.TextXAlignment = Enum.TextXAlignment.Left
PageTitle.Parent = Content

-- Скролл-фрейм для тоглов
local ListFrame = Instance.new("ScrollingFrame")
ListFrame.Size = UDim2.new(1, 0, 1, -110)
ListFrame.Position = UDim2.new(0, 0, 0, 110)
ListFrame.BackgroundTransparency = 1
ListFrame.BorderSizePixel = 0
ListFrame.ScrollBarThickness = 2
ListFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.Parent = Content

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = ListFrame
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

-- ═══════════ TOGGLE (плоский, круглый, как на скрине) ═══════════
local function createToggle(parent, text, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 52)
    row.BackgroundColor3 = C.rowBg
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 18, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    -- Круглый toggle (как на скрине)
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 46, 0, 26)
    switch.Position = UDim2.new(1, -60, 0.5, -13)
    switch.BackgroundColor3 = C.toggleOff
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.BorderSizePixel = 0
    switch.Parent = row
    corner(switch, 13)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 22, 0, 22)
    knob.Position = UDim2.new(0, 2, 0.5, -11)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 11)

    local state = default or false

    local function update(animate)
        local info = animate and TWEEN_FAST or TweenInfo.new(0)
        if state then
            tween(switch, info, {BackgroundColor3 = C.toggleOn})
            tween(knob, info, {Position = UDim2.new(1, -24, 0.5, -11)})
        else
            tween(switch, info, {BackgroundColor3 = C.toggleOff})
            tween(knob, info, {Position = UDim2.new(0, 2, 0.5, -11)})
        end
    end
    update(false)

    switch.MouseButton1Click:Connect(function()
        state = not state
        update(true)
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then notify("Error", tostring(err)) end
        end
    end)

    return {set = function(v) state = v; update(true) end, frame = row}
end

-- ═══════════ ПЕРЕКЛЮЧЕНИЕ ВКЛАДОК (через топбар-меню) ═══════════
local tabs = {}
local currentTab = nil

local function clearList()
    for _, c in ipairs(ListFrame:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

local function setTab(name)
    if currentTab == name then return end
    currentTab = name
    local tabData = tabs[name]
    if not tabData then return end

    clearList()

    -- Плавная смена
    ListFrame.GroupTransparency = 1
    tween(ListFrame, TWEEN_SOFT, {GroupTransparency = 0})

    -- Анимируем иконку
    BigEmoji.Text = tabData.icon
    PageTitle.Text = string.upper(name)

    tween(BigIcon, TWEEN_SOFT, {BackgroundTransparency = 0.4})
    task.delay(0.15, function()
        tween(BigIcon, TWEEN_SOFT, {BackgroundTransparency = 0})
    end)

    -- Создаём строки
    for _, item in ipairs(tabData.items) do
        createToggle(ListFrame, item.label, item.default, item.callback)
    end
end

-- ═══════════ ВКЛАДКИ ═══════════
tabs["Prisoner"] = {
    icon = "🔒",
    items = {
        {label = "Inf Stamina",  default = false, callback = function(v) notify("Prisoner", "Inf Stamina " .. (v and "enabled" or "disabled")) end},
        {label = "Speed Boost",  default = false, callback = function(v) notify("Prisoner", "Speed Boost " .. (v and "enabled" or "disabled")) end},
        {label = "Fast Punch",   default = false, callback = function(v) notify("Prisoner", "Fast Punch " .. (v and "enabled" or "disabled")) end},
        {label = "Auto Escape",  default = false, callback = function(v) notify("Prisoner", "Auto Escape " .. (v and "enabled" or "disabled")) end},
        {label = "Noclip",       default = false, callback = function(v) notify("Prisoner", "Noclip " .. (v and "enabled" or "disabled")) end},
    },
}

tabs["Guard"] = {
    icon = "🛡",
    items = {
        {label = "Auto Arrest",  default = false, callback = function(v) notify("Guard", "Auto Arrest " .. (v and "enabled" or "disabled")) end},
        {label = "Weapon ESP",   default = false, callback = function(v) notify("Guard", "Weapon ESP " .. (v and "enabled" or "disabled")) end},
        {label = "God Mode",     default = false, callback = function(v) notify("Guard", "God Mode " .. (v and "enabled" or "disabled")) end},
        {label = "Fast Reload",  default = false, callback = function(v) notify("Guard", "Fast Reload " .. (v and "enabled" or "disabled")) end},
        {label = "Instant Kill", default = false, callback = function(v) notify("Guard", "Instant Kill " .. (v and "enabled" or "disabled")) end},
    },
}

tabs["Visuals"] = {
    icon = "◉",
    items = {
        {label = "ESP Prisoners", default = false, callback = function(v) notify("Visuals", "ESP Prisoners " .. (v and "enabled" or "disabled")) end},
        {label = "ESP Guards",    default = false, callback = function(v) notify("Visuals", "ESP Guards " .. (v and "enabled" or "disabled")) end},
        {label = "Full Bright",   default = false, callback = function(v) notify("Visuals", "Full Bright " .. (v and "enabled" or "disabled")) end},
    },
}

tabs["Player"] = {
    icon = "●",
    items = {
        {label = "God Mode",      default = false, callback = function(v) notify("Player", "God Mode " .. (v and "enabled" or "disabled")) end},
        {label = "Anti AFK",      default = false, callback = function(v) notify("Player", "Anti AFK " .. (v and "enabled" or "disabled")) end},
        {label = "Anti Arrest",   default = false, callback = function(v) notify("Player", "Anti Arrest " .. (v and "enabled" or "disabled")) end},
        {label = "Reset Character", default = false, callback = function(v)
            if v then
                local hum = getHum()
                if hum then hum.Health = 0 end
                notify("Player", "Character reset")
            end
        end},
    },
}

tabs["Settings"] = {
    icon = "⚙",
    items = {
        {label = "Notifications", default = true, callback = function(v)
            notifEnabled = v
            if v then notify("VEXHUB", "Notifications enabled") end
        end},
    },
}

-- ═══════════ ОТКРЫТИЕ / ЗАКРЫТИЕ ═══════════
local function openUI()
    Main.Visible = true
    Main.Size = UDim2.new(0, 600, 0, 380)
    Main.BackgroundTransparency = 1
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)

    tween(Main, TWEEN_SOFT, {BackgroundTransparency = 0})

    if not currentTab then setTab("Prisoner") end
end

local function closeUI()
    tween(Main, TWEEN_SOFT, {BackgroundTransparency = 1})
    task.wait(0.3)
    Main.Visible = false
    Main.BackgroundTransparency = 0
end

-- Плавающая кнопка
local btnDragging, btnDragStart, btnStartPos = false, nil, nil
local btnDidMove = false

ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDragging = true
        btnDidMove = false
        btnDragStart = i.Position
        btnStartPos = ToggleBtn.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if btnDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - btnDragStart
        if delta.Magnitude > 4 then btnDidMove = true end
        ToggleBtn.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        btnDragging = false
    end
end)

ToggleBtn.MouseButton1Click:Connect(function()
    if btnDidMove then return end
    if Main.Visible then closeUI() else openUI() end
end)

-- Перетаскивание окна за топбар
local winDragging, winDragStart, winStartPos = false, nil, nil
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        winDragging = true
        winDragStart = i.Position
        winStartPos = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if winDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - winDragStart
        Main.Position = UDim2.new(
            winStartPos.X.Scale, winStartPos.X.Offset + delta.X,
            winStartPos.Y.Scale, winStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        winDragging = false
    end
end)

-- Кнопки топбара
Minimize.MouseButton1Click:Connect(closeUI)
Close.MouseButton1Click:Connect(function()
    closeUI()
    task.wait(0.35)
    ScreenGui.Enabled = false
end)

-- Меню иконка (три полоски) — открывает выбор вкладки
MenuIcon.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        -- Простой цикл по вкладкам
        local order = {"Prisoner", "Guard", "Visuals", "Player", "Settings"}
        local idx = 1
        for k, v in ipairs(order) do
            if v == currentTab then idx = k end
        end
        idx = idx % #order + 1
        setTab(order[idx])
    end
end)

MenuIcon.MouseEnter:Connect(function()
    for _, line in ipairs(MenuIcon:GetChildren()) do
        if line:IsA("Frame") then
            tween(line, TWEEN_FAST, {BackgroundColor3 = C.accent})
        end
    end
end)
MenuIcon.MouseLeave:Connect(function()
    for _, line in ipairs(MenuIcon:GetChildren()) do
        if line:IsA("Frame") then
            tween(line, TWEEN_FAST, {BackgroundColor3 = C.text})
        end
    end
end)

-- ═══════════ ХОТКЕЙ ═══════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Main.Visible then closeUI() else openUI() end
    end
end)

-- Приветствие
task.wait(0.6)
notify("VEXHUB", "Successfully loaded. Press RightShift to toggle")
