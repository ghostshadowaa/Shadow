-- Shadow Hub V25 - Final Source Code (GitHub Ready)
-- Criado para: Adrian
-- Alvo: Bandit Farm Auto-Quest (Lv 50)

local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- --- CONFIGURAÇÕES GLOBAIS ---
_G.AutoFarm = false
_G.FastAttack = true
local LEVEL_LIMIT = 50
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)

-- --- FUNÇÕES DE SEGURANÇA (ANTI-NIL) ---
local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end

local function HasQuest()
    local success, result = pcall(function()
        -- Verifica se a barra de progresso da missão está visível na tela
        return Player.PlayerGui.QuestOptions.IsQuestFrame.Process.Visible
    end)
    return success and result
end

local function EquipTool()
    local char = GetChar()
    local tool = Player.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
    if tool and tool.Parent ~= char then
        tool.Parent = char
    end
    return tool
end

-- --- MOTOR DE FAST ATTACK (ULTRA SPEED) ---
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoFarm and _G.FastAttack then
            pcall(function()
                local tool = GetChar():FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    -- Simula múltiplos cliques por segundo
                    VIM:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
            end)
        end
    end
end)

-- --- INTERFACE GRÁFICA (GUI) ---
local sg = Instance.new("ScreenGui", Player.PlayerGui)
sg.Name = "ShadowHub_Adrian"
sg.ResetOnSpawn = false

local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 150); Main.Position = UDim2.new(0.5, -110, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "SHADOW HUB | LV 50"; Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 50)
FarmBtn.Text = "AUTO FARM: OFF"; FarmBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
FarmBtn.TextColor3 = Color3.new(1, 1, 1); FarmBtn.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", FarmBtn)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"; CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0); CloseBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", CloseBtn)

local OpenBtn = Instance.new("TextButton", sg)
OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 20, 0.5, 0)
OpenBtn.Text = "S"; OpenBtn.Visible = false; OpenBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); OpenBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

-- Lógica UI
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() Main.Visible = true; OpenBtn.Visible = false end)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "AUTO FARM: ON" or "AUTO FARM: OFF"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(35, 35, 40)
end)

-- --- LOOP PRINCIPAL (QUEST + TELEPORT FARM) ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = GetChar():WaitForChild("HumanoidRootPart")
                
                -- Checa se já tem missão
                if not HasQuest() then
                    -- 1. TELEPORTE NPC QUEST
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.5)
                    
                    -- 2. INTERAGIR (PROXIMITY PROMPT)
                    -- Procura o prompt mais próximo do personagem
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.Parent.Position - hrp.Position).Magnitude < 20 then
                            if fireproximityprompt then
                                fireproximityprompt(v)
                            else
                                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                                task.wait(2.5) -- Tempo para o giro completo
                                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                            end
                            break
                        end
                    end
                    
                    -- 3. ACEITAR MISSÃO VIA EVENTO
                    task.wait(0.5)
                    RS.Events.GotQuest:FireServer(1) -- Ativa a quest dos Bandits
                else
                    -- 4. TELEPORTE E FARM DE BANDIDOS
                    -- Usa busca recursiva para achar a pasta Bandits
                    local banditsFolder = workspace:FindFirstChild("Bandits", true)
                    
                    if banditsFolder then
                        for _, bandit in pairs(banditsFolder:GetChildren()) do
                            local hum = bandit:FindFirstChildOfClass("Humanoid")
                            local bHrp = bandit:FindFirstChild("HumanoidRootPart")
                            
                            if hum and hum.Health > 0 and bHrp then
                                EquipTool()
                                -- Cola no bandido e ataca até ele morrer ou a quest acabar
                                repeat
                                    if not _G.AutoFarm or not HasQuest() then break end
                                    hrp.CFrame = bHrp.CFrame * CFrame.new(0, 0, 3)
                                    task.wait()
                                until hum.Health <= 0
                                if not HasQuest() then break end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
