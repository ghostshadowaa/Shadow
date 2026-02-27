-- Shadow Hub: V22 - Mobile Optimized (Fixed Edition)
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES
local States = { FarmAuto = false, FarmInteractive = false, Asking = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- FUNÇÕES DE SUPORTE ---

local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if root then
        task.wait(0.5)
        SavedSpawnCFrame = root.CFrame
    end
end

-- Garante que sempre teremos o local de retorno
Player.CharacterAdded:Connect(CaptureSpawn)
task.spawn(CaptureSpawn)

-- Função de coleta precisa
local function collectSpecific(targetNPC)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Se o spawn salvo sumiu (morreu), tenta capturar a posição atual antes de ir
    if not SavedSpawnCFrame and root then SavedSpawnCFrame = root.CFrame end

    if root and targetNPC and SavedSpawnCFrame then
        local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local oldPos = root.CFrame
            root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
            
            task.wait(0.2) -- Tempo necessário para o servidor processar a posição
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
            
            local prompt = targetNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end
            
            task.wait(0.1)
            root.CFrame = SavedSpawnCFrame
        end
    end
end

-- Busca de NPC (Voltou a ler TextLabels, mas de forma otimizada)
local function GetBestNPC()
    local map = workspace:FindFirstChild("Map")
    local folder = map and map:FindFirstChild("Zones") and map.Zones:FindFirstChild("Field") and map.Zones.Field:FindFirstChild("NPC")
    if not folder then return nil end
    
    local children = folder:GetChildren()
    local matches = {}

    for _, npc in ipairs(children) do
        local info = ""
        -- Lê apenas o necessário para identificar
        for _, obj in ipairs(npc:GetDescendants()) do
            if obj:IsA("TextLabel") then
                info = info .. " " .. obj.Text
            elseif obj:IsA("StringValue") then
                info = info .. " " .. obj.Value
            end
        end

        for _, rarity in ipairs(PriorityList) do
            if string.find(string.lower(info), string.lower(rarity)) then
                if not matches[rarity] then matches[rarity] = {} end
                table.insert(matches[rarity], npc)
                break 
            end
        end
    end

    for _, rarity in ipairs(PriorityList) do
        if matches[rarity] and #matches[rarity] > 0 then
            return matches[rarity][math.random(1, #matches[rarity])], rarity
        end
    end
    return nil
end

-- --- INTERFACE MOBILE ---
local function AskToCollect(npcName, npcObject)
    if States.Asking then return end 
    States.Asking = true
    
    local askGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
    askGui.Name = "ShadowAsk"
    
    local frame = Instance.new("Frame", askGui)
    frame.Size = UDim2.new(0, 260, 0, 100)
    frame.Position = UDim2.new(0.5, -130, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", frame)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 150, 255)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 50)
    label.Text = "NPC ENCONTRADO:\n" .. npcName
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    
    local s = Instance.new("TextButton", frame)
    s.Size = UDim2.new(0, 100, 0, 35); s.Position = UDim2.new(0.1, 0, 0.55, 0)
    s.Text = "COLETAR"; s.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    s.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", s)
    
    local n = Instance.new("TextButton", frame)
    n.Size = UDim2.new(0, 100, 0, 35); n.Position = UDim2.new(0.55, 0, 0.55, 0)
    n.Text = "IGNORAR"; n.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    n.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", n)
    
    s.MouseButton1Click:Connect(function() 
        askGui:Destroy()
        collectSpecific(npcObject)
        States.Asking = false 
    end)
    n.MouseButton1Click:Connect(function() askGui:Destroy(); States.Asking = false end)
end

-- --- LOOP DE CONTROLE ---
task.spawn(function()
    while true do
        task.wait(0.8) -- Delay seguro para evitar lag no mobile
        if States.FarmAuto then
            local target = GetBestNPC()
            if target then collectSpecific(target) end
        end
        if States.FarmInteractive and not States.Asking then
            local target, name = GetBestNPC()
            if target then AskToCollect(name:upper(), target) end
        end
    end
end)

-- --- PAINEL PRINCIPAL ---
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "ShadowHub_Mobile"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)

local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 40); GuiTitle.Text = "SHADOW HUB V22"; GuiTitle.Font = Enum.Font.GothamBold; GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255); GuiTitle.TextSize = 16; GuiTitle.BackgroundTransparency = 1

local function CreateBtn(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 40); btn.Position = pos
    btn.Text = text; btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

local AutoBtn = CreateBtn("AUTO FARM: OFF", UDim2.new(0, 15, 0, 50), function(self)
    States.FarmAuto = not States.FarmAuto
    self.Text = States.FarmAuto and "AUTO FARM: ON" or "AUTO FARM: OFF"
    self.TextColor3 = States.FarmAuto and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

local InterBtn = CreateBtn("MODO MANUAL: OFF", UDim2.new(0, 15, 0, 100), function(self)
    States.FarmInteractive = not States.FarmInteractive
    self.Text = States.FarmInteractive and "MODO MANUAL: ON" or "MODO MANUAL: OFF"
    self.TextColor3 = States.FarmInteractive and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
end)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 45, 0, 45); OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.Text = "S"; OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255); Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 150, 255)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
