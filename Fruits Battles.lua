-- // Proteção para não executar o script duas vezes
if _G.ScriptRodando then return end
_G.ScriptRodando = true

-- // Configurações Locais
local NPC_CF = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local TS = game:GetService("TweenService")

-- // Carregando a Library (Orion)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Elite Hub Local", HidePremium = false, SaveConfig = false})

-- // Função de Movimentação Otimizada
local function FlyTo(target)
    local char = LP.Character or LP.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local distance = (root.Position - target.Position).Magnitude
    local info = TweenInfo.new(distance / _G.Velocidade, Enum.EasingStyle.Linear)
    
    local tween = TS:Create(root, info, {CFrame = target})
    tween:Play()
    return tween
end

-- // Função Principal (Auto Quest)
local function StartQuest()
    while _G.AutoFarm do
        task.wait(0.5)
        pcall(function()
            -- 1. Verificar GUI de Quest
            local playerGui = LP:WaitForChild("PlayerGui")
            local questGui = playerGui:FindFirstChild("QuestOptions")
            
            -- Se a missão não estiver aceita (Botão Accept visível)
            if questGui and questGui.QuestFrame.Accept.Visible then
                -- Clica no botão
                local btn = questGui.QuestFrame.Accept
                for _, v in pairs(getconnections(btn.MouseButton1Click)) do v:Fire() end
            else
                -- 2. Se não tem missão, vai ao NPC
                local tw = FlyTo(NPC_CF)
                tw.Completed:Wait()
                
                -- Interage com o ProximityPrompt (Simula segurar E)
                -- Procura em um raio de 15 studs da CFrame do NPC
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and (v.Parent.WorldPivot.Position - NPC_CF.Position).Magnitude < 15 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
            end

            -- 3. Ir até os Bandidos
            local banditsPath = workspace:WaitForChild("Visuals"):WaitForChild("More"):WaitForChild("Npcs"):WaitForChild("Enemy"):WaitForChild("Bandits")
            local bandit = banditsPath:FindFirstChildOfClass("Model") -- Pega o primeiro bandido disponível
            
            if bandit and bandit:FindFirstChild("HumanoidRootPart") and bandit.Humanoid.Health > 0 then
                local bRoot = bandit.HumanoidRootPart
                local twB = FlyTo(bRoot.CFrame * CFrame.new(0, 0, 3))
                twB.Completed:Wait()
                
                -- Fica no bandido até ele morrer
                repeat
                    if _G.AutoFarm and bRoot then
                        LP.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                    end
                    task.wait(0.1)
                until not _G.AutoFarm or bandit.Humanoid.Health <= 0 or not bandit.Parent
            end
        end)
    end
end

-- // Interface
local Tab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483362458"})

_G.AutoFarm = false
_G.Velocidade = 150

Tab:AddToggle({
    Name = "Auto Quest Level 0+",
    Default = false,
    Callback = function(v)
        _G.AutoFarm = v
        if v then task.spawn(StartQuest) end
    end
})

Tab:AddSlider({
    Name = "Velocidade",
    Min = 50, Max = 400, Default = 150,
    Callback = function(v) _G.Velocidade = v end
})

OrionLib:Init()
