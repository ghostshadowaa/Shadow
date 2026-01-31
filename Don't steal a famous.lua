-- Shadow Hub: Premium Stealth & Agressive TP
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- CONFIGURAÇÕES DE LÓGICA
local States = { Farm = false }
local BaseCFrame = CFrame.new(-29.6688538, -1.23751986, 57.1520157, 0, -1, 0, 0, 0, -1, 1, 0, 0)
local SafeHeight = -1.23751986 
local npcFolder = workspace.Map.Zones.Field.NPC

-- --- INTERFACE VISUAL SHADOW HUB ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999 

-- --- TELA DE CARREGAMENTO (MANTIDA) ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 50)
LoadingFrame.Position = UDim2.new(0, 0, 0, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 1000

local LoaderTitle = Instance.new("TextLabel", LoadingFrame)
LoaderTitle.Size = UDim2.new(1, 0, 0, 100)
LoaderTitle.Position = UDim2.new(0, 0, 0.4, 0)
LoaderTitle.Text = "EXECUTANDO SHADOW HUB"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 22
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.ZIndex = 1001

local ProgressBarBack = Instance.new("Frame", LoadingFrame)
ProgressBarBack.Size = UDim2.new(0, 280, 0, 4)
ProgressBarBack.Position = UDim2.new(0.5, -140, 0.55, 0)
ProgressBarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProgressBarBack.BorderSizePixel = 0
ProgressBarBack.ZIndex = 1001

local ProgressBarFill = Instance.new("Frame", ProgressBarBack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 1002

-- --- INTERFACE PRINCIPAL (AJUSTADA) ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 175) -- Aumentado para o novo botão
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -87)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Função para Criar Botão de Alternância (Toggle)
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

-- Função para Criar Botão de Clique Único (Action)
local function createActionButton(name, pos, actionFunc)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(60, 60, 60)

    btn.MouseButton1Click:Connect(function()
        actionFunc()
        -- Efeito visual rápido de clique
        btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    end)
end

-- --- ADICIONANDO BOTÕES ---
createToggle("AGRESSIVE FARM", UDim2.new(0, 15, 0, 35), "Farm")

createActionButton("TELEPORT TO BASE", UDim2.new(0, 15, 0, 95), function()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = BaseCFrame
    end
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- SEQUÊNCIA DE CARREGAMENTO (MANTIDA) ---
task.spawn(function()
    ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quart", 2.5, true)
    for i = 1, 5 do
        LoaderTitle.TextTransparency = 0.5
        task.wait(0.25)
        LoaderTitle.TextTransparency = 0
        task.wait(0.25)
    end
    local fade = TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBack, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    fade:Play()
    fade.Completed:Wait()
    LoadingFrame.Visible = false
    OpenBtn.Visible = true
    MainFrame.Visible = true
end)

-- --- LÓGICA DE FARM (MANTIDA) ---
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
