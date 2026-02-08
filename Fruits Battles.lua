-- // 1. CONFIGURAÇÕES DE IDENTIFICAÇÃO (AJUSTE AQUI)
local NOME_SOCO = "Melee"   -- Coloque o nome do item de soco no seu inventário
local NOME_ESPADA = "Sword" -- Coloque o nome da sua espada no seu inventário

-- // 2. LIMPEZA E INICIALIZAÇÃO
local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
if pg:FindFirstChild("EliteHubV3") then pg:FindFirstChild("EliteHubV3"):Destroy() end

_G.AutoFarm = false
_G.Velocidade = 190
_G.ArmaSelecionada = "Soco"

-- // 3. INTERFACE ESTILO BLOX FRUIT (MAIOR)
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubV3"
sg.ResetOnSpawn = false

-- Botão de Abrir/Fechar com IMAGEM CUSTOMIZADA
local OpenBtn = Instance.new("ImageButton", sg)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.Image = "rbxassetid://128327214285742" -- Sua Imagem
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.BackgroundTransparency = 0.2
local CornerIcon = Instance.new("UICorner", OpenBtn)
CornerIcon.CornerRadius = UDim.new(0, 12)

-- Janela Principal
local MainFrame = Instance.new("Frame", sg)
MainFrame.Size = UDim2.new(0, 380, 0, 280) -- Um pouco maior
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Barra de Título
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Instance.new("UICorner", TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "ELITE HUB | AUTO QUEST"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

-- // 4. BOTÕES DE CONTROLE
-- Toggle Principal
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
FarmBtn.Text = "AUTO FARM [DESLIGADO]"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.GothamSemibold
FarmBtn.TextSize = 16
Instance.new("UICorner", FarmBtn)

-- Seletores de Arma
local SocoBtn = Instance.new("TextButton", MainFrame)
SocoBtn.Size = UDim2.new(0.43, 0, 0, 45)
SocoBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
SocoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
SocoBtn.Text = "SOCO"
SocoBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SocoBtn)

local EspadaBtn = Instance.new("TextButton", MainFrame)
EspadaBtn.Size = UDim2.new(0.43, 0, 0, 45)
EspadaBtn.Position = UDim2.new(0.52, 0, 0.5, 0)
EspadaBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
EspadaBtn.Text = "ESPADA"
EspadaBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", EspadaBtn)

local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.BackgroundTransparency = 1
Status.Text = "Aguardando início..."
Status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Status.Font = Enum.Font.Gotham

-- // 5. FUNÇÕES DE LÓGICA (CONSERTADAS)

-- Minimizar
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Seleção de Arma
SocoBtn.MouseButton1Click:Connect(function()
    _G.ArmaSelecionada = "Soco"
    SocoBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    EspadaBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
end)

EspadaBtn.MouseButton1Click:Connect(function()
    _G.ArmaSelecionada = "Espada"
    EspadaBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    SocoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
end)

local function Equipar()
    local nome = (_G.ArmaSelecionada == "Soco") and NOME_SOCO or NOME_ESPADA
    local tool = p.Backpack:FindFirstChild(nome) or p.Character:FindFirstChild(nome)
    if tool and tool.Parent ~= p.Character then
        p.Character.Humanoid:EquipTool(tool)
    end
end

local function To(target)
    local char = p.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local dist = (root.Position - target.Position).Magnitude
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = target})
        tween:Play()
        return tween
    end
end

-- Lógica de Farm Reforçada
local function AutoFarm()
    while _G.AutoFarm do
        task.wait(0.1)
        pcall(function()
            local qGui = pg:FindFirstChild("QuestOptions")
            
            -- 1. Verifica Quest
            if not qGui or not qGui.QuestFrame.Accept.Visible then
                Status.Text = "Buscando Missão..."
                local t = To(CFrame.new(-483.65, 31.39, -811.27))
                if t then t.Completed:Wait() end
                
                -- Tenta abrir o NPC
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and p:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(v, 2)
                        task.wait(0.5)
                        break
                    end
                end
                
                -- Clica em Aceitar
                if qGui and qGui.QuestFrame.Accept.Visible then
                    for _, c in pairs(getconnections(qGui.QuestFrame.Accept.MouseButton1Click)) do c:Fire() end
                end
            end

            -- 2. Atacar Bandidos
            local bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
            for _, b in pairs(bandits) do
                if _G.AutoFarm and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                    local bRoot = b:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        Status.Text = "Farmando: " .. b.Name
                        Equipar()
                        
                        -- Vai até o bandido
                        local move = To(bRoot.CFrame * CFrame.new(0, 0, 3))
                        if move then move.Completed:Wait() end
                        
                        repeat
                            if _G.AutoFarm and bRoot and b.Humanoid.Health > 0 then
                                p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                                -- Ataque
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                            end
                            task.wait(0.1)
                        until not _G.AutoFarm or b.Humanoid.Health <= 0 or not b.Parent
                    end
                end
            end
        end)
    end
    Status.Text = "Farm Desligado."
end

-- Iniciar
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM [LIGADO]" or "AUTO FARM [DESLIGADO]"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 120, 200) or Color3.fromRGB(35, 35, 45)
    if _G.AutoFarm then task.spawn(AutoFarm) end
end)
