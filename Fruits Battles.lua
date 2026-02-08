-- // CONFIGURAÇÕES FIXAS
local NPC_POSICAO = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)

_G.AutoFarm = false
_G.Velocidade = 190
_G.ArmaSelecionada = "Soco"

local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")
local TS = game:GetService("TweenService")

-- Interface Nativa
if pg:FindFirstChild("EliteHubV7") then pg.EliteHubV7:Destroy() end
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubV7"
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
Title.Text = "ELITE HUB | FINAL FIX"
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
Status.Text = "Status: Aguardando..."
Status.TextColor3 = Color3.new(0.8, 0.8, 0.8)

-- // FUNÇÕES TÉCNICAS
local function To(targetCF)
    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - targetCF.Position).Magnitude
        local tween = TS:Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = targetCF})
        tween:Play()
        return tween
    end
end

local function Equipar()
    local char = p.Character
    if not char or char:FindFirstChildOfClass("Tool") then return end
    for _, tool in pairs(p.Backpack:GetChildren()) do
        local n = tool.Name:lower()
        if (_G.ArmaSelecionada == "Soco" and (n:find("melee") or n:find("combat") or n:find("soco"))) or
           (_G.ArmaSelecionada == "Espada" and (n:find("sword") or n:find("espada"))) then
            char.Humanoid:EquipTool(tool)
            break
        end
    end
end

-- // LOOP PRINCIPAL
local function StartFarm()
    while _G.AutoFarm do
        task.wait(0.1)
        pcall(function()
            -- Caminho exato da Quest que você passou
            local questPath = pg:FindFirstChild("QuestOptions")
            local questFrame = questPath and questPath:FindFirstChild("QuestFrame")
            local acceptBtn = questFrame and questFrame:FindFirstChild("Accept")

            -- 1. SE NÃO TIVER MISSÃO NA TELA, VAI AO NPC
            if not questFrame or questFrame.Visible == false then
                Status.Text = "Status: Indo ao NPC"
                local t = To(NPC_POSICAO)
                if t then t.Completed:Wait() end
                
                -- INTERAÇÃO COM PROXIMITYPROMPT (Segurando por 2s)
                for _, prompt in pairs(workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local dist = (prompt.Parent:GetPivot().Position - NPC_POSICAO.Position).Magnitude
                        if dist < 15 then
                            Status.Text = "Status: Segurando E..."
                            -- Simulação real de segurar o botão
                            prompt:InputHoldBegin()
                            task.wait(2.1) -- Segura o tempo necessário
                            prompt:InputHoldEnd()
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            -- 2. CLICAR NO ACEITAR (Caminho Específico)
            if questFrame and questFrame.Visible == true and acceptBtn then
                Status.Text = "Status: Clicando em Accept"
                -- Força o clique através de conexões de botão
                for _, connection in pairs(getconnections(acceptBtn.MouseButton1Click)) do
                    connection:Fire()
                end
                task.wait(1)
            end

            -- 3. FARM DE BANDIDOS (Se a missão sumiu da tela, significa que aceitou)
            if questFrame and questFrame.Visible == false then
                -- Busca segura da pasta de bandidos
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
                                Status.Text = "Status: Combatendo " .. b.Name
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
                end
            end
        end)
    end
    Status.Text = "Status: Farm Desligado"
end

-- Botão
FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(40, 40, 50)
    if _G.AutoFarm then task.spawn(StartFarm) end
end)
