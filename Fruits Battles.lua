-- // 1. CONFIGURAÇÕES FIXAS (CFRAME QUE VOCÊ PASSOU)
local NPC_POSICAO = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

_G.AutoFarm = false
_G.Velocidade = 190
_G.ArmaSelecionada = "Soco"

local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
local TS = game:GetService("TweenService")

-- Limpeza de UI para evitar erro de duplicata
if pg:FindFirstChild("EliteHubV6") then pg.EliteHubV6:Destroy() end

-- // 2. INTERFACE (Nativa para evitar erro HTTP 404)
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubV6"
sg.ResetOnSpawn = false

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 360, 0, 260)
Main.Position = UDim2.new(0.5, -180, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local OpenBtn = Instance.new("ImageButton", sg)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -25)
OpenBtn.Image = "rbxassetid://128327214285742"
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "ELITE HUB | CORRIGIDO"
Title.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 50)
FarmBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
FarmBtn.Text = "AUTO FARM: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FarmBtn)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.85, 0)
Status.BackgroundTransparency = 1
Status.Text = "Aguardando..."
Status.TextColor3 = Color3.new(0.8, 0.8, 0.8)

-- // 3. FUNÇÕES CORRIGIDAS (ANTI-ERRO)

-- Função de Voo (Tween)
local function To(targetCF)
    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - targetCF.Position).Magnitude
        local tween = TS:Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = targetCF})
        tween:Play()
        return tween
    end
end

-- Equipar Arma (Busca Segura por nome)
local function Equipar()
    local char = p.Character
    if not char or char:FindFirstChildOfClass("Tool") then return end
    for _, tool in pairs(p.Backpack:GetChildren()) do
        local n = tool.Name:lower()
        if (_G.ArmaSelecionada == "Soco" and (n:find("melee") or n:find("combat") or n:find("soco"))) or
           (_G.ArmaSelecionada == "Espada" and (n:find("sword") or n:find("espada") or n:find("katana"))) then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

-- // 4. LOOP PRINCIPAL (Lógica de Missão e Farm)
local function StartFarm()
    while _G.AutoFarm do
        task.wait(0.1)
        pcall(function()
            local qOptions = pg:FindFirstChild("QuestOptions")
            local qFrame = qOptions and qOptions:FindFirstChild("QuestFrame")
            
            -- ETAPA 1: PEGAR MISSÃO
            -- Se não houver missão ativa ou a tela de aceitar estiver visível
            if not qFrame or qFrame.Visible == false then
                Status.Text = "Status: Indo ao NPC da Missão"
                local t = To(NPC_POSICAO)
                if t then t.Completed:Wait() end
                
                -- Procura o Prompt de interação próximo à CFrame
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local dist = (prompt.Parent:GetPivot().Position - NPC_POSICAO.Position).Magnitude
                        if dist < 15 then
                            fireproximityprompt(prompt)
                            task.wait(0.5)
                        end
                    end
                end
                
                -- Clica no botão Accept se a GUI abrir
                if qFrame and qFrame.Visible then
                    Status.Text = "Status: Aceitando Quest"
                    for _, c in pairs(getconnections(qFrame.Accept.MouseButton1Click)) do c:Fire() end
                end
            end

            -- ETAPA 2: MATAR BANDIDOS
            -- Busca a pasta de bandidos de forma segura (sem usar caminhos fixos que dão erro)
            local banditsFolder = nil
            for _, folder in pairs(workspace:GetDescendants()) do
                if folder:IsA("Folder") and folder.Name == "Bandits" then
                    banditsFolder = folder
                    break
                end
            end

            if banditsFolder then
                for _, b in pairs(banditsFolder:GetChildren()) do
                    if _G.AutoFarm and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                        local bRoot = b:FindFirstChild("HumanoidRootPart")
                        if bRoot then
                            Status.Text = "Status: Farmando " .. b.Name
                            Equipar()
                            To(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
                            
                            repeat
                                if _G.AutoFarm and bRoot and b.Humanoid.Health > 0 then
                                    p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                                end
                                task.wait(0.1)
                            until not _G.AutoFarm or b.Humanoid.Health <= 0 or not b.Parent
                        end
                    end
                end
            else
                Status.Text = "Status: Pasta de Bandidos não encontrada!"
            end
        end)
    end
    Status.Text = "Status: Farm Desligado"
end

-- Configuração dos Botões
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 50)
    if _G.AutoFarm then task.spawn(StartFarm) end
end)
