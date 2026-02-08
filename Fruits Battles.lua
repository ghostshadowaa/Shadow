-- // Variáveis de Controle
_G.AutoFarm = false
_G.Velocidade = 150
local NPC_CF = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

-- // Criando Interface Simples (UI Nativa)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "EliteHubNative"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -75, 0.5, -50)
MainFrame.Size = UDim2.new(0, 150, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true -- Você pode arrastar na tela

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Elite Hub v1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1

ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ToggleBtn.Text = "Auto Quest: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)

-- // Função de Movimentação
local function To(TargetCFrame)
    local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (root.Position - TargetCFrame.Position).Magnitude
        local info = TweenInfo.new(distance / _G.Velocidade, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(root, info, {CFrame = TargetCFrame})
        tween:Play()
        return tween
    end
end

-- // Lógica da Quest
local function StartQuest()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            local lp = game.Players.LocalPlayer
            local questGui = lp.PlayerGui:FindFirstChild("QuestOptions")
            
            if not questGui or not questGui.QuestFrame.Accept.Visible then
                To(NPC_CF).Completed:Wait()
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and lp:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
                task.wait(0.5)
                if questGui and questGui.QuestFrame.Accept.Visible then
                    local btn = questGui.QuestFrame.Accept
                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                end
            end

            -- Ir até os Bandidos
            local folder = workspace.Visuals.More.Npcs.Enemy.Bandits
            for _, bandit in pairs(folder:GetChildren()) do
                if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                    local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        To(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
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

-- // Botão Toggle
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "Auto Quest: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        task.spawn(StartQuest)
    else
        ToggleBtn.Text = "Auto Quest: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)
