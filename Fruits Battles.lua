-- // CONFIGURAÇÕES TÉCNICAS (CONFORME SOLICITADO)
local NPC_CFRAME = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)
local CAMINHO_BANDIDOS = workspace.Visuals.More.Npcs.Enemy.Bandits

_G.AutoFarm = false
_G.Velocidade = 190
_G.ArmaSelecionada = "Soco"

local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
local TS = game:GetService("TweenService")

-- Limpeza de UI
if pg:FindFirstChild("EliteHubFinal") then pg.EliteHubFinal:Destroy() end

-- // INTERFACE ESTILO BLOX FRUITS
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubFinal"
sg.ResetOnSpawn = false

local OpenBtn = Instance.new("ImageButton", sg)
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
OpenBtn.Image = "rbxassetid://128327214285742"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", OpenBtn)

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 380, 0, 280)
Main.Position = UDim2.new(0.5, -190, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
Main.Draggable = true
Main.Active = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "ELITE HUB | QUEST 0+"
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title)

-- Botões
local function CreateBtn(text, pos, sizeX)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(sizeX, 0, 0, 45)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", b)
    return b
end

local FarmBtn = CreateBtn("AUTO FARM: OFF", UDim2.new(0.05, 0, 0.25, 0), 0.9)
local SocoBtn = CreateBtn("SOCO", UDim2.new(0.05, 0, 0.5, 0), 0.43)
local EspadaBtn = CreateBtn("ESPADA", UDim2.new(0.52, 0, 0.5, 0), 0.43)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.8, 0)
Status.Text = "Aguardando Comando..."
Status.TextColor3 = Color3.new(0.7, 0.7, 0.7)
Status.BackgroundTransparency = 1

-- Funções
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local function To(targetCF)
    local char = p.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - targetCF.Position).Magnitude
        local tween = TS:Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = targetCF})
        tween:Play()
        return tween
    end
end

local function Equipar()
    for _, tool in pairs(p.Backpack:GetChildren()) do
        if _G.ArmaSelecionada == "Soco" and (tool.Name:lower():find("melee") or tool.Name:lower():find("combat") or tool.Name:lower():find("soco")) then
            p.Character.Humanoid:EquipTool(tool)
        elseif _G.ArmaSelecionada == "Espada" and (tool.Name:lower():find("sword") or tool.Name:lower():find("espada")) then
            p.Character.Humanoid:EquipTool(tool)
        end
    end
end

-- // LOOP REESTRUTURADO
local function StartQuestFarm()
    while _G.AutoFarm do
        task.wait(0.1)
        pcall(function()
            local qFrame = pg:WaitForChild("QuestOptions"):WaitForChild("QuestFrame")
            
            -- 1. IR AO NPC (Usando CFrame)
            if not qFrame.Visible then
                Status.Text = "Indo ao NPC da Quest..."
                local t = To(NPC_CFRAME)
                if t then t.Completed:Wait() end
                
                -- Segurar E por 2 segundos (ProximityPrompt)
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and p:DistanceFromCharacter(prompt.Parent.WorldPivot.Position) < 15 then
                        fireproximityprompt(prompt, 2)
                        task.wait(2.2) -- Espera o tempo de segurar + lag
                        break
                    end
                end
                
                -- Clicar em Accept
                if qFrame.Visible then
                    Status.Text = "Aceitando Missão..."
                    for _, conn in pairs(getconnections(qFrame.Accept.MouseButton1Click)) do conn:Fire() end
                end
            end

            -- 2. IR AOS BANDIDOS (Caminho Fixo)
            if qFrame.Visible == false or qFrame.Parent.Visible then -- Se a quest foi aceita
                local bandits = CAMINHO_BANDIDOS:GetChildren()
                for _, bandit in pairs(bandits) do
                    if _G.AutoFarm and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                        local bRoot = bandit:FindFirstChild("HumanoidRootPart")
                        if bRoot then
                            Status.Text = "Em Combate: " .. bandit.Name
                            Equipar()
                            To(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
                            
                            repeat
                                if _G.AutoFarm and bRoot and bandit.Humanoid.Health > 0 then
                                    p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                                end
                                task.wait(0.1)
                            until not _G.AutoFarm or bandit.Humanoid.Health <= 0 or not bandit.Parent
                        end
                    end
                end
            end
        end)
    end
end

-- Ativação
SocoBtn.MouseButton1Click:Connect(function() 
    _G.ArmaSelecionada = "Soco" 
    Status.Text = "Arma: Soco Selecionado"
end)
EspadaBtn.MouseButton1Click:Connect(function() 
    _G.ArmaSelecionada = "Espada" 
    Status.Text = "Arma: Espada Selecionada"
end)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(35, 35, 45)
    if _G.AutoFarm then task.spawn(StartQuestFarm) end
end)
