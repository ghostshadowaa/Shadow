-- Shadow Hub: Definitive Elite Edition (Dynamic Spawn Fix + Loading)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil 
local TweenSpeed = 100 
local SafeHeightOffset = 3.5
local AuraRadius = 15 

-- HIERARQUIA DE PRIORIDADE
local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- FUNÇÃO PARA CAPTURAR O SPAWN ---
local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5) 
    SavedSpawnCFrame = root.CFrame
    print("Shadow Hub: Nova Base Salva!")
end

Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

-- --- INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Dynamic"
ScreenGui.ResetOnSpawn = false

-- --- TELA DE CARREGAMENTO (ADICIONADA) ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 50)
LoadingFrame.Position = UDim2.new(0, 0, 0, -25)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
LoadingFrame.ZIndex = 100

local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 100)
LoadTitle.Position = UDim2.new(0, 0, 0.2, 0)
LoadTitle.Text = "SHADOW HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
LoadTitle.TextSize = 50
LoadTitle.BackgroundTransparency = 1

local Runner = Instance.new("TextLabel", LoadingFrame)
Runner.Size = UDim2.new(0, 100, 0, 100)
Runner.Position = UDim2.new(-0.2, 0, 0.5, -50)
Runner.Text = "🏃"
Runner.TextSize = 80
Runner.BackgroundTransparency = 1

local BarBack = Instance.new("Frame", LoadingFrame)
BarBack.Size = UDim2.new(0, 280, 0, 6)
BarBack.Position = UDim2.new(0.5, -140, 0.75, 0)
BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBack.BorderSizePixel = 0

local BarFill = Instance.new("Frame", BarBack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
BarFill.BorderSizePixel = 0

local StatusLabel = Instance.new("TextLabel", LoadingFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.82, 0)
StatusLabel.Text = "INICIALIZANDO..."
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
StatusLabel.TextSize = 16
StatusLabel.BackgroundTransparency = 1

-- --- ELEMENTOS DA GUI ORIGINAL (OCULTOS INICIALMENTE) ---
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
GuiTitle.Text = "SHADOW HUB (SPAWN)"
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

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 150, 255)

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
                        local dist = (root.Position - part.Position).Magnitude
                        local t1 = TweenService:Create(root, TweenInfo.new(dist/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)})
                        t1:Play()
                        t1.Completed:Wait()
                        
                        task.wait(0.2)
                        collectAura()
                        task.wait(0.2)
                        
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

-- --- LÓGICA DA TELA DE CARREGAMENTO ---
task.spawn(function()
    -- Animação do Corredor e Barra
    TweenService:Create(Runner, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {Position = UDim2.new(1.1, 0, 0.5, -50)}):Play()
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 3.5, true)
    
    local msgs = {"CARREGANDO ASSETS...", "SINCRONIZANDO SPAWN...", "OTIMIZANDO TWEEN...", "PRONTO!"}
    for _, m in ipairs(msgs) do
        StatusLabel.Text = m
        task.wait(0.8)
    end
    
    -- Efeito de Saída
    local fade = TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    fade:Play()
    for _, v in pairs(LoadingFrame:GetChildren()) do
        if v:IsA("TextLabel") or v:IsA("Frame") then
            TweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1}):Play()
        end
    end
    
    fade.Completed:Connect(function()
        LoadingFrame:Destroy()
        OpenBtn.Visible = true
        MainFrame.Visible = true -- Abre o painel automaticamente na primeira execução
    end)
end)
