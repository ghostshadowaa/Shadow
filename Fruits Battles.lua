-- // Aguardar o jogo carregar completamente
if not game:IsLoaded() then game.Loaded:Wait() end

-- // Carregando Rayfield Library (A mais estável para você)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Elite Hub | Auto Quest",
   LoadingTitle = "Carregando Configurações...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- // Variáveis de Controle
_G.AutoFarm = false
_G.Velocidade = 150
local NPC_CFrame = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

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

-- // Lógica Principal da Quest
local function StartAutoQuest()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            local lp = game.Players.LocalPlayer
            local questGui = lp.PlayerGui:FindFirstChild("QuestOptions")
            
            -- 1. Verifica se precisa aceitar a missão
            if not questGui or not questGui.QuestFrame.Accept.Visible then
                -- Vai até o NPC
                local tw = To(NPC_CFrame)
                if tw then tw.Completed:Wait() end
                
                -- Interage (Segura E por 2s)
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and lp:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        task.wait(0.5)
                        break
                    end
                end
                
                -- Clica no botão Accept
                if questGui and questGui.QuestFrame.Accept.Visible then
                    local btn = questGui.QuestFrame.Accept
                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                        conn:Fire()
                    end
                end
            end

            -- 2. Ir até os Bandidos
            -- Caminho: Visuals.More.Npcs.Enemy.Bandits
            local banditFolder = workspace.Visuals.More.Npcs.Enemy.Bandits
            for _, bandit in pairs(banditFolder:GetChildren()) do
                if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                    local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        -- Voa até o bandido
                        local twB = To(bRoot.CFrame * CFrame.new(0, 0, 3))
                        if twB then twB.Completed:Wait() end
                        
                        -- Fica colado nele até morrer
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

-- // Criação da Aba e Botões
local MainTab = Window:CreateTab("Farm Automático", 4483362458)

MainTab:CreateToggle({
   Name = "Ativar Quest (Level 0+)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
          task.spawn(StartAutoQuest)
      end
   end,
})

MainTab:CreateSlider({
   Name = "Velocidade do Tween",
   Min = 50,
   Max = 400,
   CurrentValue = 150,
   Flag = "SliderVel",
   Callback = function(Value)
      _G.Velocidade = Value
   end,
})

-- Notificação de Sucesso
Rayfield:Notify({
   Title = "Elite Hub Ativo",
   Content = "Script carregado pelo gerenciador local.",
   Duration = 5,
   Image = 4483362458,
})
