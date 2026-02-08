--[[
    Auto Quest Script - Mobile/PC
    Nota: Use com moderação para evitar bans.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Elite Hub | Auto Quest",
   LoadingTitle = "Carregando Interface...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = true, FileName = "QuestConfig" }
})

-- Variáveis de Controle
local _G = {
    AutoFarm = false,
    DistanciaNPC = CFrame.new(0, 0, 0), -- Definir a posição do NPC de Level 0
    DistanciaInimigo = "Visuals.More.Npcs.Enemy.Bandits"
}

-- Função de Tween (Movimentação Suave)
local function To(TargetCFrame)
    local Character = game.Players.LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local TweenService = game:GetService("TweenService")
        local Info = TweenInfo.new((Character.HumanoidRootPart.Position - TargetCFrame.Position).Magnitude / 50, Enum.EasingStyle.Linear)
        local Tween = TweenService:Create(Character.HumanoidRootPart, Info, {CFrame = TargetCFrame})
        Tween:Play()
        return Tween
    end
end

-- Lógica Principal
local function StartAutoQuest()
    while _G.AutoFarm do
        task.wait(1)
        
        -- 1. Ir até o NPC e Interagir
        To(_G.DistanciaNPC) 
        task.wait(2) -- Tempo para chegar
        
        -- Simula segurar a tecla E no ProximityPrompt
        local prompt = workspace:FindFirstChild("NPC_Quest_Name"):FindFirstChildOfClass("ProximityPrompt") -- Ajuste o nome do NPC
        if prompt then
            fireproximityprompt(prompt, 2) -- Segura por 2 segundos
        end
        
        -- 2. Aceitar a Missão via GUI
        local Player = game.Players.LocalPlayer
        local AcceptBtn = Player.PlayerGui:WaitForChild("QuestOptions"):WaitForChild("QuestFrame"):FindFirstChild("Accept")
        
        if AcceptBtn and AcceptBtn.Visible then
            -- Simula o clique no botão
            for _, v in pairs(getconnections(AcceptBtn.MouseButton1Click)) do
                v:Fire()
            end
        end
        
        -- 3. Ir até os Bandidos
        local BanditFolder = workspace.Visuals.More.Npcs.Enemy.Bandits
        for _, bandit in pairs(BanditFolder:GetChildren()) do
            if _G.AutoFarm and bandit:FindFirstChild("HumanoidRootPart") and bandit.Humanoid.Health > 0 then
                repeat
                    To(bandit.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)) -- Fica a 3 studs do inimigo
                    task.wait(0.1)
                until not _G.AutoFarm or bandit.Humanoid.Health <= 0
            end
        end
    end
end

-- Aba Principal no HUB
local MainTab = Window:CreateTab("Principal", 4483362458)

MainTab:CreateToggle({
   Name = "Auto Quest Level 0+",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoFarm = Value
      if Value then
          StartAutoQuest()
      end
   end,
})

Rayfield:Notify({
   Title = "Script Ativado",
   Content = "Boa sorte no farm!",
   Duration = 5,
   Image = 4483362458,
})
