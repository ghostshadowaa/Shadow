-- Shadow Hub: Definitive Sniper Edition (Custom Loading)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

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
end
Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

-- --- INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_CustomLoad"
ScreenGui.ResetOnSpawn = false

-- --- TELA DE CARREGAMENTO ANIMADA ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 100)
LoadingFrame.Position = UDim2.new(0, 0, 0, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
LoadingFrame.ZIndex = 100

local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 100)
LoadTitle.Position = UDim2.new(0, 0, 0.4, 0)
LoadTitle.Text = "SHADOW HUB"
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
LoadTitle.TextSize = 55
LoadTitle.BackgroundTransparency = 1

local StatusLabel = Instance.new("TextLabel", LoadingFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0.52, 0)
StatusLabel.Text = "INICIALIZANDO..."
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 18
StatusLabel.BackgroundTransparency = 1

local BarBack = Instance.new("Frame", LoadingFrame)
BarBack.Size = UDim2.new(0, 300, 0, 4)
BarBack.Position = UDim2.new(0.5, -150, 0.58, 0)
BarBack.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BarBack.BorderSizePixel = 0

local BarFill = Instance.new("Frame", BarBack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BarFill.BorderSizePixel = 0

-- --- ELEMENTOS DA GUI PRINCIPAL ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)

local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 40)
GuiTitle.Text = "SHADOW HUB V2"
GuiTitle.Font = Enum.Font.GothamBold
GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
GuiTitle.TextSize = 18
GuiTitle.BackgroundTransparency = 1

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 210, 0, 45)
FarmBtn.Position = UDim2.new(0, 15, 0, 60)
FarmBtn.Text = "AUTO FARM (SNIPER)"
FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", FarmBtn)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 150, 255)

-- --- LÓGICA DE COLETA SNIPER ---
local function collectSpecific(targetNPC)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root and targetNPC then
        local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
        if part then
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
            local prompt = targetNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
            end
        end
    end
end

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
                        root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
                        task.wait(0.3) 
                        collectSpecific(target)
                        task.wait(0.1)
                        root.CFrame = SavedSpawnCFrame
                    end
                end
            end)
        end
    end
end)

-- --- CONTROLES GUI ---
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.Text = States.Farm and "FARM: ON" or "AUTO FARM (SNIPER)"
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- --- ANIMAÇÃO TELA DE CARREGAMENTO ---
task.spawn(function()
    local statusMsgs = {
        "Carregando Assets...",
        "Ativando Anti-Kick...",
        "Buscando Map Zones...",
        "Configurando Teleport...",
        "Shadow Hub Pronto!"
    }
    
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 4, true)
    
    for i = 1, #statusMsgs do
        StatusLabel.Text = statusMsgs[i]
        task.wait(0.8)
    end
    
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
        MainFrame.Visible = true
    end)
end)
