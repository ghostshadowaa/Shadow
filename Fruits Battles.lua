-- // CONFIGURAÇÕES
_G.AutoFarm = false
_G.Velocidade = 200
_G.Arma = "Soco"

local p = game.Players.LocalPlayer
local pg = p:WaitForChild("PlayerGui")

-- Interface Nativa (Para evitar o erro HTTP 404)
if pg:FindFirstChild("EliteHubV5") then pg.EliteHubV5:Destroy() end
local sg = Instance.new("ScreenGui", pg)
sg.Name = "EliteHubV5"
sg.ResetOnSpawn = false

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 350, 0, 250)
Main.Position = UDim2.new(0.5, -175, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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
Title.Text = "ELITE HUB | FIX CONSOLE"
Title.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
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
Status.TextColor3 = Color3.new(0.7, 0.7, 0.7)

-- // FUNÇÕES DE BUSCA SEGURA (Resolve o erro "not a valid member")
local function LocalizarNPC()
    -- Tenta pela CFrame que você mandou
    local npcPos = Vector3.new(-483.65, 31.39, -811.27)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
            if (v.HumanoidRootPart.Position - npcPos).Magnitude < 10 then
                return v.HumanoidRootPart
            end
        end
    end
    return nil
end

local function LocalizarPastaBandidos()
    -- Procura em todo o workspace para não dar erro de caminho
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Folder") and v.Name == "Bandits" then
            return v
        end
    end
    return nil
end

local function To(cf)
    local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - cf.Position).Magnitude
        local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(dist/_G.Velocidade, Enum.EasingStyle.Linear), {CFrame = cf})
        tween:Play()
        return tween
    end
end

-- // LOOP PRINCIPAL
local function Start()
    while _G.AutoFarm do
        task.wait(0.1)
        pcall(function()
            local qGui = pg:FindFirstChild("QuestOptions")
            
            -- Se não tem missão, vai ao NPC
            if not qGui or not qGui.QuestFrame.Accept.Visible then
                Status.Text = "Procurando NPC da Quest..."
                local npc = LocalizarNPC()
                if npc then
                    local t = To(npc.CFrame * CFrame.new(0, 0, 3))
                    if t then t.Completed:Wait() end
                    
                    -- Interação
                    for _, pmp in pairs(workspace:GetDescendants()) do
                        if pmp:IsA("ProximityPrompt") and p:DistanceFromCharacter(pmp.Parent.WorldPivot.Position) < 15 then
                            fireproximityprompt(pmp)
                            task.wait(0.5)
                        end
                    end
                    
                    -- Aceitar
                    if qGui and qGui.QuestFrame.Accept.Visible then
                        for _, c in pairs(getconnections(qGui.QuestFrame.Accept.MouseButton1Click)) do c:Fire() end
                    end
                end
            end

            -- Atacar Bandidos
            Status.Text = "Procurando Bandidos..."
            local pasta = LocalizarPastaBandidos()
            if pasta then
                for _, b in pairs(pasta:GetChildren()) do
                    if _G.AutoFarm and b:FindFirstChild("Humanoid") and b.Humanoid.Health > 0 then
                        local bRoot = b:FindFirstChild("HumanoidRootPart")
                        if bRoot then
                            Status.Text = "Atacando: " .. b.Name
                            To(bRoot.CFrame * CFrame.new(0, 0, 3)).Completed:Wait()
                            repeat
                                if bRoot and _G.AutoFarm then
                                    p.Character.HumanoidRootPart.CFrame = bRoot.CFrame * CFrame.new(0, 0, 3)
                                    game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                                end
                                task.wait(0.1)
                            until not _G.AutoFarm or b.Humanoid.Health <= 0
                        end
                    end
                end
            end
        end)
    end
end

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    if _G.AutoFarm then task.spawn(Start) end
end)
