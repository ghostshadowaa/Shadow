-- Shadow Hub v8.0 | Performance & Funções
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Variáveis de Estado
local states = {
    noclip = false,
    infJump = false,
    desync = false,
    esp = false,
    speed = 16
}

local character = Player.Character or Player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

-- Sistema de Notificação Melhorado
local function notify(text, color)
    local sg = PlayerGui:FindFirstChild("ShadowHubV5")
    if not sg then return end
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 220, 0, 45)
    notif.Position = UDim2.new(1, 20, 0.8, 0) -- Começa fora da tela
    notif.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    notif.BorderSizePixel = 0
    notif.Parent = sg
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", notif)
    stroke.Color = color or Color3.fromRGB(170, 0, 255)
    stroke.Thickness = 2
    
    local txt = Instance.new("TextLabel", notif)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 13

    -- Animação de entrada e saída
    notif:TweenPosition(UDim2.new(1, -240, 0.8, 0), "Out", "Back", 0.5, true)
    task.delay(2.5, function()
        notif:TweenPosition(UDim2.new(1, 20, 0.8, 0), "In", "Quad", 0.5, true)
        task.wait(0.5)
        notif:Destroy()
    end)
end

-- Lógica de Noclip e Desync (Rodando em cada frame)
RunService.Stepped:Connect(function()
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    -- Noclip
    if states.noclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Desync (Simples: altera o CFrame da Root para confundir o servidor)
    if states.desync then
        local oldCFrame = character.HumanoidRootPart.CFrame
        character.HumanoidRootPart.CFrame = oldCFrame * CFrame.Angles(0, math.rad(renderVelocity or 90), 0)
        RunService.RenderStepped:Wait()
        character.HumanoidRootPart.CFrame = oldCFrame
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if states.infJump and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Sistema de ESP (Destaque de NPCs)
local function toggleESP(state)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj.Name ~= Player.Name then
            if state then
                if not obj:FindFirstChild("ShadowESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ShadowESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.Parent = obj
                end
            else
                if obj:FindFirstChild("ShadowESP") then obj.ShadowESP:Destroy() end
            end
        end
    end
end

-- Interface
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ShadowHubV5"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 380)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(170, 0, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "SHADOW HUB V8"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title)

local Container = Instance.new("ScrollingFrame", MainFrame)
Container.Size = UDim2.new(1, 0, 1, -50)
Container.Position = UDim2.new(0, 0, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 1.2, 0)
Container.ScrollBarThickness = 2

local layout = Instance.new("UIListLayout", Container)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 10)

-- Função para criar botões de alternância
local function createToggle(name, stateKey, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        local active = states[stateKey]
        btn.Text = name .. ": " .. (active and "ON" or "OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(80, 0, 150) or Color3.fromRGB(30, 30, 30)
        notify(name .. (active and " Ativado" or " Desativado"), active and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50))
        if callback then callback(active) end
    end)
end

-- Criando os Botões
createToggle("Noclip", "noclip")
createToggle("Pulo Infinito", "infJump")
createToggle("Desync (Anti-Hit)", "desync")
createToggle("ESP NPCs", "esp", function(v) toggleESP(v) end)

createToggle("Super Speed", "speedActive", function(v)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = v and 100 or 16
    end
end)

-- Botão de Abrir
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "SH"
OpenBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

notify("Shadow Hub V8 Carregado!", Color3.fromRGB(170, 0, 255))
