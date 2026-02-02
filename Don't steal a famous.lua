-- Shadow Hub: Definitive Elite Edition (Animated Loading Screen)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil -- Será definida automaticamente ao nascer
local TweenSpeed = 100 
local SafeHeightOffset = 3.5
local AuraRadius = 15 

-- HIERARQUIA DE PRIORIDADE
local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- TELA DE CARREGAMENTO ANIMADA ---
local LoadingScreen = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
LoadingScreen.Name = "AnimatedLoadingScreen"
LoadingScreen.ResetOnSpawn = false

local Background = Instance.new("Frame", LoadingScreen)
Background.Size = UDim2.new(1, 0, 1, 0)
Background.Position = UDim2.new(0, 0, 0, 0)
Background.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Dark base
Background.ZIndex = 100

local RunnerImage = Instance.new("ImageLabel", Background)
RunnerImage.Size = UDim2.new(0, 150, 0, 150)
RunnerImage.Position = UDim2.new(0.5, -75, 0.4, 0)
RunnerImage.BackgroundTransparency = 1
RunnerImage.Image = "rbxassetid://13264624467" -- ID de um personagem correndo (ou outro asset animado se tiver)
RunnerImage.ImageColor3 = Color3.fromRGB(0, 180, 255) -- Neon Blue

local Title = Instance.new("TextLabel", Background)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0.15, 0)
Title.Text = "SHADOW HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 150, 255) -- Neon Blue
Title.TextSize = 45
Title.BackgroundTransparency = 1
Title.ZIndex = 101

local StatusText = Instance.new("TextLabel", Background)
StatusText.Size = UDim2.new(1, 0, 0, 30)
StatusText.Position = UDim2.new(0, 0, 0.7, 0)
StatusText.Text = "Loading: Initializing Core Systems..."
StatusText.Font = Enum.Font.GothamSemibold
StatusText.TextColor3 = Color3.fromRGB(0, 255, 150) -- Neon Green
StatusText.TextSize = 20
StatusText.BackgroundTransparency = 1
StatusText.ZIndex = 101

local ProgressBar = Instance.new("Frame", Background)
ProgressBar.Size = UDim2.new(0, 280, 0, 6)
ProgressBar.Position = UDim2.new(0.5, -140, 0.8, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Darker Grey
ProgressBar.BorderSizePixel = 0
ProgressBar.ZIndex = 101

local ProgressFill = Instance.new("Frame", ProgressBar)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Neon Magenta
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 102

-- --- FUNÇÃO PARA CAPTURAR O SPAWN ---
local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5) -- Pequeno delay para garantir que o spawn foi concluído
    SavedSpawnCFrame = root.CFrame
    print("Shadow Hub: Nova Base Salva!")
end

Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

-- --- LÓGICA DE COLETA ---
local function collectAura()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local npcs = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Zones") and workspace.Map.Zones.Field:FindFirstChild("NPC")
    if root and npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            local part = npc:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local distance = (root.Position - part.Position).Magnitude
                if distance <= AuraRadius then
                    firetouchinterest(root, part, 0)
                    firetouchinterest(root, part, 1)
                    local prompt = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        prompt.HoldDuration = 0
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
    end
end

-- --- INTERFACE PRINCIPAL (GUI) ---
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -22)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 150, 255)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)

local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 40)
GuiTitle.Text = "SHADOW HUB"
GuiTitle.Font = Enum.Font.GothamBold
GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
GuiTitle.TextSize = 18
GuiTitle.BackgroundTransparency = 1

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 210, 0, 45)
FarmBtn.Position = UDim2.new(0, 15, 0, 55)
FarmBtn.Text = "AUTO FARM"
FarmBtn.Font = Enum.Font.GothamSemibold
FarmBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function GetBestNPC()
    local folder = workspace:FindFirstChild("Map") and workspace.Map.Zones.Field:FindFirstChild("NPC")
    if not folder then return nil end
    local children = folder:GetChildren()
    local sorted = {}
    for _, r in ipairs(PriorityList) do sorted[r] = {} end

    for _, npc in pairs(children) do
        local txt = ""
        for _, d in pairs(npc:GetDescendants()) do
            if d:IsA("TextLabel") then txt = txt .. " " .. d.Text
            elseif d:IsA("StringValue") then txt = txt .. " " .. d.Value end
        end
        for _, r in ipairs(PriorityList) do
            if string.find(string.lower(txt), string.lower(r)) then
                table.insert(sorted[r], npc)
                break
            end
        end
    end

    for _, r in ipairs(PriorityList) do
        if #sorted[r] > 0 then return sorted[r][math.random(1, #sorted[r])] end
    end
    return children[math.random(1, #children)]
end

-- --- LOOP DE FARM ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm and SavedSpawnCFrame then
            pcall(function()
                local target = GetBestNPC()
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                
                if target and root then
                    local part = target:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        -- IDA
                        local dist = (root.Position - part.Position).Magnitude
                        local t1 = TweenService:Create(root, TweenInfo.new(dist/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)})
                        t1:Play()
                        t1.Completed:Wait()
                        
                        task.wait(0.2)
                        collectAura()
                        task.wait(0.2)
                        
                        -- VOLTA PARA O SPAWN SALVO
                        local dist2 = (root.Position - SavedSpawnCFrame.Position).Magnitude
                        local t2 = TweenService:Create(root, TweenInfo.new(dist2/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = SavedSpawnCFrame})
                        t2:Play()
                        t2.Completed:Wait()
                    end
                end
            end)
        end
    end
end)

-- --- LÓGICA DE ANIMAÇÃO DA TELA DE CARREGAMENTO ---
task.spawn(function()
    local loadingMessages = {
        "Initializing Core Systems...",
        "Scanning for Game Assets...",
        "Loading GUI Components...",
        "Establishing Connection Protocol...",
        "Configuring Player Preferences...",
        "Optimizing Performance...",
        "Preparing for Action!"
    }

    -- Animação da barra de progresso
    ProgressFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quart", 4, true)

    local currentProgress = 0
    local totalSteps = #loadingMessages * 2 + 2 -- Para incluir a corrida e fade out

    for i = 1, #loadingMessages do
        StatusText.Text = "Loading: " .. loadingMessages[i]
        
        -- Pequena animação de opacidade para o texto
        TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0.2}):Play()
        task.wait(0.1)
        TweenService:Create(StatusText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        
        task.wait(0.5) -- Tempo para cada mensagem
    end

    StatusText.Text = "Loading: Ready!"
    task.wait(0.5)

    -- Animação de fade out e movimento final
    TweenService:Create(RunnerImage, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -75, -0.2, 0), ImageTransparency = 1}):Play()
    TweenService:Create(Background, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    TweenService:Create(StatusText, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
    TweenService:Create(ProgressBar, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    TweenService:Create(ProgressFill, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    
    task.wait(1.5)
    LoadingScreen:Destroy() -- Remove a tela de carregamento após a animação
    OpenBtn.Visible = true -- Torna o botão do menu principal visível
end)
