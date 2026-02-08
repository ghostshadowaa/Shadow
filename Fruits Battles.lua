-- // 1. LIMPEZA (Remove versões antigas para não bugar)
local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
if pg:FindFirstChild("EliteHubFinal") then
    pg:FindFirstChild("EliteHubFinal"):Destroy()
end

-- // 2. CONFIGURAÇÕES
_G.AutoFarm = false
_G.Velocidade = 180
local NPC_CF = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

-- // 3. INTERFACE (Criada no PlayerGui)
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubFinal"
sg.ResetOnSpawn = false -- Não some quando você morre

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 160, 0, 100)
frame.Position = UDim2.new(0.5, -80, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "ELITE HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.8, 0, 0.4, 0)
btn.Position = UDim2.new(0.1, 0, 0.4, 0)
btn.Text = "START"
btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btn.TextColor3 = Color3.new(1,1,1)

-- // 4. FUNÇÃO DE MOVIMENTO
local function To(target)
    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - target.Position).Magnitude
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = target})
        tween:Play()
        return tween
    end
end

-- // 5. LÓGICA
local function Loop()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            local qGui = pg:FindFirstChild("QuestOptions")
            
            -- NPC / Quest
            if not qGui or not qGui.QuestFrame.Accept.Visible then
                local t = To(NPC_CF)
                if t then t.Completed:Wait() end
                
                -- Procura o Prompt
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and p:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
                task.wait(1)
                -- Aceitar
                if qGui and qGui.QuestFrame.Accept.Visible then
                    local accept = qGui.QuestFrame.Accept
                    for _, c in pairs(getconnections(accept.MouseButton1Click)) do c:Fire() end
                end
            end

            -- Bandidos
            local bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
            for _, b in pairs(bandits) do
                if _G.AutoFarm and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                    local bRoot = b:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        To(bRoot.CFrame * CFrame.new(0,0,3)).Completed:Wait()
                        repeat
                            if bRoot and _G.AutoFarm then
                                p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0,0,3)
                            end
                            task.wait(0.1)
                        until not _G.AutoFarm or b.Humanoid.Health <= 0 or not b.Parent
                    end
                end
            end
        end)
    end
end

-- // 6. CLICK
btn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    btn.Text = _G.AutoFarm and "STOP" or "START"
    btn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    if _G.AutoFarm then task.spawn(Loop) end
end)
