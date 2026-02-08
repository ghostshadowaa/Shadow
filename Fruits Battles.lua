-- // Variáveis de Configuração
_G.AutoFarm = false
_G.Velocidade = 180
local NPC_CF = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

-- // Criando a Interface (Simples e Funcional)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local SpeedLabel = Instance.new("TextLabel")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "EliteHubNativo"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -90, 0.4, -60)
MainFrame.Size = UDim2.new(0, 180, 0, 120)
MainFrame.Active = true
MainFrame.Draggable = true -- Pode arrastar pelo celular

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "ELITE HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

ToggleBtn.Name = "Toggle"
ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.35, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.3, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.Text = "AUTO QUEST: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold

SpeedLabel.Parent = MainFrame
SpeedLabel.Position = UDim2.new(0, 0, 0.75, 0)
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.Text = "Velocidade: 180"
SpeedLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
SpeedLabel.BackgroundTransparency = 1

-- // Função de Movimentação (Tween)
local function To(TargetCFrame)
    local char = game.Players.LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (root.Position - TargetCFrame.Position).Magnitude
        local info = TweenInfo.new(distance / _G.Velocidade, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(root, info, {CFrame = TargetCFrame})
        tween:Play()
        return tween
    end
end

-- // Lógica Principal
local function StartQuest()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            local lp = game.Players.LocalPlayer
            local questGui = lp.PlayerGui:WaitForChild("QuestOptions", 5)
            
            -- Verificar se precisa ir ao NPC
            if not questGui or not questGui.QuestFrame.Accept.Visible then
                local t = To(NPC_CF)
                if t then t.Completed:Wait() end
                
                -- Interação ProximityPrompt
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and lp:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
                
                task.wait(0.8)
                
                -- Aceitar Missão
                if questGui and questGui.QuestFrame.Accept.Visible then
                    local btn = questGui.QuestFrame.Accept
                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                end
            end

            -- Ir até os Bandidos
            local bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
            for _, bandit in pairs(bandits) do
                if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                    local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        local tB = To(bRoot.CFrame * CFrame.new(0, 0, 3))
                        if tB then tB.Completed:Wait() end
                        
                        repeat
                            if bRoot and _G.AutoFarm then
                                lp.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                            end
                            task.wait(0.1)
                        until not _G.AutoFarm or not bandit:Parent or bandit.Humanoid.Health <= 0
                    end
                end
            end
        end)
    end
end

-- // Botão ON/OFF
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "AUTO QUEST: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        task.spawn(StartQuest)
    else
        ToggleBtn.Text = "AUTO QUEST: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)
