-- Shadow Hub V31 - Adrian Final Quest Fix
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
_G.SelectedWeapon = "Melee" 

-- CFRAMES
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- --- FUNÇÕES DE VERIFICAÇÃO ---
local function HasQuest()
    local success, result = pcall(function()
        -- Verifica se a GUI de progresso da missão existe e está visível
        return Player.PlayerGui.QuestOptions.IsQuestFrame.Process.Visible
    end)
    return success and result
end

local function EquipWeapon()
    local char = Player.Character
    if not char then return end
    local weaponType = _G.SelectedWeapon
    
    -- Tenta encontrar a arma certa
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if weaponType == "Sword" and (tool.Name:find("Katana") or tool.Name:find("Sword")) then
            tool.Parent = char break
        elseif weaponType == "Melee" and (tool.Name:find("Combat") or tool.Name:find("Melee")) then
            tool.Parent = char break
        end
    end
end

-- --- INTERFACE ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V31"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 150); Main.Position = UDim2.new(0.5, -110, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(15,15,15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local WepBtn = Instance.new("TextButton", Main)
WepBtn.Size = UDim2.new(1, -20, 0, 40); WepBtn.Position = UDim2.new(0, 10, 0, 45); WepBtn.Text = "WEAPON: MELEE"
WepBtn.BackgroundColor3 = Color3.fromRGB(40,40,40); WepBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", WepBtn)

WepBtn.MouseButton1Click:Connect(function()
    _G.SelectedWeapon = (_G.SelectedWeapon == "Melee") and "Sword" or "Melee"
    WepBtn.Text = "WEAPON: " .. _G.SelectedWeapon:upper()
end)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 90); FarmBtn.Text = "START AUTO FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200); FarmBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "STOP FARM" or "START AUTO FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 100, 200)
end)

-- --- ATAQUE ---
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoFarm and Player.Character then
            local t = Player.Character:FindFirstChildOfClass("Tool")
            if t then t:Activate() end
        end
    end
end)

-- --- LÓGICA PRINCIPAL (CORREÇÃO DE MISSÃO) ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                
                if not HasQuest() then
                    -- 1. VAI AO NPC
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.5)
                    
                    -- 2. TENTA INTERAGIR DE TODAS AS FORMAS
                    -- Tenta o Remote de várias formas (Número, Nome, String)
                    RS.Events.GotQuest:FireServer(1)
                    RS.Events.GotQuest:FireServer("Bandit")
                    RS.Events.GotQuest:FireServer("Bandit Quest")
                    
                    -- Tenta o Botão de Interação (ProximityPrompt)
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and (v.Parent.Position - hrp.Position).Magnitude < 25 then
                            if fireproximityprompt then fireproximityprompt(v) end
                        end
                    end
                    
                    -- Simula a tecla E fisicamente
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(2.2)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                else
                    -- 3. VAI PARA O FARM
                    local folder = workspace:FindFirstChild("Bandits", true)
                    local target = nil
                    if folder then
                        for _, v in pairs(folder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                target = v break
                            end
                        end
                    end
                    
                    if target then
                        EquipWeapon()
                        while target and target.Parent and target.Humanoid.Health > 0 and _G.AutoFarm and HasQuest() do
                            hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            task.wait()
                        end
                    else
                        hrp.CFrame = BANDITS_SPAWN_CFRAME
                    end
                end
            end)
        end
    end
end)
