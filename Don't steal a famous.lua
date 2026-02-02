-- Shadow Hub: Gomes Elite (Priority Collection & Aura)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local SavedSpawnCFrame = nil
local TweenSpeed = 110 -- Velocidade otimizada
local SafeHeight = 3.5 -- Altura para não bugar no chão
local AuraRadius = 18

-- HIERARQUIA DE PRIORIDADE (O script foca do topo para baixo)
local PriorityList = {
    "Secret", "OldGen", "Youtuber god", "Godly",
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- FUNÇÃO PARA PEGAR O SPAWN ---
local function SaveSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(1)
    SavedSpawnCFrame = root.CFrame
    print("Base salva: ", tostring(SavedSpawnCFrame.Position))
end
Player.CharacterAdded:Connect(SaveSpawn)
task.spawn(SaveSpawn)

-- --- NOCLIP (ATIVADO NO FARM) ---
RunService.Stepped:Connect(function()
    if States.Farm and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- --- BUSCAR MELHOR NPC (LÓGICA DE PRIORIDADE) ---
local function GetBestNPC()
    local field = workspace:FindFirstChild("Map") and workspace.Map.Zones.Field:FindFirstChild("NPC")
    if not field then return nil end
    
    local allNPCs = field:GetChildren()
    local sortedByRarity = {}
    for _, rarity in ipairs(PriorityList) do sortedByRarity[rarity] = {} end

    for _, npc in pairs(allNPCs) do
        local content = ""
        -- Lê textos e valores dentro do NPC para identificar a raridade
        for _, obj in pairs(npc:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("StringValue") then
                content = content .. " " .. string.lower(obj.Text or obj.Value)
            end
        end

        for _, rarity in ipairs(PriorityList) do
            if string.find(content, string.lower(rarity)) then
                table.insert(sortedByRarity[rarity], npc)
                break
            end
        end
    end

    -- Retorna o primeiro NPC encontrado na ordem da PriorityList
    for _, rarity in ipairs(PriorityList) do
        if #sortedByRarity[rarity] > 0 then
            return sortedByRarity[rarity][math.random(1, #sortedByRarity[rarity])]
        end
    end
    return allNPCs[math.random(1, #allNPCs)]
end

-- --- AURA DE COLETA ---
local function AuraCollect()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local field = workspace.Map.Zones.Field:FindFirstChild("NPC")
    if root and field then
        for _, npc in pairs(field:GetChildren()) do
            local part = npc:FindFirstChildWhichIsA("BasePart", true)
            if part and (root.Position - part.Position).Magnitude <= AuraRadius then
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

-- --- INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "Shadow hub"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.5, -110, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 150, 255)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SHADOW PRIORITY"
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 190, 0, 50)
FarmBtn.Position = UDim2.new(0, 15, 0, 50)
FarmBtn.Text = "INICIAR FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 15, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 150, 255)

-- --- LÓGICA DE FARM ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm and SavedSpawnCFrame then
            pcall(function()
                local target = GetBestNPC()
                local root = Player.Character.HumanoidRootPart
                
                if target and root then
                    local part = target:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        -- IDA AO ALVO
                        local d1 = (root.Position - part.Position).Magnitude
                        local t1 = TweenService:Create(root, TweenInfo.new(d1/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, SafeHeight, 0)})
                        t1:Play()
                        t1.Completed:Wait()
                        
                        -- COLETA
                        task.wait(0.2)
                        AuraCollect()
                        task.wait(0.3)
                        
                        -- VOLTA PARA BASE (SPAWN DINÂMICO)
                        local d2 = (root.Position - SavedSpawnCFrame.Position).Magnitude
                        local t2 = TweenService:Create(root, TweenInfo.new(d2/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = SavedSpawnCFrame})
                        t2:Play()
                        t2.Completed:Wait()
                    end
                end
            end)
        end
    end
end)

FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.Text = States.Farm and "FARM ATIVO" or "INICIAR FARM"
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- TELA DE LOADING RÁPIDA
task.spawn(function()
    local L = Instance.new("Frame", ScreenGui)
    L.Size = UDim2.new(1,0,1,0)
    L.BackgroundColor3 = Color3.new(0,0,0)
    L.ZIndex = 50
    local T = Instance.new("TextLabel", L)
    T.Size = UDim2.new(1,0,1,0)
    T.Text = "SHADOW HUB\nCONFIGURANDO PRIORIDADES..."
    T.TextColor3 = Color3.fromRGB(0, 150, 255)
    T.Font = Enum.Font.GothamBold
    T.TextSize = 24
    T.BackgroundTransparency = 1
    task.wait(2.5)
    L:Destroy()
    OpenBtn.Visible = true
    MainFrame.Visible = true
end)
