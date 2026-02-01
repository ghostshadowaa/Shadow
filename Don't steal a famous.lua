--- Shadow Hub: Definitive Elite Edition (New GUI)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- CONFIGURAÇÕES
local States = { Farm = false }
local BasePos = Vector3.new(-29.6688538, 3, 57.1520157) 
local TweenSpeed = 250 
local SafeHeightOffset = 3

-- HIERARQUIA DE PRIORIDADE (OldGen no TOPO)
local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- INTERFACE ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Ultimate_V3"
ScreenGui.ResetOnSpawn = false

-- --- TELA DE CARREGAMENTO (MANTIDA POIS VC GOSTOU) ---
local LoadingFrame = Instance.new("Frame", ScreenGui)
LoadingFrame.Size = UDim2.new(1, 0, 1, 100)
LoadingFrame.Position = UDim2.new(0, 0, 0, -50)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LoadingFrame.ZIndex = 1000

local LoaderTitle = Instance.new("TextLabel", LoadingFrame)
LoaderTitle.Size = UDim2.new(1, 0, 0, 100)
LoaderTitle.Position = UDim2.new(0, 0, 0.4, 0)
LoaderTitle.Text = "SHADOW HUB"
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
LoaderTitle.TextSize = 50
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.ZIndex = 1001

local BarBack = Instance.new("Frame", LoadingFrame)
BarBack.Size = UDim2.new(0, 300, 0, 3)
BarBack.Position = UDim2.new(0.5, -150, 0.52, 0)
BarBack.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BarBack.BorderSizePixel = 0
BarBack.ZIndex = 1001

local BarFill = Instance.new("Frame", BarBack)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BarFill.ZIndex = 1002

-- --- GUI PRINCIPAL (MELHORADA) ---
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 140)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.5

local GuiTitle = Instance.new("TextLabel", MainFrame)
GuiTitle.Size = UDim2.new(1, 0, 0, 40)
GuiTitle.Text = "SHADOW HUB"
GuiTitle.Font = Enum.Font.GothamBold
GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
GuiTitle.TextSize = 18
GuiTitle.BackgroundTransparency = 1

local Line = Instance.new("Frame", MainFrame)
Line.Size = UDim2.new(0.8, 0, 0, 1)
Line.Position = UDim2.new(0.1, 0, 0, 35)
Line.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Line.BorderSizePixel = 0

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 210, 0, 45)
FarmBtn.Position = UDim2.new(0, 15, 0, 55)
FarmBtn.Text = "AUTO FARM"
FarmBtn.Font = Enum.Font.GothamSemibold
FarmBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FarmBtn.AutoButtonColor = false
Instance.new("UICorner", FarmBtn).CornerRadius = UDim.new(0, 8)
local BtnStroke = Instance.new("UIStroke", FarmBtn)
BtnStroke.Color = Color3.fromRGB(30, 30, 30)

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
OpenStroke.Thickness = 2

-- --- LÓGICA DE INTERAÇÃO DO HUB ---
FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    local targetColor = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(150, 150, 150)
    local targetBg = States.Farm and Color3.fromRGB(0, 40, 80) or Color3.fromRGB(20, 20, 20)
    
    TweenService:Create(FarmBtn, TweenInfo.new(0.3), {TextColor3 = targetColor, BackgroundColor3 = targetBg}):Play()
    TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Color = targetColor}):Play()
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    TweenService:Create(OpenBtn, TweenInfo.new(0.2), {Rotation = MainFrame.Visible and 90 or 0}):Play()
end)

-- --- LÓGICA DE COLETA E PRIORIDADE (MANTIDAS) ---
local function interact(npc)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    local part = npc:FindFirstChildWhichIsA("BasePart", true)
    if root and part then
        for i = 1, 3 do
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
            for _, p in pairs(npc:GetDescendants()) do
                if p:IsA("ProximityPrompt") then p.HoldDuration = 0 fireproximityprompt(p) end
            end
        end
    end
end

local function GetBestNPC()
    local children = workspace.Map.Zones.Field.NPC:GetChildren()
    local sorted = {}
    for _, r in ipairs(PriorityList) do sorted[r] = {} end
    for _, npc in pairs(children) do
        local txt = ""
        for _, d in pairs(npc:GetDescendants()) do
            if d:IsA("TextLabel") then txt = txt .. " " .. d.Text
            elseif d:IsA("StringValue") then txt = txt .. " " .. d.Value end
        end
        for _, r in ipairs(PriorityList) do
            if string.find(string.lower(txt), string.lower(r)) then table.insert(sorted[r], npc) break end
        end
    end
    for _, r in ipairs(PriorityList) do
        if #sorted[r] > 0 then return sorted[r][math.random(1, #sorted[r])] end
    end
    return children[math.random(1, #children)]
end

-- --- ANIMAÇÃO DE LOADING ---
task.spawn(function()
    BarFill:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Quart", 2.2, true)
    task.wait(2.4)
    TweenService:Create(LoadingFrame, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    TweenService:Create(LoaderTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.8)
    LoadingFrame.Visible = false
    OpenBtn.Visible = true
end)

-- --- LOOP DE FARM ---
task.spawn(function()
    while true do
        task.wait(0.1)
        if States.Farm then
            pcall(function()
                local target = GetBestNPC()
                if target then
                    local part = target:FindFirstChildWhichIsA("BasePart", true)
                    local char = Player.Character
                    if part and char and char:FindFirstChild("HumanoidRootPart") then
                        -- Ir
                        local dist1 = (char.HumanoidRootPart.Position - part.Position).Magnitude
                        local t1 = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist1/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)})
                        t1:Play() t1.Completed:Wait()
                        interact(target)
                        task.wait(0.2)
                        -- Voltar
                        local dist2 = (char.HumanoidRootPart.Position - BasePos).Magnitude
                        local t2 = TweenService:Create(char.HumanoidRootPart, TweenInfo.new(dist2/TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(BasePos)})
                        t2:Play() t2.Completed:Wait()
                    end
                end
            end)
        end
    end
end)
