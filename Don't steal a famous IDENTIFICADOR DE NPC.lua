-- Shadow Hub: V18 - Interactive Sniper (Confirm System)
local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- CONFIGURAÇÕES ORIGINAIS (MANTIDAS)
local States = { Farm = false, Asking = false }
local SavedSpawnCFrame = nil 
local SafeHeightOffset = 3.5

local PriorityList = {
    "OldGen", "Secret", "Youtuber god", 
    "Mythic", "Legendary", "Epic", "Rare", "Uncommon", "Common"
}

-- --- CAPTURAR SPAWN ---
local function CaptureSpawn()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    task.wait(0.5) 
    SavedSpawnCFrame = root.CFrame
end
Player.CharacterAdded:Connect(CaptureSpawn)
if Player.Character then task.spawn(CaptureSpawn) end

-- --- INTERFACE DE PERGUNTA NO TOPO (SIM/NÃO) ---
local function AskToCollect(npcName, npcObject)
    if States.Asking then return end -- Evita abrir várias janelas ao mesmo tempo
    States.Asking = true

    local sg = Player.PlayerGui:FindFirstChild("ShadowAsk") or Instance.new("ScreenGui", Player.PlayerGui)
    sg.Name = "ShadowAsk"
    
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 400, 0, 80)
    frame.Position = UDim2.new(0.5, -200, -0.2, 0) -- Começa fora da tela
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", frame)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 150, 255)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, 0, 0, 40)
    label.Text = "NPC DETECTADO: " .. npcName .. "\nDESEJA COLETAR?"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.BackgroundTransparency = 1

    local btnSim = Instance.new("TextButton", frame)
    btnSim.Size = UDim2.new(0, 180, 0, 30); btnSim.Position = UDim2.new(0, 15, 0, 40)
    btnSim.Text = "SIM"; btnSim.BackgroundColor3 = Color3.fromRGB(0, 120, 0); btnSim.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnSim)

    local btnNao = Instance.new("TextButton", frame)
    btnNao.Size = UDim2.new(0, 180, 0, 30); btnNao.Position = UDim2.new(0, 205, 0, 40)
    btnNao.Text = "NÃO"; btnNao.BackgroundColor3 = Color3.fromRGB(120, 0, 0); btnNao.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", btnNao)

    -- Animação de entrada
    frame:TweenPosition(UDim2.new(0.5, -200, 0.05, 0), "Out", "Back", 0.5)

    -- Função de fechar
    local function fechar()
        frame:TweenPosition(UDim2.new(0.5, -200, -0.2, 0), "In", "Back", 0.5)
        task.delay(0.6, function() sg:Destroy(); States.Asking = false end)
    end

    btnSim.MouseButton1Click:Connect(function()
        fechar()
        -- EXECUTA A SUA COLETA QUE FUNCIONA
        local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local part = npcObject:FindFirstChildWhichIsA("BasePart", true)
        if root and part and SavedSpawnCFrame then
            root.CFrame = part.CFrame * CFrame.new(0, SafeHeightOffset, 0)
            task.wait(0.4)
            -- Método do seu script
            firetouchinterest(root, part, 0)
            firetouchinterest(root, part, 1)
            local prompt = npcObject:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then prompt.HoldDuration = 0; fireproximityprompt(prompt) end
            task.wait(0.2)
            root.CFrame = SavedSpawnCFrame
        end
    end)

    btnNao.MouseButton1Click:Connect(function()
        fechar()
    end)
end

-- --- LÓGICA DE IDENTIFICAÇÃO ---
local function ScanForNPCs()
    local folder = workspace:FindFirstChild("Map") and workspace.Map.Zones.Field:FindFirstChild("NPC")
    if not folder then return end
    
    for _, r in ipairs(PriorityList) do
        for _, npc in pairs(folder:GetChildren()) do
            local txt = ""
            for _, d in pairs(npc:GetDescendants()) do
                if d:IsA("TextLabel") then txt = txt .. " " .. d.Text
                elseif d:IsA("StringValue") then txt = txt .. " " .. d.Value end
            end
            
            if string.find(string.lower(txt), string.lower(r)) then
                -- Mostra o nome real encontrado no label ou a raridade
                AskToCollect(r:upper(), npc)
                return -- Para no primeiro que achar da lista de prioridade
            end
        end
    end
end

-- --- LOOP PRINCIPAL ---
task.spawn(function()
    while true do
        task.wait(2)
        if States.Farm and not States.Asking then
            ScanForNPCs()
        end
    end
end)

-- --- GUI PRINCIPAL ---
local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ShadowHub_Core"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 140); MainFrame.Position = UDim2.new(0.5, -120, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12); MainFrame.Visible = false
Instance.new("UICorner", MainFrame)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 150, 255)

local FarmBtn = Instance.new("TextButton", MainFrame)
FarmBtn.Size = UDim2.new(0, 210, 0, 50); FarmBtn.Position = UDim2.new(0, 15, 0, 50)
FarmBtn.Text = "IDENTIFICAR RARE: OFF"; FarmBtn.Font = Enum.Font.GothamBold
FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    States.Farm = not States.Farm
    FarmBtn.Text = States.Farm and "SCANNER: ATIVO" or "IDENTIFICAR RARE: OFF"
    FarmBtn.TextColor3 = States.Farm and Color3.fromRGB(0, 150, 255) or Color3.new(1,1,1)
end)

-- Botão de Abrir
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 20, 0.5, -25)
OpenBtn.Text = "S"; Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Tela de Loading (Simplificada para carregar rápido)
task.spawn(function()
    task.wait(1)
    MainFrame.Visible = true
end)
