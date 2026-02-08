-- // Configurações de Farm
_G.AutoFarm = false
_G.Velocidade = 180
local NPC_Posicao = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

-- // 1. CRIAÇÃO DA INTERFACE (NATIVA)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")
local UICorner = Instance.new("UICorner")

-- Configuração da ScreenGui
ScreenGui.Name = "EliteHubCustom"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Janela Principal
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, -60)
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Active = true
MainFrame.Draggable = true -- Permite arrastar no Mobile

local MainCorner = UICorner:Clone()
MainCorner.Parent = MainFrame

-- Título
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "ELITE HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
UICorner:Clone().Parent = Title

-- Botão de Ativar
ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.35, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
ToggleBtn.Text = "AUTO QUEST: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
UICorner:Clone().Parent = ToggleBtn

-- Status
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Aguardando..."
StatusLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7)
StatusLabel.TextSize = 12

-- // 2. FUNÇÕES DE MOVIMENTO E LÓGICA
local function VoarPara(target)
    local root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local distancia = (root.Position - target.Position).Magnitude
        local info = TweenInfo.new(distancia / _G.Velocidade, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(root, info, {CFrame = target})
        tween:Play()
        return tween
    end
end

local function LoopFarm()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            local lp = game.Players.LocalPlayer
            local questGui = lp.PlayerGui:FindFirstChild("QuestOptions")
            
            -- Passo 1: Aceitar Missão
            if not questGui or not questGui.QuestFrame.Accept.Visible then
                StatusLabel.Text = "Indo ao NPC..."
                local t = VoarPara(NPC_Posicao)
                if t then t.Completed:Wait() end
                
                -- Segurar E (ProximityPrompt)
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and lp:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
                
                task.wait(0.8)
                
                -- Clicar em Accept
                if questGui and questGui.QuestFrame.Accept.Visible then
                    StatusLabel.Text = "Aceitando Missão..."
                    local btn = questGui.QuestFrame.Accept
                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do conn:Fire() end
                end
            end

            -- Passo 2: Matar Bandidos
            StatusLabel.Text = "Procurando Bandidos..."
            local bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
            for _, bandit in pairs(bandits) do
                if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                    local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        StatusLabel.Text = "Atacando Bandido..."
                        VoarPara(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
                        
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
    StatusLabel.Text = "Farm Desligado."
end

-- // 3. EVENTO DO BOTÃO
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "AUTO QUEST: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        task.spawn(LoopFarm)
    else
        ToggleBtn.Text = "AUTO QUEST: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    end
end)
