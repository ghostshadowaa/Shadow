-- Shadow Hub: Premium Stealth & Agressive TP
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES DE LÓGICA
local States = { Farm = false }
local BaseCFrame = CFrame.new(-29.6688538, -1.23751986, 57.1520157, 0, -1, 0, 0, 0, -1, 1, 0, 0)
local SafeHeight = -1.23751986 
local npcFolder = workspace.Map.Zones.Field.NPC

-- --- INTERFACE VISUAL SHADOW HUB ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub"

-- Botão Flutuante (Estilo Sombra)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.BorderSizePixel = 0

local BtnCorner = Instance.new("UICorner", OpenBtn)
BtnCorner.CornerRadius = UDim.new(0, 10)

local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Thickness = 2
BtnStroke.Color = Color3.fromRGB(40, 40, 40)

-- Painel Principal Shadow
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
MainFrame.ClipsDescendants = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 15)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(60, 60, 60)

-- Título Shadow Hub
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1

-- Efeito de Abrir/Fechar
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame:TweenPosition(UDim2.new(0.5, -110, 0.5, -70), "Out", "Quad", 0.3, true)
    end
end)

-- Botões de Toggle (Estilo Stealth)
local function createToggle(name, pos, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.AutoButtonColor = false
    
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 10)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(45, 45, 45)

    btn.MouseButton1Click:Connect(function()
        States[key] = not States[key]
        if States[key] then
            btnStroke.Color = Color3.fromRGB(0, 120, 255) -- Azul para ON
            btn.TextColor3 = Color3.fromRGB(0, 180, 255)
        else
            btnStroke.Color = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

createToggle("AGRESSIVE FARM", UDim2.new(0, 15, 0, 55), "Farm")

-- --- LÓGICA DE COLETA AGRESSIVA ---
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

-- LOOP PRINCIPAL
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
