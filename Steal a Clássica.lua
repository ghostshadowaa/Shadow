-- Shadow Hub | Steal a Classic
-- Criado para: Adrian

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Detectar onde o player nasceu (Base)
local baseCFrame = RootPart.CFrame
print("Base detectada em: " .. tostring(baseCFrame.Position))

-- Configuração da Screen GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Botão de Abrir/Fechar (Menu Toggle)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 120, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Text = "Shadow Hub"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 14
OpenBtn.Parent = ScreenGui

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = OpenBtn

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.Parent = MainFrame

-- Título (Conforme solicitado)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub | Steal a Classic"
Title.TextColor3 = Color3.fromRGB(170, 0, 255) -- Roxo neon
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- Botão de Voltar para Base
local TeleportBtn = Instance.new("TextButton")
TeleportBtn.Name = "TeleportBtn"
TeleportBtn.Size = UDim2.new(0.8, 0, 0, 45)
TeleportBtn.Position = UDim2.new(0.1, 0, 0.5, 0)
TeleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TeleportBtn.Text = "VOLTAR PARA BASE (TP)"
TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
TeleportBtn.Font = Enum.Font.GothamSemibold
TeleportBtn.TextSize = 16
TeleportBtn.Parent = MainFrame

local TPBtnCorner = Instance.new("UICorner")
TPBtnCorner.Parent = TeleportBtn

-- Lógica de Abrir e Fechar
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        OpenBtn.Text = "Fechar"
    else
        OpenBtn.Text = "Shadow Hub"
    end
end)

-- Lógica do Teleporte
TeleportBtn.MouseButton1Click:Connect(function()
    local currentCharacter = Player.Character
    if currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart") then
        -- Efeito de transparência antes do TP (Opcional)
        TeleportBtn.Text = "Teleportando..."
        TeleportBtn.TextColor3 = Color3.fromRGB(170, 0, 255)
        
        task.wait(0.2)
        currentCharacter.HumanoidRootPart.CFrame = baseCFrame
        
        task.wait(0.5)
        TeleportBtn.Text = "VOLTAR PARA BASE (TP)"
        TeleportBtn.TextColor3 = Color3.new(1, 1, 1)
    end
end)

-- Manter a posição da base atualizada se você quiser que seja o novo spawn após morrer
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = newChar:WaitForChild("HumanoidRootPart")
    -- Comentado abaixo: Se quiser que a base seja sempre onde você renasce, remova o "--"
    -- baseCFrame = RootPart.CFrame 
end)
