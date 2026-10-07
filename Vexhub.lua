--[[
    VexHub - Prison Life Edition (Ultimate Update)
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
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Translations Dictionary
local CurrentLang = "RU"
local Translations = {
    RU = {
        Home = "Главная",
        Main = "Основные",
        Visuals = "Визуалы",
        Settings = "Настройки",
        AimEnabled = "Aimbot",
        TargetCriminals = "Цель: Преступники (Красные)",
        TargetGuards = "Цель: Охрана (Синие)",
        TargetInmates = "Цель: Заключенные (Оранжевые)",
        WallCheck = "Проверка стен",
        FovRadius = "Радиус FOV",
        InfStamina = "Бесконечная выносливость",
        SpeedHack = "Speed Hack",
        SpeedHackVal = "Скорость бега",
        FastPunch = "Быстрый удар",
        Noclip = "Проход сквозь стены (Noclip)",
        EspEnabled = "Подсветка игроков (ESP)",
        Fullbright = "Светлая карта (Fullbright)",
        AntiAFK = "Анти-АФК",
        ResetChar = "Сбросить персонажа",
        Rejoin = "Перезайти",
        ServerHop = "Сменить сервер",
        Notifications = "Уведомления",
        SaveConfig = "Сохранить конфиг",
        LoadConfig = "Загрузить конфиг",
        Language = "Язык / Language",
        UnloadUI = "Выгрузить скрипт",
        -- Tooltips
        TT_AimEnabled = "Автоматическое наведение прицела на игроков в зоне FOV.",
        TT_TargetCriminals = "Разрешить наведение на красную команду.",
        TT_TargetGuards = "Разрешить наведение на синюю команду.",
        TT_TargetInmates = "Разрешить наведение на оранжевую команду.",
        TT_WallCheck = "Не наводиться, если игрок за стеной.",
        TT_FovRadius = "Размер круга захвата цели для Aimbot.",
        TT_InfStamina = "Выносливость при беге больше не расходуется.",
        TT_SpeedHack = "Включает пользовательскую скорость передвижения.",
        TT_SpeedHackVal = "Устанавливает значение скорости бега персонажа.",
        TT_FastPunch = "Убирает задержку между ударами кулаками.",
        TT_Noclip = "Позволяет ходить сквозь стены и объекты.",
        TT_EspEnabled = "Подсвечивает всех игроков силуэтами их команд.",
        TT_Fullbright = "Делает карту полностью освещенной без теней и ночи.",
        TT_AntiAFK = "Предотвращает кик из игры за бездействие.",
        TT_Rejoin = "Перезаходит на текущий сервер.",
        TT_ServerHop = "Автоматически находит и подключает к новому серверу.",
        TT_SaveConfig = "Сохраняет текущие настройки в файл.",
        TT_LoadConfig = "Загружает ранее сохраненные настройки."
    },
    EN = {
        Home = "Home",
        Main = "Main",
        Visuals = "Visuals",
        Settings = "Settings",
        AimEnabled = "Aimbot",
        TargetCriminals = "Target: Criminals (Red)",
        TargetGuards = "Target: Guards (Blue)",
        TargetInmates = "Target: Inmates (Orange)",
        WallCheck = "Wall Check",
        FovRadius = "FOV Radius",
        InfStamina = "Infinite Stamina",
        SpeedHack = "Speed Hack",
        SpeedHackVal = "Movement Speed",
        FastPunch = "Fast Punch",
        Noclip = "Noclip",
        EspEnabled = "Player ESP",
        Fullbright = "Fullbright Map",
        AntiAFK = "Anti-AFK",
        ResetChar = "Reset Character",
        Rejoin = "Rejoin Server",
        ServerHop = "Server Hop",
        Notifications = "Notifications",
        SaveConfig = "Save Config",
        LoadConfig = "Load Config",
        Language = "Language / Язык",
        UnloadUI = "Unload Script",
        -- Tooltips
        TT_AimEnabled = "Automatically aims at players inside the FOV circle.",
        TT_TargetCriminals = "Allow aimbotting on Criminals team.",
        TT_TargetGuards = "Allow aimbotting on Guards team.",
        TT_TargetInmates = "Allow aimbotting on Inmates team.",
        TT_WallCheck = "Do not aim if target is behind walls.",
        TT_FovRadius = "Adjusts the target acquisition circle size.",
        TT_InfStamina = "Sprint stamina will never deplete.",
        TT_SpeedHack = "Enables custom walkspeed multiplier.",
        TT_SpeedHackVal = "Set custom movement speed value.",
        TT_FastPunch = "Removes cooldown delay between punches.",
        TT_Noclip = "Allows walking through walls and structures.",
        TT_EspEnabled = "Displays player highlights through obstacles.",
        TT_Fullbright = "Makes the entire map bright removing fog and night.",
        TT_AntiAFK = "Prevents idle disconnect kicks.",
        TT_Rejoin = "Rejoins the current server session.",
        TT_ServerHop = "Searches for and joins a different active server.",
        TT_SaveConfig = "Saves current feature configuration.",
        TT_LoadConfig = "Loads saved feature settings."
    },
    AR = {
        Home = "الرئيسية",
        Main = "الرئيسي",
        Visuals = "البصريات",
        Settings = "الإعدادات",
        AimEnabled = "التصويب التلقائي",
        TargetCriminals = "الهدف: المجرمين (أحمر)",
        TargetGuards = "الهدف: الحراس (أزرق)",
        TargetInmates = "الهدف: السجناء (برتقالي)",
        WallCheck = "فحص الجدران",
        FovRadius = "نطاق FOV",
        InfStamina = "لياقت بدنية غير محدودة",
        SpeedHack = "تسريع الحركة",
        SpeedHackVal = "سرعة المشي",
        FastPunch = "لكم سريع",
        Noclip = "اختراق الجدران",
        EspEnabled = "كشف اللاعبين (ESP)",
        Fullbright = "إضاءة الخريطة بالكامل",
        AntiAFK = "منع الطرد لعدم النشاط",
        ResetChar = "إعادة ضبط الشخصية",
        Rejoin = "إعادة الانضمام",
        ServerHop = "تغيير الخادم",
        Notifications = "الإشعارات",
        SaveConfig = "حفظ الإعدادات",
        LoadConfig = "تحميل الإعدادات",
        Language = "اللغة",
        UnloadUI = "إغلاق السكريبت",
        -- Tooltips
        TT_AimEnabled = "يصوب تلقائياً على اللاعبين داخل دائرة الرؤية.",
        TT_TargetCriminals = "السماح بالتصويب على فريق المجرمين.",
        TT_TargetGuards = "السماح بالتصويب على فريق الحراس.",
        TT_TargetInmates = "السماح بالتصويب على فريق السجناء.",
        TT_WallCheck = "عدم التصويب إذا كان الهدف خلف جدار.",
        TT_FovRadius = "تعديل حجم دائرة التصويب.",
        TT_InfStamina = "لا تنفذ طاقة الركض أبداً.",
        TT_SpeedHack = "تفعيل سرعة حركة مخصصة.",
        TT_SpeedHackVal = "تحديد قيمة سرعة الحركة.",
        TT_FastPunch = "إزالة التأخير بين اللكمات.",
        TT_Noclip = "يسمح بالمرور عبر الجدران.",
        TT_EspEnabled = "إظهار اللاعبين عبر الجدران.",
        TT_Fullbright = "جعل الخريطة مضاءة بالكامل بدون ظلام.",
        TT_AntiAFK = "يمنع طردك عند التوقف عن اللعب.",
        TT_Rejoin = "إعادة الدخول لنفس الخادم.",
        TT_ServerHop = "البحث عن خادم آخر والانضمام إليه.",
        TT_SaveConfig = "حفظ التكوين الحالي في ملف.",
        TT_LoadConfig = "تحميل التكوين المحفوظ."
    }
}

local function tr(key)
    return (Translations[CurrentLang] and Translations[CurrentLang][key]) or (Translations["EN"][key] or key)
end

-- Feature State
local FeatureState = {
    AimEnabled = false,
    FovRadius = 100,
    WallCheck = true,
    TargetCriminals = true,
    TargetGuards = true,
    TargetInmates = true,
    EspEnabled = false,
    Fullbright = false,
    InfStamina = false,
    SpeedHack = false,
    SpeedHackValue = 32,
    Noclip = false,
    FastPunch = false,
    AntiAFK = true
}

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

-- Container Setup
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

    task.delay(3, function()
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

-- Tooltip Box
local TooltipFrame = Instance.new("Frame")
TooltipFrame.Name = "TooltipFrame"
TooltipFrame.Size = UDim2.new(0, 240, 0, 45)
TooltipFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TooltipFrame.BorderSizePixel = 0
TooltipFrame.Visible = false
TooltipFrame.ZIndex = 100
TooltipFrame.Parent = ScreenGui
createCorner(TooltipFrame, 8)

local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, -16, 1, -10)
TooltipText.Position = UDim2.new(0, 8, 0, 5)
TooltipText.BackgroundTransparency = 1
TooltipText.TextColor3 = C_TEXT
TooltipText.Font = Enum.Font.GothamMedium
TooltipText.TextSize = 11
TooltipText.TextWrapped = true
TooltipText.ZIndex = 101
TooltipText.Parent = TooltipFrame

local currentTooltipTween = nil
local function showTooltip(desc)
    if not desc or desc == "" then return end
    TooltipText.Text = desc
    TooltipFrame.Visible = true
    TooltipFrame.BackgroundTransparency = 1
    TooltipText.TextTransparency = 1
    
    if currentTooltipTween then currentTooltipTween:Cancel() end
    currentTooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.1})
    TweenService:Create(TooltipText, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
    currentTooltipTween:Play()
end

local function hideTooltip()
    if currentTooltipTween then currentTooltipTween:Cancel() end
    currentTooltipTween = TweenService:Create(TooltipFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
    TweenService:Create(TooltipText, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    currentTooltipTween.Completed:Connect(function()
        if TooltipFrame.BackgroundTransparency >= 0.9 then
            TooltipFrame.Visible = false
        end
    end)
end

UserInputService.InputChanged:Connect(function(input)
    if TooltipFrame.Visible and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        TooltipFrame.Position = UDim2.new(0, input.Position.X + 15, 0, input.Position.Y + 15)
    end
end)

local function bindTooltip(guiObject, tooltipKey)
    local isPressing = false
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPressing = true
            task.delay(0.3, function()
                if isPressing then
                    showTooltip(tr(tooltipKey))
                end
            end)
        end
    end)
    guiObject.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPressing = false
            hideTooltip()
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

-- Content Frame
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

-- Helper UI Builders
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

local function createToggle(parent, titleKey, defaultState, callback)
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
    lbl.Text = tr(titleKey)
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

    bindTooltip(row, "TT_" .. titleKey)

    row.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.16), {BackgroundColor3 = state and C_TOGGLE_ON or C_TOGGLE_OFF}):Play()
        TweenService:Create(knob, TweenInfo.new(0.16), {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}):Play()
        pcall(callback, state)
    end)

    return row
end

local function createSlider(parent, titleKey, minVal, maxVal, defaultVal, callback)
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
    lbl.Text = tr(titleKey)
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

    bindTooltip(card, "TT_" .. titleKey)

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

local function createButton(parent, titleKey, callback)
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
    lbl.Text = tr(titleKey)
    lbl.TextColor3 = C_TEXT
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.Parent = btn

    bindTooltip(btn, "TT_" .. titleKey)

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
            TabTitleHeader.Text = tr(data.labelKey)
            clearContent()
            data.build()
        else
            TweenService:Create(data.btn, TweenInfo.new(0.16), {BackgroundColor3 = C_SIDEBAR}):Play()
            data.lbl.TextColor3 = C_MUTED
            data.iconImg.ImageColor3 = C_MUTED
        end
    end
end

local function registerTab(name, iconAsset, labelKey, buildFunc, order)
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
    lbl.Text = tr(labelKey)
    lbl.TextColor3 = C_MUTED
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    btn.MouseButton1Click:Connect(function() selectTab(name) end)

    tabs[name] = {
        btn = btn, iconAsset = iconAsset, labelKey = labelKey, lbl = lbl, iconImg = iconImg, build = buildFunc
    }
end

-- TAB BUILDERS
local function buildHomeTab()
    local sf = makeScrollingFrame()

    local card1 = Instance.new("Frame")
    card1.Size = UDim2.new(1, 0, 0, 110)
    card1.BackgroundColor3 = C_CARD
    card1.BackgroundTransparency = 0.1
    card1.Parent = sf
    createCorner(card1, 10)

    local wbName = Instance.new("TextLabel")
    wbName.Size = UDim2.new(1, -20, 0, 30)
    wbName.Position = UDim2.new(0, 16, 0, 18)
    wbName.BackgroundTransparency = 1
    wbName.Text = "VexHub - Prison Life"
    wbName.TextColor3 = C_TEXT
    wbName.Font = Enum.Font.GothamBold
    wbName.TextSize = 20
    wbName.TextXAlignment = Enum.TextXAlignment.Left
    wbName.Parent = card1

    local wbUser = Instance.new("TextLabel")
    wbUser.Size = UDim2.new(1, -20, 0, 20)
    wbUser.Position = UDim2.new(0, 16, 0, 52)
    wbUser.BackgroundTransparency = 1
    wbUser.Text = "Logged in as: " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
    wbUser.TextColor3 = C_MUTED
    wbUser.Font = Enum.Font.GothamMedium
    wbUser.TextSize = 12
    wbUser.TextXAlignment = Enum.TextXAlignment.Left
    wbUser.Parent = card1

    -- Server Controls
    createButton(sf, "Rejoin", function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    createButton(sf, "ServerHop", function()
        notify("Server Hop", "Searching for available servers...")
        task.spawn(function()
            local servers = {}
            local req = request or http_request or (syn and syn.request)
            if req then
                local res = req({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
                local data = HttpService:JSONDecode(res.Body)
                if data and data.data then
                    for _, v in ipairs(data.data) do
                        if v.playing < v.maxPlayers and v.id ~= game.JobId then
                            table.insert(servers, v.id)
                        end
                    end
                end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                notify("Server Hop", "No other servers found!")
            end
        end)
    end)
end

local function buildMainTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "AimEnabled", FeatureState.AimEnabled, function(v)
        FeatureState.AimEnabled = v
        FovCircle.Visible = v
    end)

    createToggle(sf, "TargetCriminals", FeatureState.TargetCriminals, function(v) FeatureState.TargetCriminals = v end)
    createToggle(sf, "TargetGuards", FeatureState.TargetGuards, function(v) FeatureState.TargetGuards = v end)
    createToggle(sf, "TargetInmates", FeatureState.TargetInmates, function(v) FeatureState.TargetInmates = v end)
    createToggle(sf, "WallCheck", FeatureState.WallCheck, function(v) FeatureState.WallCheck = v end)

    createSlider(sf, "FovRadius", 30, 400, FeatureState.FovRadius, function(v)
        FeatureState.FovRadius = v
        FovCircle.Radius = v
    end)

    createToggle(sf, "InfStamina", FeatureState.InfStamina, function(v) FeatureState.InfStamina = v end)
    
    createToggle(sf, "SpeedHack", FeatureState.SpeedHack, function(v) FeatureState.SpeedHack = v end)
    createSlider(sf, "SpeedHackVal", 16, 150, FeatureState.SpeedHackValue, function(v) FeatureState.SpeedHackValue = v end)

    createToggle(sf, "FastPunch", FeatureState.FastPunch, function(v) FeatureState.FastPunch = v end)
    createToggle(sf, "Noclip", FeatureState.Noclip, function(v) FeatureState.Noclip = v end)
end

local function buildVisualsTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "EspEnabled", FeatureState.EspEnabled, function(v) FeatureState.EspEnabled = v end)
    createToggle(sf, "Fullbright", FeatureState.Fullbright, function(v) FeatureState.Fullbright = v end)
end

local function buildSettingsTab()
    local sf = makeScrollingFrame()

    createToggle(sf, "Notifications", notifEnabled, function(v) notifEnabled = v end)
    createToggle(sf, "AntiAFK", FeatureState.AntiAFK, function(v) FeatureState.AntiAFK = v end)

    -- Language Switcher
    local langCard = Instance.new("Frame")
    langCard.Size = UDim2.new(1, 0, 0, 56)
    langCard.BackgroundColor3 = C_CARD
    langCard.BackgroundTransparency = 0.1
    langCard.Parent = sf
    createCorner(langCard, 10)

    local langLbl = Instance.new("TextLabel")
    langLbl.Size = UDim2.new(0.4, 0, 1, 0)
    langLbl.Position = UDim2.new(0, 14, 0, 0)
    langLbl.BackgroundTransparency = 1
    langLbl.Text = tr("Language")
    langLbl.TextColor3 = C_TEXT
    langLbl.Font = Enum.Font.GothamMedium
    langLbl.TextSize = 13
    langLbl.TextXAlignment = Enum.TextXAlignment.Left
    langLbl.Parent = langCard

    local function makeLangBtn(text, langCode, posX)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 50, 0, 28)
        btn.Position = UDim2.new(1, posX, 0.5, -14)
        btn.BackgroundColor3 = (CurrentLang == langCode) and C_ACCENT or C_SIDEBAR
        btn.Text = text
        btn.TextColor3 = C_TEXT
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = langCard
        createCorner(btn, 6)

        btn.MouseButton1Click:Connect(function()
            CurrentLang = langCode
            selectTab(currentTab)
            for name, data in pairs(tabs) do
                data.lbl.Text = tr(data.labelKey)
            end
        end)
    end

    makeLangBtn("RU", "RU", -170)
    makeLangBtn("EN", "EN", -110)
    makeLangBtn("AR", "AR", -50)

    -- Config System
    createButton(sf, "SaveConfig", function()
        if writefile then
            writefile("VexHub_Config.json", HttpService:JSONEncode(FeatureState))
            notify("Config", "Configuration saved successfully!")
        end
    end)

    createButton(sf, "LoadConfig", function()
        if readfile and isfile and isfile("VexHub_Config.json") then
            local data = HttpService:JSONDecode(readfile("VexHub_Config.json"))
            if data then
                for k, v in pairs(data) do FeatureState[k] = v end
                selectTab(currentTab)
                notify("Config", "Configuration loaded successfully!")
            end
        end
    end)

    createButton(sf, "UnloadUI", function()
        getgenv().VexHub_Loaded = false
        FovCircle:Remove()
        ScreenGui:Destroy()
    end)
end

-- Register Tabs
registerTab("Home", "rbxassetid://7539983773", "Home", buildHomeTab, 1)
registerTab("Main", "rbxassetid://10974441727", "Main", buildMainTab, 2)
registerTab("Visuals", "rbxassetid://17412298151", "Visuals", buildVisualsTab, 3)
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

-- Floating Toggle Button
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

-- Wall Check Logic
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

-- Fast Punch Event
local mainRemotes = ReplicatedStorage:FindFirstChild("meleeEvent")
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and FeatureState.FastPunch and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if mainRemotes then
            mainRemotes:FireServer(LocalPlayer)
        end
    end
end)

-- Fullbright Store
local origBrightness = Lighting.Brightness
local origClockTime = Lighting.ClockTime
local origGlobalShadows = Lighting.GlobalShadows
local origFogEnd = Lighting.FogEnd

-- NOCLIP LOOP
RunService.Stepped:Connect(function()
    if FeatureState.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- MAIN RENDER LOOP
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Position = centerScreen

    -- Speed Hack
    if FeatureState.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = FeatureState.SpeedHackValue
    end

    -- Fullbright
    if FeatureState.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
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

-- Infinite Stamina Meta Hook
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

notify("VexHub", "Successfully loaded with all requested updates!")
