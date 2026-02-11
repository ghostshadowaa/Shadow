-- Shadow Hub | Steal a Classic
-- Versão: 6.0 (Anti-Hit Avançado + Otimizações)
-- Data: 12/02/2024

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Variáveis de controle
local noclipActive = false
local antiHitActive = false
local isTweening = false
local baseCFrame = nil
local antiHitConnection = nil
local noclipConnection = nil
local character = nil

-- Sistema de notificação
local function showNotification(text, color)
    local Notification = Instance.new("TextLabel")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 300, 0, 40)
    Notification.Position = UDim2.new(0.5, -150, 0.1, 0)
    Notification.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notification.BackgroundTransparency = 0.3
    Notification.Text = "   " .. text
    Notification.TextColor3 = color or Color3.new(1, 1, 1)
    Notification.Font = Enum.Font.GothamBold
    Notification.TextSize = 14
    Notification.TextXAlignment = Enum.TextXAlignment.Left
    Notification.Visible = true
    Notification.Parent = PlayerGui:WaitForChild("ShadowHubV5")
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Notification
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = color or Color3.fromRGB(170, 0, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Notification
    
    -- Animar entrada
    Notification.Position = UDim2.new(0.5, -150, 0, -50)
    local tweenIn = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -150, 0.1, 0)
    })
    tweenIn:Play()
    
    -- Remover após 3 segundos
    task.wait(3)
    
    local tweenOut = TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
        Position = UDim2.new(0.5, -150, 0, -50)
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function()
        Notification:Destroy()
    end)
end

-- Detectar e gerenciar personagem
local function setupCharacter()
    character = Player.Character or Player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Definir base inicial
    local root = character:WaitForChild("HumanoidRootPart")
    baseCFrame = root.CFrame
    
    -- Configurar anti-hit se estiver ativo
    if antiHitActive then
        activateAntiHit()
    end
    
    return character
end

-- Configurar anti-hit avançado
local function activateAntiHit()
    if not character then return end
    
    -- Remover conexão anterior se existir
    if antiHitConnection then
        antiHitConnection:Disconnect()
        antiHitConnection = nil
    end
    
    -- Prevenir dano de diversas fontes
    antiHitConnection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then 
            antiHitConnection:Disconnect()
            return 
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and root then
            -- Manter vida no máximo
            humanoid.Health = humanoid.MaxHealth
            
            -- Prevenir estados negativos
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            
            -- Remover forças externas
            for _, force in pairs(root:GetChildren()) do
                if force:IsA("BodyForce") or force:IsA("BodyVelocity") or force:IsA("BodyAngularVelocity") then
                    force:Destroy()
                end
            end
        end
    end)
    
    -- Proteção contra danos diretos
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Massless = true
        end
    end
end

local function deactivateAntiHit()
    if antiHitConnection then
        antiHitConnection:Disconnect()
        antiHitConnection = nil
    end
    
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            -- Restaurar estados
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
end

-- Sistema de Noclip otimizado
local function manageNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if noclipActive then
        noclipConnection = RunService.Stepped:Connect(function()
            if character and character:IsDescendantOf(workspace) then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                        part.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end
        end)
    end
end

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Botão flutuante estilizado
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -30)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenBtn.Image = "rbxassetid://3926305904"
OpenBtn.ImageRectOffset = Vector2.new(964, 324)
OpenBtn.ImageRectSize = Vector2.new(36, 36)
OpenBtn.Parent = ScreenGui

-- Efeitos visuais do botão
local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = OpenBtn

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(170, 0, 255)
ButtonStroke.Thickness = 3
ButtonStroke.Parent = OpenBtn

local ButtonShadow = Instance.new("ImageLabel")
ButtonShadow.Name = "ButtonShadow"
ButtonShadow.Size = UDim2.new(1, 20, 1, 20)
ButtonShadow.Position = UDim2.new(0, -10, 0, -10)
ButtonShadow.BackgroundTransparency = 1
ButtonShadow.Image = "rbxassetid://5554236805"
ButtonShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
ButtonShadow.ImageTransparency = 0.8
ButtonShadow.ScaleType = Enum.ScaleType.Slice
ButtonShadow.SliceCenter = Rect.new(23, 23, 277, 277)
ButtonShadow.Parent = OpenBtn

-- Sistema de arrasto melhorado
local dragging, dragInput, dragStart, startPos
local dragSpeed = 0.5

local function update(input)
    local delta = (input.Position - dragStart) * dragSpeed
    OpenBtn.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = OpenBtn.Position
        
        -- Efeito visual ao pressionar
        TweenService:Create(OpenBtn, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 55, 0, 55)
        }):Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(OpenBtn, TweenInfo.new(0.1), {
                    Size = UDim2.new(0, 60, 0, 60)
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
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(170, 0, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Cabeçalho do menu
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SHADOW HUB v6.0 ⚡"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = TitleBar

-- Função para criar botões do menu
local function createButton(text, pos, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.Text = "   " .. text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(40, 40, 40)
    btnStroke.Thickness = 1
    btnStroke.Parent = btn
    
    -- Ícone do botão
    if icon then
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.Position = UDim2.new(1, -32, 0.5, -12)
        Icon.BackgroundTransparency = 1
        Icon.Image = icon
        Icon.Parent = btn
    end
    
    -- Efeito hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        }):Play()
    end)
    
    return btn
end

-- Botões do menu
local BaseBtn = createButton("Voltar para Base", UDim2.new(0.05, 0, 0.15, 0), "rbxassetid://3926307971")
local NoclipBtn = createButton("Atravessar Parede: OFF", UDim2.new(0.05, 0, 0.3, 0), "rbxassetid://3926305904")
local AntiHitBtn = createButton("Anti-Hit: OFF", UDim2.new(0.05, 0, 0.45, 0), "rbxassetid://3926305904")
local SetBaseBtn = createButton("Definir Nova Base", UDim2.new(0.05, 0, 0.6, 0), "rbxassetid://3926305904")
local CloseBtn = createButton("Fechar Menu", UDim2.new(0.05, 0, 0.75, 0), "rbxassetid://3926305904")

-- Botão para fechar o menu
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseButton

-- Lógica dos botões
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
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root and not isTweening and baseCFrame then
        isTweening = true
        BaseBtn.Text = "   Teleportando..."
        
        local distance = (root.Position - baseCFrame.Position).Magnitude
        local speed = 50
        local tweenTime = math.clamp(distance / speed, 1, 10)
        
        local tween = TweenService:Create(root, TweenInfo.new(tweenTime, Enum.EasingStyle.Quad), {
            CFrame = baseCFrame
        })
        
        tween:Play()
        showNotification("Teleportando para base...", Color3.fromRGB(0, 170, 255))
        
        tween.Completed:Connect(function()
            isTweening = false
            BaseBtn.Text = "   Voltar para Base"
            showNotification("Chegou na base!", Color3.fromRGB(0, 255, 0))
        end)
    elseif not baseCFrame then
        showNotification("Base não definida!", Color3.fromRGB(255, 50, 50))
    end
end)

SetBaseBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        baseCFrame = root.CFrame
        showNotification("Nova base definida!", Color3.fromRGB(0, 255, 170))
    end
end)

NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    
    if noclipActive then
        NoclipBtn.Text = "   Atravessar Parede: ON"
        showNotification("Noclip ativado", Color3.fromRGB(170, 0, 255))
    else
        NoclipBtn.Text = "   Atravessar Parede: OFF"
        showNotification("Noclip desativado", Color3.fromRGB(255, 255, 255))
    end
    
    manageNoclip()
end)

AntiHitBtn.MouseButton1Click:Connect(function()
    antiHitActive = not antiHitActive
    
    if antiHitActive then
        AntiHitBtn.Text = "   Anti-Hit: ON"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
        showNotification("Anti-Hit ativado", Color3.fromRGB(255, 85, 0))
        
        if Player.Character then
            character = Player.Character
            activateAntiHit()
        end
    else
        AntiHitBtn.Text = "   Anti-Hit: OFF"
        AntiHitBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        showNotification("Anti-Hit desativado", Color3.fromRGB(255, 255, 255))
        deactivateAntiHit()
    end
end)

-- Inicializar personagem
Player.CharacterAdded:Connect(function(char)
    character = char
    task.wait(0.5)
    
    if antiHitActive then
        activateAntiHit()
    end
    
    if noclipActive then
        manageNoclip()
    end
end)

-- Inicializar
setupCharacter()
showNotification("Shadow Hub v6.0 carregado!", Color3.fromRGB(170, 0, 255))

-- Limpeza ao fechar
PlayerGui.ChildRemoved:Connect(function(child)
    if child.Name == "ShadowHubV5" then
        if antiHitConnection then
            antiHitConnection:Disconnect()
        end
        if noclipConnection then
            noclipConnection:Disconnect()
        end
    end
end)