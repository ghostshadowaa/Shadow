-- Shadow Hub V29 - PRO Edition
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- --- CONFIGURAÇÕES ---
_G.AutoFarm = false
_G.SelectedWeapon = "Combat" -- Padrão
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

-- Sistema de Equipamento por Seleção
local function EquipSelected()
    local char = GetChar()
    local backpack = Player.Backpack
    local weaponName = _G.SelectedWeapon
    
    local current = char:FindFirstChildOfClass("Tool")
    if current and (current.Name:find(weaponName) or (weaponName == "Espada" and current.Name:find("Katana"))) then
        return current
    end

    for _, tool in pairs(backpack:GetChildren()) do
        if weaponName == "Espada" and (tool.Name:find("Katana") or tool.Name:find("Sword")) then
            tool.Parent = char
            return tool
        elseif weaponName == "Combat" and tool.Name == "Combat" then
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

-- --- INTERFACE GRÁFICA ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V29"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 230, 0, 200); Main.Position = UDim2.new(0.5, -115, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "SHADOW HUB PRO V29"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1

-- Botão de Seleção de Arma
local WeaponBtn = Instance.new("TextButton", Main)
WeaponBtn.Size = UDim2.new(1, -20, 0, 35); WeaponBtn.Position = UDim2.new(0, 10, 0, 45)
WeaponBtn.Text = "ARMA: COMBAT"; WeaponBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); WeaponBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", WeaponBtn)

WeaponBtn.MouseButton1Click:Connect(function()
    if _G.SelectedWeapon == "Combat" then
        _G.SelectedWeapon = "Espada"
        WeaponBtn.Text = "ARMA: ESPADA/KATANA"
    else
        _G.SelectedWeapon = "Combat"
        WeaponBtn.Text = "ARMA: COMBAT"
    end
end)

-- Botão Auto Farm
local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 90)
FarmBtn.Text = "INICIAR AUTO FARM"; FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); FarmBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARMANDO... [ON]" or "INICIAR AUTO FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(0, 100, 200)
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

-- --- LÓGICA PRINCIPAL (REMOTE + TELEPORT) ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = GetChar():WaitForChild("HumanoidRootPart")
                
                if not HasQuest() then
                    -- Tenta aceitar via Remote primeiro (sem ir lá)
                    RS.Events.GotQuest:FireServer(1)
                    task.wait(0.5)
                    
                    -- Se após o remote ainda não tiver quest, ele vai até o NPC
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
                    -- EXECUTA O FARM
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
