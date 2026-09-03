-- // 1. CORE + SETTINGS // --
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

print("[Zwac] Core yüklendi")
