-- Shadow Hub | Steal a Classic
-- Versão: 7.0 (Anti-Hit Avançado para FNAF + Spawn Base)
-- Data: 12/02/2024

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Variáveis de controle
local noclipActive = false
local antiHitActive = false
local isTweening = false
local baseCFrame = nil
local antiHitConnections = {}
local character = nil
local spawnLocation = nil

-- Encontrar local de spawn inicial
local function findSpawnLocation()
    -- Procurar por spawnpoints no mapa
    local spawns = Workspace:FindFirstChild("SpawnLocation") or 
                   Workspace:FindFirstChild("Spawn") or
                   Workspace:FindFirstChild("SpawnPoint")
    
    if spawns then
        if spawns:IsA("BasePart") then
            spawnLocation = spawns.CFrame
        elseif spawns:IsA("Model") then
            local primary = spawns:FindFirstChildWhichIsA("BasePart")
            if primary then
                spawnLocation = primary.CFrame
            end
        end
    end
    
    -- Se não encontrar, usar posição inicial do player
    if Player.Character then
        local root = Player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            baseCFrame = root.CFrame
            if not spawnLocation then
                spawnLocation = root.CFrame
            end
        end
    end
    
    -- Criar marcador visual para a base
    if spawnLocation then
        local marker = Instance.new("Part")
        marker.Name = "SpawnMarker"
        marker.Size = Vector3.new(4, 0.2, 4)
        marker.Position = spawnLocation.Position
        marker.Anchored = true
        marker.CanCollide = false
        marker.Transparency = 0.7
        marker.Material = EnumMaterial.Neon
        marker.Color = Color3.fromRGB(0, 255, 0)
        marker.Parent = Workspace
        
        local light = Instance.new("PointLight")
        light.Brightness = 2
        light.Range = 15
        light.Color = Color3.fromRGB(0, 255, 0)
        light.Parent = marker
    end
end

-- Sistema de notificação
local function showNotification(text, color)
    if not PlayerGui:FindFirstChild("ShadowHubV5") then return end
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 320, 0, 50)
    Notification.Position = UDim2.new(0.5, -160, 0.1, -60)
    Notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notification.BackgroundTransparency = 0.2
    Notification.Parent = PlayerGui:WaitForChild("ShadowHubV5")
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color or Color3.fromRGB(170, 0, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Notification
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = text
    TextLabel.TextColor3 = color or Color3.new(1, 1, 1)
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.Parent = Notification
    
    -- Animar entrada
    local tweenIn = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -160, 0.1, 0)
    })
    tweenIn:Play()
    
    -- Remover após 3 segundos
    task.delay(3, function()
        if Notification and Notification.Parent then
            local tweenOut = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -160, 0.1, -60)
            })
            tweenOut:Play()
            tweenOut.Completed:Connect(function()
                Notification:Destroy()
            end)
        end
    end)
end

-- ANTI-HIT AVANÇADO PARA FNAF
local function activateAntiHit()
    if not character then return end
    
    showNotification("🔒 Anti-Hit ATIVADO", Color3.fromRGB(255, 50, 50))
    
    -- 1. Proteção contra danos diretos
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Prevenir morte
        humanoid.Health = humanoid.MaxHealth
        
        -- Conectar para manter vida cheia
        table.insert(antiHitConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end))
        
        -- Prevenir estados negativos
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        
        -- Prevenir dano de todas as fontes
        local function preventDamage(damage)
            return 0
        end
        
        -- Sobrescrever método TakeDamage se existir
        if humanoid:FindFirstChild("TakeDamage") then
            humanoid.TakeDamage:Destroy()
        end
    end
    
    -- 2. Proteção contra colisões com inimigos
    table.insert(antiHitConnections, RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then return end
        
        -- Tornar todas as partes intangíveis
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CanTouch = false
                part.CanQuery = false
                part.Massless = true
                
                -- Remover forças físicas
                for _, force in pairs(part:GetChildren()) do
                    if force:IsA("BodyForce") or force:IsA("BodyVelocity") or force:IsA("BodyAngularVelocity") then
                        force:Destroy()
                    end
                end
            end
        end
        
        -- Detectar e evitar inimigos próximos
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= character then
                local humanoid = obj:FindFirstChild("Humanoid")
                if humanoid then
                    -- Imunidade a dano de inimigos
                    for _, part in pairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") and part:CanTouch(character:FindFirstChild("HumanoidRootPart")) then
                            part.CanTouch = false
                        end
                    end
                end
            end
        end
    end))
    
    -- 3. Campo de força visual (opcional)
    local forceField = Instance.new("ForceField")
    forceField.Visible = true
    forceField.Parent = character
    table.insert(antiHitConnections, forceField)
end

local function deactivateAntiHit()
    showNotification("🔓 Anti-Hit DESATIVADO", Color3.fromRGB(255, 255, 255))
    
    -- Limpar todas as conexões
    for _, connection in pairs(antiHitConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        elseif connection:IsA("Instance") then
            connection:Destroy()
        end
    end
    antiHitConnections = {}
    
    -- Restaurar estados do humanoid
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        
        -- Restaurar propriedades das partes
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                part.CanTouch = true
                part.CanQuery = true
                part.Massless = false
            end
        end
    end
end

-- Função para voltar à base (spawn)
local function teleportToSpawn()
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if isTweening then return end
    isTweening = true
    
    -- Usar spawnLocation como base
    local targetCFrame = spawnLocation or baseCFrame
    if not targetCFrame then
        showNotification("❌ Base não encontrada!", Color3.fromRGB(255, 50, 50))
        isTweening = false
        return
    end
    
    -- Calcular distância e tempo de tween
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local speed = 100 -- Unidades por segundo
    local duration = math.clamp(distance / speed, 0.5, 5)
    
    showNotification("🚀 Teleportando para spawn...", Color3.fromRGB(0, 170, 255))
    
    -- Criar efeito visual durante o teleporte
    local teleportEffect = Instance.new("Part")
    teleportEffect.Size = Vector3.new(5, 5, 5)
    teleportEffect.Position = root.Position
    teleportEffect.Anchored = true
    teleportEffect.CanCollide = false
    teleportEffect.Transparency = 0.5
    teleportEffect.Color = Color3.fromRGB(170, 0, 255)
    teleportEffect.Material = EnumMaterial.Neon
    teleportEffect.Parent = Workspace
    
    -- Animação de tween
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = targetCFrame
    })
    
    tween:Play()
    
    tween.Completed:Connect(function()
        isTweening = false
        teleportEffect:Destroy()
        showNotification("✅ Chegou no spawn!", Color3.fromRGB(0, 255, 0))
        
        -- Piscar o personagem por 1 segundo
        if character then
            local originalTransparency = {}
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    originalTransparency[part] = part.Transparency
                    part.Transparency = 0.5
                end
            end
            
            task.wait(1)
            
            for part, transparency in pairs(originalTransparency) do
                if part.Parent then
                    part.Transparency = transparency
                end
            end
        end
    end)
end

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Botão flutuante
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 65, 0, 65)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -32.5)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Image = "rbxassetid://3926305904"
OpenBtn.ImageRectOffset = Vector2.new(964, 324)
OpenBtn.ImageRectSize = Vector2.new(36, 36)
OpenBtn.ImageColor3 = Color3.fromRGB(170, 0, 255)
OpenBtn.Parent = ScreenGui

-- Efeitos do botão
local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = OpenBtn

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(170, 0, 255)
ButtonStroke.Thickness = 3
ButtonStroke.Parent = OpenBtn

-- Sistema de arrasto
local dragging, dragInput, dragStart, startPos
local dragSpeed = 0.5

local function update(input)
    local delta = (input.Position - dragStart) * dragSpeed
    local newPos = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
    
    -- Limitar ao espaço da tela
    newPos = UDim2.new(
        math.clamp(newPos.X.Scale, 0, 1),
        math.clamp(newPos.X.Offset, 0, ScreenGui.AbsoluteSize.X - OpenBtn.AbsoluteSize.X),
        math.clamp(newPos.Y.Scale, 0, 1),
        math.clamp(newPos.Y.Offset, 0, ScreenGui.AbsoluteSize.Y - OpenBtn.AbsoluteSize.Y)
    )
    
    OpenBtn.Position = newPos
end

OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
        
        -- Efeito de clique
        TweenService:Create(OpenBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 60, 0, 60)
        }):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(OpenBtn, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 65, 0, 65)
                }):Play()
            end
        end)
    end
end)

OpenBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)

-- Menu Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.05
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(170, 0, 255)
MainStroke.Thickness = 3
MainStroke.Parent = MainFrame

-- Cabeçalho
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔮 SHADOW HUB v7.0 🔮"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.Parent = TitleBar

-- Função para criar botões
local function createButton(text, pos, icon, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 55)
    btn.Position = pos
    btn.BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(50, 50, 50)
    btnStroke.Thickness = 2
    btnStroke.Parent = btn
    
    -- Ícone
    if icon then
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 28, 0, 28)
        Icon.Position = UDim2.new(1, -35, 0.5, -14)
        Icon.BackgroundTransparency = 1
        Icon.Image = icon
        Icon.Parent = btn
    end
    
    -- Efeito hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = color or Color3.fromRGB(25, 25, 25)
        }):Play()
    end)
    
    return btn
end

-- Criar botões
local BaseBtn = createButton("Teleport para Spawn", UDim2.new(0.05, 0, 0.15, 0), "rbxassetid://3926305904", Color3.fromRGB(30, 30, 100))
local NoclipBtn = createButton("🚫 Atravessar Parede: OFF", UDim2.new(0.05, 0, 0.3, 0), "rbxassetid://3926307971", Color3.fromRGB(30, 30, 30))
local AntiHitBtn = createButton("🛡️ Anti-Hit: OFF", UDim2.new(0.05, 0, 0.45, 0), "rbxassetid://3926305904", Color3.fromRGB(30, 30, 30))
local CloseBtn = createButton("❌ Fechar Menu", UDim2.new(0.05, 0, 0.75, 0), "rbxassetid://3926305904", Color3.fromRGB(60, 30, 30))

-- Botão de fechar no cabeçalho
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

-- Eventos dos botões
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        showNotification("Menu aberto", Color3.fromRGB(170, 0, 255))
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

BaseBtn.MouseButton1Click:Connect(function()
    teleportToSpawn()
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    
    if noclipActive then
        NoclipBtn.Text = "   ✅ Atravessar Parede: ON"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        showNotification("Noclip ativado", Color3.fromRGB(0, 255, 0))
    else
        NoclipBtn.Text = "   🚫 Atravessar Parede: OFF"
        NoclipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        showNotification("Noclip desativado", Color3.fromRGB(255, 50, 50))
    end
})

AntiHitBtn.MouseButton1Click:Connect(function()
    antiHitActive = not antiHitActive
    
    if antiHitActive then
        AntiHitBtn.Text = "   🛡️ Anti-Hit: ON"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        activateAntiHit()
    else
        AntiHitBtn.Text = "   🛡️ Anti-Hit: OFF"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        deactivateAntiHit()
    end
end)

-- Gerenciar noclip
RunService.Stepped:Connect(function()
    if noclipActive and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

-- Inicialização
character = Player.Character or Player.CharacterAdded:Wait()
findSpawnLocation()

Player.CharacterAdded:Connect(function(newChar)
    character = newChar
    task.wait(1)
    
    if antiHitActive then
        activateAntiHit()
    end
    
    -- Atualizar spawn se necessário
    findSpawnLocation()
end)

-- Notificação inicial
task.wait(1)
showNotification("✨ Shadow Hub v7.0 carregado!", Color3.fromRGB(170, 0, 255))

-- Limpeza
ScreenGui.Destroying:Connect(function()
    deactivateAntiHit()
end)