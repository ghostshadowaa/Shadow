-- Shadow Hub V30 - Adrian PRO (Melee/Sword Selector)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- --- CONFIGURAÇÕES ---
_G.AutoFarm = false
_G.SelectedWeapon = "Melee" -- Melee ou Sword
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- --- FUNÇÕES DE SISTEMA ---
local function GetChar() return Player.Character or Player.CharacterAdded:Wait() end

local function HasQuest()
    local success, result = pcall(function()
        return Player.PlayerGui.QuestOptions.IsQuestFrame.Process.Visible
    end)
    return success and result
end

-- Seleção de Arma Profissional
local function EquipSelected()
    local char = GetChar()
    local backpack = Player.Backpack
    local weaponType = _G.SelectedWeapon
    
    local current = char:FindFirstChildOfClass("Tool")
    if current then
        if weaponType == "Sword" and (current.Name:lower():find("katana") or current.Name:lower():find("sword")) then return current end
        if weaponType == "Melee" and (current.Name:lower():find("combat") or current.Name:lower():find("melee")) then return current end
    end

    for _, tool in pairs(backpack:GetChildren()) do
        if weaponType == "Sword" and (tool.Name:lower():find("katana") or tool.Name:lower():find("sword")) then
            tool.Parent = char
            return tool
        elseif weaponType == "Melee" and (tool.Name:lower():find("combat") or tool.Name:lower():find("melee")) then
            tool.Parent = char
            return tool
        end
    end
end

-- --- ANTI-AFK ---
pcall(function()
    Player.Idled:Connect(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end)

-- --- INTERFACE ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V30"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 230, 0, 180); Main.Position = UDim2.new(0.5, -115, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "SHADOW HUB V30"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold

-- Seletor Melee/Sword
local WeaponBtn = Instance.new("TextButton", Main)
WeaponBtn.Size = UDim2.new(1, -20, 0, 40); WeaponBtn.Position = UDim2.new(0, 10, 0, 50)
WeaponBtn.Text = "WEAPON: MELEE"; WeaponBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50); WeaponBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", WeaponBtn)

WeaponBtn.MouseButton1Click:Connect(function()
    if _G.SelectedWeapon == "Melee" then
        _G.SelectedWeapon = "Sword"
        WeaponBtn.Text = "WEAPON: SWORD"
    else
        _G.SelectedWeapon = "Melee"
        WeaponBtn.Text = "WEAPON: MELEE"
    end
end)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 100)
FarmBtn.Text = "START AUTO FARM"; FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200); FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARMING... [ON]" or "START AUTO FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(0, 80, 200)
end)

-- --- MOTOR DE ATAQUE ---
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

-- --- LOOP PRINCIPAL ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = GetChar():WaitForChild("HumanoidRootPart")
                
                if not HasQuest() then
                    -- 1. TENTA REMOTE QUEST
                    RS.Events.GotQuest:FireServer(1)
                    task.wait(0.5)
                    
                    -- 2. SE NÃO FUNCIONAR, VAI AO NPC
                    if not HasQuest() then
                        hrp.CFrame = NPC_QUEST_CFRAME
                        task.wait(0.5)
                        local prompt = workspace:FindFirstChild("ProximityPrompt", true)
                        if prompt then
                            if fireproximityprompt then fireproximityprompt(prompt) end
                            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                            task.wait(2.2)
                            VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        end
                        RS.Events.GotQuest:FireServer(1)
                    end
                else
                    -- 3. EXECUTA O FARM
                    local banditsFolder = workspace:FindFirstChild("Bandits", true)
                    local target = nil
                    
                    if banditsFolder then
                        for _, v in pairs(banditsFolder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                target = v break
                            end
                        end
                    end
                    
                    if target then
                        EquipSelected()
                        local tHrp = target:FindFirstChild("HumanoidRootPart")
                        if tHrp then
                            while target and target.Parent and target.Humanoid.Health > 0 and _G.AutoFarm and HasQuest() do
                                hrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                                task.wait()
                            end
                        end
                    else
                        hrp.CFrame = BANDITS_SPAWN_CFRAME
                    end
                end
            end)
        end
    end
end)
