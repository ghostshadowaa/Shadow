-- Shadow Hub: Versão Corrigida
local Player = game.Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil

-- --- PROTEÇÃO CONTRA DUPLICAÇÃO ---
if PlayerGui:FindFirstChild("ShadowHub_Gomes") then
    PlayerGui.ShadowHub_Gomes:Destroy()
end

-- --- CRIAÇÃO DA GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHub_Gomes"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

-- --- 1. MENU PRINCIPAL (CRIADO PRIMEIRO) ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false -- Fica escondido até o loading acabar
MainFrame.ZIndex = 5
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 150, 255)
Stroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 180, 0, 45)
FarmBtn.Position = UDim2.new(0.5, -90, 0.6, -10)
FarmBtn.Text = "AUTO FARM: OFF"
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.TextColor3 = Color3.new(1, 1, 1)
FarmBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", FarmBtn)

-- --- 2. BOTÃO DE ABRIR (BOTÃO "S") ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Visible = false
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 20
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OStroke = Instance.new("UIStroke", OpenBtn)
OStroke.Color = Color3.fromRGB(0, 150, 255)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- 3. TELA DE CARREGAMENTO (SIMPLIFICADA) ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 50)
LoadingFrame.Position = UDim2.new(0, 0, 0, -25)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LoadingFrame.ZIndex = 10

local LTitle = Instance.new("TextLabel", LoadingFrame)
LTitle.Size = UDim2.new(1, 0, 1, 0)
LTitle.Text = "SHADOW HUB\nCARREGANDO..."
LTitle.Font = Enum.Font.GothamBold
LTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
LTitle.TextSize = 30
LTitle.BackgroundTransparency = 1

-- --- LÓGICA DE INICIALIZAÇÃO ---

-- Capturar Spawn
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    SavedSpawnCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end)

-- Timer de Loading (2 segundos apenas)
task.wait(2)
LoadingFrame:Destroy() -- Remove a tela preta
OpenBtn.Visible = true -- Mostra o botão "S"
MainFrame.Visible = true -- Abre o menu automaticamente na primeira vez

-- --- FUNÇÕES DOS BOTÕES ---
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.Text = States.Farm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.new(1, 1, 1)
end)
