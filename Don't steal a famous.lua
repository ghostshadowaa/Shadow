-- Shadow Hub: Gomes Elite Edition (FIXED GUI)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil
local TweenSpeed = 100 

-- --- PROTEÇÃO DE GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHub_Gomes_V4"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- --- 1. CRIAR O MENU PRINCIPAL PRIMEIRO (Mas deixá-lo invisível) ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 150)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false -- Escondido até o fim do loading
MainFrame.ZIndex = 5
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 200, 0, 50)
FarmBtn.Position = UDim2.new(0.5, -100, 0.5, -25)
FarmBtn.Text = "AUTO FARM"
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

-- --- 2. BOTÃO DE ABRIR "S" ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Visible = false -- Escondido até o fim do loading
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.ZIndex = 10
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 150, 255)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- --- 3. TELA DE CARREGAMENTO (POR CIMA DE TUDO) ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
LoadingFrame.ZIndex = 100 -- Valor alto para cobrir tudo

local Title = Instance.new("TextLabel", LoadingFrame)
Title.Size = UDim2.new(1, 0, 0, 100)
Title.Position = UDim2.new(0, 0, 0.2, 0)
Title.Text = "SHADOW HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.TextSize = 50
Title.BackgroundTransparency = 1

local Runner = Instance.new("TextLabel", LoadingFrame)
Runner.Size = UDim2.new(0, 100, 0, 100)
Runner.Position = UDim2.new(-0.2, 0, 0.5, -50)
Runner.Text = "🏃" -- Boneco correndo
Runner.TextSize = 80
Runner.BackgroundTransparency = 1

local BarBack = Instance.new("Frame", LoadingFrame)
BarBack.Size = UDim2.new(0, 280, 0, 6)
BarBack.Position = UDim2.new(0.5, -140, 0.75, 0)
BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBack.BorderSizePixel = 0

local BarFill = Instance.new("Frame", BarBack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Magenta Neon
BarFill.BorderSizePixel = 0

local Status = Instance.new("TextLabel", LoadingFrame)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.82, 0)
Status.Text = "A INICIALIZAR..."
Status.Font = Enum.Font.GothamBold
Status.TextColor3 = Color3.fromRGB(0, 255, 150)
Status.TextSize = 16
Status.BackgroundTransparency = 1

-- --- LÓGICA DE FUNCIONAMENTO ---

-- Salvar Spawn
local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    SavedSpawnCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end
task.spawn(CaptureSpawn)

-- Animação de Carregamento
task.spawn(function()
    -- Boneco cruza a tela
    TweenService:Create(Runner, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Position = UDim2.new(1.1, 0, 0.5, -50)}):Play()
    -- Barra enche
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 3.5, true)
    
    local textos = {"A CARREGAR ASSETS...", "A CONFIGURAR FARM...", "CONEXÃO ESTABELECIDA!", "PRONTO!"}
    for _, txt in ipairs(textos) do
        Status.Text = txt
        task.wait(0.8)
    end
    
    -- Fade out total
    local fade = TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    fade:Play()
    for _, v in pairs(LoadingFrame:GetChildren()) do
        if v:IsA("TextLabel") or v:IsA("Frame") then
            TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
        end
    end
    
    fade.Completed:Connect(function()
        LoadingFrame:Destroy()
        OpenBtn.Visible = true -- SÓ APARECE AQUI
        print("Shadow Hub carregado com sucesso!")
    end)
end)

-- Lógica do Botão Farm
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.new(1,1,1)
    FarmBtn.Text = States.Farm and "FARM: ATIVO" or "AUTO FARM"
end)
