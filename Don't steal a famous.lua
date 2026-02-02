-- Shadow Hub: Gomes Elite (Fixed Animation & GUI)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES DE FARM
local States = { Farm = false }
local SavedSpawnCFrame = nil
local TweenSpeed = 100 
local AuraRadius = 15 

-- --- CAPTURA DE SPAWN ---
local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5)
    SavedSpawnCFrame = root.CFrame
end
Player.CharacterAdded:Connect(CaptureSpawn)
task.spawn(CaptureSpawn)

-- --- CRIAÇÃO DA INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Final_V3"
ScreenGui.ResetOnSpawn = false

-- TELA DE LOADING
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LoadingFrame.ZIndex = 100

local Title = Instance.new("TextLabel", LoadingFrame)
Title.Size = UDim2.new(1, 0, 0, 100)
Title.Position = UDim2.new(0, 0, 0.2, 0)
Title.Text = "SHADOW HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.TextSize = 50
Title.BackgroundTransparency = 1

-- O BONECO (Usaremos um ícone de pessoa/corredor padrão do Roblox)
local Runner = Instance.new("TextLabel", LoadingFrame)
Runner.Size = UDim2.new(0, 100, 0, 100)
Runner.Position = UDim2.new(-0.2, 0, 0.5, -50) -- Começa fora da tela
Runner.Text = "🏃" -- Emoji de corredor (funciona em todos os dispositivos)
Runner.TextSize = 80
Runner.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", LoadingFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 50)
StatusLabel.Position = UDim2.new(0, 0, 0.7, 0)
StatusLabel.Text = "CARREGANDO SISTEMAS..."
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.TextSize = 18
StatusLabel.BackgroundTransparency = 1

local BarBack = Instance.new("Frame", LoadingFrame)
BarBack.Size = UDim2.new(0, 300, 0, 6)
BarBack.Position = UDim2.new(0.5, -150, 0.8, 0)
BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBack.BorderSizePixel = 0

local BarFill = Instance.new("Frame", BarBack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
BarFill.BorderSizePixel = 0

-- --- MENU PRINCIPAL (ESCONDIDO NO INÍCIO) ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Visible = false -- Fica invisível até acabar o loading
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 150, 255)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false -- Começa fechado
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 200, 0, 50)
FarmBtn.Position = UDim2.new(0.5, -100, 0.5, -25)
FarmBtn.Text = "AUTO FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

-- --- LÓGICA DE ABRIR/FECHAR ---
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- ANIMAÇÃO DE CARREGAMENTO (BONECO CORRENDO) ---
task.spawn(function()
    -- Faz o corredor atravessar a tela
    TweenService:Create(Runner, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = UDim2.new(1.2, 0, 0.5, -50)}):Play()
    
    -- Faz a barra encher
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 4, true)
    
    local msgs = {"ESTABELECENDO CONEXÃO...", "LENDO MAPA...", "CARREGANDO SCRIPTS...", "PRONTO!"}
    for i, msg in ipairs(msgs) do
        StatusLabel.Text = msg
        task.wait(1)
    end
    
    -- Fade Out da tela de loading
    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(StatusLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(BarBack, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Runner, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    
    task.wait(0.6)
    LoadingFrame:Destroy()
    OpenBtn.Visible = true -- AGORA O BOTÃO APARECE!
end)

-- --- LÓGICA DO FARM (Simplificada para teste) ---
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.new(1,1,1)
    print("Farm status: ", States.Farm)
end)

-- O loop de farm deve ser adicionado abaixo conforme sua lógica anterior...
