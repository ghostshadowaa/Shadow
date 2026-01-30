-- Shadow Hub: Premium Stealth & Agressive TP + Auto Upgrade
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES DE LÓGICA
local States = { Farm = false, Upgrade = false }
local BaseCFrame = CFrame.new(-29.6688538, -1.23751986, 57.1520157, 0, -1, 0, 0, 0, -1, 1, 0, 0)
local SafeHeight = -1.23751986 
local npcFolder = workspace.Map.Zones.Field.NPC
local slotsPath = workspace.Map.Plots.Plot2.Plot.Slots

-- --- INTERFACE VISUAL SHADOW HUB ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999

-- Botão Flutuante (Abre/Fecha)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)
local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Color = Color3.fromRGB(40, 40, 40)
BtnStroke.Thickness = 2

-- Painel Principal (Aumentado para caber o novo botão)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 60, 60)
MainStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1

-- Funções Visuais de Toggle
local function createToggle(name, pos, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(45, 45, 45)

    btn.MouseButton1Click:Connect(function()
        States[key] = not States[key]
        btn.TextColor3 = States[key] and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(200, 200, 200)
        btnStroke.Color = States[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 45)
    end)
end

createToggle("AGRESSIVE FARM", UDim2.new(0, 15, 0, 55), "Farm")
createToggle("AUTO UPGRADE (BASE)", UDim2.new(0, 15, 0, 110), "Upgrade")

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- LÓGICA DE UPGRADE ---
spawn(function()
    while true do
        task.wait(0.5) -- Delay para não sobrecarregar o servidor
        if States.Upgrade then
            for i = 1, 16 do
                local slot = slotsPath:FindFirstChild(tostring(i))
                if slot and slot:FindFirstChild("UpgradeSing") then
                    local upgradePart = slot.UpgradeSing
                    -- Simula o toque/clique no botão de upgrade
                    firetouchinterest(Player.Character.HumanoidRootPart, upgradePart, 0)
                    firetouchinterest(Player.Character.HumanoidRootPart, upgradePart, 1)
                    
                    -- Se houver ProximityPrompt no upgrade, ativa também
                    local prompt = upgradePart:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                end
            end
        end
    end
end)

-- --- LÓGICA DE FARM AGRESSIVO (MANTIDA) ---
local function AgressiveCollect(npc)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local npcRoot = npc:FindFirstChildWhichIsA("BasePart") or npc:FindFirstChild("HumanoidRootPart")
    if root and npcRoot then
        root.CFrame = CFrame.new(npcRoot.Position.X, SafeHeight, npcRoot.Position.Z)
        for i = 1, 5 do
            firetouchinterest(root, npcRoot, 0)
            firetouchinterest(root, npcRoot, 1)
            task.wait()
        end
        local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then fireproximityprompt(prompt) end
    end
end

spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm then
            local targetNPC = nil
            for _, v in pairs(npcFolder:GetChildren()) do
                if v:FindFirstChildWhichIsA("BasePart") or v:FindFirstChild("HumanoidRootPart") then
                    targetNPC = v
                    break
                end
            end
            if targetNPC then
                AgressiveCollect(targetNPC)
                task.wait(0.15) 
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = BaseCFrame end
                task.wait(0.4)
            end
        end
    end
end)
