local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Elite Hub | Auto Quest",
   LoadingTitle = "Carregando Configurações...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FileName = "QuestConfig" }
})

-- Variáveis de Configuração
local _G = {
    AutoFarm = false,
    NPC_CFrame = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625),
    Velocidade = 150 -- Aumentado para maior rapidez
}

-- Função de Movimentação Ultra Rápida
local function To(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    if Root then
        local Distance = (Root.Position - TargetCFrame.Position).Magnitude
        local TweenService = game:GetService("TweenService")
        -- Cálculo de tempo baseado na nova velocidade
        local Info = TweenInfo.new(Distance / _G.Velocidade, Enum.EasingStyle.Linear)
        local Tween = TweenService:Create(Root, {CFrame = TargetCFrame})
        Tween:Play()
        return Tween
    end
end

-- Lógica de Auto Quest
local function StartAutoQuest()
    while _G.AutoFarm do
        task.wait(0.5)
        local Player = game.Players.LocalPlayer
        local QuestFrame = Player.PlayerGui:WaitForChild("QuestOptions"):WaitForChild("QuestFrame")
        
        -- Verificar se já está em missão (Se o frame de aceitar NÃO estiver visível)
        if not QuestFrame.Visible then
            -- 1. Voar até o NPC
            local t = To(_G.NPC_CFrame)
            if t then t.Completed:Wait() end
            
            -- 2. Interagir com ProximityPrompt (Segurar E por 2s)
            -- Procura o prompt mais próximo na área do NPC
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (v.Parent.WorldPivot.Position - _G.NPC_CFrame.Position).Magnitude < 10 then
                    fireproximityprompt(v, 2)
                    break
                end
            end
            
            -- 3. Clicar no botão Accept
            task.wait(0.5)
            if QuestFrame.Accept.Visible then
                for _, connection in pairs(getconnections(QuestFrame.Accept.MouseButton1Click)) do
                    connection:Fire()
                end
            end
        end

        -- 4. Ir até os Bandidos
        local Bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
        for _, bandit in pairs(Bandits) do
            if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                if bRoot then
                    -- Vai até o bandido e fica batendo (ajuste a CFrame para trás dele se quiser)
                    local t = To(bRoot.CFrame * CFrame.new(0, 0, 3))
                    repeat
                        task.wait(0.1)
                    until not _G.AutoFarm or not bandit:Parent or bandit.Humanoid.Health <= 0
                end
            end
        end
    end
end

-- Interface
local MainTab = Window:CreateTab("Farm Automático", 4483362458)

MainTab:CreateToggle({
   Name = "Ativar Auto Quest (Level 0+)",
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
   Max = 300,
   CurrentValue = 150,
   Flag = "SliderVelocidade",
   Callback = function(Value)
      _G.Velocidade = Value
   end,
})
