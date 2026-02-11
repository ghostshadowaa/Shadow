-- Shadow Hub v9.0 | Steal a Brainrot Edition
-- Foco: Teleport, ESP de Slots e Proteção de Tween

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

local character = Player.Character or Player.CharacterAdded:Wait()
local states = {
    noclip = false,
    antiHit = false, -- Ativado automaticamente no Tween
    esp = false
}

-- 1. SISTEMA DE NOTIFICAÇÃO (Moderno)
local function notify(text, color)
    local sg = PlayerGui:FindFirstChild("ShadowNotify") or Instance.new("ScreenGui", PlayerGui)
    sg.Name = "ShadowNotify"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(1, 10, 0.8, -#sg:GetChildren() * 45)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = color or Color3.fromRGB(170, 0, 255)
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = text
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12

    frame:TweenPosition(UDim2.new(1, -210, 0.8, frame.Position.Y.Offset), "Out", "Back", 0.5, true)
    task.delay(3, function()
        frame:TweenPosition(UDim2.new(1, 10, 0.8, frame.Position.Y.Offset), "In", "Quad", 0.5, true)
        task.wait(0.5)
        frame:Destroy()
    end)
end

-- 2. NOCLIP & ANTI-HIT (Loop de Frame)
RunService.Stepped:Connect(function()
    if states.noclip or states.antiHit then
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 3. TELEPORT PARA BASE COM PROTEÇÃO
local function teleportToBase()
    local root = character:FindFirstChild("HumanoidRootPart")
    local spawn = Workspace:FindFirstChild("SpawnLocation", true) or Workspace:FindFirstChild("Base", true)
    
    if root and spawn then
        states.antiHit = true -- Ativa proteção durante o trajeto
        states.noclip = true
        notify("Retornando à Base...", Color3.fromRGB(0, 170, 255))
        
        local distance = (root.Position - spawn.Position).Magnitude
        local info = TweenInfo.new(distance/75, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, info, {CFrame = spawn.CFrame + Vector3.new(0, 5, 0)})
        
        tween:Play()
        tween.Completed:Connect(function()
            states.antiHit = false
            states.noclip = false
            notify("Chegou na Base!", Color3.fromRGB(0, 255, 100))
        end)
    else
        notify("Erro: Base não encontrada", Color3.fromRGB(255, 0, 0))
    end
end

-- 4. ESP DE BRAINROTS/NPC NOS SLOTS
local function toggleESP(val)
    states.esp = val
    -- Remove ESP antigo
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "BrainrotESP" then v:Destroy() end
    end
    
    if val then
        for _, base in pairs(Workspace:GetChildren()) do
            -- Procura por modelos dentro de slots ou bases de players
            if base.Name:lower():find("base") or base.Name:lower():find("slot") then
                for _, item in pairs(base:GetDescendants()) do
                    if item:IsA("Model") and item:FindFirstChild("Humanoid") then
                        local h = Instance.new("Highlight")
                        h.Name = "BrainrotESP"
                        h.FillColor = Color3.fromRGB(255, 170, 0)
                        h.OutlineColor = Color3.new(1, 1, 1)
                        h.Parent = item
                    end
                end
            end
        end
        notify("ESP de Slots Ativado", Color3.fromRGB(255, 255, 0))
    end
end

-- 5. INTERFACE GRÁFICA
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ShadowHubMain"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0.5, -110, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Instance.new("UICorner", Main)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(170, 0, 255)
stroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB v9"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title)

local function createButton(name, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- Botões
createButton("Voltar para Base", UDim2.new(0.075, 0, 0.2, 0), teleportToBase)

local noclipBtn = createButton("Noclip: OFF", UDim2.new(0.075, 0, 0.4, 0), function()
    states.noclip = not states.noclip
    notify("Noclip " .. (states.noclip and "ON" or "OFF"))
end)

local espBtn = createButton("ESP Slots: OFF", UDim2.new(0.075, 0, 0.6, 0), function()
    states.esp = not states.esp
    toggleESP(states.esp)
end)

-- Botão de Toggle Menu
local Toggle = Instance.new("TextButton", ScreenGui)
Toggle.Size = UDim2.new(0, 40, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0.4, 0)
Toggle.Text = "SH"
Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)
Toggle.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

notify("Script Carregado!", Color3.fromRGB(170, 0, 255))
