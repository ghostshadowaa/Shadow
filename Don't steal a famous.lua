-- Shadow Hub: V22 - Mobile Optimized (Lite Edition)
local Player = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES OTIMIZADAS
local States = { FarmAuto = false, FarmInteractive = false, Asking = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

-- Cache de serviços para performance
local Workspace = game:GetService("Workspace")

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
Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

-- Coleta Otimizada (Evita Wait desnecessário)
local function collectSpecific(targetNPC)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root and targetNPC and SavedSpawnCFrame then
        local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local originalPos = root.CFrame
            root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
            
            task.wait(0.15) -- Reduzido para resposta mais rápida
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

-- Busca de NPC Otimizada (Evita loops excessivos de string)
local function GetBestNPC()
    local mapPath = Workspace:FindFirstChild("Map")
    local folder = mapPath and mapPath.Zones.Field:FindFirstChild("NPC")
    if not folder then return nil end
    
    local children = folder:GetChildren()
    local foundNPCs = {}

    for _, npc in ipairs(children) do
        local combinedData = ""
        -- Busca apenas em nomes e valores essenciais para economizar CPU
        for _, d in ipairs(npc:GetChildren()) do
            if d:IsA("StringValue") then
                combinedData = combinedData .. d.Value
            elseif d:IsA("Model") or d:IsA("Part") then
                combinedData = combinedData .. d.Name
            end
        end

        for _, priority in ipairs(PriorityList) do
            if string.find(string.lower(combinedData), string.lower(priority)) then
                if not foundNPCs[priority] then foundNPCs[priority] = {} end
                table.insert(foundNPCs[priority], npc)
                break 
            end
        end
    end

    for _, priority in ipairs(PriorityList) do
        if foundNPCs[priority] and #foundNPCs[priority] > 0 then
            return foundNPCs[priority][math.random(1, #foundNPCs[priority])], priority
        end
    end
    return nil
end

-- --- INTERFACE MOBILE LITE ---
local function AskToCollect(npcName, npcObject)
    if States.Asking then return end 
    States.Asking = true
    
    local askGui = Instance.new("ScreenGui")
    askGui.Name = "ShadowAsk"
    askGui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame", askGui)
    frame.Size = UDim2.new(0, 280, 0, 90) -- Menor para telas de celular
    frame.Position = UDim2.new(0.5, -140, 0.1, -150)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Instance.new("UICorner", frame)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 40)
    label.Text = "COLETAR: " .. npcName .. "?"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    
    local s = Instance.new("TextButton", frame)
    s.Size = UDim2.new(0, 110, 0, 30); s.Position = UDim2.new(0.1, 0, 0.55, 0)
    s.Text = "SIM"; s.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    s.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", s)
    
    local n = Instance.new("TextButton", frame)
    n.Size = UDim2.new(0, 110, 0, 30); n.Position = UDim2.new(0.55, 0, 0.55, 0)
    n.Text = "NÃO"; n.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    n.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", n)
    
    frame:TweenPosition(UDim2.new(0.5, -140, 0.15, 0), "Out", "Quad", 0.3, true)
    
    s.MouseButton1Click:Connect(function() 
        States.Asking = false
        collectSpecific(npcObject)
        askGui:Destroy()
    end)
    n.MouseButton1Click:Connect(function() 
        States.Asking = false 
        askGui:Destroy() 
    end)
end

-- --- LOOP DE CONTROLE (Otimizado com task.wait adaptável) ---
task.spawn(function()
    while true do
        -- Intervalo maior (0.5s) economiza muita bateria e CPU no mobile
        task.wait(0.5)
        
        if (States.FarmAuto or States.FarmInteractive) and not States.Asking then
            local target, name = GetBestNPC()
            if target then
                if States.FarmAuto then
                    collectSpecific(target)
                elseif States.FarmInteractive then
                    AskToCollect(name:upper(), target)
                end
            end
        end
    end
end)

-- --- PAINEL PRINCIPAL (Estilo Mobile-Friendly) ---
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "ShadowHub_Mobile"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 150)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = true
Instance.new("UICorner", MainFrame)

local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 40)
GuiTitle.Text = "SHADOW LITE V22"
GuiTitle.Font = Enum.Font.GothamBold
GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
GuiTitle.TextSize = 16
GuiTitle.BackgroundTransparency = 1

-- Animação simplificada (Menos estresse na GPU)
task.spawn(function()
    while MainFrame do
        local tween = TweenService:Create(GuiTitle, TweenInfo.new(2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
        tween:Play()
        task.wait(2)
        local tween2 = TweenService:Create(GuiTitle, TweenInfo.new(2), {TextColor3 = Color3.fromRGB(0, 150, 255)})
        tween2:Play()
        task.wait(2)
    end
end)

local function CreateBtn(text, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function() callback(btn) end)
    return btn
end

local AutoBtn = CreateBtn("AUTO FARM: OFF", UDim2.new(0, 15, 0, 50), function(self)
    States.FarmAuto = not States.FarmAuto
    self.Text = States.FarmAuto and "AUTO FARM: ON" or "AUTO FARM: OFF"
    self.BackgroundColor3 = States.FarmAuto and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 30)
end)

local InterBtn = CreateBtn("INTERATIVO: OFF", UDim2.new(0, 15, 0, 95), function(self)
    States.FarmInteractive = not States.FarmInteractive
    self.Text = States.FarmInteractive and "INTERATIVO: ON" or "INTERATIVO: OFF"
    self.BackgroundColor3 = States.FarmInteractive and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 30)
end)

-- Botão de Minimizar Flutuante
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -20)
OpenBtn.Text = "S"
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

OpenBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)
