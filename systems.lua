-- // 3. SYSTEMS // --
local Zwac = getgenv().Zwac
if not Zwac then return warn("Önce Core ve GUI'yi yükle!") end

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
        if not Zwac.Settings.AutoRoll then continue end
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
            if Zwac.StatusLabel then Zwac.StatusLabel.Text = "HEDEF ATTRIBUTE: " .. attr end
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
                    pcall(function() Zwac.LairRemote:FireServer("200") end)
                    Zwac.Settings.LairCounter += 1
                    if Zwac.StatusLabel then Zwac.StatusLabel.Text = "Lair Runs: " .. Zwac.Settings.LairCounter end
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
                if Zwac.QuestRemote then pcall(function() Zwac.QuestRemote:InvokeServer("Start", q.RemoteArg) end) end
                Zwac.KillCount = 0
                Zwac.CurrentTarget = nil
                Zwac.LastTarget = nil
                task.wait(0.4)
                Zwac.CurrentState = "FARMING"

            elseif Zwac.CurrentState == "FARMING" then
                Zwac.CurrentTarget = Zwac.GetTargetMob()

                if Zwac.CurrentTarget \~= Zwac.LastTarget then
                    if Zwac.LastTarget and (not Zwac.LastTarget.Parent or not Zwac.LastTarget:FindFirstChild("Humanoid") or Zwac.LastTarget.Humanoid.Health <= 0) then
                        Zwac.KillCount += 1
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

print("[Zwac] Tüm sistemler yüklendi ✓")
