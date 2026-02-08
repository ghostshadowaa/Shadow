--[[ 
    SHADOW HUB V8 - VERSÃO ESTÁVEL DELTA
    - Botão de abertura em Texto (Garante visibilidade)
    - Auto Farm Bandits (CFrame Original)
    - Key: Shadow
]]

-- 1. CONFIGURAÇÕES E VARIÁVEIS
local player = game.Players.LocalPlayer
local parentGui = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")
local CHAVE = "Shadow"
local farmAtivo = false

-- CFRAME DO NPC DA MISSÃO (O que você enviou)
local questNPC_CFrame = CFrame.new(-483.656006, 32.7710686, -810.33313)

-- 2. LIMPEZA DE VERSÕES ANTIGAS
if parentGui:FindFirstChild("ShadowV8") then
    parentGui:FindFirstChild("ShadowV8"):Destroy()
end

-- 3. CRIAÇÃO DA UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowV8"
screenGui.Parent = parentGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- BOTÃO DE ABRIR/FECHAR (TEXTO PARA NÃO BUGAR)
local abrirBtn = Instance.new("TextButton", screenGui)
abrirBtn.Name = "AbrirBtn"
abrirBtn.Size = UDim2.new(0, 100, 0, 40)
abrirBtn.Position = UDim2.new(0, 10, 0.5, -20) -- Lado esquerdo, meio da tela
abrirBtn.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
abrirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
abrirBtn.Text = "ABRIR HUB"
abrirBtn.Visible = false -- Fica invisível até acertar a key
abrirBtn.ZIndex = 999
Instance.new("UICorner", abrirBtn)

-- TELA DE KEY
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 400, 0, 180)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -90)
keyFrame.BackgroundColor3 = Color3.fromRGB(11, 0, 49)
keyFrame.ZIndex = 1000

local keyInput = Instance.new("TextBox", keyFrame)
keyInput.Size = UDim2.new(0, 250, 0, 40)
keyInput.Position = UDim2.new(0.5, -125, 0.3, 0)
keyInput.PlaceholderText = "Digite a Key..."
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(8, 5, 89)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local verifyBtn = Instance.new("TextButton", keyFrame)
verifyBtn.Size = UDim2.new(0, 150, 0, 40)
verifyBtn.Position = UDim2.new(0.5, -75, 0.7, 0)
verifyBtn.Text = "Verificar"
verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 126, 255)
verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- PAINEL PRINCIPAL (HUB)
local hubFrame = Instance.new("Frame", screenGui)
hubFrame.Size = UDim2.new(0, 300, 0, 200)
hubFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
hubFrame.BackgroundColor3 = Color3.fromRGB(0, 8, 75)
hubFrame.Visible = false
hubFrame.ZIndex = 500
Instance.new("UICorner", hubFrame)

local farmBtn = Instance.new("TextButton", hubFrame)
farmBtn.Size = UDim2.new(0, 240, 0, 50)
farmBtn.Position = UDim2.new(0.5, -120, 0.3, 0)
farmBtn.Text = "Auto Farm: OFF"
farmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 120)
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", farmBtn)

-----------------------------------------------------------
-- 4. LÓGICA DO SCRIPT
-----------------------------------------------------------

-- Verificar Key
verifyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CHAVE then
        keyFrame.Visible = false
        abrirBtn.Visible = true -- APARECE O BOTÃO DE ABRIR
        hubFrame.Visible = true -- JÁ ABRE O HUB LOGO DE CARA
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "CHAVE INCORRETA!"
    end
end)

-- Abrir/Fechar Hub
abrirBtn.MouseButton1Click:Connect(function()
    hubFrame.Visible = not hubFrame.Visible
    abrirBtn.Text = hubFrame.Visible and "FECHAR HUB" or "ABRIR HUB"
end)

-- Botão de Farm
farmBtn.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    farmBtn.Text = farmAtivo and "Auto Farm: ON" or "Auto Farm: OFF"
    farmBtn.BackgroundColor3 = farmAtivo and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(20, 20, 120)
end)

-- Loop do Auto Farm (Executa no Delta)
task.spawn(function()
    while task.wait(0.1) do
        if farmAtivo then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- 1. ACEITAR MISSÃO
                local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
                if questGui and questGui.QuestFrame.Visible then
                    local acceptBtn = questGui.QuestFrame:FindFirstChild("Accept")
                    if acceptBtn and firesignal then
                        firesignal(acceptBtn.MouseButton1Click)
                    end
                end

                -- 2. BUSCAR INIMIGO
                local inimigosFolder = workspace.Visuals.More.Npcs.Enemy.Bandits
                local alvo = nil
                for _, enemy in pairs(inimigosFolder:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        alvo = enemy
                        break
                    end
                end

                if alvo then
                    -- Teleporta para o alvo
                    hrp.CFrame = alvo.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    -- Ataca com o que tiver na mão
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                else
                    -- Se não tem alvo, vai para o NPC
                    hrp.CFrame = questNPC_CFrame
                    -- Usa o executor para falar com o NPC
                    for _, p in pairs(workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and (p.Parent.Position - questNPC_CFrame.Position).Magnitude < 15 then
                            if fireproximityprompt then fireproximityprompt(p) end
                        end
                    end
                end
            end)
        end
    end
end)

print("Shadow Hub v8 Ativado!")