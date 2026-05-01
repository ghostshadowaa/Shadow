-- ============================================
-- GUI INTERFACE + ESP/AIMBOT FUNCIONAIS
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

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
        TeamCheck = true,
        MaxDistance = 1000
    },
    AIMBOT = {
        Enabled = false,
        TargetPart = "Head",
        FOV = 150,
        ShowFOV = true,
        Smoothness = 0.08,
        TeamCheck = true,
        WallCheck = false
    },
    CLIENT = {
        UnlockFPS = false,
        GodMode = false,
        HitboxExpanded = false,
        HitboxSize = Vector3.new(2, 2, 1),
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- ============================================
-- SISTEMA ESP FUNCIONAL
-- ============================================
local ESPObjects = {}

-- Limpar ESP antigo
local function ClearESP()
    for _, obj in pairs(ESPObjects) do
        for _, drawing in pairs(obj) do
            if typeof(drawing) == "Instance" then
                drawing:Destroy()
            end
        end
    end
    ESPObjects = {}
end

-- Criar ESP para um jogador
local function CreateESP(targetPlayer)
    if targetPlayer == player then return end
    if ESPObjects[targetPlayer] then return end
    
    local espContainer = {}
    
    -- ESP Box
    espContainer.Box = Drawing.new("Square")
    espContainer.Box.Visible = false
    espContainer.Box.Thickness = 2
    espContainer.Box.Color = Settings.ESP.Color
    espContainer.Box.Transparency = 0.7
    espContainer.Box.Filled = false
    
    -- ESP Box Filled (background)
    espContainer.BoxFilled = Drawing.new("Square")
    espContainer.BoxFilled.Visible = false
    espContainer.BoxFilled.Thickness = 1
    espContainer.BoxFilled.Color = Color3.new(0, 0, 0)
    espContainer.BoxFilled.Transparency = 0.3
    espContainer.BoxFilled.Filled = true
    
    -- ESP Skeleton lines
    espContainer.Skeleton = {}
    for i = 1, 10 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 1.5
        line.Color = Settings.ESP.Color
        line.Transparency = 0.8
        table.insert(espContainer.Skeleton, line)
    end
    
    -- Health Bar Background
    espContainer.HealthBg = Drawing.new("Square")
    espContainer.HealthBg.Visible = false
    espContainer.HealthBg.Thickness = 1
    espContainer.HealthBg.Color = Color3.new(0, 0, 0)
    espContainer.HealthBg.Filled = true
    
    -- Health Bar
    espContainer.HealthBar = Drawing.new("Square")
    espContainer.HealthBar.Visible = false
    espContainer.HealthBar.Thickness = 1
    espContainer.HealthBar.Color = Color3.new(0, 1, 0)
    espContainer.HealthBar.Filled = true
    
    -- Distance Text
    espContainer.Distance = Drawing.new("Text")
    espContainer.Distance.Visible = false
    espContainer.Distance.Size = 14
    espContainer.Distance.Color = Color3.new(1, 1, 1)
    espContainer.Distance.Outline = true
    espContainer.Distance.OutlineColor = Color3.new(0, 0, 0)
    espContainer.Distance.Center = true
    
    -- Name Text
    espContainer.Name = Drawing.new("Text")
    espContainer.Name.Visible = false
    espContainer.Name.Size = 16
    espContainer.Name.Color = Settings.ESP.Color
    espContainer.Name.Outline = true
    espContainer.Name.OutlineColor = Color3.new(0, 0, 0)
    espContainer.Name.Center = true
    
    -- Tracer Line
    espContainer.Tracer = Drawing.new("Line")
    espContainer.Tracer.Visible = false
    espContainer.Tracer.Thickness = 1
    espContainer.Tracer.Color = Settings.ESP.Color
    espContainer.Tracer.Transparency = 0.5
    
    ESPObjects[targetPlayer] = espContainer
end

-- Atualizar ESP
local function UpdateESP()
    for targetPlayer, esp in pairs(ESPObjects) do
        local character = targetPlayer.Character
        if not character then
            -- Esconder se não tiver personagem
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in pairs(obj) do line.Visible = false end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not hrp or not head then
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in pairs(obj) do line.Visible = false end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        -- Team Check
        if Settings.ESP.TeamCheck and targetPlayer.Team == player.Team then
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in pairs(obj) do line.Visible = false end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        -- Verificar distância
        local distance = (hrp.Position - Camera.CFrame.Position).Magnitude
        if distance > Settings.ESP.MaxDistance then
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in pairs(obj) do line.Visible = false end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        -- Calcular posição na tela
        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos, footOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        if not headOnScreen and not footOnScreen then
            for _, obj in pairs(esp) do
                if typeof(obj) == "table" then
                    for _, line in pairs(obj) do line.Visible = false end
                elseif obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
            continue
        end
        
        local boxHeight = math.abs(headPos.Y - footPos.Y)
        local boxWidth = boxHeight * 0.6
        local boxPosition = Vector2.new(
            math.clamp(headPos.X - boxWidth / 2, 0, Camera.ViewportSize.X),
            math.clamp(headPos.Y, 0, Camera.ViewportSize.Y)
        )
        
        -- ESP Box
        if Settings.ESP.Box then
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = boxPosition
            esp.Box.Color = Settings.ESP.Color
            esp.Box.Visible = true
            
            esp.BoxFilled.Size = Vector2.new(boxWidth, boxHeight)
            esp.BoxFilled.Position = boxPosition
            esp.BoxFilled.Visible = true
        else
            esp.Box.Visible = false
            esp.BoxFilled.Visible = false
        end
        
        -- ESP Skeleton
        if Settings.ESP.Skeleton then
            local joints = {
                head, -- Cabeça
                character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
                character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"),
                character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"),
                character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"),
                character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
                character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"),
            }
            
            local connections = {
                {1, 2}, -- Cabeça -> Torso
                {2, 3}, -- Torso -> LowerTorso
                {2, 4}, -- Torso -> Braço Esquerdo
                {4, 5}, -- Braço Esq -> Antebraço Esq
                {2, 6}, -- Torso -> Braço Direito
                {6, 7}, -- Braço Dir -> Antebraço Dir
                {3, 8}, -- LowerTorso -> Perna Esq
                {8, 9}, -- Coxa Esq -> Canela Esq
                {3, 10}, -- LowerTorso -> Perna Dir
                {10, 11}, -- Coxa Dir -> Canela Dir
            }
            
            for i, line in ipairs(esp.Skeleton) do
                if connections[i] then
                    local part1 = joints[connections[i][1]]
                    local part2 = joints[connections[i][2]]
                    if part1 and part2 then
                        local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                        local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                        if on1 and on2 then
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                            line.Color = Settings.ESP.Color
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(esp.Skeleton) do
                line.Visible = false
            end
        end
        
        -- ESP Health
        if Settings.ESP.Health then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barWidth = 4
            
            esp.HealthBg.Size = Vector2.new(barWidth, boxHeight)
            esp.HealthBg.Position = Vector2.new(boxPosition.X - barWidth - 2, boxPosition.Y)
            esp.HealthBg.Visible = true
            
            esp.HealthBar.Size = Vector2.new(barWidth, barHeight)
            esp.HealthBar.Position = Vector2.new(boxPosition.X - barWidth - 2, boxPosition.Y + (boxHeight - barHeight))
            esp.HealthBar.Color = Color3.new(1 - healthPercent, healthPercent, 0)
            esp.HealthBar.Visible = true
        else
            esp.HealthBg.Visible = false
            esp.HealthBar.Visible = false
        end
        
        -- ESP Distance
        if Settings.ESP.Distance then
            esp.Distance.Text = math.floor(distance) .. "m"
            esp.Distance.Position = Vector2.new(boxPosition.X + boxWidth / 2, boxPosition.Y + boxHeight + 2)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- ESP Name
        esp.Name.Text = targetPlayer.Name .. " [" .. math.floor(humanoid.Health) .. " HP]"
        esp.Name.Position = Vector2.new(boxPosition.X + boxWidth / 2, boxPosition.Y - 20)
        esp.Name.Color = Settings.ESP.Color
        esp.Name.Visible = true
        
        -- ESP Line (Tracer)
        if Settings.ESP.Line then
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(headPos.X, headPos.Y)
            esp.Tracer.Color = Settings.ESP.Color
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
    end
end

-- ============================================
-- SISTEMA AIMBOT FUNCIONAL
-- ============================================
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = false
FOV_Circle.Thickness = 1.5
FOV_Circle.Color = Color3.fromRGB(0, 150, 255)
FOV_Circle.Transparency = 0.5
FOV_Circle.Filled = false
FOV_Circle.NumSides = 64

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Settings.AIMBOT.FOV
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer == player then continue end
        
        local character = targetPlayer.Character
        if not character then continue end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local targetPart = character:FindFirstChild(Settings.AIMBOT.TargetPart)
        
        if not humanoid or humanoid.Health <= 0 or not targetPart then continue end
        
        -- Team Check
        if Settings.AIMBOT.TeamCheck and targetPlayer.Team == player.Team then continue end
        
        -- Wall Check
        if Settings.AIMBOT.WallCheck then
            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {Camera, character, player.Character}
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            local result = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
            if result and not result.Instance:IsDescendantOf(character) then continue end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < shortestDistance then
            closestPlayer = targetPlayer
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

local function Aimbot()
    if not Settings.AIMBOT.Enabled then return end
    
    local target = GetClosestPlayer()
    if not target then return end
    
    local character = target.Character
    local targetPart = character:FindFirstChild(Settings.AIMBOT.TargetPart)
    if not targetPart then return end
    
    local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    
    local moveVector = (Vector2.new(targetPos.X, targetPos.Y) - mousePos) * Settings.AIMBOT.Smoothness
    
    -- Mover mouse (simulação)
    mousemoverel(moveVector.X, moveVector.Y)
end

-- Atualizar FOV Circle
local function UpdateFOV()
    if Settings.AIMBOT.ShowFOV then
        FOV_Circle.Radius = Settings.AIMBOT.FOV
        FOV_Circle.Position = Vector2.new(mouse.X, mouse.Y)
        FOV_Circle.Visible = true
    else
        FOV_Circle.Visible = false
    end
end

-- ============================================
-- CRIAÇÃO DA INTERFACE GUI
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameMenuInterface"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

-- Botão de toggle (3 toques)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "TripleTapToggle"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0.95, -25, 0.1, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.Text = "☰"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.BorderSizePixel = 0
ToggleButton.Visible = false
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🔧 PAINEL DE CONTROLE"
TitleText.TextColor3 = Color3.fromRGB(0, 150, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Botão fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Container de abas
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(0, 120, 1, -50)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 10)
TabCorner.Parent = TabContainer

-- Container de conteúdo
local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentContainer

-- ============================================
-- FUNÇÕES UTILITÁRIAS DA GUI
-- ============================================

local function CreateToggle(parent, text, pos, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 40)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 25)
    toggleBtn.Position = UDim2.new(1, -55, 0.5, -12.5)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toggleBtn
    
    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            toggleBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
            toggleBtn.Text = "OFF"
        end
        if callback then callback(enabled) end
    end)
    
    return toggleBtn, frame
end

local function CreateSlider(parent, text, pos, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 50)
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    local value = default
    local dragging = false
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (pos * (max - min)))
            sliderFill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = text .. ": " .. value
            if callback then callback(value) end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return frame
end

-- ============================================
-- CRIAÇÃO DAS ABAS
-- ============================================

local Tabs = {}
local TabContents = {}

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, #Tabs * 45 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = TabContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Name = name .. "Content"
    content.Size = UDim2.new(1, -10, 1, -10)
    content.Position = UDim2.new(0, 5, 0, 5)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    content.Visible = false
    content.CanvasSize = UDim2.new(0, 0, 0, 400)
    content.Parent = ContentContainer
    
    table.insert(Tabs, btn)
    TabContents[name] = content
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        end
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        
        for _, cont in pairs(TabContents) do
            cont.Visible = false
        end
        content.Visible = true
    end)
    
    return content
end

-- ============================================
-- ABA: ESP
-- ============================================
local ESPContent = CreateTab("ESP", "👁️")

CreateToggle(ESPContent, "ESP Skeleton", UDim2.new(0.05, 0, 0, 10), function(enabled)
    Settings.ESP.Skeleton = enabled
    print("ESP Skeleton:", enabled)
end)

CreateToggle(ESPContent, "ESP Box", UDim2.new(0.05, 0, 0, 55), function(enabled)
    Settings.ESP.Box = enabled
    print("ESP Box:", enabled)
end)

CreateToggle(ESPContent, "ESP Health", UDim2.new(0.05, 0, 0, 100), function(enabled)
    Settings.ESP.Health = enabled
    print("ESP Health:", enabled)
end)

CreateToggle(ESPContent, "ESP Distance", UDim2.new(0.05, 0, 0, 145), function(enabled)
    Settings.ESP.Distance = enabled
    print("ESP Distance:", enabled)
end)

CreateToggle(ESPContent, "ESP Line (Tracers)", UDim2.new(0.05, 0, 0, 190), function(enabled)
    Settings.ESP.Line = enabled
    print("ESP Line:", enabled)
end)

CreateToggle(ESPContent, "Team Check", UDim2.new(0.05, 0, 0, 235), function(enabled)
    Settings.ESP.TeamCheck = enabled
    print("ESP Team Check:", enabled)
end)

CreateSlider(ESPContent, "Distância Máx", UDim2.new(0.05, 0, 0, 280), 100, 2000, 1000, function(value)
    Settings.ESP.MaxDistance = value
end)

-- Cores do ESP
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(0.9, 0, 0, 25)
ColorLabel.Position = UDim2.new(0.05, 0, 0, 335)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Cor do ESP:"
ColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorLabel.TextSize = 14
ColorLabel.Font = Enum.Font.GothamSemibold
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = ESPContent

local RedBtn = Instance.new("TextButton")
RedBtn.Size = UDim2.new(0.28, 0, 0, 30)
RedBtn.Position = UDim2.new(0.05, 0, 0, 365)
RedBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
RedBtn.Text = "Vermelho"
RedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RedBtn.TextSize = 12
RedBtn.Font = Enum.Font.GothamSemibold
RedBtn.Parent = ESPContent

local GreenBtn = Instance.new("TextButton")
GreenBtn.Size = UDim2.new(0.28, 0, 0, 30)
GreenBtn.Position = UDim2.new(0.36, 0, 0, 365)
GreenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
GreenBtn.Text = "Verde"
GreenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
GreenBtn.TextSize = 12
GreenBtn.Font = Enum.Font.GothamSemibold
GreenBtn.Parent = ESPContent

local BlueBtn = Instance.new("TextButton")
BlueBtn.Size = UDim2.new(0.28, 0, 0, 30)
BlueBtn.Position = UDim2.new(0.67, 0, 0, 365)
BlueBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BlueBtn.Text = "Azul"
BlueBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlueBtn.TextSize = 12
BlueBtn.Font = Enum.Font.GothamSemibold
BlueBtn.Parent = ESPContent

RedBtn.MouseButton1Click:Connect(function() Settings.ESP.Color = Color3.fromRGB(255, 0, 0) end)
GreenBtn.MouseButton1Click:Connect(function() Settings.ESP.Color = Color3.fromRGB(0, 255, 0) end)
BlueBtn.MouseButton1Click:Connect(function() Settings.ESP.Color = Color3.fromRGB(0, 150, 255) end)

-- ============================================
-- ABA: AIMBOT
-- ============================================
local AIMBOTContent = CreateTab("AIMBOT", "🎯")

CreateToggle(AIMBOTContent, "Ativar Aimbot", UDim2.new(0.05, 0, 0, 10), function(enabled)
    Settings.AIMBOT.Enabled = enabled
    print("Aimbot:", enabled)
end)

-- Seleção de parte
local PartLabel = Instance.new("TextLabel")
PartLabel.Size = UDim2.new(0.9, 0, 0, 25)
PartLabel.Position = UDim2.new(0.05, 0, 0, 55)
PartLabel.BackgroundTransparency = 1
PartLabel.Text = "Alvo:"
PartLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PartLabel.TextSize = 14
PartLabel.Font = Enum.Font.GothamSemibold
PartLabel.TextXAlignment = Enum.TextXAlignment.Left
PartLabel.Parent = AIMBOTContent

local HeadBtn = Instance.new("TextButton")
HeadBtn.Size = UDim2.new(0.43, 0, 0, 30)
HeadBtn.Position = UDim2.new(0.05, 0, 0, 85)
HeadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
HeadBtn.Text = "Cabeça"
HeadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadBtn.TextSize = 12
HeadBtn.Font = Enum.Font.GothamSemibold
HeadBtn.Parent = AIMBOTContent

local ChestBtn = Instance.new("TextButton")
ChestBtn.Size = UDim2.new(0.43, 0, 0, 30)
ChestBtn.Position = UDim2.new(0.52, 0, 0, 85)
ChestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
ChestBtn.Text = "Peito"
ChestBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ChestBtn.TextSize = 12
ChestBtn.Font = Enum.Font.GothamSemibold
ChestBtn.Parent = AIMBOTContent

HeadBtn.MouseButton1Click:Connect(function()
    Settings.AIMBOT.TargetPart = "Head"
    HeadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ChestBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
end)

ChestBtn.MouseButton1Click:Connect(function()
    Settings.AIMBOT.TargetPart = "HumanoidRootPart"
    ChestBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    HeadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
end)

CreateToggle(AIMBOTContent, "Mostrar FOV", UDim2.new(0.05, 0, 0, 125), function(enabled)
    Settings.AIMBOT.ShowFOV = enabled
    print("Show FOV:", enabled)
end)

CreateToggle(AIMBOTContent, "Team Check", UDim2.new(0.05, 0, 0, 170), function(enabled)
    Settings.AIMBOT.TeamCheck = enabled
    print("Aimbot Team Check:", enabled)
end)

CreateToggle(AIMBOTContent, "Wall Check", UDim2.new(0.05, 0, 0, 215), function(enabled)
    Settings.AIMBOT.WallCheck = enabled
    print("Wall Check:", enabled)
end)

CreateSlider(AIMBOTContent, "Tamanho FOV", UDim2.new(0.05, 0, 0, 260), 10, 500, 150, function(value)
    Settings.AIMBOT.FOV = value
end)

CreateSlider(AIMBOTContent, "Suavização", UDim2.new(0.05, 0, 0, 315), 1, 20, 8, function(value)
    Settings.AIMBOT.Smoothness = value / 100
end)

-- ============================================
-- ABA: SERVER
-- ============================================
local SERVERContent = CreateTab("SERVER", "🌐")

local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(0.9, 0, 0, 200)
InfoFrame.Position = UDim2.new(0.05, 0, 0, 10)
InfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
InfoFrame.BorderSizePixel = 0
InfoFrame.Parent = SERVERContent

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 10)
InfoCorner.Parent = InfoFrame

local PlayersLabel = Instance.new("TextLabel")
PlayersLabel.Size = UDim2.new(1, -20, 0, 30)
PlayersLabel.Position = UDim2.new(0, 10, 0, 10)
PlayersLabel.BackgroundTransparency = 1
PlayersLabel.Text = "👥 Players: Carregando..."
PlayersLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
PlayersLabel.TextSize = 16
PlayersLabel.Font = Enum.Font.GothamBold
PlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
PlayersLabel.Parent = InfoFrame

local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(1, -20, 0, 30)
PingLabel.Position = UDim2.new(0, 10, 0, 50)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "📡 Ping: Carregando..."
PingLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
PingLabel.TextSize = 16
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextXAlignment = Enum.TextXAlignment.Left
PingLabel.Parent = InfoFrame

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(1, -20, 0, 30)
FPSLabel.Position = UDim2.new(0, 10, 0, 90)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "🎮 FPS: Carregando..."
FPSLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
FPSLabel.TextSize = 16
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Parent = InfoFrame

local RegionLabel = Instance.new("TextLabel")
RegionLabel.Size = UDim2.new(1, -20, 0, 30)
RegionLabel.Position = UDim2.new(0, 10, 0, 130)
RegionLabel.BackgroundTransparency = 1
RegionLabel.Text = "🌍 Região: " .. game:GetService("LocalizationService").RobloxLocaleId
RegionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
RegionLabel.TextSize = 14
RegionLabel.Font = Enum.Font.GothamSemibold
RegionLabel.TextXAlignment = Enum.TextXAlignment.Left
RegionLabel.Parent = InfoFrame

local ServerTime = Instance.new("TextLabel")
ServerTime.Size = UDim2.new(1, -20, 0, 30)
ServerTime.Position = UDim2.new(0, 10, 0, 165)
ServerTime.BackgroundTransparency = 1
ServerTime.Text = "⏰ Tempo: 00:00"
ServerTime.TextColor3 = Color3.fromRGB(200, 200, 200)
ServerTime.TextSize = 14
ServerTime.Font = Enum.Font.GothamSemibold
ServerTime.TextXAlignment = Enum.TextXAlignment.Left
ServerTime.Parent = InfoFrame

-- Atualização em tempo real
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate > 1 then
        lastUpdate = tick()
        PlayersLabel.Text = "👥 Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
        PingLabel.Text = "📡 Ping: " .. math.floor(Stats.PerformanceStats.Ping:GetValue()) .. " ms"
        
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        FPSLabel.Text = "🎮 FPS: " .. fps
        
        local minutes = math.floor(workspace.DistributedGameTime / 60)
        local seconds = math.floor(workspace.DistributedGameTime % 60)
        ServerTime.Text = string.format("⏰ Tempo: %02d:%02d", minutes, seconds)
    end
end)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 35)
RefreshBtn.Position = UDim2.new(0.05, 0, 0, 220)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshBtn.Text = "🔄 Atualizar Dados"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 14
RefreshBtn.Font = Enum.Font.GothamSemibold
RefreshBtn.Parent = SERVERContent

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = RefreshBtn

RefreshBtn.MouseButton1Click:Connect(function()
    PlayersLabel.Text = "👥 Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    RefreshBtn.Text = "✅ Atualizado!"
    wait(1)
    RefreshBtn.Text = "🔄 Atualizar Dados"
end)

-- ============================================
-- ABA: CLIENT
-- ============================================
local CLIENTContent = CreateTab("CLIENT", "⚙️")

CreateToggle(CLIENTContent, "🔓 Unlock FPS", UDim2.new(0.05, 0, 0, 10), function(enabled)
    Settings.CLIENT.UnlockFPS = enabled
    if enabled then
        setfpscap(999)
        print("FPS Desbloqueado")
    else
        setfpscap(60)
        print("FPS Limitado a 60")
    end
end)

CreateToggle(CLIENTContent, "👑 God Mode", UDim2.new(0.05, 0, 0, 55), function(enabled)
    Settings.CLIENT.GodMode = enabled
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        if enabled then
            char.Humanoid.MaxHealth = math.huge
            char.Humanoid.Health = math.huge
        else
            char.Humanoid.MaxHealth = 100
            char.Humanoid.Health = 100
        end
    end
    print("God Mode:", enabled)
end)

local HitboxLabel = Instance.new("TextLabel")
HitboxLabel.Size = UDim2.new(0.9, 0, 0, 25)
HitboxLabel.Position = UDim2.new(0.05, 0, 0, 100)
HitboxLabel.BackgroundTransparency = 1
HitboxLabel.Text = "📦 Configurar Hitbox:"
HitboxLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
HitboxLabel.TextSize = 16
HitboxLabel.Font = Enum.Font.GothamBold
HitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
HitboxLabel.Parent = CLIENTContent

CreateToggle(CLIENTContent, "Hitbox Expandida", UDim2.new(0.05, 0, 0, 130), function(enabled)
    Settings.CLIENT.HitboxExpanded = enabled
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        if enabled then
            char.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
            char.HumanoidRootPart.Transparency = 0.7
        else
            char.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            char.HumanoidRootPart.Transparency = 1
        end
    end
    print("Hitbox Expanded:", enabled)
end)

CreateSlider(CLIENTContent, "Tamanho Hitbox", UDim2.new(0.05, 0, 0, 175), 1, 20, 2, function(value)
    Settings.CLIENT.HitboxSize = Vector3.new(value, value, value)
    if Settings.CLIENT.HitboxExpanded then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Size = Vector3.new(value, value, value)
        end
    end
end)

CreateSlider(CLIENTContent, "Velocidade", UDim2.new(0.05, 0, 0, 230), 16, 200, 16, function(value)
    Settings.CLIENT.WalkSpeed = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

CreateSlider(CLIENTContent, "Pulo", UDim2.new(0.05, 0, 0, 285), 50, 300, 50, function(value)
    Settings.CLIENT.JumpPower = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

-- ============================================
-- SISTEMA DE TOGGLE (3 TOQUES)
-- ============================================

local tapCount = 0
local lastTapTime = 0
local TAP_TIMEOUT = 0.5
local REQUIRED_TAPS = 3

UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if processed then return end
    
    local currentTime = tick()
    if currentTime - lastTapTime > TAP_TIMEOUT then
        tapCount = 0
    end
    
    tapCount = tapCount + 1
    lastTapTime = currentTime
    
    if tapCount >= REQUIRED_TAPS then
        tapCount = 0
        ToggleButton.Visible = not ToggleButton.Visible
        
        local feedback = Instance.new("TextLabel")
        feedback.Size = UDim2.new(0, 200, 0, 50)
        feedback.Position = UDim2.new(0.5, -100, 0.8, 0)
        feedback.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        feedback.Text = ToggleButton.Visible and "🔓 Menu Ativado" or "🔒 Menu Desativado"
        feedback.TextColor3 = Color3.fromRGB(255, 255, 255)
        feedback.TextSize = 18
        feedback.Font = Enum.Font.GothamBold
        feedback.Parent = ScreenGui
        
        local fbCorner = Instance.new("UICorner")
        fbCorner.CornerRadius = UDim.new(0, 10)
        fbCorner.Parent = feedback
        
        TweenService:Create(feedback, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(feedback, 1)
    end
end)

-- Triple-click para PC
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local currentTime = tick()
        if currentTime - lastTapTime > TAP_TIMEOUT then
            tapCount = 0
        end
        tapCount = tapCount + 1
        lastTapTime = currentTime
        
        if tapCount >= REQUIRED_TAPS then
            tapCount = 0
            ToggleButton.Visible = not ToggleButton.Visible
        end
    end
end)

-- ============================================
-- BOTÃO TOGGLE DO MENU
-- ============================================

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 350),
            Position = UDim2.new(0.5, -250, 0.5, -175)
        }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    wait(0.2)
    MainFrame.Visible = false
end)

-- ============================================
-- LOOP PRINCIPAL (ESP + AIMBOT)
-- ============================================

-- Criar ESP para jogadores existentes
for _, p in ipairs(Players:GetPlayers()) do
    CreateESP(p)
end

-- Criar ESP para novos jogadores
Players.PlayerAdded:Connect(function(newPlayer)
    CreateESP(newPlayer)
end)

-- Remover ESP quando jogador sai
Players.PlayerRemoving:Connect(function(removedPlayer)
    if ESPObjects[removedPlayer] then
        for _, obj in pairs(ESPObjects[removedPlayer]) do
            if typeof(obj) == "table" then
                for _, line in pairs(obj) do line:Remove() end
            elseif obj.Remove then
                obj:Remove()
            end
        end
        ESPObjects[removedPlayer] = nil
    end
end)

-- Loop de renderização
RunService.RenderStepped:Connect(function()
    -- Atualizar ESP
    pcall(UpdateESP)
    
    -- Atualizar Aimbot
    pcall(Aimbot)
    
    -- Atualizar FOV Circle
    pcall(UpdateFOV)
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

Tabs[1].BackgroundColor3 = Color3.fromRGB(0, 150, 255)
TabContents["ESP"].Visible = true

-- Notificação de inicialização
local Notif = Instance.new("Frame")
Notif.Size = UDim2.new(0, 300, 0, 60)
Notif.Position = UDim2.new(0.5, -150, 0, -70)
Notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Notif.BorderSizePixel = 0
Notif.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 12)
NotifCorner.Parent = Notif

local NotifStroke = Instance.new("UIStroke")
NotifStroke.Color = Color3.fromRGB(0, 150, 255)
NotifStroke.Thickness = 2
NotifStroke.Parent = Notif

local NotifText = Instance.new("TextLabel")
NotifText.Size = UDim2.new(1, -20, 1, 0)
NotifText.Position = UDim2.new(0, 10, 0, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = "✅ Interface Carregada!\nESP e Aimbot Ativos!\nToque 3x na tela para ativar o botão"
NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifText.TextSize = 14
NotifText.Font = Enum.Font.GothamSemibold
NotifText.Parent = Notif

TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0, 20)
}):Play()

wait(4)
TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, -150, 0, -70)
}):Play()
game:GetService("Debris"):AddItem(Notif, 1)

print("=== INTERFACE CARREGADA ===")
print("ESP e Aimbot funcionando!")
print("Toque 3 vezes na tela para mostrar/esconder o botão do menu")
