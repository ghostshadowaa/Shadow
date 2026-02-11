-- Shadow Hub v9.1 | Steal a Brainrot Edition
-- Foco: Teleport para o Spawn de Origem + Proteção

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Variáveis de Controle
local character = Player.Character or Player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local initialSpawnCFrame = root.CFrame -- Salva onde você nasceu

local states = {
    noclip = false,
    antiHitTween = false,
    esp = false
}

-- 1. SISTEMA DE NOTIFICAÇÃO
local function notify(text, color)
    local sg = PlayerGui:FindFirstChild("ShadowNotify") or Instance.new("ScreenGui", PlayerGui)
    sg.Name = "ShadowNotify"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(1, 10, 0.8, -#sg:GetChildren() * 45)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame)
    Instance.new("UIStroke", frame).Color = color or Color3.fromRGB(170, 0, 255)
    
    local txt = Instance.new("TextLabel", frame)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.Text = text
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 12

    frame:TweenPosition(UDim2.new(1, -210, 0.8, frame.Position.Y.Offset), "Out", "Back", 0.5, true)
    task.delay(3, function()
        if frame then
            frame:TweenPosition(UDim2.new(1, 10, 0.8, frame.Position.Y.Offset), "In", "Quad", 0.5, true)
            task.wait(0.5)
            frame:Destroy()
        end
    end)
end

-- 2. LOOP DE PROTEÇÃO (Noclip e Anti-Hit)
RunService.Stepped:Connect(function()
    if states.noclip or states.antiHitTween then
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- 3. VOLTAR PARA O SPAWN DE NASCIMENTO
local function teleportToBirthSpawn()
    local currentRoot = character:FindFirstChild("HumanoidRootPart")
    if not currentRoot then return end
    
    states.antiHitTween = true -- Ativa a imunidade de colisão
    notify("Retornando ao Spawn...", Color3.fromRGB(0, 170, 255))
    
    local distance = (currentRoot.Position - initialSpawnCFrame.Position).Magnitude
    local speed = 80 -- Velocidade do Tween
    local duration = math.clamp(distance / speed, 0.5, 5)
    
    local tween = TweenService:Create(currentRoot, TweenInfo.new(duration, Enum.EasingStyle.Quad), {CFrame = initialSpawnCFrame})
    
    tween:Play()
    tween.Completed:Connect(function()
        states.antiHitTween = false
        notify("Chegou no Spawn!", Color3.fromRGB(0, 255, 100))
    end)
end

-- 4. ESP DE BRAINROTS NOS SLOTS
local function toggleESP(val)
    states.esp = val
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "BrainrotESP" then v:Destroy() end
    end
    
    if val then
        for _, obj in pairs(Workspace:GetDescendants()) do
            -- Procura modelos que pareçam NPCs/Brainrots em bases
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= Player.Name then
                local h = Instance.new("Highlight")
                h.Name = "BrainrotESP"
                h.FillColor = Color3.fromRGB(255, 170, 0)
                h.Parent = obj
            end
        end
        notify("ESP Ativado", Color3.fromRGB(255, 255, 0))
    end
end

-- 5. INTERFACE
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "ShadowHubV9"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 280)
Main.Position = UDim2.new(0.5, -110, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", Main)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(170, 0, 255)
mainStroke.Thickness = 2

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW HUB V9.1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBlack
Instance.new("UICorner", Title)

local function createButton(text, pos, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0.85, 0, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("Ir para Spawn Original", UDim2.new(0.075, 0, 0.2, 0), teleportToBirthSpawn)

createButton("Noclip: OFF", UDim2.new(0.075, 0, 0.4, 0), function(self)
    states.noclip = not states.noclip
    self.Text = "Noclip: " .. (states.noclip and "ON" or "OFF")
    notify("Noclip " .. (states.noclip and "Ativado" or "Desativado"))
end)

createButton("ESP Brainrots: OFF", UDim2.new(0.075, 0, 0.6, 0), function(self)
    states.esp = not states.esp
    self.Text = "ESP Brainrots: " .. (states.esp and "ON" or "OFF")
    toggleESP(states.esp)
end)

-- Botão Flutuante para Abrir/Fechar
local Open = Instance.new("TextButton", ScreenGui)
Open.Size = UDim2.new(0, 45, 0, 45)
Open.Position = UDim2.new(0, 10, 0.5, 0)
Open.Text = "SH"
Open.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
Open.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Open).CornerRadius = UDim.new(1, 0)
Open.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

-- Atualiza referências quando morrer
Player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
end)

notify("Shadow Hub Carregado!", Color3.fromRGB(0, 255, 150))
