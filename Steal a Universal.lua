-- Shadow Hub | Versão Corrigida e Funcional
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local noclipActive = false
local antiHitActive = false
local isTweening = false
local spawnLocation = nil
local character = Player.Character or Player.CharacterAdded:Wait()

-- Corrigido: Localizar Spawn com segurança
local function findSpawnLocation()
    local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawn then
        spawnLocation = spawn.CFrame + Vector3.new(0, 3, 0)
    else
        spawnLocation = character:GetPivot()
    end
end

-- Sistema de Notificação (Melhorado)
local function showNotification(text, color)
    local sg = PlayerGui:FindFirstChild("ShadowHubV5")
    if not sg then return end
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 40)
    frame.Position = UDim2.new(0.5, -125, 0, -50)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = sg
    
    local corner = Instance.new("UICorner", frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color or Color3.fromRGB(170, 0, 255)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14

    TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -125, 0.1, 0)}):Play()
    task.delay(2.5, function()
        TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(0.5, -125, 0, -50)}):Play()
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- Anti-Hit Realista (God Mode em LocalScript é limitado, então usamos invisibilidade de colisão)
RunService.Stepped:Connect(function()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if antiHitActive or noclipActive then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Teleporte
local function teleportToSpawn()
    if isTweening or not spawnLocation then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    isTweening = true
    showNotification("Teleportando...", Color3.fromRGB(0, 170, 255))
    
    local tween = TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Quart), {CFrame = spawnLocation})
    tween:Play()
    tween.Completed:Connect(function() isTweening = false end)
end

-- Interface
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ShadowHubV5"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = Color3.fromRGB(170, 0, 255)
mainStroke.Thickness = 2

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB V7"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title)

-- Botões
local function createBtn(name, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.8, 0, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local noclipBtn = createBtn("Noclip: OFF", UDim2.new(0.1, 0, 0.25, 0), function()
    noclipActive = not noclipActive
    showNotification("Noclip " .. (noclipActive and "ON" or "OFF"))
end)

local antiHitBtn = createBtn("Anti-Hit: OFF", UDim2.new(0.1, 0, 0.45, 0), function()
    antiHitActive = not antiHitActive
    showNotification("Anti-Hit " .. (antiHitActive and "ON" or "OFF"))
end)

createBtn("Teleport Spawn", UDim2.new(0.1, 0, 0.65, 0), teleportToSpawn)

-- Botão de Abrir
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "SH"
OpenBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Loop de Personagem
Player.CharacterAdded:Connect(function(char)
    character = char
    findSpawnLocation()
end)

findSpawnLocation()
showNotification("Shadow Hub Carregado!", Color3.fromRGB(0, 255, 100))
