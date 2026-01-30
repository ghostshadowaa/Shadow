-- Shadow Hub: Premium Stealth (CORRIGIDO)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES DE LÓGICA
local States = { Farm = false, Upgrade = false }
local BaseCFrame = CFrame.new(-29.6688538, -1.23751986, 57.1520157, 0, -1, 0, 0, 0, -1, 1, 0, 0)
local SafeHeight = -1.23751986 
local npcFolder = workspace.Map.Zones.Field.NPC

-- TENTA ENCONTRAR OS SLOTS AUTOMATICAMENTE (Correção do erro do print)
local function GetSlotsPath()
    local plot = workspace.Map.Plots.Plot2:FindFirstChild("Plot")
    if plot then
        -- Tenta achar "Slots" ou "slots"
        return plot:FindFirstChild("Slots") or plot:FindFirstChild("slots")
    end
    return nil
end

-- --- INTERFACE VISUAL ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Premium"
ScreenGui.DisplayOrder = 999

local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

local function createToggle(name, pos, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", btn)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(45, 45, 45)

    btn.MouseButton1Click:Connect(function()
        States[key] = not States[key]
        btn.TextColor3 = States[key] and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(200, 200, 200)
        btnStroke.Color = States[key] and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(45, 45, 45)
    end)
end

createToggle("AGRESSIVE FARM", UDim2.new(0, 15, 0, 55), "Farm")
createToggle("AUTO UPGRADE", UDim2.new(0, 15, 0, 110), "Upgrade")

OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- --- LÓGICA DE UPGRADE (COM FIX DE ERRO) ---
spawn(function()
    while true do
        task.wait(1)
        if States.Upgrade then
            local slots = GetSlotsPath()
            if slots then
                for i = 1, 16 do
                    local slot = slots:FindFirstChild(tostring(i))
                    if slot and slot:FindFirstChild("UpgradeSing") then
                        firetouchinterest(Player.Character.HumanoidRootPart, slot.UpgradeSing, 0)
                        firetouchinterest(Player.Character.HumanoidRootPart, slot.UpgradeSing, 1)
                    end
                end
            else
                print("Shadow Hub: Pasta Slots não encontrada! Verifique o caminho.")
            end
        end
    end
end)

-- --- LÓGICA DE FARM (MANTIDA) ---
local function AgressiveCollect(npc)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local npcRoot = npc:FindFirstChildWhichIsA("BasePart") or npc:FindFirstChild("HumanoidRootPart")
    if root and npcRoot then
        root.CFrame = CFrame.new(npcRoot.Position.X, SafeHeight, npcRoot.Position.Z)
        for i = 1, 5 do
            firetouchinterest(root, npcRoot, 0)
            firetouchinterest(root, npcRoot, 1)
            task.wait()
        end
    end
end

spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm then
            local targetNPC = nil
            for _, v in pairs(npcFolder:GetChildren()) do
                if v:FindFirstChildWhichIsA("BasePart") or v:FindFirstChild("HumanoidRootPart") then
                    targetNPC = v
                    break
                end
            end
            if targetNPC then
                AgressiveCollect(targetNPC)
                task.wait(0.15) 
                Player.Character.HumanoidRootPart.CFrame = BaseCFrame
                task.wait(0.4)
            end
        end
    end
end)
