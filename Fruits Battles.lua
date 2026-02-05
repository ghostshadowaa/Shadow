-- Shadow Hub V28 - Adrian Final (NPC Quest Fix)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
-- CFrames Exatos
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- --- ANTI-AFK ---
pcall(function()
    Player.Idled:Connect(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end)

-- --- FUNÇÕES DE VERIFICAÇÃO ---
local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end

local function HasQuest()
    local success, result = pcall(function()
        -- Verifica se o Frame da Missão existe e se o Processo é visível
        local questGui = Player.PlayerGui:FindFirstChild("QuestOptions")
        if questGui then
            local frame = questGui:FindFirstChild("IsQuestFrame")
            if frame then
                return frame.Process.Visible
            end
        end
        return false
    end)
    return success and result
end

local function EquipPriorityTool()
    local char = GetChar()
    local backpack = Player.Backpack
    
    local current = char:FindFirstChildOfClass("Tool")
    if current and (current.Name:find("Katana") or current.Name:find("Sword") or current.Name:find("Combat")) then
        return current
    end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool.Name:find("Katana") or tool.Name:find("Sword") then
            tool.Parent = char
            return tool
        end
    end

    local combat = backpack:FindFirstChild("Combat")
    if combat then
        combat.Parent = char
        return combat
    end
end

-- --- ULTRA FAST ATTACK ---
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoFarm then
            pcall(function()
                local tool = GetChar():FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    VIM:SendMouseButtonEvent(500, 500, 0, true, game, 0)
                    VIM:SendMouseButtonEvent(500, 500, 0, false, game, 0)
                end
            end)
        end
    end
end)

-- --- INTERFACE ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V28"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 200, 0, 130); Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 40)
FarmBtn.Text = "FORCE AUTO-FARM"; FarmBtn.BackgroundColor3 = Color3.fromRGB(40, 0, 60); FarmBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARMANDO..." or "FORCE AUTO-FARM"
end)

-- --- LÓGICA DE MOVIMENTO (NPC <-> FARM) ---
task.spawn(function()
    while true do
        task.wait(1) -- Delay maior para evitar conflitos de teleporte
        if _G.AutoFarm then
            pcall(function()
                local hrp = GetChar():WaitForChild("HumanoidRootPart")
                
                if not HasQuest() then
                    -- FORÇAR IDA AO NPC
                    print("Indo buscar missão...")
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.7)
                    
                    -- Interação
                    local prompt = nil
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.Parent.Position - hrp.Position).Magnitude < 25 then
                            prompt = v break
                        end
                    end
                    
                    if prompt then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(2.3)
                        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    
                    -- Evento de Aceitar
                    RS.Events.GotQuest:FireServer(1)
                    task.wait(0.5)
                else
                    -- IR PARA O FARM
                    local banditsFolder = workspace:FindFirstChild("Bandits", true)
                    local target = nil
                    
                    if banditsFolder then
                        for _, v in pairs(banditsFolder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                target = v
                                break
                            end
                        end
                    end
                    
                    if target then
                        EquipPriorityTool()
                        local tHrp = target:FindFirstChild("HumanoidRootPart")
                        if tHrp then
                            -- Loop focado no bandido até ele morrer
                            while target and target.Parent and target.Humanoid.Health > 0 and _G.AutoFarm and HasQuest() do
                                hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                                task.wait()
                            end
                        end
                    else
                        -- Se estiver sem missão ou sem bandido, garante que não fica parado no NPC
                        hrp.CFrame = BANDITS_SPAWN_CFRAME
                    end
                end
            end)
        end
    end
end)
