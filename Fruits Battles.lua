-- // 1. LIMPEZA E CONFIGURAÇÕES INICIAIS
local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
if pg:FindFirstChild("EliteHubV3") then pg:FindFirstChild("EliteHubV3"):Destroy() end

_G.AutoFarm = false
_G.Velocidade = 190
_G.ArmaSelecionada = "Soco" -- Padrão

-- // 2. INTERFACE ESTILO BLOX FRUITS
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubV3"
sg.ResetOnSpawn = false

-- Botão de Minimizar (Canto)
local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 60, 0, 30)
OpenBtn.Position = UDim2.new(0, 10, 0.1, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", OpenBtn)

-- Janela Principal (Maior)
local MainFrame = Instance.new("Frame", sg)
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 10)

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Instance.new("UICorner", TopBar)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ELITE HUB | AUTO FARM"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

-- // 3. BOTÕES E SELEÇÕES
-- Toggle Auto Farm
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 45)
FarmBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FarmBtn.Text = "Status: AUTO FARM [OFF]"
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", FarmBtn)

-- Seleção de Arma (Soco)
local SocoBtn = Instance.new("TextButton", MainFrame)
SocoBtn.Size = UDim2.new(0.42, 0, 0, 40)
SocoBtn.Position = UDim2.new(0.05, 0, 0.5, 0)
SocoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Verde pois começa selecionado
SocoBtn.Text = "Equipar: SOCO"
SocoBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", SocoBtn)

-- Seleção de Arma (Espada)
local EspadaBtn = Instance.new("TextButton", MainFrame)
EspadaBtn.Size = UDim2.new(0.42, 0, 0, 40)
EspadaBtn.Position = UDim2.new(0.53, 0, 0.5, 0)
EspadaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
EspadaBtn.Text = "Equipar: ESPADA"
EspadaBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", EspadaBtn)

-- Label de Informação
local InfoLabel = Instance.new("TextLabel", MainFrame)
InfoLabel.Size = UDim2.new(1, 0, 0, 30)
InfoLabel.Position = UDim2.new(0, 0, 0.8, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Selecione sua arma antes de iniciar"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 14

-- // 4. FUNÇÕES DE INTERAÇÃO
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

SocoBtn.MouseButton1Click:Connect(function()
    _G.ArmaSelecionada = "Soco"
    SocoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    EspadaBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)

EspadaBtn.MouseButton1Click:Connect(function()
    _G.ArmaSelecionada = "Espada"
    EspadaBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    SocoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
end)

local function EquiparArma()
    local toolName = (_G.ArmaSelecionada == "Soco") and "Melee" or "Sword" -- Ajuste o nome interno da espada se for diferente
    local tool = p.Backpack:FindFirstChild(toolName) or p.Character:FindFirstChild(toolName)
    
    if tool and not p.Character:FindFirstChild(toolName) then
        p.Character.Humanoid:EquipTool(tool)
    end
end

-- // 5. LÓGICA DE MOVIMENTO E FARM
local function To(target)
    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - target.Position).Magnitude
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = target})
        tween:Play()
        return tween
    end
end

local function AutoFarmLoop()
    while _G.AutoFarm do
        task.wait(0.2)
        pcall(function()
            local qGui = pg:FindFirstChild("QuestOptions")
            
            -- Equipar a arma escolhida
            EquiparArma()

            -- NPC / Quest
            if not qGui or not qGui.QuestFrame.Accept.Visible then
                InfoLabel.Text = "Indo buscar missão..."
                local t = To(CFrame.new(-483.65, 31.39, -811.27))
                if t then t.Completed:Wait() end
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and p:DistanceFromCharacter(v.Parent.WorldPivot.Position) < 12 then
                        fireproximityprompt(v, 2)
                        break
                    end
                end
                task.wait(0.5)
                if qGui and qGui.QuestFrame.Accept.Visible then
                    local accept = qGui.QuestFrame.Accept
                    for _, c in pairs(getconnections(accept.MouseButton1Click)) do c:Fire() end
                end
            end

            -- Matar Bandidos
            local bandits = workspace.Visuals.More.Npcs.Enemy.Bandits:GetChildren()
            for _, b in pairs(bandits) do
                if _G.AutoFarm and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                    local bRoot = b:FindFirstChild("HumanoidRootPart")
                    if bRoot then
                        InfoLabel.Text = "Farmando bandidos..."
                        To(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
                        repeat
                            if bRoot and _G.AutoFarm then
                                p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                                -- Simula o ataque
                                game:GetService("VirtualUser"):CaptureController()
                                game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
                            end
                            task.wait(0.1)
                        until not _G.AutoFarm or b.Humanoid.Health <= 0 or not b.Parent
                    end
                end
            end
        end)
    end
    InfoLabel.Text = "Auto Farm parado."
end

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "Status: AUTO FARM [ON]" or "Status: AUTO FARM [OFF]"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(40, 40, 50)
    if _G.AutoFarm then task.spawn(AutoFarmLoop) end
end)
