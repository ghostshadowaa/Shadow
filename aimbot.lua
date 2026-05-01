-- ============================================
-- GUI INTERFACE + SISTEMAS (AIM/ESP/FOV)
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
        Skeleton = false,
        Box = false,
        Health = false,
        Distance = false,
        Line = false,
        Color = Color3.fromRGB(255, 0, 0),
        Transparency = 0.5
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
        HitboxSize = Vector3.new(2, 2, 1),
        HitboxExpanded = false
    }
}

-- Biblioteca de Desenho (Drawing) para os Visuais
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ============================================
-- LÓGICA CORE (AIMBOT E ESP)
-- ============================================

local function IsEnemy(target)
    if not Settings.AIMBOT.TeamCheck then return true end
    return target.Team ~= player.Team
end

local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Settings.AIMBOT.FOV

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player and v.Character and v.Character:FindFirstChild(Settings.AIMBOT.TargetPart) then
            if IsEnemy(v) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
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

-- Gerenciador de ESP para cada Player
local function AddESP(targetPlayer)
    local Box = Drawing.new("Square")
    local Line = Drawing.new("Line")
    local DistanceText = Drawing.new("Text")

    RunService.RenderStepped:Connect(function()
        if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Parent then
            local root = targetPlayer.Character.HumanoidRootPart
            local hum = targetPlayer.Character:FindFirstChild("Humanoid")
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            if onScreen and IsEnemy(targetPlayer) and hum and hum.Health > 0 then
                -- Configuração da Box
                if Settings.ESP.Box then
                    Box.Size = Vector2.new(2000 / pos.Z, 2500 / pos.Z)
                    Box.Position = Vector2.new(pos.X - Box.Size.X / 2, pos.Y - Box.Size.Y / 2)
                    Box.Color = Settings.ESP.Color
                    Box.Visible = true
                else Box.Visible = false end

                -- Configuração da Line
                if Settings.ESP.Line then
                    Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Line.To = Vector2.new(pos.X, pos.Y)
                    Line.Color = Settings.ESP.Color
                    Line.Visible = true
                else Line.Visible = false end

                -- Configuração de Distância/Vida
                if Settings.ESP.Distance or Settings.ESP.Health then
                    local dist = math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    DistanceText.Text = (Settings.ESP.Health and "HP: "..math.floor(hum.Health).." | " or "") .. (Settings.ESP.Distance and dist.."m" or "")
                    DistanceText.Position = Vector2.new(pos.X, pos.Y + (Box.Size.Y / 2))
                    DistanceText.Center = true
                    DistanceText.Outline = true
                    DistanceText.Size = 14
                    DistanceText.Visible = true
                else DistanceText.Visible = false end
            else
                Box.Visible = false Line.Visible = false DistanceText.Visible = false
            end
        else
            Box.Visible = false Line.Visible = false DistanceText.Visible = false
        end
    end)
end

-- ============================================
-- INTERFACE PRINCIPAL (SUA GUI ORIGINAL)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameMenuInterface"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "TripleTapToggle"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.95, -25, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- [CONTAINERS]
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)

local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 120, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

-- ============================================
-- FUNÇÕES DE CRIAÇÃO (SEU ESTILO)
-- ============================================

local function CreateToggle(parent, text, pos, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 50, 0, 25)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggleBtn.Text = "OFF"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 12)
    
    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleBtn.Text = enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 65)
        callback(enabled)
    end)
end

local function CreateSlider(parent, text, pos, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    
    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    
    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    
    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (pos * (max - min)))
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = text .. ": " .. val
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ============================================
-- CONFIGURAÇÃO DAS ABAS (MANTENDO SEU DESIGN)
-- ============================================

local TabButtons = {}
local TabFrames = {}

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, #TabButtons * 45 + 10)
    btn.Text = icon .. " " .. name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local frame = Instance.new("ScrollingFrame", ContentContainer)
    frame.Size = UDim2.new(1, -10, 1, -10)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.CanvasSize = UDim2.new(0,0,0,400)

    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(TabFrames) do v.Visible = false end
        frame.Visible = true
    end)

    table.insert(TabButtons, btn)
    table.insert(TabFrames, frame)
    return frame
end

-- [ABA ESP]
local ESPTab = CreateTab("ESP", "👁️")
CreateToggle(ESPTab, "ESP Box", UDim2.new(0.05,0,0,10), function(v) Settings.ESP.Box = v end)
CreateToggle(ESPTab, "ESP Line", UDim2.new(0.05,0,0,55), function(v) Settings.ESP.Line = v end)
CreateToggle(ESPTab, "ESP Distance", UDim2.new(0.05,0,0,100), function(v) Settings.ESP.Distance = v end)
CreateToggle(ESPTab, "ESP Health", UDim2.new(0.05,0,0,145), function(v) Settings.ESP.Health = v end)

-- [ABA AIMBOT]
local AimTab = CreateTab("AIM", "🎯")
CreateToggle(AimTab, "Ativar Aimbot", UDim2.new(0.05,0,0,10), function(v) Settings.AIMBOT.Enabled = v end)
CreateToggle(AimTab, "Mostrar FOV", UDim2.new(0.05,0,0,55), function(v) Settings.AIMBOT.ShowFOV = v end)
CreateSlider(AimTab, "Tamanho FOV", UDim2.new(0.05,0,0,100), 10, 500, 100, function(v) Settings.AIMBOT.FOV = v end)
CreateSlider(AimTab, "Suavização", UDim2.new(0.05,0,0,155), 1, 10, 5, function(v) Settings.AIMBOT.Smoothness = v/10 end)
CreateToggle(AimTab, "Team Check", UDim2.new(0.05,0,0,210), function(v) Settings.AIMBOT.TeamCheck = v end)

-- ============================================
-- LOOP DE EXECUÇÃO (O QUE FAZ TUDO FUNCIONAR)
-- ============================================

RunService.RenderStepped:Connect(function()
    -- Atualizar Círculo de FOV
    FOVCircle.Visible = Settings.AIMBOT.ShowFOV
    FOVCircle.Radius = Settings.AIMBOT.FOV
    FOVCircle.Position = UserInputService:GetMouseLocation()

    -- Lógica do Aimbot
    if Settings.AIMBOT.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local targetPos = target.Character[Settings.AIMBOT.TargetPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Settings.AIMBOT.Smoothness)
        end
    end
end)

-- Sistema de 3 Toques e Abrir Menu
local tapCount = 0
local lastTap = 0
UserInputService.TouchTapInWorld:Connect(function()
    if tick() - lastTap < 0.5 then tapCount = tapCount + 1 else tapCount = 1 end
    lastTap = tick()
    if tapCount >= 3 then ToggleButton.Visible = not ToggleButton.Visible end
end)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseButton.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Inicializar ESP para jogadores
for _, p in pairs(Players:GetPlayers()) do if p ~= player then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

TabFrames[1].Visible = true -- Mostra a primeira aba por padrão
print("Sistemas e GUI carregados com sucesso!")
