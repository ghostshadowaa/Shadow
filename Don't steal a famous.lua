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

-- --- TELA DE CARREGAMENTO ESTILIZADA ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100

local Blur = Instance.new("BlurEffect", Lighting)
Blur.Size = 0

local LoaderContent = Instance.new("Frame", LoadingFrame)
LoaderContent.Size = UDim2.new(0, 300, 0, 100)
LoaderContent.Position = UDim2.new(0.5, -150, 0.5, -50)
LoaderContent.BackgroundTransparency = 1
LoaderContent.ZIndex = 101

local LoaderTitle = Instance.new("TextLabel", LoaderContent)
LoaderTitle.Size = UDim2.new(1, 0, 0, 40)
LoaderTitle.Text = "EXECUTANDO SHADOW HUB"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 20
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.ZIndex = 102

local ProgressBarBack = Instance.new("Frame", LoaderContent)
ProgressBarBack.Size = UDim2.new(0, 250, 0, 4)
ProgressBarBack.Position = UDim2.new(0.5, -125, 0.7, 0)
ProgressBarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ProgressBarBack.BorderSizePixel = 0
ProgressBarBack.ZIndex = 102

local ProgressBarFill = Instance.new("Frame", ProgressBarBack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0)
ProgressBarFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ProgressBarFill.BorderSizePixel = 0
ProgressBarFill.ZIndex = 103

local FillGlow = Instance.new("UIStroke", ProgressBarFill)
FillGlow.Color = Color3.fromRGB(0, 180, 255)
FillGlow.Thickness = 2

-- --- INTERFACE PRINCIPAL ---
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
local BtnStroke = Instance.new("UIStroke", OpenBtn)
BtnStroke.Color = Color3.fromRGB(40, 40, 40)
BtnStroke.Thickness = 2

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 140)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -70)
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

-- Funções Visuais
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
        if States[key] then
            btnStroke.Color = Color3.fromRGB(0, 120, 255)
            btn.TextColor3 = Color3.fromRGB(0, 180, 255)
        else
            btnStroke.Color = Color3.fromRGB(45, 45, 45)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

createToggle("AGRESSIVE FARM", UDim2.new(0, 15, 0, 55), "Farm")

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- LÓGICA DE CARREGAMENTO ---
task.spawn(function()
    TweenService:Create(Blur, TweenInfo.new(1), {Size = 20}):Play()
    task.wait(0.5)
    ProgressBarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 2, true)
    task.wait(2.2)
    
    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBarBack, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressBarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 0}):Play()
    
    task.wait(0.5)
    LoadingFrame:Destroy()
    Blur:Destroy()
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
