-- Shadow Hub | Steal a Classic
-- Versão: 2.0 (Noclip Update)

local Player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Variáveis de estado
local noclipActive = false
local baseCFrame = nil

-- Função para capturar a base inicial
local function setInitialBase()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    baseCFrame = root.CFrame
end
setInitialBase()

-- 1. Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Botão de Abrir/Fechar
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 120, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Text = "Shadow Hub"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn)

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub | Steal a Classic"
Title.TextColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- 2. BOTÕES DE FUNÇÃO

-- Botão: Voltar para Base
local BaseBtn = Instance.new("TextButton")
BaseBtn.Size = UDim2.new(0.9, 0, 0, 45)
BaseBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
BaseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BaseBtn.Text = "Voltar para Base (TP)"
BaseBtn.TextColor3 = Color3.new(1, 1, 1)
BaseBtn.Font = Enum.Font.GothamSemibold
BaseBtn.Parent = MainFrame
Instance.new("UICorner", BaseBtn)

-- Botão: Noclip (Atravessar Parede)
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 45)
NoclipBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NoclipBtn.Text = "Atravessar parede: OFF"
NoclipBtn.TextColor3 = Color3.new(1, 1, 1)
NoclipBtn.Font = Enum.Font.GothamSemibold
NoclipBtn.Parent = MainFrame
Instance.new("UICorner", NoclipBtn)

--- LÓGICA DAS FUNÇÕES ---

-- Abrir/Fechar
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Teleporte
BaseBtn.MouseButton1Click:Connect(function()
    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = baseCFrame
    end
end)

-- Ativar/Desativar Noclip
NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    if noclipActive then
        NoclipBtn.Text = "Atravessar parede: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
    else
        NoclipBtn.Text = "Atravessar parede: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

-- Loop do Noclip (Executa a cada frame)
RunService.Stepped:Connect(function()
    if noclipActive then
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Garantir que a base seja resetada ao dar respawn (se desejar)
Player.CharacterAdded:Connect(function(char)
    -- Se quiser que a base mude para o novo local de nascimento, descomente a linha abaixo:
    -- baseCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end)
