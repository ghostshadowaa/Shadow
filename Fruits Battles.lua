-- Shadow Hub V26 - Adrian Final (Quest to Farm Logic)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
-- CFrame central de onde os bandidos ficam (ajuste se necessário)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- --- FUNÇÕES ---
local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end

local function HasQuest()
    local success, result = pcall(function()
        return Player.PlayerGui.QuestOptions.IsQuestFrame.Process.Visible
    end)
    return success and result
end

local function EquipTool()
    local char = GetChar()
    local tool = Player.Backpack:FindFirstChildOfClass("Tool") or char:FindFirstChildOfClass("Tool")
    if tool and tool.Parent ~= char then tool.Parent = char end
end

-- --- FAST ATTACK ---
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
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V26"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 200, 0, 130); Main.Position = UDim2.new(0.5, -100, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 40)
FarmBtn.Text = "INICIAR FARM"; FarmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); FarmBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARMANDO..." or "INICIAR FARM"
end)

-- --- LOOP DE JORNADA (NPC -> BANDITS) ---
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFarm then
            local char = GetChar()
            local hrp = char:WaitForChild("HumanoidRootPart")
            
            if not HasQuest() then
                -- 1. VAI PEGAR A MISSÃO
                hrp.CFrame = NPC_QUEST_CFRAME
                task.wait(0.5)
                
                -- Interação (Segura E ou FirePrompt)
                local prompt = workspace:FindFirstChild("ProximityPrompt", true)
                if fireproximityprompt and prompt then
                    fireproximityprompt(prompt)
                else
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(2.2)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
                
                -- Aceita Missão
                RS.Events.GotQuest:FireServer(1)
                task.wait(0.5)
            else
                -- 2. VAI PARA OS BANDIDOS
                local banditsFolder = workspace:FindFirstChild("Bandits", true)
                local inimigo = nil
                
                -- Procura bandido vivo
                if banditsFolder then
                    for _, v in pairs(banditsFolder:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            inimigo = v
                            break
                        end
                    end
                end
                
                if inimigo then
                    -- TELEPORTA E COLA NO BANDIDO
                    EquipTool()
                    local targetHrp = inimigo:FindFirstChild("HumanoidRootPart")
                    if targetHrp then
                        repeat
                            if not _G.AutoFarm or not HasQuest() then break end
                            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
                            task.wait()
                        until not inimigo.Parent or inimigo.Humanoid.Health <= 0
                    end
                else
                    -- Se não achou bandido no momento, vai pro spawn deles esperar
                    hrp.CFrame = BANDITS_SPAWN_CFRAME
                end
            end
        end
    end
end)
