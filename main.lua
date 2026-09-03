-- // ZwacHub Combined - Modern Horizontal GUI // --
-- Mobile Friendly | Left Sidebar | Fixed & Optimized

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local HOVER_HEIGHT = 8
local LAIR_START_POS = Vector3.new(-681, -116, -810)

-- Settings
local Settings = {
    -- Lair
    AutoLair = false,
    -- Quest
    AutoQuest = false,
    SelectedQuest = "Bruford",
    -- Roll
    AutoRoll = false,
    -- Combat
    AutoStand = false,
    SkillE = true,
    SkillT = true,
    SkillR = true,
    SkillX = true,
    -- Visuals
    PlayerESP = false,
    MobESP = false,
    -- Internal
    LastE = 0,
    LairCounter = 0
}

local TargetAttributes = {
    Legendary = true,
    Forceful = true,
    Thief = true,
    Invincible = true,
    Critical = true,
    Tragic = true,
    None = false
}

local QuestData = {
    Bruford = {
        RemoteArg = "BrufordHamonVeteran",
        MobName = "Hamon Veteran",
        KillsRequired = 3,
        NpcPos = Vector3.new(101, -116, -1513),
        FarmPos = Vector3.new(101, -116, -1513)
    },
    Polnareff = {
        RemoteArg = "admpn",
        MobName = "Polnareff",
        KillsRequired = 1,
        NpcPos = Vector3.new(15935, 238, -9070),
        FarmPos = Vector3.new(15935, 238, -9070)
    }
}

local Remotes = ReplicatedStorage:FindFirstChild("Library") and ReplicatedStorage.Library:FindFirstChild("Remotes")
local QuestRemote = Remotes and Remotes:FindFirstChild("Quest")
local ItemRemote = Remotes and Remotes:FindFirstChild("Send")
local LairRemote = Remotes and Remotes:FindFirstChild("Lair")

-- State
local CurrentState = "START_QUEST"
local KillCount = 0
local CurrentTarget = nil
local LastTarget = nil

-- // GUI // --
if CoreGui:FindFirstChild("ZwacHub_Modern") then
    CoreGui.ZwacHub_Modern:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZwacHub_Modern"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

-- Theme
local Theme = {
    Bg = Color3.fromRGB(12, 12, 14),
    Side = Color3.fromRGB(18, 18, 22),
    Card = Color3.fromRGB(24, 24, 28),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(235, 235, 235),
    Dim = Color3.fromRGB(150, 150, 150),
    On = Color3.fromRGB(255, 255, 255),
    Off = Color3.fromRGB(55, 55, 60)
}

-- Floating Bubble
local Bubble = Instance.new("TextButton")
Bubble.Name = "Bubble"
Bubble.Size = UDim2.new(0, 52, 0, 52)
Bubble.Position = UDim2.new(1, -72, 0.45, 0)
Bubble.BackgroundColor3 = Theme.Bg
Bubble.BackgroundTransparency = 0.15
Bubble.Text = "Z"
Bubble.Font = Enum.Font.GothamBlack
Bubble.TextSize = 22
Bubble.TextColor3 = Theme.Accent
Bubble.Parent = ScreenGui

local BubbleCorner = Instance.new("UICorner")
BubbleCorner.CornerRadius = UDim.new(1, 0)
BubbleCorner.Parent = Bubble

local BubbleStroke = Instance.new("UIStroke")
BubbleStroke.Color = Color3.fromRGB(80, 80, 85)
BubbleStroke.Thickness = 1.4
BubbleStroke.Transparency = 0.35
BubbleStroke.Parent = Bubble

-- Main Frame
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Theme.Bg
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 60)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.4
MainStroke.Parent = Main

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Side
TopBar.BackgroundTransparency = 0.3
TopBar.BorderSizePixel = 0
TopBar.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ZwacHub  •  Combined"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextColor3 = Theme.Text
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.TextColor3 = Theme.Text
CloseBtn.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 18)
StatusLabel.Position = UDim2.new(0, 12, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Hazır"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Theme.Dim
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = Main

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 118, 1, -72)
Sidebar.Position = UDim2.new(0, 10, 0, 64)
Sidebar.BackgroundColor3 = Theme.Side
Sidebar.BackgroundTransparency = 0.25
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = Sidebar

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 5)
SideList.Parent = Sidebar

local SidePad = Instance.new("UIPadding")
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.PaddingLeft = UDim.new(0, 6)
SidePad.PaddingRight = UDim.new(0, 6)
SidePad.Parent = Sidebar

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -140, 1, -72)
Content.Position = UDim2.new(0, 134, 0, 64)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.Parent = Main

local Tabs = {}
local CurrentTab = nil

local function CreateTab(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Theme.Card
    Btn.BackgroundTransparency = 0.4
    Btn.Text = name
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.TextColor3 = Theme.Dim
    Btn.Parent = Sidebar

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 95)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = Content

    local List = Instance.new("UIListLayout")
    List.Padding = UDim.new(0, 7)
    List.Parent = Page

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingBottom = UDim.new(0, 8)
    Pad.Parent = Page

    List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 12)
    end)

    Tabs[name] = {Btn = Btn, Page = Page}

    Btn.MouseButton1Click:Connect(function()
        if CurrentTab then
            Tabs[CurrentTab].Btn.BackgroundTransparency = 0.4
            Tabs[CurrentTab].Btn.TextColor3 = Theme.Dim
            Tabs[CurrentTab].Page.Visible = false
        end
        CurrentTab = name
        Btn.BackgroundTransparency = 0.05
        Btn.TextColor3 = Theme.Accent
        Page.Visible = true
    end)

    return Page
end

-- Animated Toggle
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -4, 0, 38)
    Frame.BackgroundColor3 = Theme.Card
    Frame.BackgroundTransparency = 0.3
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 9)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -62, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 13
    Label.TextColor3 = Theme.Text
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 42, 0, 24)
    Switch.Position = UDim2.new(1, -52, 0.5, -12)
    Switch.BackgroundColor3 = default and Theme.On or Theme.Off
    Switch.Parent = Frame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    Circle.Parent = Switch

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local state = default

    local function Set(v)
        state = v
        local pos = v and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        local col = v and Theme.On or Theme.Off
        TweenService:Create(Circle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = pos}):Play()
        TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = col}):Play()
        if callback then callback(v) end
    end

    Switch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Set(not state)
        end
    end)

    return Set
end

-- Create Tabs
local LairPage = CreateTab("Auto Lair")
local QuestPage = CreateTab("Auto Quest")
local RollPage = CreateTab("Auto Roll")
local VisualPage = CreateTab("Visuals")
local SettingsPage = CreateTab("Settings")

-- Default tab
Tabs["Auto Lair"].Btn.BackgroundTransparency = 0.05
Tabs["Auto Lair"].Btn.TextColor3 = Theme.Accent
Tabs["Auto Lair"].Page.Visible = true
CurrentTab = "Auto Lair"

-- Lair Toggles
CreateToggle(LairPage, "Auto Lair", false, function(v) Settings.AutoLair = v end)
CreateToggle(LairPage, "Auto Stand (Q)", false, function(v) Settings.AutoStand = v end)

-- Quest
local QuestSelect = Instance.new("TextButton")
QuestSelect.Size = UDim2.new(1, -4, 0, 34)
QuestSelect.BackgroundColor3 = Theme.Card
QuestSelect.Text = "Görev: Bruford"
QuestSelect.Font = Enum.Font.GothamMedium
QuestSelect.TextSize = 13
QuestSelect.TextColor3 = Color3.fromRGB(255, 210, 90)
QuestSelect.Parent = QuestPage

local QSCorner = Instance.new("UICorner")
QSCorner.CornerRadius = UDim.new(0, 9)
QSCorner.Parent = QuestSelect

QuestSelect.MouseButton1Click:Connect(function()
    if Settings.SelectedQuest == "Bruford" then
        Settings.SelectedQuest = "Polnareff"
        QuestSelect.Text = "Görev: Polnareff"
    else
        Settings.SelectedQuest = "Bruford"
        QuestSelect.Text = "Görev: Bruford"
    end
    CurrentState = "START_QUEST"
    KillCount = 0
end)

CreateToggle(QuestPage, "Auto Quest", false, function(v)
    Settings.AutoQuest = v
    if v then CurrentState = "START_QUEST" end
end)
CreateToggle(QuestPage, "Skill E (7s)", true, function(v) Settings.SkillE = v end)
CreateToggle(QuestPage, "Skill T", true, function(v) Settings.SkillT = v end)
CreateToggle(QuestPage, "Skill R", true, function(v) Settings.SkillR = v end)
CreateToggle(QuestPage, "Skill X", true, function(v) Settings.SkillX = v end)

-- Roll
CreateToggle(RollPage, "Auto Roll Attribute", false, function(v) Settings.AutoRoll = v end)

local AttrHeader = Instance.new("TextLabel")
AttrHeader.Size = UDim2.new(1, -4, 0, 22)
AttrHeader.BackgroundTransparency = 1
AttrHeader.Text = "Saklanacak Attribute'lar"
AttrHeader.Font = Enum.Font.GothamBold
AttrHeader.TextSize = 12
AttrHeader.TextColor3 = Theme.Dim
AttrHeader.TextXAlignment = Enum.TextXAlignment.Left
AttrHeader.Parent = RollPage

for name, enabled in pairs(TargetAttributes) do
    CreateToggle(RollPage, name, enabled, function(v)
        TargetAttributes[name] = v
    end)
end

-- Visuals
CreateToggle(VisualPage, "Player ESP", false, function(v) Settings.PlayerESP = v end)
CreateToggle(VisualPage, "Mob ESP", false, function(v) Settings.MobESP = v end)

-- Settings
CreateToggle(SettingsPage, "Auto Stand", false, function(v) Settings.AutoStand = v end)

-- Open / Close
local Open = false
local function ToggleGUI()
    Open = not Open
    if Open then
        Main.Visible = true
        Main.Size = UDim2.new(0, 420, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 420, 0, 340)
        }):Play()
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
            Size = UDim2.new(0, 420, 0, 0)
        })
        t:Play()
        t.Completed:Connect(function()
            Main.Visible = false
        end)
    end
end

Bubble.MouseButton1Click:Connect(ToggleGUI)
CloseBtn.MouseButton1Click:Connect(ToggleGUI)

-- Drag (Main + Bubble)
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos, dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(Main, TopBar)
MakeDraggable(Bubble, Bubble)

-- // HELPERS // --
local function PressKey(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.035)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

local function GetCurrentAttribute()
    local result = "None"
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            local stats = data:FindFirstChild("Stats")
            if stats then
                local attr = stats:FindFirstChild("Attribute")
                if attr then
                    if attr:IsA("ValueBase") then
                        result = tostring(attr.Value)
                    else
                        result = tostring(attr)
                    end
                else
                    local a = stats:GetAttribute("Attribute")
                    if a then result = tostring(a) end
                end
            end
        end
    end)
    if result == "" then result = "None" end
    return result
end

local function GetTargetMob()
    local living = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Living")
    if not living then return nil end
    local targetName = QuestData[Settings.SelectedQuest].MobName
    for _, mob in ipairs(living:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            return mob
        end
    end
    return nil
end

local function GetLairBoss()
    local success, boss = pcall(function()
        return workspace.World.Map.Lairs.Model.Alive.Vanilla
    end)
    if success and boss and boss:FindFirstChild("HumanoidRootPart") then
        return boss
    end
    return nil
end

-- // FLIGHT ENGINE // --
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Settings.AutoLair then
        local boss = GetLairBoss()
        if boss then
            local bossPos = boss.HumanoidRootPart.Position
            local hover = bossPos + Vector3.new(0, HOVER_HEIGHT, 0)
            root.CFrame = CFrame.lookAt(hover, bossPos + Vector3.new(0, 0, 0.001))
            root.AssemblyLinearVelocity = Vector3.zero
        end
    elseif Settings.AutoQuest then
        local q = QuestData[Settings.SelectedQuest]
        if CurrentState == "FARMING" then
            if CurrentTarget and CurrentTarget:FindFirstChild("HumanoidRootPart") then
                local pos = CurrentTarget.HumanoidRootPart.Position
                root.CFrame = CFrame.lookAt(pos + Vector3.new(0, HOVER_HEIGHT, 0), pos + Vector3.new(0, 0, 0.001))
            else
                root.CFrame = CFrame.lookAt(q.FarmPos + Vector3.new(0, HOVER_HEIGHT, 0), q.FarmPos)
            end
        else
            root.CFrame = CFrame.new(q.NpcPos)
        end
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- // MAIN LOOPS // --
-- Auto Roll
task.spawn(function()
    while task.wait(1.1) do
        if not Settings.AutoRoll then continue end
        local attr = GetCurrentAttribute()
        local wanted = false
        for name, on in pairs(TargetAttributes) do
            if on and string.lower(attr) == string.lower(name) then
                wanted = true
                break
            end
        end
        if wanted then
            Settings.AutoRoll = false
            StatusLabel.Text = "HEDEF ATTRIBUTE GELDİ: " .. attr
        else
            if ItemRemote then
                pcall(function()
                    ItemRemote:FireServer("Item", "Rokakaka")
                    task.wait(0.7)
                    ItemRemote:FireServer("Item", "Unusual Arrow")
                end)
            end
        end
    end
end)

-- Combat + Quest + Lair
task.spawn(function()
    while task.wait(0.14) do
        if Settings.AutoStand and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Stand") then
            PressKey(Enum.KeyCode.Q)
        end

        -- Auto Lair
        if Settings.AutoLair and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local boss = GetLairBoss()

            if boss then
                if Settings.SkillE and (tick() - Settings.LastE) >= 7 then
                    PressKey(Enum.KeyCode.E)
                    Settings.LastE = tick()
                end
                if Settings.SkillT then PressKey(Enum.KeyCode.T) end
                if Settings.SkillR then PressKey(Enum.KeyCode.R) end
                if Settings.SkillX then PressKey(Enum.KeyCode.X) end
            else
                if (root.Position - LAIR_START_POS).Magnitude > 25 then
                    root.CFrame = CFrame.new(LAIR_START_POS)
                elseif LairRemote then
                    pcall(function() LairRemote:FireServer("200") end)
                    Settings.LairCounter += 1
                    StatusLabel.Text = "Lair Runs: " .. Settings.LairCounter
                    task.wait(0.9)
                end
            end
        end

        -- Auto Quest
        if Settings.AutoQuest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local q = QuestData[Settings.SelectedQuest]
            StatusLabel.Text = string.format("Quest: %s | Attr: %s | Kill: %d/%d", Settings.SelectedQuest, GetCurrentAttribute(), KillCount, q.KillsRequired)

            if CurrentState == "START_QUEST" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(q.NpcPos)
                task.wait(0.45)
                if QuestRemote then
                    pcall(function() QuestRemote:InvokeServer("Start", q.RemoteArg) end)
                end
                KillCount = 0
                CurrentTarget = nil
                LastTarget = nil
                task.wait(0.4)
                CurrentState = "FARMING"

            elseif CurrentState == "FARMING" then
                CurrentTarget = GetTargetMob()

                if CurrentTarget \~= LastTarget then
                    if LastTarget and (not LastTarget.Parent or not LastTarget:FindFirstChild("Humanoid") or LastTarget.Humanoid.Health <= 0) then
                        KillCount += 1
                    end
                    LastTarget = CurrentTarget
                end

                if KillCount >= q.KillsRequired then
                    CurrentState = "COMPLETE_QUEST"
                elseif CurrentTarget then
                    if Settings.SkillE and (tick() - Settings.LastE) >= 7 then
                        PressKey(Enum.KeyCode.E)
                        Settings.LastE = tick()
                    end
                    if Settings.SkillT then PressKey(Enum.KeyCode.T) end
                    if Settings.SkillR then PressKey(Enum.KeyCode.R) end
                    if Settings.SkillX then PressKey(Enum.KeyCode.X) end
                end

            elseif CurrentState == "COMPLETE_QUEST" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(q.NpcPos)
                task.wait(0.45)
                if QuestRemote then
                    pcall(function()
                        QuestRemote:InvokeServer("Response", q.RemoteArg)
                        task.wait(0.25)
                        QuestRemote:InvokeServer("Start", q.RemoteArg)
                    end)
                end
                KillCount = 0
                CurrentTarget = nil
                LastTarget = nil
                task.wait(0.4)
                CurrentState = "FARMING"
            end
        end
    end
end)

-- ESP (Optimized)
task.spawn(function()
    while task.wait(1.2) do
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and (v.Name == "Zwac_PlayerESP" or v.Name == "Zwac_MobESP") then
                if (v.Name == "Zwac_PlayerESP" and not Settings.PlayerESP) or (v.Name == "Zwac_MobESP" and not Settings.MobESP) then
                    v:Destroy()
                end
            end
        end

        if Settings.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr \~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if not plr.Character:FindFirstChild("Zwac_PlayerESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "Zwac_PlayerESP"
                        h.FillColor = Color3.fromRGB(255, 255, 255)
                        h.OutlineColor = Color3.fromRGB(200, 200, 200)
                        h.FillTransparency = 0.6
                        h.Parent = plr.Character
                    end
                end
            end
        end

        if Settings.MobESP then
            local living = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Living")
            if living then
                for _, mob in ipairs(living:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and not mob:FindFirstChild("Zwac_MobESP") then
                        local h = Instance.new("Highlight")
                        h.Name = "Zwac_MobESP"
                        h.FillColor = Color3.fromRGB(220, 60, 60)
                        h.OutlineColor = Color3.fromRGB(180, 40, 40)
                        h.FillTransparency = 0.55
                        h.Parent = mob
                    end
                end
            end
        end
    end
end)

print("ZwacHub Combined Modern GUI yüklendi")
