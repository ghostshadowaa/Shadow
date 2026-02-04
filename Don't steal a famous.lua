-- Shadow Hub: V22 - Unified Collector Logic (Instant Edition)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES (MANTIDAS)
local States = { FarmAuto = false, FarmInteractive = false, Asking = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- FUNÇÕES ORIGINAIS ---

local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5) 
    SavedSpawnCFrame = root.CFrame
end
Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

local function collectSpecific(targetNPC)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if root and targetNPC then
        local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
        if part then
            root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
            task.wait(0.3) 
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
            local prompt = targetNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                prompt.HoldDuration = 0
                fireproximityprompt(prompt)
            end
            task.wait(0.1)
            root.CFrame = SavedSpawnCFrame
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
        if #sorted[r] > 0 then return sorted[r][math.random(1, #sorted[r])], r end
    end
    return nil
end

-- --- INTERFACE DE PERGUNTA ---
local function AskToCollect(npcName, npcObject)
    if States.Asking then return end 
    States.Asking = true
    local askGui = Instance.new("ScreenGui", Player.PlayerGui)
    askGui.Name = "ShadowAsk"
    
    local frame = Instance.new("Frame", askGui)
    frame.Size = UDim2.new(0, 320, 0, 100); frame.Position = UDim2.new(0.5, -160, -0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", frame)
    local stroke = Instance.new("UIStroke", frame); stroke.Color = Color3.fromRGB(0, 150, 255); stroke.Thickness = 2
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 50); label.Text = "NPC: " .. npcName .. "\nDESEJA COLETAR?"; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.TextSize = 14
    
    local s = Instance.new("TextButton", frame); s.Size = UDim2.new(0, 130, 0, 35); s.Position = UDim2.new(0, 20, 0, 55); s.Text = "SIM"; s.BackgroundColor3 = Color3.fromRGB(0, 120, 255); s.TextColor3 = Color3.new(1,1,1); s.Font = Enum.Font.GothamBold; Instance.new("UICorner", s)
    local n = Instance.new("TextButton", frame); n.Size = UDim2.new(0, 130, 0, 35); n.Position = UDim2.new(0, 170, 0, 55); n.Text = "NÃO"; n.BackgroundColor3 = Color3.fromRGB(40, 40, 40); n.TextColor3 = Color3.new(1,1,1); n.Font = Enum.Font.GothamBold; Instance.new("UICorner", n)
    
    frame:TweenPosition(UDim2.new(0.5, -160, 0.1, 0), "Out", "Back", 0.5)
    
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
        task.wait(0.2)
        if States.FarmAuto and SavedSpawnCFrame then
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
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Adrian"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 180); MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10); MainFrame.Visible = true -- VISÍVEL AO CARREGAR
Instance.new("UICorner", MainFrame)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Color3.fromRGB(0, 150, 255); MainStroke.Thickness = 2

-- Título Neon Pulsante
local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 50); GuiTitle.Text = "SHADOW HUB V22"; GuiTitle.Font = Enum.Font.GothamBold; GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255); GuiTitle.TextSize = 20; GuiTitle.BackgroundTransparency = 1

task.spawn(function()
    while true do
        TweenService:Create(GuiTitle, TweenInfo.new(1), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(MainStroke, TweenInfo.new(1), {Color = Color3.fromRGB(255, 255, 255)}):Play()
        task.wait(1)
        TweenService:Create(GuiTitle, TweenInfo.new(1), {TextColor3 = Color3.fromRGB(0, 150, 255)}):Play()
        TweenService:Create(MainStroke, TweenInfo.new(1), {Color = Color3.fromRGB(0, 150, 255)}):Play()
        task.wait(1)
    end
end)

local function StyleButton(btn)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    local bstroke = Instance.new("UIStroke", btn); bstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; bstroke.Color = Color3.fromRGB(30,30,30)
end

local AutoBtn = Instance.new("TextButton", MainFrame)
AutoBtn.Size = UDim2.new(0, 230, 0, 45); AutoBtn.Position = UDim2.new(0, 15, 0, 60); AutoBtn.Text = "AUTO FARM: OFF"; AutoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); AutoBtn.TextColor3 = Color3.new(1,1,1); StyleButton(AutoBtn)

local InterBtn = Instance.new("TextButton", MainFrame)
InterBtn.Size = UDim2.new(0, 230, 0, 45); InterBtn.Position = UDim2.new(0, 15, 0, 115); InterBtn.Text = "INTERATIVO: OFF"; InterBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); InterBtn.TextColor3 = Color3.new(1,1,1); StyleButton(InterBtn)

AutoBtn.MouseButton1Click:Connect(function()
    States.FarmAuto = not States.FarmAuto
    AutoBtn.Text = States.FarmAuto and "AUTO FARM: ON" or "AUTO FARM: OFF"
    AutoBtn.BackgroundColor3 = States.FarmAuto and Color3.fromRGB(0, 60, 120) or Color3.fromRGB(20, 20, 20)
    AutoBtn.TextColor3 = States.FarmAuto and Color3.fromRGB(0, 200, 255) or Color3.new(1,1,1)
end)

InterBtn.MouseButton1Click:Connect(function()
    States.FarmInteractive = not States.FarmInteractive
    InterBtn.Text = States.FarmInteractive and "INTERATIVO: ON" or "INTERATIVO: OFF"
    InterBtn.BackgroundColor3 = States.FarmInteractive and Color3.fromRGB(0, 60, 120) or Color3.fromRGB(20, 20, 20)
    InterBtn.TextColor3 = States.FarmInteractive and Color3.fromRGB(0, 200, 255) or Color3.new(1,1,1)
end)

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 20, 0.5, -25); OpenBtn.Text = "S"; OpenBtn.Visible = true; OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15); OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255); StyleButton(OpenBtn); OpenBtn.UICorner.CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 150, 255)

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
