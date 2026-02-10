-- Shadow Hub | Steal a Classic
-- Versão: 3.0 (Tween + Anti-Hit Update)

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Variáveis de controle
local noclipActive = false
local isTweening = false
local baseCFrame = nil

-- Detectar Base inicial
local function setBase()
    local char = Player.Character or Player.CharacterAdded:Wait()
    baseCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end
setBase()

-- Interface
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHubV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 260)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub | Steal a Classic"
Title.TextColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Botão Abrir/Fechar
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 120, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Text = "Shadow Hub"
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn)

-- Botão Voltar Base (Tween)
local BaseBtn = Instance.new("TextButton")
BaseBtn.Size = UDim2.new(0.9, 0, 0, 45)
BaseBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
BaseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BaseBtn.Text = "Voltar para Base (Tween)"
BaseBtn.TextColor3 = Color3.new(1, 1, 1)
BaseBtn.Font = Enum.Font.GothamSemibold
BaseBtn.Parent = MainFrame
Instance.new("UICorner", BaseBtn)

-- Botão Atravessar Parede
local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 45)
NoclipBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
NoclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NoclipBtn.Text = "Atravessar parede: OFF"
NoclipBtn.TextColor3 = Color3.new(1, 1, 1)
NoclipBtn.Font = Enum.Font.GothamSemibold
NoclipBtn.Parent = MainFrame
Instance.new("UICorner", NoclipBtn)

--- LÓGICA ---

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sistema de Tween com Anti-Hit
BaseBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root and not isTweening then
        isTweening = true
        BaseBtn.Text = "ANTI-HIT ATIVADO..."
        BaseBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)

        -- Cálculo de distância para manter a velocidade constante
        local distance = (root.Position - baseCFrame.Position).Magnitude
        local speed = 50 -- Ajuste aqui (menor = mais devagar)
        local duration = distance / speed
        
        local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = baseCFrame})
        
        tween:Play()
        tween.Completed:Connect(function()
            isTweening = false
            BaseBtn.Text = "Voltar para Base (Tween)"
            BaseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        end)
    end
end)

-- Noclip Toggle
NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipBtn.Text = noclipActive and "Atravessar parede: ON" or "Atravessar parede: OFF"
    NoclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 30)
end)

-- Loop de Colisão (Noclip e Anti-Hit)
RunService.Stepped:Connect(function()
    -- Se o Noclip estiver ligado OU se estiver fazendo Tween (Anti-Hit)
    if noclipActive or isTweening then
        if Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    -- Opcional: descomente abaixo se quiser que a base mude para onde você renascer
    -- baseCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end)
