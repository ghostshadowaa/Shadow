--[[ 
    SHADOW HUB V9 - AUTO FARM OPTIMIZED
    Missão: Levels. 0+ (Bandits)
    Executor: Delta / Fluxus / Arceus
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local parentGui = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

-- CONFIGURAÇÕES EXATAS DO USUÁRIO
local CHAVE = "Shadow"
local questNPC_CFrame = CFrame.new(-483.656006, 32.7710686, -810.33313)
local pastaBanditos = workspace:WaitForChild("Visuals"):WaitForChild("More"):WaitForChild("Npcs"):WaitForChild("Enemy"):WaitForChild("Bandits")

-- VARIÁVEIS DE CONTROLE
_G.AutoFarm = false

-- 1. LIMPEZA E UI (Botão de Abrir e Painel)
if parentGui:FindFirstChild("ShadowV9") then parentGui:FindFirstChild("ShadowV9"):Destroy() end

local screenGui = Instance.new("ScreenGui", parentGui)
screenGui.Name = "ShadowV9"

local abrirBtn = Instance.new("TextButton", screenGui)
abrirBtn.Size = UDim2.new(0, 100, 0, 40)
abrirBtn.Position = UDim2.new(0, 10, 0.5, -20)
abrirBtn.Text = "ABRIR HUB"
abrirBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200)
abrirBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
abrirBtn.Visible = false
Instance.new("UICorner", abrirBtn)

local hub = Instance.new("Frame", screenGui)
hub.Size = UDim2.new(0, 300, 0, 150)
hub.Position = UDim2.new(0.5, -150, 0.5, -75)
hub.BackgroundColor3 = Color3.fromRGB(5, 5, 40)
hub.Visible = false
Instance.new("UICorner", hub)

local farmBtn = Instance.new("TextButton", hub)
farmBtn.Size = UDim2.new(0, 200, 0, 50)
farmBtn.Position = UDim2.new(0.5, -100, 0.4, 0)
farmBtn.Text = "AUTO FARM: OFF"
farmBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
farmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", farmBtn)

-- LÓGICA DE INTERFACE
abrirBtn.MouseButton1Click:Connect(function()
    hub.Visible = not hub.Visible
    abrirBtn.Text = hub.Visible and "FECHAR" or "ABRIR"
end)

farmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    farmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(150, 0, 0)
end)

-- TELA DE KEY SIMPLIFICADA PARA TESTE
local keyF = Instance.new("Frame", screenGui)
keyF.Size = UDim2.new(0, 300, 0, 150)
keyF.Position = UDim2.new(0.5, -150, 0.5, -75)
keyF.BackgroundColor3 = Color3.fromRGB(10, 0, 30)

local kInp = Instance.new("TextBox", keyF)
kInp.Size = UDim2.new(0, 200, 0, 30)
kInp.Position = UDim2.new(0.5, -100, 0.3, 0)
kInp.PlaceholderText = "Key: Shadow"

local kVer = Instance.new("TextButton", keyF)
kVer.Size = UDim2.new(0, 100, 0, 30)
kVer.Position = UDim2.new(0.5, -50, 0.7, 0)
kVer.Text = "Verificar"

kVer.MouseButton1Click:Connect(function()
    if kInp.Text == CHAVE then
        keyF.Visible = false
        abrirBtn.Visible = true
        hub.Visible = true
    end
end)

-----------------------------------------------------------
-- LÓGICA DO AUTO FARM (O MOTOR DO SCRIPT)
-----------------------------------------------------------

-- Função para garantir que temos uma ferramenta na mão
local function equiparArma()
    local mochila = player.Backpack:GetChildren()
    local ferramenta = player.Character:FindFirstChildOfClass("Tool")
    
    if not ferramenta and #mochila > 0 then
        mochila[1].Parent = player.Character
    end
end

-- Função para clicar no botão Accept de forma invisível
local function clicarAceitar()
    local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
    if questGui and questGui.QuestFrame.Visible then
        local acceptBtn = questGui.QuestFrame:FindFirstChild("Accept")
        if acceptBtn then
            -- firesignal é um comando de executor (Delta) que clica sem precisar tocar
            if firesignal then
                firesignal(acceptBtn.MouseButton1Click)
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoFarm then
            pcall(function()
                local char = player.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
                
                -- PASSO 1: ACEITAR MISSÃO SE A JANELA ESTIVER ABERTA
                if questGui and questGui.QuestFrame.Visible then
                    clicarAceitar()
                    task.wait(0.5)
                end

                -- PASSO 2: PROCURAR INIMIGO VIVO
                local alvo = nil
                for _, inimigo in pairs(pastaBanditos:GetChildren()) do
                    if inimigo:FindFirstChild("Humanoid") and inimigo.Humanoid.Health > 0 then
                        alvo = inimigo
                        break
                    end
                end

                if alvo then
                    -- TELEPORTA PARA O BANDIDO (Atrás dele para segurança)
                    hrp.CFrame = alvo.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    equiparArma()
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                else
                    -- PASSO 3: IR ATÉ O NPC SE NÃO TIVER INIMIGO/MISSÃO
                    hrp.CFrame = questNPC_CFrame
                    
                    -- Interagir com o NPC usando comando de Executor (Delta)
                    for _, p in pairs(workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Parent:IsA("BasePart") then
                            if (p.Parent.Position - questNPC_CFrame.Position).Magnitude < 15 then
                                -- fireproximityprompt ignora o tempo de segurar
                                if fireproximityprompt then
                                    fireproximityprompt(p)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("✔️ Shadow Farm Bandits V9 Carregado!")