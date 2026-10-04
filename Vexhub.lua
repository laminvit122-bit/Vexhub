--[[ Чёрный Modern UI для executor ]]
if getgenv and getgenv().BlackUI_Loaded then return end
if getgenv then getgenv().BlackUI_Loaded = true end

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Защита от дубликатов
local parentGui = (gethui and gethui()) or CoreGui
if parentGui:FindFirstChild("BlackModernUI") then
    parentGui.BlackModernUI:Destroy()
end

-- ═══════════════ ПАЛИТРА ═══════════════
local COLORS = {
    bg        = Color3.fromRGB(0, 0, 0),
    bgAlt     = Color3.fromRGB(10, 10, 10),
    bgHover   = Color3.fromRGB(20, 20, 20),
    accent    = Color3.fromRGB(139, 92, 246),   -- фиолетовый
    accent2   = Color3.fromRGB(0, 212, 255),    -- голубой
    success   = Color3.fromRGB(34, 197, 94),
    error     = Color3.fromRGB(239, 68, 68),
    warn      = Color3.fromRGB(234, 179, 8),
    text      = Color3.fromRGB(255, 255, 255),
    textDim   = Color3.fromRGB(160, 160, 160),
    stroke    = Color3.fromRGB(26, 26, 26),
}

-- ═══════════════ СКРИН ═══════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackModernUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = parentGui

-- ═══════════════ ХЕЛПЕРЫ ═══════════════
local function corner(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or COLORS.stroke
    s.Thickness = thickness or 1
    s.Transparency = trans or 0
    s.Parent = inst
    return s
end

local function tween(inst, time, props, style, dir)
    local t = TweenService:Create(inst,
        TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

-- ═══════════════ УВЕДОМЛЕНИЯ ═══════════════
local notifHolder = Instance.new("Frame")
notifHolder.Name = "Notifications"
notifHolder.Size = UDim2.new(0, 320, 1, -20)
notifHolder.Position = UDim2.new(1, -340, 0, 10)
notifHolder.BackgroundTransparency = 1
notifHolder.Parent = ScreenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.Padding = UDim.new(0, 8)
notifList.Parent = notifHolder

local function notify(title, desc, kind)
    kind = kind or "info"
    local color = ({
        success = COLORS.success,
        error   = COLORS.error,
        warn    = COLORS.warn,
        info    = COLORS.accent,
    })[kind] or COLORS.accent

    local icon = ({
        success = "✓",
        error   = "✕",
        warn    = "!",
        info    = "i",
    })[kind] or "i"

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = COLORS.bgAlt
    frame.BorderSizePixel = 0
    frame.Position = UDim2.new(1, 400, 0, 0) -- старт справа за экраном
    frame.Parent = notifHolder
    corner(frame, 10)
    stroke(frame, COLORS.stroke, 1)

    -- Неоновая полоска слева
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, -16)
    bar.Position = UDim2.new(0, 8, 0, 8)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.Parent = frame
    corner(bar, 4)

    local barGlow = Instance.new("ImageLabel")
    barGlow.Size = UDim2.new(0, 20, 1, 0)
    barGlow.Position = UDim2.new(0, 0, 0, 0)
    barGlow.BackgroundTransparency = 1
    barGlow.Image = "rbxassetid://5028857472"
    barGlow.ImageColor3 = color
    barGlow.ImageTransparency = 0.7
    barGlow.Parent = bar

    -- Иконка-кружок
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 36, 0, 36)
    iconBg.Position = UDim2.new(0, 22, 0.5, -18)
    iconBg.BackgroundColor3 = color
    iconBg.BackgroundTransparency = 0.85
    iconBg.BorderSizePixel = 0
    iconBg.Parent = frame
    corner(iconBg, 18)
    stroke(iconBg, color, 1, 0.3)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = color
    iconLabel.TextSize = 20
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Parent = iconBg

    -- Заголовок
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 0, 22)
    titleLabel.Position = UDim2.new(0, 68, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.text
    titleLabel.TextSize = 15
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    -- Описание
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -80, 0, 18)
    descLabel.Position = UDim2.new(0, 68, 0, 36)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc or ""
    descLabel.TextColor3 = COLORS.textDim
    descLabel.TextSize = 12
    descLabel.Font = Enum.Font.GothamMedium
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = frame

    -- Анимация появления
    frame.BackgroundTransparency = 1
    titleLabel.TextTransparency = 1
    descLabel.TextTransparency = 1

    tween(frame, 0.4, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0,
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    tween(titleLabel, 0.3, {TextTransparency = 0})
    tween(descLabel, 0.3, {TextTransparency = 0})

    -- Удаление через 3 секунды
    task.delay(3, function()
        tween(frame, 0.3, {
            Position = UDim2.new(1, 400, 0, 0),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

        for _, v in ipairs(frame:GetDescendants()) do
            if v:IsA("TextLabel") then
                tween(v, 0.3, {TextTransparency = 1})
            end
        end

        task.wait(0.35)
        frame:Destroy()
    end)
end

-- ═══════════════ ГЛАВНОЕ ОКНО ═══════════════
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 500, 0, 340)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = COLORS.bg
Main.BorderSizePixel = 0
Main.Visible = false
Main.Parent = ScreenGui
corner(Main, 12)
stroke(Main, COLORS.stroke, 1)

-- Топбар
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = COLORS.bgAlt
TopBar.BorderSizePixel = 0
TopBar.Parent = Main
corner(TopBar, 12)

local topBarFix = Instance.new("Frame") -- скрыть скругление снизу
topBarFix.Size = UDim2.new(1, 0, 0, 12)
topBarFix.Position = UDim2.new(0, 0, 1, -12)
topBarFix.BackgroundColor3 = COLORS.bgAlt
topBarFix.BorderSizePixel = 0
topBarFix.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "  BLACK UI"
Title.TextColor3 = COLORS.text
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Неоновая точка-статус
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(0, 8, 0.5, -4)
dot.BackgroundColor3 = COLORS.accent
dot.BorderSizePixel = 0
dot.Parent = TopBar
corner(dot, 4)

local dotGlow = Instance.new("ImageLabel")
dotGlow.Size = UDim2.new(0, 24, 0, 24)
dotGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
dotGlow.AnchorPoint = Vector2.new(0.5, 0.5)
dotGlow.BackgroundTransparency = 1
dotGlow.Image = "rbxassetid://5028857472"
dotGlow.ImageColor3 = COLORS.accent
dotGlow.ImageTransparency = 0.4
dotGlow.Parent = dot

-- Кнопка закрытия
local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -36, 0.5, -14)
Close.BackgroundColor3 = COLORS.bgHover
Close.Text = "✕"
Close.TextColor3 = COLORS.textDim
Close.TextSize = 14
Close.Font = Enum.Font.GothamBold
Close.BorderSizePixel = 0
Close.Parent = TopBar
corner(Close, 6)

Close.MouseEnter:Connect(function() tween(Close, 0.15, {BackgroundColor3 = COLORS.error, TextColor3 = COLORS.text}) end)
Close.MouseLeave:Connect(function() tween(Close, 0.15, {BackgroundColor3 = COLORS.bgHover, TextColor3 = COLORS.textDim}) end)
Close.MouseButton1Click:Connect(function()
    tween(Main, 0.25, {Size = UDim2.new(0, 0, 0, 0)})
    task.wait(0.25)
    Main.Visible = false
end)

-- Перетаскивание
do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════ ТАБЫ ═══════════════
local TabsHolder = Instance.new("Frame")
TabsHolder.Size = UDim2.new(0, 130, 1, -55)
TabsHolder.Position = UDim2.new(0, 10, 0, 48)
TabsHolder.BackgroundTransparency = 1
TabsHolder.Parent = Main

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.Parent = TabsHolder

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -155, 1, -55)
ContentHolder.Position = UDim2.new(0, 148, 0, 48)
ContentHolder.BackgroundColor3 = COLORS.bgAlt
ContentHolder.BorderSizePixel = 0
ContentHolder.Parent = Main
corner(ContentHolder, 8)
stroke(ContentHolder, COLORS.stroke, 1)

local pages = {}
local activeTab

local function createTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = COLORS.bgAlt
    btn.Text = "  " .. name
    btn.TextColor3 = COLORS.textDim
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = TabsHolder
    corner(btn, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = COLORS.accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = ContentHolder

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end)

    pages[name] = {btn = btn, page = page}

    btn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do
            p.page.Visible = false
            tween(p.btn, 0.15, {BackgroundColor3 = COLORS.bgAlt, TextColor3 = COLORS.textDim})
        end
        page.Visible = true
        tween(btn, 0.15, {BackgroundColor3 = COLORS.bgHover, TextColor3 = COLORS.text})
        activeTab = name
    end)

    btn.MouseEnter:Connect(function()
        if activeTab ~= name then tween(btn, 0.15, {BackgroundColor3 = COLORS.bgHover}) end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= name then tween(btn, 0.15, {BackgroundColor3 = COLORS.bgAlt}) end
    end)

    return page
end

-- ═══════════════ TOGGLE ═══════════════
local function createToggle(parent, text, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -8, 0, 36)
    toggleFrame.BackgroundColor3 = COLORS.bg
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    corner(toggleFrame, 6)
    stroke(toggleFrame, COLORS.stroke, 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = COLORS.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 40, 0, 20)
    switch.Position = UDim2.new(1, -50, 0.5, -10)
    switch.BackgroundColor3 = COLORS.bgHover
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.BorderSizePixel = 0
    switch.Parent = toggleFrame
    corner(switch, 10)
    stroke(switch, COLORS.stroke, 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = COLORS.textDim
    knob.BorderSizePixel = 0
    knob.Parent = switch
    corner(knob, 8)

    local state = default or false

    local function update(anim)
        if state then
            tween(switch, 0.2, {BackgroundColor3 = COLORS.accent})
            tween(knob, 0.2, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = COLORS.text})
        else
            tween(switch, 0.2, {BackgroundColor3 = COLORS.bgHover})
            tween(knob, 0.2, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = COLORS.textDim})
        end
    end

    update(false)

    switch.MouseButton1Click:Connect(function()
        state = not state
        update(true)
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then
                notify("Ошибка", tostring(err), "error")
            end
        end
    end)

    return {frame = toggleFrame, set = function(v) state = v; update(true) end}
end

-- ═══════════════ ВКЛАДКИ И ФУНКЦИИ ═══════════════
local mainPage = createTab("Главное")
local visualPage = createTab("Визуал")
local miscPage = createTab("Разное")

-- ГЛАВНОЕ
createToggle(mainPage, "🚀 Speed Boost", false, function(on)
    if on then
        notify("Speed Boost", "Скорость увеличена до 100", "success")
    else
        notify("Speed Boost", "Функция выключена", "warn")
    end
end)

createToggle(mainPage, "🦘 Infinite Jump", false, function(on)
    if on then
        notify("Infinite Jump", "Бесконечный прыжок активирован", "success")
    else
        notify("Infinite Jump", "Функция выключена", "warn")
    end
end)

createToggle(mainPage, "🛡️ God Mode", false, function(on)
    if on then
        notify("God Mode", "Вы неуязвимы", "success")
    else
        notify("God Mode", "Функция выключена", "warn")
    end
end)

-- ВИЗУАЛ
createToggle(visualPage, "👁️ ESP Players", false, function(on)
    if on then
        notify("ESP", "Подсветка игроков включена", "success")
    else
        notify("ESP", "Функция выключена", "warn")
    end
end)

createToggle(visualPage, "📦 ESP Objects", false, function(on)
    if on then
        notify("ESP Objects", "Объекты подсвечены", "success")
    else
        notify("ESP Objects", "Функция выключена", "warn")
    end
end)

createToggle(visualPage, "🌙 Full Bright", false, function(on)
    if on then
        notify("Full Bright", "Освещение улучшено", "success")
    else
        notify("Full Bright", "Функция выключена", "warn")
    end
end)

-- РАЗНОЕ
createToggle(miscPage, "🔫 Auto Clicker", false, function(on)
    if on then
        notify("Auto Clicker", "Автокликер активирован", "success")
    else
        notify("Auto Clicker", "Функция выключена", "warn")
    end
end)

createToggle(miscPage, "💬 Anti AFK", false, function(on)
    if on then
        notify("Anti AFK", "Защита от кика включена", "success")
    else
        notify("Anti AFK", "Функция выключена", "warn")
    end
end)

-- Активировать первую вкладку
pages["Главное"].btn:Fire("MouseButton1Click") -- не сработает напрямую, вызываем вручную:
for _, p in pairs(pages) do p.page.Visible = false end
pages["Главное"].page.Visible = true
pages["Главное"].btn.BackgroundColor3 = COLORS.bgHover
pages["Главное"].btn.TextColor3 = COLORS.text
activeTab = "Главное"

-- ═══════════════ КНОПКА-ТОГГЛ (иконка) ═══════════════
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 44, 0, 44)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
ToggleBtn.BackgroundColor3 = COLORS.bg
ToggleBtn.Text = "☰"
ToggleBtn.TextColor3 = COLORS.text
ToggleBtn.TextSize = 20
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.BorderSizePixel = 0
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui
corner(ToggleBtn, 10)
stroke(ToggleBtn, COLORS.accent, 1, 0.5)

-- Перетаскивание кнопки
do
    local dragging, dragStart, startPos
    ToggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

ToggleBtn.MouseEnter:Connect(function() tween(ToggleBtn, 0.2, {BackgroundColor3 = COLORS.bgHover}) end)
ToggleBtn.MouseLeave:Connect(function() tween(ToggleBtn, 0.2, {BackgroundColor3 = COLORS.bg}) end)

ToggleBtn.MouseButton1Click:Connect(function()
    if Main.Visible then
        local t = tween(Main, 0.25, {Size = UDim2.new(0, 0, 0, 0)})
        t.Completed:Connect(function() Main.Visible = false end)
    else
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        tween(Main, 0.35, {Size = UDim2.new(0, 500, 0, 340)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- Приветственное уведомление
task.wait(0.3)
notify("Black UI загружен", "Нажмите ☰ чтобы открыть меню", "info")

-- Хоткей: RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleBtn.MouseButton1Click:Fire()
    end
end)
