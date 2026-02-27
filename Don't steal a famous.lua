-- Shadow Hub: V22 - Unified Collector Logic (Instant Edition) [FIXED]
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES
local States = { FarmAuto = false, FarmInteractive = false, Asking = false, Active = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- VARIÁVEIS DE CONTROLE DE CONEXÕES
local Connections = {}
local AnimationConnection = nil
local MainLoopConnection = nil

-- --- FUNÇÕES UTILITÁRIAS ---

local function DisconnectAll()
    for _, conn in pairs(Connections) do
        if conn then conn:Disconnect() end
    end
    Connections = {}
    if AnimationConnection then
        AnimationConnection:Disconnect()
        AnimationConnection = nil
    end
    if MainLoopConnection then
        MainLoopConnection:Disconnect()
        MainLoopConnection = nil
    end
end

local function CaptureSpawn()
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        SavedSpawnCFrame = root.CFrame
    end
end

-- --- FUNÇÕES DE COLETA ---

local function collectSpecific(targetNPC)
    if not States.Active then return end
    local char = Player.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root or not targetNPC then return end
    
    local part = targetNPC:FindFirstChildWhichIsA("BasePart", true)
    if not part then return end
    
    -- Salvar posição original
    local originalCFrame = root.CFrame
    
    -- Teleporte com proteção
    local success = pcall(function()
        root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
    end)
    
    if not success then return end
    
    task.wait(0.3)
    
    -- Fire touch com proteção
    pcall(function()
        firetouchinterest(root, part, 0)
        firetouchinterest(root, part, 1)
    end)
    
    -- Proximity prompt
    local prompt = targetNPC:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt.HoldDuration = 0
        pcall(function()
            fireproximityprompt(prompt)
        end)
    end
    
    task.wait(0.1)
    
    -- Retornar se ainda estiver ativo
    if States.Active and SavedSpawnCFrame then
        pcall(function()
            root.CFrame = SavedSpawnCFrame
        end)
    end
end

local function GetBestNPC()
    local folder = workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("Zones") 
        and workspace.Map.Zones:FindFirstChild("Field") 
        and workspace.Map.Zones.Field:FindFirstChild("NPC")
    
    if not folder then return nil end
    
    local children = folder:GetChildren()
    if #children == 0 then return nil end
    
    local sorted = {}
    for _, r in ipairs(PriorityList) do sorted[r] = {} end
    
    for _, npc in pairs(children) do
        if not npc:IsA("Model") then continue end
        
        local txt = ""
        for _, d in pairs(npc:GetDescendants()) do
            if d:IsA("TextLabel") then 
                txt = txt .. " " .. d.Text
            elseif d:IsA("StringValue") then 
                txt = txt .. " " .. d.Value 
            end
        end
        
        for _, r in ipairs(PriorityList) do
            if string.find(string.lower(txt), string.lower(r)) then
                table.insert(sorted[r], npc)
                break
            end
        end
    end
    
    for _, r in ipairs(PriorityList) do
        if #sorted[r] > 0 then 
            return sorted[r][math.random(1, #sorted[r])], r 
        end
    end
    return nil
end

-- --- INTERFACE DE PERGUNTA ---

local function AskToCollect(npcName, npcObject)
    if States.Asking or not States.FarmInteractive then return end 
    
    States.Asking = true
    
    -- Verificar se já existe gui
    local existing = Player.PlayerGui:FindFirstChild("ShadowAsk")
    if existing then existing:Destroy() end
    
    local askGui = Instance.new("ScreenGui")
    askGui.Name = "ShadowAsk"
    askGui.Parent = Player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 100)
    frame.Position = UDim2.new(0.5, -160, -0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.Parent = askGui
    
    local corner = Instance.new("UICorner")
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 50)
    label.Text = "NPC: " .. npcName .. "\nDESEJA COLETAR?"
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = frame
    
    local s = Instance.new("TextButton")
    s.Size = UDim2.new(0, 130, 0, 35)
    s.Position = UDim2.new(0, 20, 0, 55)
    s.Text = "SIM"
    s.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    s.TextColor3 = Color3.new(1,1,1)
    s.Font = Enum.Font.GothamBold
    s.Parent = frame
    
    local sCorner = Instance.new("UICorner")
    sCorner.Parent = s
    
    local n = Instance.new("TextButton")
    n.Size = UDim2.new(0, 130, 0, 35)
    n.Position = UDim2.new(0, 170, 0, 55)
    n.Text = "NÃO"
    n.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    n.TextColor3 = Color3.new(1,1,1)
    n.Font = Enum.Font.GothamBold
    n.Parent = frame
    
    local nCorner = Instance.new("UICorner")
    nCorner.Parent = n
    
    frame:TweenPosition(UDim2.new(0.5, -160, 0.1, 0), "Out", "Back", 0.5)
    
    local function cleanup()
        if askGui and askGui.Parent then
            askGui:Destroy()
        end
        States.Asking = false
    end
    
    s.MouseButton1Click:Connect(function()
        if States.FarmInteractive then
            collectSpecific(npcObject)
        end
        cleanup()
    end)
    
    n.MouseButton1Click:Connect(cleanup)
    
    -- Auto-fechar após 10 segundos
    task.delay(10, cleanup)
end

-- --- LOOP PRINCIPAL CONTROLADO ---

local function StartMainLoop()
    if MainLoopConnection then return end
    
    MainLoopConnection = RunService.Heartbeat:Connect(function()
        if not States.Active then return end
        
        -- Verificar a cada 0.5 segundos (não a cada frame)
        if tick() % 0.5 > 0.1 then return end
        
        if States.FarmAuto and SavedSpawnCFrame then
            local target = GetBestNPC()
            if target then 
                collectSpecific(target)
                task.wait(0.5) -- Delay entre coletas
            end
        end
        
        if States.FarmInteractive and not States.Asking then
            local target, name = GetBestNPC()
            if target then 
                AskToCollect(name:upper(), target)
                task.wait(2) -- Delay maior para interativo
            end
        end
    end)
end

-- --- PAINEL PRINCIPAL ---

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHub_Adrian"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Título
local GuiTitle = Instance.new("TextLabel")
GuiTitle.Size = UDim2.new(1, 0, 0, 50)
GuiTitle.Text = "SHADOW HUB V22"
GuiTitle.Font = Enum.Font.GothamBold
GuiTitle.TextColor3 = Color3.fromRGB(0, 150, 255)
GuiTitle.TextSize = 20
GuiTitle.BackgroundTransparency = 1
GuiTitle.Parent = MainFrame

-- Animação otimizada (só quando visível)
local lastColor = tick()
local function UpdateAnimation()
    if not MainFrame.Visible then return end
    if tick() - lastColor < 2 then return end
    
    lastColor = tick()
    local current = GuiTitle.TextColor3
    local target = (current.R > 0.5) and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 255, 255)
    
    TweenService:Create(GuiTitle, TweenInfo.new(1), {TextColor3 = target}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(1), {Color = target}):Play()
end

-- Botões
local function StyleButton(btn)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    local btnCorner = Instance.new("UICorner")
    btnCorner.Parent = btn
    local bstroke = Instance.new("UIStroke")
    bstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bstroke.Color = Color3.fromRGB(30,30,30)
    bstroke.Parent = btn
end

local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(0, 230, 0, 45)
AutoBtn.Position = UDim2.new(0, 15, 0, 60)
AutoBtn.Text = "AUTO FARM: OFF"
AutoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
AutoBtn.TextColor3 = Color3.new(1,1,1)
AutoBtn.Parent = MainFrame
StyleButton(AutoBtn)

local InterBtn = Instance.new("TextButton")
InterBtn.Size = UDim2.new(0, 230, 0, 45)
InterBtn.Position = UDim2.new(0, 15, 0, 115)
InterBtn.Text = "INTERATIVO: OFF"
InterBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InterBtn.TextColor3 = Color3.new(1,1,1)
InterBtn.Parent = MainFrame
StyleButton(InterBtn)

-- Toggle functions
local function UpdateState()
    States.Active = States.FarmAuto or States.FarmInteractive
    
    if States.Active then
        StartMainLoop()
    end
end

AutoBtn.MouseButton1Click:Connect(function()
    States.FarmAuto = not States.FarmAuto
    AutoBtn.Text = States.FarmAuto and "AUTO FARM: ON" or "AUTO FARM: OFF"
    AutoBtn.BackgroundColor3 = States.FarmAuto and Color3.fromRGB(0, 60, 120) or Color3.fromRGB(20, 20, 20)
    AutoBtn.TextColor3 = States.FarmAuto and Color3.fromRGB(0, 200, 255) or Color3.new(1,1,1)
    
    -- Desativar interativo se auto ligar
    if States.FarmAuto and States.FarmInteractive then
        States.FarmInteractive = false
        InterBtn.Text = "INTERATIVO: OFF"
        InterBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        InterBtn.TextColor3 = Color3.new(1,1,1)
    end
    
    UpdateState()
end)

InterBtn.MouseButton1Click:Connect(function()
    States.FarmInteractive = not States.FarmInteractive
    InterBtn.Text = States.FarmInteractive and "INTERATIVO: ON" or "INTERATIVO: OFF"
    InterBtn.BackgroundColor3 = States.FarmInteractive and Color3.fromRGB(0, 60, 120) or Color3.fromRGB(20, 20, 20)
    InterBtn.TextColor3 = States.FarmInteractive and Color3.fromRGB(0, 200, 255) or Color3.new(1,1,1)
    
    -- Desativar auto se interativo ligar
    if States.FarmInteractive and States.FarmAuto then
        States.FarmAuto = false
        AutoBtn.Text = "AUTO FARM: OFF"
        AutoBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        AutoBtn.TextColor3 = Color3.new(1,1,1)
    end
    
    UpdateState()
end)

-- Botão abrir/fechar
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"
OpenBtn.Visible = true
OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenBtn.TextColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Parent = ScreenGui
StyleButton(OpenBtn)

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = OpenBtn

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(0, 150, 255)
openStroke.Parent = OpenBtn

OpenBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = not MainFrame.Visible 
end)

-- Inicialização segura
task.spawn(function()
    -- Aguardar personagem
    if not Player.Character then
        Player.CharacterAdded:Wait()
    end
    task.wait(1)
    CaptureSpawn()
    
    -- Conectar ao respawn
    table.insert(Connections, Player.CharacterAdded:Connect(function()
        task.wait(1)
        CaptureSpawn()
    end))
end)

-- Loop de animação ligado ao Heartbeat
AnimationConnection = RunService.Heartbeat:Connect(UpdateAnimation)

-- Cleanup quando o jogador sai
Player.AncestryChanged:Connect(function()
    if not Player:IsDescendantOf(game) then
        DisconnectAll()
    end
end)

print("Shadow Hub V22 [FIXED] carregado com sucesso!")
