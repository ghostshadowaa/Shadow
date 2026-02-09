local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local vim = game:GetService("VirtualInputManager")
local tweenService = game:GetService("TweenService")

-- Variáveis de Controle
_G.AutoFarm = false
_G.SafeY = 35
local questNPC_Pos = Vector3.new(-483.65, 31.40, -811.27)

-- Criar a GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowHubRedz"
screenGui.Parent = playerGui

-- Frame Principal (Estilo Redz)
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 450, 0, 300)
Main.Position = UDim2.new(0.5, -225, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.BorderSizePixel = 0
Main.Parent = screenGui
Main.Active = true
Main.Draggable = true

-- Corner Arredondado
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = Main

-- Barra Lateral (Abas)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = Sidebar

-- Container das Opções (Scrolling)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -130, 1, -10)
Container.Position = UDim2.new(0, 125, 0, 5)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Container.ScrollBarThickness = 4
Container.Parent = Main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = Container

-- Função para criar Toggle (Estilo Redz)
local function CreateToggle(name, callback)
    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(0.95, 0, 0, 40)
    bg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    bg.Text = "  " .. name
    bg.TextColor3 = Color3.fromRGB(200, 200, 200)
    bg.TextXAlignment = Enum.TextXAlignment.Left
    bg.Font = Enum.Font.Gotham
    bg.TextSize = 14
    bg.Parent = Container
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 10, 0, 10)
    indicator.Position = UDim2.new(1, -20, 0.5, -5)
    indicator.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    indicator.Parent = bg
    
    local state = false
    bg.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        callback(state)
    end)
end

-- ==========================================
-- LÓGICA DE INTERAÇÃO (MELHORADA)
-- ==========================================

local function interactWithQuest()
    -- 1. Ir até o NPC
    if (character.HumanoidRootPart.Position - questNPC_Pos).Magnitude > 10 then
        character.HumanoidRootPart.CFrame = CFrame.new(questNPC_Pos.X, _G.SafeY, questNPC_Pos.Z)
        task.wait(0.5)
    end
    
    -- 2. Interação ProximityPrompt (2 segundos)
    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(2.2) -- Um pouco mais para garantir
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    
    -- 3. Clicar no botão de Aceitar (Seu caminho específico)
    task.wait(0.8)
    local success, err = pcall(function()
        local btn = player.PlayerGui.QuestOptions.QuestFrame.Accept
        if btn and btn.Visible then
            local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
            local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)
            vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
            task.wait(0.1)
            vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end
    end)
end

-- ==========================================
-- MONTAGEM DO HUB
-- ==========================================

CreateToggle("Auto Farm Bandits", function(t)
    _G.AutoFarm = t
    if t then
        spawn(function()
            while _G.AutoFarm do
                -- Aqui você chamaria sua função de Kill, mas primeiro a Quest:
                interactWithQuest()
                task.wait(10) -- Espera o tempo de fazer a missão
            end
        end)
    end
end)

CreateToggle("Auto Quest (Only)", function(t)
    _G.AutoQuest = t
    spawn(function()
        while _G.AutoQuest do
            interactWithQuest()
            task.wait(5)
        end
    end)
end)

-- Botão de Fechar no Toggle original (estilo Redz usa um botão flutuante)
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Parent = Main
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

print("Shadow Hub carregado no estilo Redz!")
