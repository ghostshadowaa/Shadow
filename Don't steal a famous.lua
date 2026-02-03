-- Shadow Hub: Sniper Target Edition (Foco Único)
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

-- --- INTERFACE (GUI) ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Sniper"
ScreenGui.ResetOnSpawn = false

-- [TELA DE CARREGAMENTO]
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 50)
LoadingFrame.Position = UDim2.new(0, 0, 0, -25)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
LoadingFrame.ZIndex = 100
local LoadTitle = Instance.new("TextLabel", LoadingFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 100); LoadTitle.Position = UDim2.new(0, 0, 0.2, 0)
LoadTitle.Text = "SHADOW HUB"; LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextColor3 = Color3.fromRGB(0, 150, 255); LoadTitle.TextSize = 50; LoadTitle.BackgroundTransparency = 1
local StatusLabel = Instance.new("TextLabel", LoadingFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 30); StatusLabel.Position = UDim2.new(0, 0, 0.82, 0)
StatusLabel.Text = "INICIALIZANDO..."; StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 150); StatusLabel.TextSize = 16; StatusLabel.BackgroundTransparency = 1

-- [MENU PRINCIPAL]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 140); MainFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 210, 0, 45); FarmBtn.Position = UDim2.new(0, 15, 0, 55)
FarmBtn.Text = "AUTO FARM (SNIPER)"; FarmBtn.Font = Enum.Font.GothamSemibold
FarmBtn.TextColor3 = Color3.fromRGB(150, 150, 150); FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", FarmBtn)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"; OpenBtn.Visible = false; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- --- LÓGICA DE COLETA ALVO (APENAS O NPC ATUAL) ---
local function collectSpecific(targetNPC)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root and targetNPC then
        local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
        if part then
            -- Interação direta com o NPC alvo
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
                table.insert(sorted[r], npc); break
            end
        end
    end
    for _, r in ipairs(PriorityList) do
        if #sorted[r] > 0 then return sorted[r][math.random(1, #sorted[r])] end
    end
    return children[math.random(1, #children)]
end

-- --- LOOP DE FARM (SNIPER TELEPORT) ---
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
                        -- TELEPORT IDA
                        root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
                        
                        -- ESPERA PARA COLETAR APENAS ESTE ALVO
                        task.wait(0.3) 
                        collectSpecific(target) -- Coleta APENAS o NPC que escolheu
                        task.wait(0.1)
                        
                        -- TELEPORT VOLTA
                        root.CFrame = SavedSpawnCFrame
                    end
                end
            end)
        end
    end
end)

-- --- LOGICA INTERFACE ---
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
task.spawn(function()
    task.wait(2)
    LoadingFrame:Destroy(); OpenBtn.Visible = true; MainFrame.Visible = true
end)
