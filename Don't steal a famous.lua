-- Shadow Hub: Premium Stealth & Agressive TP (v3 Ultra-Fix)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- CONFIGURAÇÕES DE LÓGICA
local States = { Farm = false, Upgrade = false }
local BaseCFrame = CFrame.new(-29.6688538, -1.23751986, 57.1520157, 0, -1, 0, 0, 0, -1, 1, 0, 0)
local SafeHeight = -1.23751986 
local npcFolder = workspace.Map.Zones.Field.NPC

-- --- INTERFACE VISUAL ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_UltraFix"
ScreenGui.DisplayOrder = 9999 -- Garante prioridade máxima de visão

-- TELA DE CARREGAMENTO (ESTILIZADA)
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 100)
LoadingFrame.Position = UDim2.new(0, 0, 0, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
LoadingFrame.ZIndex = 10000

local LoaderTitle = Instance.new("TextLabel", LoadingFrame)
LoaderTitle.Size = UDim2.new(1, 0, 0, 100)
LoaderTitle.Position = UDim2.new(0, 0, 0.45, 0)
LoaderTitle.Text = "EXECUTANDO SHADOW HUB"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 25
LoaderTitle.TextColor3 = Color3.new(1, 1, 1)
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.ZIndex = 10001

-- INTERFACE PRINCIPAL
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 24
OpenBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OpenBtn.Visible = false
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 190)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -95)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)

-- Botões de Toggle
local function createToggle(name, pos, key)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 190, 0, 45)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
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

-- --- ANIMAÇÃO DE ENTRADA CORRIGIDA ---
task.spawn(function()
    task.wait(0.5)
    -- Efeito de fade no texto
    for i = 1, 3 do
        TweenService:Create(LoaderTitle, TweenInfo.new(0.3), {TextTransparency = 0.5}):Play()
        task.wait(0.3)
        TweenService:Create(LoaderTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        task.wait(0.3)
    end
    
    -- Sumir tela de carregamento
    local fade = TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    fade:Play()
    fade.Completed:Wait()
    
    LoadingFrame.Visible = false
    OpenBtn.Visible = true
    MainFrame.Visible = true
    MainFrame:TweenSize(UDim2.new(0, 220, 0, 190), "Out", "Back", 0.3, true)
end)

-- --- LÓGICA DE UPGRADE (FIX SLOTS) ---
spawn(function()
    while true do
        task.wait(1)
        if States.Upgrade then
            pcall(function()
                local plot = workspace.Map.Plots.Plot2:FindFirstChild("Plot")
                local slots = plot and (plot:FindFirstChild("Slots") or plot:FindFirstChild("slots"))
                if slots then
                    for i = 1, 16 do
                        local slot = slots:FindFirstChild(tostring(i))
                        if slot and slot:FindFirstChild("UpgradeSing") then
                            firetouchinterest(Player.Character.HumanoidRootPart, slot.UpgradeSing, 0)
                            firetouchinterest(Player.Character.HumanoidRootPart, slot.UpgradeSing, 1)
                        end
                    end
                end
            end)
        end
    end
end)

-- --- LÓGICA DE FARM AGRESSIVO ---
local function AgressiveCollect(npc)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local npcPart = npc:FindFirstChildWhichIsA("BasePart") or npc:FindFirstChild("HumanoidRootPart")
    if root and npcPart then
        root.CFrame = CFrame.new(npcPart.Position.X, SafeHeight, npcPart.Position.Z)
        for i = 1, 5 do
            firetouchinterest(root, npcPart, 0)
            firetouchinterest(root, npcPart, 1)
            task.wait()
        end
    end
end

spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm then
            pcall(function()
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
            end)
        end
    end
end)
