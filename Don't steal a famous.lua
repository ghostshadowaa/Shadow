-- Shadow Hub: Definitive Elite Edition (Aura Target Fix)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local BasePos = Vector3.new(-29.6688538, 3, 57.1520157) 
local TweenSpeed = 100 -- Velocidade equilibrada
local SafeHeightOffset = 3.5
local AuraRadius = 15 -- Raio da aura de coleta ao chegar no destino

-- HIERARQUIA DE PRIORIDADE
local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_AuraTarget"
ScreenGui.ResetOnSpawn = false

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
GuiTitle.Text = "SHADOW HUB (AURA)"
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
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Color = Color3.fromRGB(0, 150, 255)

-- --- LÓGICA DE INTERAÇÃO (AURA) ---
local function collectAura()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local npcs = workspace.Map.Zones.Field:FindFirstChild("NPC")
    if root and npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            local part = npc:FindFirstChildWhichIsA("BasePart", true)
            if part then
                local distance = (root.Position - part.Position).Magnitude
                if distance <= AuraRadius then
                    -- Interação Instantânea
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
    local folder = workspace.Map.Zones.Field:FindFirstChild("NPC")
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

-- --- LOOP DE FARM COM AURA ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm then
            pcall(function()
                local target = GetBestNPC()
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if target and root then
                    local part = target:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        -- MOVIMENTO ATÉ O ALVO
                        local dist = (root.Position - part.Position).Magnitude
                        local t1 = TweenService:Create(root, TweenInfo.new(dist/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)})
                        t1:Play()
                        t1.Completed:Wait()
                        
                        -- ATIVA AURA DE COLETA AO CHEGAR
                        task.wait(0.2)
                        collectAura() -- Pega o alvo e qualquer outro NPC próximo
                        task.wait(0.2)
                        
                        -- RETORNO
                        local dist2 = (root.Position - BasePos).Magnitude
                        local t2 = TweenService:Create(root, TweenInfo.new(dist2/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(BasePos)})
                        t2:Play()
                        t2.Completed:Wait()
                    end
                end
            end)
        end
    end
end)
