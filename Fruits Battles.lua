--[[
    Script: Auto Quest Level 0+
    Library: Orion Lib
    Status: Funcional (Mobile/PC)
]]

-- Garante que o jogo carregou antes de iniciar
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({
    Name = "Elite Hub | Auto Farm", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "EliteQuestConfig"
})

-- // Variáveis Globais \\ --
_G.AutoFarm = false
_G.TweenSpeed = 200
local NPC_CFrame = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

-- // Funções Utilitárias \\ --

local function SmoothTween(TargetCFrame)
    local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (root.Position - TargetCFrame.Position).Magnitude
        local info = TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear)
        local tween = game:GetService("TweenService"):Create(root, info, {CFrame = TargetCFrame})
        tween:Play()
        return tween
    end
end

-- // Loop Principal \\ --

local function MainLoop()
    while _G.AutoFarm do
        pcall(function()
            local lp = game.Players.LocalPlayer
            local gui = lp.PlayerGui:FindFirstChild("QuestOptions")
            
            -- Lógica: Aceitar Quest se não estiver ativa
            if not gui or not gui.QuestFrame.Accept.Visible then
                local tw = SmoothTween(NPC_CFrame)
                if tw then tw.Completed:Wait() end
                
                -- Interação com o ProximityPrompt
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and lp:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        task.wait(0.5)
                        break
                    end
                end
                
                -- Clique no Botão Aceitar
                if gui and gui.QuestFrame.Accept.Visible then
                    local btn = gui.QuestFrame.Accept
                    for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
                        conn:Fire()
                    end
                end
            end

            -- Lógica: Ir para os Bandidos
            local banditFolder = workspace.Visuals.More.Npcs.Enemy.Bandits
            for _, bandit in pairs(banditFolder:GetChildren()) do
                if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                    local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        -- Vai até o inimigo
                        local twB = SmoothTween(bRoot.CFrame * CFrame.new(0, 0, 3))
                        if twB then twB.Completed:Wait() end
                        
                        -- Fica no inimigo até ele morrer
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
        task.wait(1)
    end
end

-- // Interface \\ --

local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

FarmTab:AddToggle({
    Name = "Ativar Missão Bandidos (0+)",
    Default = false,
    Callback = function(Value)
        _G.AutoFarm = Value
        if Value then
            task.spawn(MainLoop)
        end
    end    
})

FarmTab:AddSlider({
    Name = "Velocidade do Voo",
    Min = 50,
    Max = 500,
    Default = 200,
    Color = Color3.fromRGB(0, 255, 100),
    Increment = 1,
    ValueName = "Vel",
    Callback = function(Value)
        _G.TweenSpeed = Value
    end    
})

OrionLib:Init()
