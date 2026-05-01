-- ============================================
-- GUI INTERFACE - SCRIPT EDUCACIONAL
-- ============================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

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
        TargetPart = "Head", -- "Head" ou "HumanoidRootPart" (peito)
        FOV = 100,
        ShowFOV = false,
        Smoothness = 0.5,
        TeamCheck = true
    },
    CLIENT = {
        UnlockFPS = false,
        GodMode = false,
        HitboxSize = Vector3.new(2, 2, 1), -- Tamanho padrão
        HitboxExpanded = false
    }
}

-- ============================================
-- CRIAÇÃO DA INTERFACE PRINCIPAL
-- ============================================

-- ScreenGui principal
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
ToggleButton.Visible = false -- Inicia invisível
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleButton

-- Janela principal do menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainMenu"
MainFrame.Size = UDim2.new(0, 500, 0, 350)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false -- Inicia fechado
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

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
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
CloseButton.Name = "CloseBtn"
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
TabContainer.Name = "TabContainer"
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
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -140, 1, -50)
ContentContainer.Position = UDim2.new(0, 135, 0, 45)
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
ContentCorner.Parent = ContentContainer

-- ============================================
-- FUNÇÕES UTILITÁRIAS
-- ============================================

local function CreateButton(parent, text, pos, size)
    local btn = Instance.new("TextButton")
    btn.Size = size or UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    return btn
end

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
    sliderBg.Name = "SliderBg"
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
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
    content.CanvasSize = UDim2.new(0, 0, 0, 300)
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

-- Cor do ESP
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Size = UDim2.new(0.9, 0, 0, 25)
ColorLabel.Position = UDim2.new(0.05, 0, 0, 235)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "Cor do ESP:"
ColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
ColorLabel.TextSize = 14
ColorLabel.Font = Enum.Font.GothamSemibold
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = ESPContent

local RedBtn = CreateButton(ESPContent, "Vermelho", UDim2.new(0.05, 0, 0, 265), UDim2.new(0.28, 0, 0, 30))
RedBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

local GreenBtn = CreateButton(ESPContent, "Verde", UDim2.new(0.36, 0, 0, 265), UDim2.new(0.28, 0, 0, 30))
GreenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)

local BlueBtn = CreateButton(ESPContent, "Azul", UDim2.new(0.67, 0, 0, 265), UDim2.new(0.28, 0, 0, 30))
BlueBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

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

local HeadBtn = CreateButton(AIMBOTContent, "Cabeça", UDim2.new(0.05, 0, 0, 85), UDim2.new(0.43, 0, 0, 30))
local ChestBtn = CreateButton(AIMBOTContent, "Peito", UDim2.new(0.52, 0, 0, 85), UDim2.new(0.43, 0, 0, 30))

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

-- Selecionar cabeça por padrão
HeadBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

-- FOV
CreateToggle(AIMBOTContent, "Mostrar FOV", UDim2.new(0.05, 0, 0, 125), function(enabled)
    Settings.AIMBOT.ShowFOV = enabled
    print("Show FOV:", enabled)
end)

CreateSlider(AIMBOTContent, "Tamanho FOV", UDim2.new(0.05, 0, 0, 170), 10, 300, 100, function(value)
    Settings.AIMBOT.FOV = value
end)

CreateSlider(AIMBOTContent, "Suavização", UDim2.new(0.05, 0, 0, 225), 1, 10, 5, function(value)
    Settings.AIMBOT.Smoothness = value / 10
end)

CreateToggle(AIMBOTContent, "Team Check", UDim2.new(0.05, 0, 0, 280), function(enabled)
    Settings.AIMBOT.TeamCheck = enabled
    print("Team Check:", enabled)
end)

-- ============================================
-- ABA: SERVER
-- ============================================
local SERVERContent = CreateTab("SERVER", "🌐")

-- Info display frame
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

-- Botão atualizar
local RefreshBtn = CreateButton(SERVERContent, "🔄 Atualizar Dados", UDim2.new(0.05, 0, 0, 220), UDim2.new(0.9, 0, 0, 35))
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

RefreshBtn.MouseButton1Click:Connect(function()
    PlayersLabel.Text = "👥 Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
    -- Animação de refresh
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
        setfpscap(999) -- Remove limite de FPS
        print("FPS Desbloqueado")
    else
        setfpscap(60) -- Volta ao padrão
        print("FPS Limitado a 60")
    end
end)

CreateToggle(CLIENTContent, "👑 God Mode", UDim2.new(0.05, 0, 0, 55), function(enabled)
    Settings.CLIENT.GodMode = enabled
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = enabled and math.huge or 100
        char.Humanoid.Health = enabled and math.huge or 100
    end
    print("God Mode:", enabled)
end)

-- Hitbox Configuration
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
            -- Aumenta hitbox (torna mais difícil de ser acertado visualmente)
            -- Nota: Isso é visual apenas em muitos jogos
            local hrp = char.HumanoidRootPart
            hrp.Size = Vector3.new(10, 10, 10)
            hrp.Transparency = 0.7
        else
            local hrp = char.HumanoidRootPart
            hrp.Size = Vector3.new(2, 2, 1)
            hrp.Transparency = 1
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

-- WalkSpeed
CreateSlider(CLIENTContent, "Velocidade", UDim2.new(0.05, 0, 0, 230), 16, 200, 16, function(value)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end)

-- JumpPower
CreateSlider(CLIENTContent, "Pulo", UDim2.new(0.05, 0, 0, 285), 50, 300, 50, function(value)
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
local TAP_TIMEOUT = 0.5 -- Tempo máximo entre toques
local REQUIRED_TAPS = 3

-- Detecção de toques múltiplos
UserInputService.TouchTapInWorld:Connect(function(position, processed)
    if processed then return end
    
    local currentTime = tick()
    
    -- Reset se passou muito tempo
    if currentTime - lastTapTime > TAP_TIMEOUT then
        tapCount = 0
    end
    
    tapCount = tapCount + 1
    lastTapTime = currentTime
    
    if tapCount >= REQUIRED_TAPS then
        tapCount = 0
        ToggleButton.Visible = not ToggleButton.Visible
        
        -- Feedback visual
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
        
        -- Animação de fade out
        TweenService:Create(feedback, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
            TextTransparency = 1
        }):Play()
        
        game:GetService("Debris"):AddItem(feedback, 1)
    end
end)

-- Também funciona com clique do mouse (para testes no PC)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        -- Triple-click detection para PC
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
        -- Animação de entrada
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 350),
            Position = UDim2.new(0.5, -250, 0.5, -175)
        }):Play()
    end
end)

-- Botão fechar
CloseButton.MouseButton1Click:Connect(function()
    -- Animação de saída
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    
    wait(0.2)
    MainFrame.Visible = false
end)

-- ============================================
-- INICIALIZAÇÃO
-- ============================================

-- Seleciona primeira aba por padrão
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
NotifText.Text = "✅ Interface Carregada!\nToque 3x na tela para ativar o botão"
NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
NotifText.TextSize = 14
NotifText.Font = Enum.Font.GothamSemibold
NotifText.Parent = Notif

-- Animação de entrada da notificação
TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -150, 0, 20)
}):Play()

-- Remove notificação após 3 segundos
wait(3)
TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, -150, 0, -70)
}):Play()
game:GetService("Debris"):AddItem(Notif, 1)

print("=== INTERFACE CARREGADA ===")
print("Toque 3 vezes na tela para mostrar/esconder o botão do menu")
print("Clique no botão ☰ para abrir/fechar o menu principal")
