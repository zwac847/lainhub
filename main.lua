-- // ZwacHub Combined - Part 1 (Core + GUI) // --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

getgenv().Zwac = getgenv().Zwac or {}
local Zwac = getgenv().Zwac

Zwac.Settings = {
    AutoLair = false,
    AutoQuest = false,
    SelectedQuest = "Bruford",
    AutoRoll = false,
    AutoStand = false,
    SkillE = true,
    SkillT = true,
    SkillR = true,
    SkillX = true,
    PlayerESP = false,
    MobESP = false,
    LastE = 0,
    LairCounter = 0
}

Zwac.TargetAttributes = {
    Legendary = true,
    Forceful = true,
    Thief = true,
    Invincible = true,
    Critical = true,
    Tragic = true,
    None = false
}

Zwac.QuestData = {
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
Zwac.QuestRemote = Remotes and Remotes:FindFirstChild("Quest")
Zwac.ItemRemote = Remotes and Remotes:FindFirstChild("Send")
Zwac.LairRemote = Remotes and Remotes:FindFirstChild("Lair")

Zwac.CurrentState = "START_QUEST"
Zwac.KillCount = 0
Zwac.CurrentTarget = nil
Zwac.LastTarget = nil

function Zwac.PressKey(key)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, key, false, game)
        task.wait(0.035)
        VirtualInputManager:SendKeyEvent(false, key, false, game)
    end)
end

function Zwac.GetCurrentAttribute()
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

function Zwac.GetTargetMob()
    local living = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("Living")
    if not living then return nil end
    local targetName = Zwac.QuestData[Zwac.Settings.SelectedQuest].MobName
    for _, mob in ipairs(living:GetChildren()) do
        if mob.Name == targetName and mob:FindFirstChild("HumanoidRootPart") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            return mob
        end
    end
    return nil
end

function Zwac.GetLairBoss()
    local success, boss = pcall(function()
        return workspace.World.Map.Lairs.Model.Alive.Vanilla
    end)
    if success and boss and boss:FindFirstChild("HumanoidRootPart") then
        return boss
    end
    return nil
end

-- GUI
if CoreGui:FindFirstChild("ZwacHub_Modern") then
    CoreGui.ZwacHub_Modern:Destroy()
end

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ZwacHub_Modern"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or CoreGui

local Bubble = Instance.new("TextButton")
Bubble.Size = UDim2.new(0, 52, 0, 52)
Bubble.Position = UDim2.new(1, -72, 0.45, 0)
Bubble.BackgroundColor3 = Theme.Bg
Bubble.BackgroundTransparency = 0.15
Bubble.Text = "Z"
Bubble.Font = Enum.Font.GothamBlack
Bubble.TextSize = 22
Bubble.TextColor3 = Theme.Accent
Bubble.Parent = ScreenGui
Instance.new("UICorner", Bubble).CornerRadius = UDim.new(1, 0)
local BubbleStroke = Instance.new("UIStroke", Bubble)
BubbleStroke.Color = Color3.fromRGB(80, 80, 85)
BubbleStroke.Thickness = 1.4
BubbleStroke.Transparency = 0.35

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 340)
Main.Position = UDim2.new(0.5, -210, 0.5, -170)
Main.BackgroundColor3 = Theme.Bg
Main.BackgroundTransparency = 0.08
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(55, 55, 60)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.4

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Side
TopBar.BackgroundTransparency = 0.3
TopBar.Parent = Main
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

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
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

Zwac.StatusLabel = Instance.new("TextLabel")
Zwac.StatusLabel.Size = UDim2.new(1, -20, 0, 18)
Zwac.StatusLabel.Position = UDim2.new(0, 12, 0, 42)
Zwac.StatusLabel.BackgroundTransparency = 1
Zwac.StatusLabel.Text = "Hazır"
Zwac.StatusLabel.Font = Enum.Font.Gotham
Zwac.StatusLabel.TextSize = 12
Zwac.StatusLabel.TextColor3 = Theme.Dim
Zwac.StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
Zwac.StatusLabel.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 118, 1, -72)
Sidebar.Position = UDim2.new(0, 10, 0, 64)
Sidebar.BackgroundColor3 = Theme.Side
Sidebar.BackgroundTransparency = 0.25
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SideList = Instance.new("UIListLayout", Sidebar)
SideList.Padding = UDim.new(0, 5)
local SidePad = Instance.new("UIPadding", Sidebar)
SidePad.PaddingTop = UDim.new(0, 6)
SidePad.PaddingLeft = UDim.new(0, 6)
SidePad.PaddingRight = UDim.new(0, 6)

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
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 95)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = Content

    local List = Instance.new("UIListLayout", Page)
    List.Padding = UDim.new(0, 7)
    local Pad = Instance.new("UIPadding", Page)
    Pad.PaddingTop = UDim.new(0, 2)
    Pad.PaddingBottom = UDim.new(0, 8)

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

function Zwac.CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -4, 0, 38)
    Frame.BackgroundColor3 = Theme.Card
    Frame.BackgroundTransparency = 0.3
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 9)

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
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    Circle.Parent = Switch
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

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
end

local LairPage = CreateTab("Auto Lair")
local QuestPage = CreateTab("Auto Quest")
local RollPage = CreateTab("Auto Roll")
local VisualPage = CreateTab("Visuals")
local SettingsPage = CreateTab("Settings")

Tabs["Auto Lair"].Btn.BackgroundTransparency = 0.05
Tabs["Auto Lair"].Btn.TextColor3 = Theme.Accent
Tabs["Auto Lair"].Page.Visible = true
CurrentTab = "Auto Lair"

Zwac.CreateToggle(LairPage, "Auto Lair", false, function(v) Zwac.Settings.AutoLair = v end)
Zwac.CreateToggle(LairPage, "Auto Stand (Q)", false, function(v) Zwac.Settings.AutoStand = v end)

local QuestSelect = Instance.new("TextButton")
QuestSelect.Size = UDim2.new(1, -4, 0, 34)
QuestSelect.BackgroundColor3 = Theme.Card
QuestSelect.Text = "Görev: Bruford"
QuestSelect.Font = Enum.Font.GothamMedium
QuestSelect.TextSize = 13
QuestSelect.TextColor3 = Color3.fromRGB(255, 210, 90)
QuestSelect.Parent = QuestPage
Instance.new("UICorner", QuestSelect).CornerRadius = UDim.new(0, 9)

QuestSelect.MouseButton1Click:Connect(function()
    if Zwac.Settings.SelectedQuest == "Bruford" then
        Zwac.Settings.SelectedQuest = "Polnareff"
        QuestSelect.Text = "Görev: Polnareff"
    else
        Zwac.Settings.SelectedQuest = "Bruford"
        QuestSelect.Text = "Görev: Bruford"
    end
    Zwac.CurrentState = "START_QUEST"
    Zwac.KillCount = 0
end)

Zwac.CreateToggle(QuestPage, "Auto Quest", false, function(v)
    Zwac.Settings.AutoQuest = v
    if v then Zwac.CurrentState = "START_QUEST" end
end)
Zwac.CreateToggle(QuestPage, "Skill E (7s)", true, function(v) Zwac.Settings.SkillE = v end)
Zwac.CreateToggle(QuestPage, "Skill T", true, function(v) Zwac.Settings.SkillT = v end)
Zwac.CreateToggle(QuestPage, "Skill R", true, function(v) Zwac.Settings.SkillR = v end)
Zwac.CreateToggle(QuestPage, "Skill X", true, function(v) Zwac.Settings.SkillX = v end)

Zwac.CreateToggle(RollPage, "Auto Roll Attribute", false, function(v) Zwac.Settings.AutoRoll = v end)

local AttrHeader = Instance.new("TextLabel")
AttrHeader.Size = UDim2.new(1, -4, 0, 22)
AttrHeader.BackgroundTransparency = 1
AttrHeader.Text = "Saklanacak Attribute'lar"
AttrHeader.Font = Enum.Font.GothamBold
AttrHeader.TextSize = 12
AttrHeader.TextColor3 = Theme.Dim
AttrHeader.TextXAlignment = Enum.TextXAlignment.Left
AttrHeader.Parent = RollPage

for name, enabled in pairs(Zwac.TargetAttributes) do
    Zwac.CreateToggle(RollPage, name, enabled, function(v)
        Zwac.TargetAttributes[name] = v
    end)
end

Zwac.CreateToggle(VisualPage, "Player ESP", false, function(v) Zwac.Settings.PlayerESP = v end)
Zwac.CreateToggle(VisualPage, "Mob ESP", false, function(v) Zwac.Settings.MobESP = v end)
Zwac.CreateToggle(SettingsPage, "Auto Stand", false, function(v) Zwac.Settings.AutoStand = v end)

local Open = false
local function ToggleGUI()
    Open = not Open
    if Open then
        Main.Visible = true
        Main.Size = UDim2.new(0, 420, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.32, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 420, 0, 340)}):Play()
    else
        local t = TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 420, 0, 0)})
        t:Play()
        t.Completed:Connect(function() Main.Visible = false end)
    end
end

Bubble.MouseButton1Click:Connect(ToggleGUI)
CloseBtn.MouseButton1Click:Connect(ToggleGUI)

local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos, dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

print("[Zwac] Part 1 yüklendi - GUI hazır")
-- // ZwacHub Combined - Part 2 (Systems) // --
local Zwac = getgenv().Zwac
if not Zwac then
    return warn("Önce 1. parçayı yükle!")
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Flight
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if Zwac.Settings.AutoLair then
        local boss = Zwac.GetLairBoss()
        if boss then
            local bossPos = boss.HumanoidRootPart.Position
            root.CFrame = CFrame.lookAt(bossPos + Vector3.new(0, 8, 0), bossPos + Vector3.new(0, 0, 0.001))
            root.AssemblyLinearVelocity = Vector3.zero
        end
    elseif Zwac.Settings.AutoQuest then
        local q = Zwac.QuestData[Zwac.Settings.SelectedQuest]
        if Zwac.CurrentState == "FARMING" then
            if Zwac.CurrentTarget and Zwac.CurrentTarget:FindFirstChild("HumanoidRootPart") then
                local pos = Zwac.CurrentTarget.HumanoidRootPart.Position
                root.CFrame = CFrame.lookAt(pos + Vector3.new(0, 8, 0), pos + Vector3.new(0, 0, 0.001))
            else
                root.CFrame = CFrame.lookAt(q.FarmPos + Vector3.new(0, 8, 0), q.FarmPos)
            end
        else
            root.CFrame = CFrame.new(q.NpcPos)
        end
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- Auto Roll
task.spawn(function()
    while task.wait(1.1) do
        if Zwac.Settings.AutoRoll then
            local attr = Zwac.GetCurrentAttribute()
            local wanted = false
            for name, on in pairs(Zwac.TargetAttributes) do
                if on and string.lower(attr) == string.lower(name) then
                    wanted = true
                    break
                end
            end
            if wanted then
                Zwac.Settings.AutoRoll = false
                if Zwac.StatusLabel then
                    Zwac.StatusLabel.Text = "HEDEF ATTRIBUTE: " .. attr
                end
            else
                if Zwac.ItemRemote then
                    pcall(function()
                        Zwac.ItemRemote:FireServer("Item", "Rokakaka")
                        task.wait(0.7)
                        Zwac.ItemRemote:FireServer("Item", "Unusual Arrow")
                    end)
                end
            end
        end
    end
end)

-- Main Logic
task.spawn(function()
    while task.wait(0.14) do
        if Zwac.Settings.AutoStand and LocalPlayer.Character and not LocalPlayer.Character:FindFirstChild("Stand") then
            Zwac.PressKey(Enum.KeyCode.Q)
        end

        -- Auto Lair
        if Zwac.Settings.AutoLair and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local boss = Zwac.GetLairBoss()

            if boss then
                if Zwac.Settings.SkillE and (tick() - Zwac.Settings.LastE) >= 7 then
                    Zwac.PressKey(Enum.KeyCode.E)
                    Zwac.Settings.LastE = tick()
                end
                if Zwac.Settings.SkillT then Zwac.PressKey(Enum.KeyCode.T) end
                if Zwac.Settings.SkillR then Zwac.PressKey(Enum.KeyCode.R) end
                if Zwac.Settings.SkillX then Zwac.PressKey(Enum.KeyCode.X) end
            else
                if (root.Position - Vector3.new(-681, -116, -810)).Magnitude > 25 then
                    root.CFrame = CFrame.new(-681, -116, -810)
                elseif Zwac.LairRemote then
                    pcall(function()
                        Zwac.LairRemote:FireServer("200")
                    end)
                    Zwac.Settings.LairCounter = Zwac.Settings.LairCounter + 1
                    if Zwac.StatusLabel then
                        Zwac.StatusLabel.Text = "Lair Runs: " .. Zwac.Settings.LairCounter
                    end
                    task.wait(0.9)
                end
            end
        end

        -- Auto Quest
        if Zwac.Settings.AutoQuest and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local q = Zwac.QuestData[Zwac.Settings.SelectedQuest]
            if Zwac.StatusLabel then
                Zwac.StatusLabel.Text = string.format("Quest: %s | Attr: %s | Kill: %d/%d", Zwac.Settings.SelectedQuest, Zwac.GetCurrentAttribute(), Zwac.KillCount, q.KillsRequired)
            end

            if Zwac.CurrentState == "START_QUEST" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(q.NpcPos)
                task.wait(0.45)
                if Zwac.QuestRemote then
                    pcall(function()
                        Zwac.QuestRemote:InvokeServer("Start", q.RemoteArg)
                    end)
                end
                Zwac.KillCount = 0
                Zwac.CurrentTarget = nil
                Zwac.LastTarget = nil
                task.wait(0.4)
                Zwac.CurrentState = "FARMING"

            elseif Zwac.CurrentState == "FARMING" then
                Zwac.CurrentTarget = Zwac.GetTargetMob()

                if Zwac.CurrentTarget \~= Zwac.LastTarget then
                    if Zwac.LastTarget and (not Zwac.LastTarget.Parent or not Zwac.LastTarget:FindFirstChild("Humanoid") or Zwac.LastTarget.Humanoid.Health <= 0) then
                        Zwac.KillCount = Zwac.KillCount + 1
                    end
                    Zwac.LastTarget = Zwac.CurrentTarget
                end

                if Zwac.KillCount >= q.KillsRequired then
                    Zwac.CurrentState = "COMPLETE_QUEST"
                elseif Zwac.CurrentTarget then
                    if Zwac.Settings.SkillE and (tick() - Zwac.Settings.LastE) >= 7 then
                        Zwac.PressKey(Enum.KeyCode.E)
                        Zwac.Settings.LastE = tick()
                    end
                    if Zwac.Settings.SkillT then Zwac.PressKey(Enum.KeyCode.T) end
                    if Zwac.Settings.SkillR then Zwac.PressKey(Enum.KeyCode.R) end
                    if Zwac.Settings.SkillX then Zwac.PressKey(Enum.KeyCode.X) end
                end

            elseif Zwac.CurrentState == "COMPLETE_QUEST" then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(q.NpcPos)
                task.wait(0.45)
                if Zwac.QuestRemote then
                    pcall(function()
                        Zwac.QuestRemote:InvokeServer("Response", q.RemoteArg)
                        task.wait(0.25)
                        Zwac.QuestRemote:InvokeServer("Start", q.RemoteArg)
                    end)
                end
                Zwac.KillCount = 0
                Zwac.CurrentTarget = nil
                Zwac.LastTarget = nil
                task.wait(0.4)
                Zwac.CurrentState = "FARMING"
            end
        end
    end
end)

-- ESP
task.spawn(function()
    while task.wait(1.2) do
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Highlight") and (v.Name == "Zwac_PlayerESP" or v.Name == "Zwac_MobESP") then
                if (v.Name == "Zwac_PlayerESP" and not Zwac.Settings.PlayerESP) or (v.Name == "Zwac_MobESP" and not Zwac.Settings.MobESP) then
                    v:Destroy()
                end
            end
        end

        if Zwac.Settings.PlayerESP then
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

        if Zwac.Settings.MobESP then
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

print("[Zwac] Part 2 yüklendi - Sistemler çalışıyor")
