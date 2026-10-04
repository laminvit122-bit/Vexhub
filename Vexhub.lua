--[[
    VEXHUB | Prison Life Edition
    Minimalistic black GUI in KerryHub style
    Hotkey: RightShift
--]]

if getgenv().VexHub_Loaded then
    pcall(function()
        getgenv().VexHub:Unload()
    end)
    return
end
getgenv().VexHub_Loaded = true

-- ═══════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════
-- CONFIG / PALETTE
-- ═══════════════════════════════════════════
local Palette = {
    Window    = Color3.fromHex("0D0D0D"),
    Panel     = Color3.fromHex("141414"),
    Hover     = Color3.fromHex("1C1C1C"),
    Accent    = Color3.fromHex("8B5CF6"),
    ToggleOn  = Color3.fromHex("FFFFFF"),
    ToggleOff = Color3.fromHex("2A2A2A"),
    Text      = Color3.fromHex("FFFFFF"),
    Dim       = Color3.fromHex("8A8A8A"),
    Stroke    = Color3.fromHex("222222"),
}

local State = {
    Notifications = true,
    NotifDuration = 3,
    Keybind = Enum.KeyCode.RightShift,
    Toggles = {},
    ESP = {},
    Connections = {},
    Threads = {},
}

local function Track(conn)
    table.insert(State.Connections, conn)
    return conn
end

local function TrackThread(thread)
    table.insert(State.Threads, thread)
    return thread
end

-- ═══════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════
local function new(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    for _, c in ipairs(children or {}) do
        c.Parent = inst
    end
    return inst
end

local function corner(parent, radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Palette.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, px)
    return new("UIPadding", {
        PaddingTop = UDim.new(0, px),
        PaddingBottom = UDim.new(0, px),
        PaddingLeft = UDim.new(0, px),
        PaddingRight = UDim.new(0, px),
        Parent = parent,
    })
end

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

-- ═══════════════════════════════════════════
-- NOTIFICATIONS
-- ═══════════════════════════════════════════
local NotifHolder = new("ScreenGui", {
    Name = "VexHub_Notifs",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"),
})

local NotifStack = new("Frame", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 1, -20),
    AnchorPoint = Vector2.new(0, 1),
    Size = UDim2.new(0, 260, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = NotifHolder,
})

new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 8),
    Parent = NotifStack,
})

local function Notify(title, text, dur)
    if not State.Notifications then return end
    dur = dur or State.NotifDuration

    local card = new("Frame", {
        BackgroundColor3 = Palette.Panel,
        Size = UDim2.new(1, 0, 0, 56),
        Position = UDim2.new(0, -300, 0, 0),
        ClipsDescendants = true,
        Parent = NotifStack,
    })
    corner(card, 6)
    stroke(card, Palette.Stroke, 1, 0.3)

    local strip = new("Frame", {
        BackgroundColor3 = Palette.Accent,
        Size = UDim2.new(0, 3, 1, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(strip, 6)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 8),
        Size = UDim2.new(1, -20, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = string.upper(title or "VEXHUB"),
        TextColor3 = Palette.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 26),
        Size = UDim2.new(1, -20, 0, 22),
        Font = Enum.Font.Gotham,
        Text = text or "",
        TextColor3 = Palette.Dim,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = card,
    })

    TweenService:Create(card, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 0),
    }):Play()

    task.delay(dur, function()
        local tw = TweenService:Create(card, TweenInfo.new(0.22), {
            Position = UDim2.new(0, -300, 0, 0),
            BackgroundTransparency = 1,
        })
        tw:Play()
        tw.Completed:Connect(function()
            card:Destroy()
        end)
    end)
end

-- ═══════════════════════════════════════════
-- MAIN UI
-- ═══════════════════════════════════════════
local ScreenGui = new("ScreenGui", {
    Name = "VexHub",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui"),
})

local Main = new("Frame", {
    Name = "Main",
    BackgroundColor3 = Palette.Window,
    Position = UDim2.new(0.5, -280, 0.5, -180),
    Size = UDim2.new(0, 560, 0, 360),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = ScreenGui,
})
corner(Main, 8)
stroke(Main, Palette.Stroke, 1, 0)

-- Topbar
local Topbar = new("Frame", {
    Name = "Topbar",
    BackgroundColor3 = Palette.Window,
    Size = UDim2.new(1, 0, 0, 48),
    BorderSizePixel = 0,
    Parent = Main,
})

new("Frame", {
    BackgroundColor3 = Palette.Stroke,
    Position = UDim2.new(0, 0, 1, -1),
    Size = UDim2.new(1, 0, 0, 1),
    BorderSizePixel = 0,
    Parent = Topbar,
})

local LogoDot = new("Frame", {
    BackgroundColor3 = Palette.Accent,
    Position = UDim2.new(0, 16, 0.5, -6),
    Size = UDim2.new(0, 12, 0, 12),
    BorderSizePixel = 0,
    Parent = Topbar,
})
corner(LogoDot, 6)

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 38, 0, 8),
    Size = UDim2.new(0, 200, 0, 16),
    Font = Enum.Font.GothamBold,
    Text = "VEXHUB",
    TextColor3 = Palette.Text,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Topbar,
})

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 38, 0, 26),
    Size = UDim2.new(0, 240, 0, 14),
    Font = Enum.Font.Gotham,
    Text = "Prison Life Edition",
    TextColor3 = Palette.Dim,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Topbar,
})

local CloseBtn = new("TextButton", {
    BackgroundColor3 = Palette.Panel,
    Position = UDim2.new(1, -36, 0, 14),
    Size = UDim2.new(0, 22, 0, 22),
    Font = Enum.Font.GothamBold,
    Text = "×",
    TextColor3 = Palette.Text,
    TextSize = 16,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Parent = Topbar,
})
corner(CloseBtn, 5)

local MinBtn = new("TextButton", {
    BackgroundColor3 = Palette.Panel,
    Position = UDim2.new(1, -66, 0, 14),
    Size = UDim2.new(0, 22, 0, 22),
    Font = Enum.Font.GothamBold,
    Text = "—",
    TextColor3 = Palette.Text,
    TextSize = 14,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Parent = Topbar,
})
corner(MinBtn, 5)

for _, b in ipairs({ CloseBtn, MinBtn }) do
    Track(b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = Palette.Hover }):Play()
    end))
    Track(b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundColor3 = Palette.Panel }):Play()
    end))
end

-- Sidebar
local Sidebar = new("Frame", {
    Name = "Sidebar",
    BackgroundColor3 = Palette.Window,
    Position = UDim2.new(0, 0, 0, 48),
    Size = UDim2.new(0, 140, 1, -48),
    BorderSizePixel = 0,
    Parent = Main,
})

new("Frame", {
    BackgroundColor3 = Palette.Stroke,
    Position = UDim2.new(1, -1, 0, 0),
    Size = UDim2.new(0, 1, 1, 0),
    BorderSizePixel = 0,
    Parent = Sidebar,
})

padding(Sidebar, 8)
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
    Parent = Sidebar,
})

-- Content
local Content = new("Frame", {
    Name = "Content",
    BackgroundColor3 = Palette.Window,
    Position = UDim2.new(0, 140, 0, 48),
    Size = UDim2.new(1, -140, 1, -48),
    BorderSizePixel = 0,
    Parent = Main,
})
padding(Content, 12)

local Pages = {}
local CurrentPage

local function CreatePage(name)
    local page = new("ScrollingFrame", {
        Name = name .. "Page",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Palette.Accent,
        BorderSizePixel = 0,
        Visible = false,
        Parent = Content,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = page,
    })
    Pages[name] = page
    return page
end

local TabOrder = { "PRISONER", "GUARD", "VISUALS", "PLAYER", "SETTINGS" }
local TabButtons = {}

local function SelectTab(name)
    for tabName, page in pairs(Pages) do
        page.Visible = (tabName == name)
    end
    for tabName, btn in pairs(TabButtons) do
        local on = (tabName == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and Palette.Hover or Palette.Window,
        }):Play()
        btn.TextColor3 = on and Palette.Text or Palette.Dim
        local ind = btn:FindFirstChild("Indicator")
        if ind then ind.Visible = on end
    end
    CurrentPage = name
end

local function CreateTab(name, icon)
    local btn = new("TextButton", {
        Name = name,
        BackgroundColor3 = Palette.Window,
        Size = UDim2.new(1, 0, 0, 30),
        Font = Enum.Font.GothamMedium,
        Text = "  " .. (icon or "") .. "  " .. name,
        TextColor3 = Palette.Dim,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = Sidebar,
    })
    corner(btn, 5)

    local ind = new("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Palette.Accent,
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 3, 0, 16),
        BorderSizePixel = 0,
        Visible = false,
        Parent = btn,
    })
    corner(ind, 2)

    Track(btn.MouseEnter:Connect(function()
        if CurrentPage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Panel }):Play()
        end
    end))
    Track(btn.MouseLeave:Connect(function()
        if CurrentPage ~= name then
            TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Window }):Play()
        end
    end))
    Track(btn.MouseButton1Click:Connect(function()
        SelectTab(name)
    end))

    TabButtons[name] = btn
    CreatePage(name)
    return btn
end

-- ═══════════════════════════════════════════
-- COMPONENTS
-- ═══════════════════════════════════════════
local function SectionLabel(page, text)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = string.upper(text),
        TextColor3 = Palette.Dim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = page,
    })
end

local function Toggle(page, name, default, callback)
    local row = new("Frame", {
        BackgroundColor3 = Palette.Panel,
        Size = UDim2.new(1, 0, 0, 38),
        BorderSizePixel = 0,
        Parent = page,
    })
    corner(row, 6)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Palette.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local switch = new("TextButton", {
        BackgroundColor3 = default and Palette.ToggleOn or Palette.ToggleOff,
        Position = UDim2.new(1, -50, 0.5, -9),
        Size = UDim2.new(0, 38, 0, 18),
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = row,
    })
    corner(switch, 9)

    local knob = new("Frame", {
        BackgroundColor3 = default and Palette.Window or Palette.ToggleOn,
        Position = default and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
        Size = UDim2.new(0, 14, 0, 14),
        BorderSizePixel = 0,
        Parent = switch,
    })
    corner(knob, 7)

    local state = { value = default }

    local function set(v)
        state.value = v
        TweenService:Create(switch, TweenInfo.new(0.18), {
            BackgroundColor3 = v and Palette.ToggleOn or Palette.ToggleOff,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.18), {
            Position = v and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = v and Palette.Window or Palette.ToggleOn,
        }):Play()
        if callback then
            task.spawn(function()
                pcall(callback, v)
            end)
        end
    end

    Track(switch.MouseButton1Click:Connect(function()
        set(not state.value)
        Notify(name, (state.value and "enabled" or "disabled"), 2)
    end))

    Track(row.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Hover }):Play()
    end))
    Track(row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Panel }):Play()
    end))

    State.Toggles[name] = { set = set, get = function() return state.value end }
    return row
end

local function Button(page, name, callback)
    local btn = new("TextButton", {
        BackgroundColor3 = Palette.Panel,
        Size = UDim2.new(1, 0, 0, 34),
        Font = Enum.Font.GothamMedium,
        Text = name,
        TextColor3 = Palette.Text,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = page,
    })
    corner(btn, 6)

    Track(btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Hover }):Play()
    end))
    Track(btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Palette.Panel }):Play()
    end))
    Track(btn.MouseButton1Click:Connect(function()
        task.spawn(function() pcall(callback) end)
    end))
    return btn
end

local function Slider(page, name, min, max, default, callback)
    local row = new("Frame", {
        BackgroundColor3 = Palette.Panel,
        Size = UDim2.new(1, 0, 0, 52),
        BorderSizePixel = 0,
        Parent = page,
    })
    corner(row, 6)

    new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -80, 0, 16),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Palette.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valueLbl = new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -60, 0, 6),
        Size = UDim2.new(0, 48, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = tostring(default),
        TextColor3 = Palette.Accent,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local bar = new("Frame", {
        BackgroundColor3 = Palette.ToggleOff,
        Position = UDim2.new(0, 12, 0, 34),
        Size = UDim2.new(1, -24, 0, 6),
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(bar, 3)

    local fill = new("Frame", {
        BackgroundColor3 = Palette.Accent,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BorderSizePixel = 0,
        Parent = bar,
    })
    corner(fill, 3)

    local dragging = false

    local function setFromX(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        valueLbl.Text = tostring(val)
        if callback then pcall(callback, val) end
    end

    Track(bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            setFromX(input.Position.X)
        end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(input.Position.X)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))

    return row
end

-- ═══════════════════════════════════════════
-- BUILD TABS
-- ═══════════════════════════════════════════
local icons = {
    PRISONER = "●",
    GUARD = "◆",
    VISUALS = "◎",
    PLAYER = "★",
    SETTINGS = "⚙",
}
for _, tabName in ipairs(TabOrder) do
    CreateTab(tabName, icons[tabName])
end

-- ═══════════════════════════════════════════
-- ░░ PRISONER ░░
-- ═══════════════════════════════════════════
local P = Pages.PRISONER
SectionLabel(P, "Prisoner")

Toggle(P, "Inf Stamina", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Inf Stamina"] and State.Toggles["Inf Stamina"].get() do
                pcall(function()
                    local hum = getHum()
                    if hum then
                        hum.MaxStamina = math.huge
                    end
                end)
                task.wait(0.5)
            end
        end))
    end
end)

Toggle(P, "Speed Boost", false, function(on)
    local hum = getHum()
    if hum then
        hum.WalkSpeed = on and 55 or 16
    end
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Speed Boost"] and State.Toggles["Speed Boost"].get() do
                local h = getHum()
                if h and h.WalkSpeed < 55 then h.WalkSpeed = 55 end
                task.wait(0.3)
            end
            local h = getHum()
            if h then h.WalkSpeed = 16 end
        end))
    end
end)

Toggle(P, "Fast Punch", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Fast Punch"] and State.Toggles["Fast Punch"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end)
                task.wait(0.15)
            end
        end))
    end
end)

Toggle(P, "Auto Escape", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Auto Escape"] and State.Toggles["Auto Escape"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local targets = {
                            Vector3.new(140, 0, -30),
                            Vector3.new(180, 5, 40),
                            Vector3.new(250, 5, 0),
                        }
                        for _, pos in ipairs(targets) do
                            if char and char.Parent then
                                char:MoveTo(pos + Vector3.new(0, 5, 0))
                                task.wait(0.4)
                            end
                        end
                    end
                end)
                task.wait(0.2)
            end
        end))
    end
end)

Toggle(P, "Noclip", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            local conn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end
            end)
            while State.Toggles["Noclip"] and State.Toggles["Noclip"].get() do
                task.wait(0.2)
            end
            conn:Disconnect()
        end))
    end
end)

-- ═══════════════════════════════════════════
-- ░░ GUARD ░░
-- ═══════════════════════════════════════════
local G = Pages.GUARD
SectionLabel(G, "Guard")

Toggle(G, "Auto Arrest", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Auto Arrest"] and State.Toggles["Auto Arrest"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                local team = plr.Team and plr.Team.Name or ""
                                if thrp and (team == "Prisoners" or team == "Criminals" or team == "") then
                                    local dist = (thrp.Position - hrp.Position).Magnitude
                                    if dist < 12 then
                                        local tool = char:FindFirstChild("Handcuffs") or char:FindFirstChildOfClass("Tool")
                                        if tool then
                                            tool:Activate()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.4)
            end
        end))
    end
end)

Toggle(G, "Weapon ESP", false, function(on)
    local store = "WeaponESP"
    if on then
        State.ESP[store] = {}
        TrackThread(task.spawn(function()
            while State.Toggles["Weapon ESP"] and State.Toggles["Weapon ESP"].get() do
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        for _, obj in ipairs(plr.Character:GetChildren()) do
                            if obj:IsA("Tool") then
                                if not State.ESP[store][obj] then
                                    local hl = Instance.new("Highlight")
                                    hl.Adornee = obj
                                    hl.FillColor = Color3.fromHex("8B5CF6")
                                    hl.OutlineColor = Color3.fromHex("FFFFFF")
                                    hl.FillTransparency = 0.5
                                    hl.OutlineTransparency = 0
                                    hl.Parent = ScreenGui
                                    State.ESP[store][obj] = hl
                                end
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            for obj, hl in pairs(State.ESP[store]) do
                if hl and hl.Parent then hl:Destroy() end
            end
            State.ESP[store] = nil
        end))
    end
end)

Toggle(G, "God Mode", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["God Mode"] and State.Toggles["God Mode"].get() do
                local hum = getHum()
                if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
                task.wait(0.5)
            end
        end))
    end
end)

Toggle(G, "Fast Reload", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Fast Reload"] and State.Toggles["Fast Reload"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, t in ipairs(char:GetChildren()) do
                            if t:IsA("Tool") then
                                for _, s in ipairs(t:GetDescendants()) do
                                    if s:IsA("Script") or s:IsA("LocalScript") then
                                        -- attempt cooldown adjust
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end))
    end
end)

Toggle(G, "Instant Kill", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Instant Kill"] and State.Toggles["Instant Kill"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, plr in ipairs(Players:GetPlayers()) do
                            if plr ~= LocalPlayer and plr.Character then
                                local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                local thum = plr.Character:FindFirstChildOfClass("Humanoid")
                                if thrp and thum then
                                    if (thrp.Position - hrp.Position).Magnitude < 8 then
                                        thum.Health = 0
                                    end
                                end
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end))
    end
end)

-- ═══════════════════════════════════════════
-- ░░ VISUALS ░░
-- ═══════════════════════════════════════════
local V = Pages.VISUALS
SectionLabel(V, "Visuals")

local function isTeam(plr, names)
    if not plr.Team then return false end
    for _, n in ipairs(names) do
        if plr.Team.Name == n then return true end
    end
    return false
end

local function makeESPLoop(key, teamNames, color)
    return function(on)
        if on then
            State.ESP[key] = {}
            TrackThread(task.spawn(function()
                while State.Toggles[key] and State.Toggles[key].get() do
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character and isTeam(plr, teamNames) then
                            if not State.ESP[key][plr] then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = plr.Character
                                hl.FillColor = color
                                hl.OutlineColor = color
                                hl.FillTransparency = 0.55
                                hl.OutlineTransparency = 0.2
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = ScreenGui
                                State.ESP[key][plr] = hl
                            end
                        end
                    end
                    task.wait(0.4)
                end
                for plr, hl in pairs(State.ESP[key] or {}) do
                    if hl and hl.Parent then hl:Destroy() end
                end
                State.ESP[key] = nil
            end))
        end
    end
end

Toggle(V, "ESP Prisoners", false, makeESPLoop("ESPPrisoners", {"Prisoners", "Criminals"}, Color3.fromHex("8B5CF6")))
Toggle(V, "ESP Guards", false, makeESPLoop("ESPGuards", {"Guards", "Police"}, Color3.fromHex("FFFFFF")))

Toggle(V, "Tracers", false, function(on)
    local key = "Tracers"
    if on then
        State.ESP[key] = {}
        TrackThread(task.spawn(function()
            while State.Toggles[key] and State.Toggles[key].get() do
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Character then
                            local thrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if thrp then
                                local line = State.ESP[key][plr]
                                if not line then
                                    line = Drawing.new("Line")
                                    line.Color = Palette.Accent
                                    line.Thickness = 1
                                    line.Transparency = 1
                                    State.ESP[key][plr] = line
                                end
                                local sp, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                                local tp = Camera:WorldToViewportPoint(thrp.Position)
                                if onScreen then
                                    line.Visible = true
                                    line.From = Vector2.new(sp.X, sp.Y + 40)
                                    line.To = Vector2.new(tp.X, tp.Y)
                                else
                                    line.Visible = false
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
            for _, line in pairs(State.ESP[key] or {}) do
                pcall(function() line:Remove() end)
            end
            State.ESP[key] = nil
        end))
    end
end)

Toggle(V, "Full Bright", false, function(on)
    if on then
        Lighting.Brightness = 3
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
    else
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end)

-- ═══════════════════════════════════════════
-- ░░ PLAYER ░░
-- ═══════════════════════════════════════════
local PL = Pages.PLAYER
SectionLabel(PL, "Player")

Toggle(PL, "Anti AFK", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Anti AFK"] and State.Toggles["Anti AFK"].get() do
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new())
                end)
                task.wait(60)
            end
        end))
    end
end)

Toggle(PL, "Anti Arrest", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["Anti Arrest"] and State.Toggles["Anti Arrest"].get() do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        for _, obj in ipairs(char:GetChildren()) do
                            if obj:IsA("Tool") and (obj.Name:lower():find("cuff") or obj.Name:lower():find("restrain")) then
                                obj:Destroy()
                            end
                        end
                        for _, obj in ipairs(char:GetDescendants()) do
                            if obj:IsA("Script") and obj.Name:lower():find("cuff") then
                                obj:Destroy()
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end))
    end
end)

Button(PL, "Reset Character", function()
    local hum = getHum()
    if hum then hum.Health = 0 end
end)

Toggle(PL, "God Mode", false, function(on)
    if on then
        TrackThread(task.spawn(function()
            while State.Toggles["God Mode"] and State.Toggles["God Mode"].get() do
                local hum = getHum()
                if hum then hum.MaxHealth = math.huge; hum.Health = math.huge end
                task.wait(0.5)
            end
        end))
    end
end)

-- ═══════════════════════════════════════════
-- ░░ SETTINGS ░░
-- ═══════════════════════════════════════════
local S = Pages.SETTINGS
SectionLabel(S, "Settings")

Toggle(S, "Notifications", true, function(on)
    State.Notifications = on
end)

Slider(S, "Notif Duration", 1, 10, 3, function(v)
    State.NotifDuration = v
end)

local kbRow = new("Frame", {
    BackgroundColor3 = Palette.Panel,
    Size = UDim2.new(1, 0, 0, 38),
    BorderSizePixel = 0,
    Parent = S,
})
corner(kbRow, 6)

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -100, 1, 0),
    Font = Enum.Font.Gotham,
    Text = "UI Keybind",
    TextColor3 = Palette.Text,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = kbRow,
})

local kbBtn = new("TextButton", {
    BackgroundColor3 = Palette.Window,
    Position = UDim2.new(1, -90, 0.5, -11),
    Size = UDim2.new(0, 78, 0, 22),
    Font = Enum.Font.GothamMedium,
    Text = "RightShift",
    TextColor3 = Palette.Accent,
    TextSize = 11,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Parent = kbRow,
})
corner(kbBtn, 5)

local listening = false
Track(kbBtn.MouseButton1Click:Connect(function()
    listening = true
    kbBtn.Text = "..."
end))

Track(UserInputService.InputBegan:Connect(function(input, gp)
    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
        State.Keybind = input.KeyCode
        kbBtn.Text = input.KeyCode.Name
        listening = false
    end
end))

Button(S, "Unload UI", function()
    getgenv().VexHub:Unload()
end)

-- ═══════════════════════════════════════════
-- DRAG SYSTEM
-- ═══════════════════════════════════════════
do
    local dragging, dragStart, startPos
    Track(Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end))
end

-- ═══════════════════════════════════════════
-- TOGGLE / MINIMIZE / CLOSE
-- ═══════════════════════════════════════════
local uiVisible = true

local function setVisible(v)
    uiVisible = v
    Main.Visible = v
end

Track(CloseBtn.MouseButton1Click:Connect(function()
    setVisible(false)
end))

local minimized = false
Track(MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    local target = minimized and UDim2.new(0, 560, 0, 48) or UDim2.new(0, 560, 0, 360)
    TweenService:Create(Main, TweenInfo.new(0.2), { Size = target }):Play()
    Sidebar.Visible = not minimized
    Content.Visible = not minimized
end))

Track(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == State.Keybind then
        setVisible(not uiVisible)
    end
end))

-- ═══════════════════════════════════════════
-- UNLOAD
-- ═══════════════════════════════════════════
local function Unload()
    pcall(function()
        for _, conn in ipairs(State.Connections) do
            conn:Disconnect()
        end
        State.Connections = {}

        for _, hlGroup in pairs(State.ESP) do
            for key, obj in pairs(hlGroup) do
                pcall(function()
                    if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end
                end)
            end
        end
        State.ESP = {}

        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
        if NotifHolder and NotifHolder.Parent then NotifHolder:Destroy() end

        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = true

        getgenv().VexHub_Loaded = false
        getgenv().VexHub = nil
    end)
end

getgenv().VexHub = {
    Unload = Unload,
    Notify = Notify,
    Toggle = function(name, value)
        local t = State.Toggles[name]
        if t then t.set(value) end
    end,
}

-- Initial tab
SelectTab("PRISONER")

-- Welcome notification
task.wait(0.4)
Notify("VEXHUB", "Loaded | Press " .. State.Keybind.Name, 3)
