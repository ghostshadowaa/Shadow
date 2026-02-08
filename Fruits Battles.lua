--[[ 
    SHADOW HUB V7 - ESTÁVEL PARA DELTA
    Instruções: Copie e cole no Delta. 
    Chave: Shadow
]]

-- Aguardar o jogo carregar
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Tentar usar CoreGui (comum em executores), se falhar usa PlayerGui
local parentGui = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

-- Limpar versões antigas para não duplicar
if parentGui:FindFirstChild("ShadowSystemV7") then
    parentGui:FindFirstChild("ShadowSystemV7"):Destroy()
end

-- 1. CRIAÇÃO DA UI BASE
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowSystemV7"
screenGui.Parent = parentGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 2. TELA DE KEY
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Name = "KeyFrame"
keyFrame.Size = UDim2.new(0, 400, 0, 200)
keyFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
keyFrame.BackgroundColor3 = Color3.fromRGB(11, 0, 49)
keyFrame.BorderSizePixel = 0
keyFrame.Active = true
keyFrame.Draggable = true -- Permite mover no mobile

local keyInput = Instance.new("TextBox", keyFrame)
keyInput.Size = UDim2.new(0, 250, 0, 40)
keyInput.Position = UDim2.new(0.5, -125, 0.4, -20)
keyInput.PlaceholderText = "Digite a Key..."
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(8, 5, 89)
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)

local verifyBtn = Instance.new("TextButton", keyFrame)
verifyBtn.Size = UDim2.new(0, 150, 0, 40)
verifyBtn.Position = UDim2.new(0.5, -75, 0.7, -20)
verifyBtn.Text = "Verificar"
verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 126, 255)
verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 3. PAINEL DE FUNÇÕES (HUB)
local mainHub = Instance.new("Frame", screenGui)
mainHub.Name = "MainHub"
mainHub.Size = UDim2.new(0, 350, 0, 250)
mainHub.Position = UDim2.new(0.5, -175, 0.5, -125)
mainHub.BackgroundColor3 = Color3.fromRGB(0, 8, 75)
mainHub.Visible = false
Instance.new("UICorner", mainHub)

local farmBtn = Instance.new("TextButton", mainHub)
farmBtn.Size = UDim2.new(0, 280, 0, 50)
farmBtn.Position = UDim2.new(0.5, -140, 0.2, 0)
farmBtn.Text = "Auto Farm: OFF"
farmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 120)
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", farmBtn)

-- 4. BOTÃO DE ABRIR/FECHAR (MASCOTE)
local toggleBtn = Instance.new("ImageButton", screenGui)
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Image = "rbxassetid://128327214285742"
toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Visible = false
local corner = Instance.new("UICorner", toggleBtn)
corner.CornerRadius = UDim.new(1, 0)

-----------------------------------------------------------
-- LÓGICA DO SCRIPT
-----------------------------------------------------------
local CHAVE = "Shadow"
local autoFarm = false
local questNPC_CFrame = CFrame.new(-483.656006, 32.7710686, -810.33313)

-- Verificação de Key
verifyBtn.MouseButton1Click:Connect(function()
    if keyInput.Text == CHAVE then
        keyFrame.Visible = false
        toggleBtn.Visible = true
        mainHub.Visible = true
        print("✅ Acesso Permitido!")
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "KEY INCORRETA!"
    end
end)

-- Toggle Hub
toggleBtn.MouseButton1Click:Connect(function()
    mainHub.Visible = not mainHub.Visible
end)

-- Auto Farm
farmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    farmBtn.Text = autoFarm and "Auto Farm: ON" or "Auto Farm: OFF"
    farmBtn.BackgroundColor3 = autoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(20, 20, 120)
end)

-- Loop do Farm
task.spawn(function()
    while task.wait() do
        if autoFarm then
            pcall(function()
                local char = player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- 1. Verificar Missão na GUI
                local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
                if questGui and questGui.QuestFrame.Visible then
                    local acceptBtn = questGui.QuestFrame:FindFirstChild("Accept")
                    if acceptBtn and firesignal then
                        firesignal(acceptBtn.MouseButton1Click)
                    end
                end

                -- 2. Procurar Inimigo
                local inimigosFolder = workspace.Visuals.More.Npcs.Enemy.Bandits
                local alvo = nil
                for _, enemy in pairs(inimigosFolder:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        alvo = enemy
                        break
                    end
                end

                if alvo then
                    -- Teleportar para o inimigo (atrás dele)
                    hrp.CFrame = alvo.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    -- Atacar
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then 
                        tool:Activate() 
                    end
                else
                    -- Se não tem inimigo, vai ao NPC da Quest
                    hrp.CFrame = questNPC_CFrame
                    -- Tentar interagir com ProximityPrompt (Delta)
                    for _, p in pairs(workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p:IsDescendantOf(workspace) then
                            if (p.Parent.Position - questNPC_CFrame.Position).Magnitude < 15 then
                                if fireproximityprompt then fireproximityprompt(p) end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("Shadow Hub v7 Carregado com Sucesso!")