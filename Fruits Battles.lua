-- Shadow Hub V32 - Adrian Edition (Levels. 0+ Fix)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
_G.SelectedWeapon = "Melee" 

-- CFRAMES
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- --- FUNÇÕES ---
local function HasQuest()
    local success, result = pcall(function()
        return Player.PlayerGui.QuestOptions.IsQuestFrame.Process.Visible
    end)
    return success and result
end

local function EquipWeapon()
    local char = Player.Character
    if not char then return end
    local backpack = Player.Backpack
    local weaponType = _G.SelectedWeapon
    
    for _, tool in pairs(backpack:GetChildren()) do
        if weaponType == "Sword" and (tool.Name:find("Katana") or tool.Name:find("Sword")) then
            tool.Parent = char break
        elseif weaponType == "Melee" and (tool.Name:find("Combat") or tool.Name:find("Melee")) then
            tool.Parent = char break
        end
    end
end

-- --- INTERFACE ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V32"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 150); Main.Position = UDim2.new(0.5, -110, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(10,10,10); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "SHADOW HUB V32"; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1

local WepBtn = Instance.new("TextButton", Main)
WepBtn.Size = UDim2.new(1, -20, 0, 35); WepBtn.Position = UDim2.new(0, 10, 0, 45); WepBtn.Text = "WEAPON: MELEE"
WepBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); WepBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", WepBtn)

WepBtn.MouseButton1Click:Connect(function()
    _G.SelectedWeapon = (_G.SelectedWeapon == "Melee") and "Sword" or "Melee"
    WepBtn.Text = "WEAPON: " .. _G.SelectedWeapon:upper()
end)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 90); FarmBtn.Text = "START AUTO FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 200); FarmBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "STOP FARM" or "START AUTO FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(150, 0, 0) or Color3.fromRGB(0, 80, 200)
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

-- --- LÓGICA PRINCIPAL ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                
                if not HasQuest() then
                    -- 1. TELEPORT NPC
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.5)
                    
                    -- 2. COLETA MISSÃO (LEVELS. 0+)
                    -- Envia o nome exato para o servidor
                    RS.Events.GotQuest:FireServer("Levels. 0+")
                    
                    -- Interação física (Hold E)
                    local prompt = workspace:FindFirstChild("ProximityPrompt", true)
                    if prompt and (prompt.Parent.Position - hrp.Position).Magnitude < 20 then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(2.2)
                        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    
                    -- Clique de segurança caso apareça um botão na GUI
                    for _, btn in pairs(Player.PlayerGui:GetDescendants()) do
                        if btn:IsA("TextButton") and btn.Text:find("0+") then
                            local pos = btn.AbsolutePosition
                            VIM:SendMouseButtonEvent(pos.X + 30, pos.Y + 30, 0, true, game, 0)
                            task.wait(0.1)
                            VIM:SendMouseButtonEvent(pos.X + 30, pos.Y + 30, 0, false, game, 0)
                        end
                    end
                else
                    -- 3. FARM BANDIDOS
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
