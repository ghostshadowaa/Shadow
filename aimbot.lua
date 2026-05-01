-- ============================================
-- SCRIPT EDUCACIONAL - GUI + SISTEMAS FUNCIONAIS
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================
local Settings = {
    ESP = {
        Box = false,
        Health = false,
        Distance = false,
        Line = false,
        Color = Color3.fromRGB(255, 0, 0),
    },
    AIMBOT = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 100,
        ShowFOV = false,
        Smoothness = 0.5,
        TeamCheck = true
    },
    CLIENT = {
        UnlockFPS = false,
        GodMode = false,
        HitboxExpanded = false,
        HitboxSize = 2
    }
}

-- Elementos do Desenho (Drawing API)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ============================================
-- LÓGICA DE SISTEMAS (BACKEND)
-- ============================================

local function isEnemy(targetPlayer)
    if not Settings.AIMBOT.TeamCheck then return true end
    return targetPlayer.Team ~= player.Team
end

local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Settings.AIMBOT.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(Settings.AIMBOT.TargetPart) then
            if isEnemy(v) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.AIMBOT.TargetPart].Position)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        target = v
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return target
end

local function CreateESP(targetPlayer)
    local Box = Drawing.new("Square")
    local Tracer = Drawing.new("Line")
    local Label = Drawing.new("Text")

    local function Update()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Parent ~= nil then
                local root = targetPlayer.Character.HumanoidRootPart
                local head = targetPlayer.Character:FindFirstChild("Head")
                local hum = targetPlayer.Character:FindFirstChild("Humanoid")
                
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen and isEnemy(targetPlayer) and hum and hum.Health > 0 then
                    -- ESP Box
                    if Settings.ESP.Box then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        Box.Size = Vector2.new(2000 / pos.Z, headPos.Y - legPos.Y)
                        Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                        Box.Color = Settings.ESP.Color
                        Box.Visible = true
                    else Box.Visible = false end

                    -- ESP Line
                    if Settings.ESP.Line then
                        Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        Tracer.To = Vector2.new(pos.X, pos.Y)
                        Tracer.Color = Settings.ESP.Color
                        Tracer.Visible = true
                    else Tracer.Visible = false end

                    -- ESP Info (Vida e Distância)
                    if Settings.ESP.Distance or Settings.ESP.Health then
                        local dist = math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                        Label.Text = (Settings.ESP.Health and "HP: "..math.floor(hum.Health).." | " or "") .. (Settings.ESP.Distance and dist.."m" or "")
                        Label.Position = Vector2.new(pos.X, pos.Y + 20)
                        Label.Center = true
                        Label.Size = 14
                        Label.Outline = true
                        Label.Color = Color3.new(1,1,1)
                        Label.Visible = true
                    else Label.Visible = false end
                else
                    Box.Visible = false Tracer.Visible = false Label.Visible = false
                end
            else
                Box.Visible = false Tracer.Visible = false Label.Visible = false
                if not targetPlayer.Parent then connection:Disconnect() end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- ============================================
-- CRIAÇÃO DA INTERFACE (FRONTEND)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameMenuInterface"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.95, -25, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.new(1,1,1)
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- [ELEMENTOS DE UI INTERNOS]
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.Parent = MainFrame

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentContainer.Parent = MainFrame

-- Funções de criação de botões (Reutilizando sua lógica)
local function CreateToggle(parent, text, pos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamSemibold
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 25)
    btn.Position = UDim2.new(1, -55, 0.5, -12.5)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60,60,65)
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = active and "ON" or "OFF"
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60,60,65)
        callback(active)
    end)
end

-- ============================================
-- ABAS E FUNÇÕES
-- ============================================

local ESPContent = Instance.new("ScrollingFrame", ContentContainer)
ESPContent.Size = UDim2.new(1,0,1,0)
ESPContent.BackgroundTransparency = 1

CreateToggle(ESPContent, "ESP Box", UDim2.new(0.05,0,0,10), function(v) Settings.ESP.Box = v end)
CreateToggle(ESPContent, "ESP Line", UDim2.new(0.05,0,0,55), function(v) Settings.ESP.Line = v end)
CreateToggle(ESPContent, "ESP Distance", UDim2.new(0.05,0,0,100), function(v) Settings.ESP.Distance = v end)
CreateToggle(ESPContent, "ESP Health", UDim2.new(0.05,0,0,145), function(v) Settings.ESP.Health = v end)

local AimContent = Instance.new("ScrollingFrame", ContentContainer)
AimContent.Size = UDim2.new(1,0,1,0)
AimContent.BackgroundTransparency = 1
AimContent.Visible = false

CreateToggle(AimContent, "Ativar Aimbot", UDim2.new(0.05,0,0,10), function(v) Settings.AIMBOT.Enabled = v end)
CreateToggle(AimContent, "Mostrar FOV", UDim2.new(0.05,0,0,55), function(v) Settings.AIMBOT.ShowFOV = v end)
CreateToggle(AimContent, "Team Check", UDim2.new(0.05,0,0,100), function(v) Settings.AIMBOT.TeamCheck = v end)

-- [LOOP PRINCIPAL DE ATUALIZAÇÃO]
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.AIMBOT.ShowFOV
    FOVCircle.Radius = Settings.AIMBOT.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    if Settings.AIMBOT.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local targetPos = target.Character[Settings.AIMBOT.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Settings.AIMBOT.Smoothness)
        end
    end
end)

-- Fechar e Abrir
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Sistema de 3 Toques (Triple Tap)
local tapCount = 0
local lastTap = 0
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if tick() - lastTap < 0.5 then
            tapCount = tapCount + 1
        else
            tapCount = 1
        end
        lastTap = tick()
        if tapCount >= 3 then
            ToggleButton.Visible = not ToggleButton.Visible
            tapCount = 0
        end
    end
end)

-- Inicialização
for _, p in pairs(Players:GetPlayers()) do if p ~= player then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

print("Interface Completa Carregada!")
