-- Shadow Hub V33 - Adrian Edition (Manual Click Fix)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
_G.SelectedWeapon = "Melee" 

-- CFRAMES
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- Posição do Botão que você passou
local BUTTON_POS_X = 0.756419659
local BUTTON_POS_Y = 1.08244634

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
    local weaponType = _G.SelectedWeapon
    for _, tool in pairs(Player.Backpack:GetChildren()) do
        if weaponType == "Sword" and (tool.Name:find("Katana") or tool.Name:find("Sword")) then
            tool.Parent = char break
        elseif weaponType == "Melee" and (tool.Name:find("Combat") or tool.Name:find("Melee")) then
            tool.Parent = char break
        end
    end
end

-- --- INTERFACE ---
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V33"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 150); Main.Position = UDim2.new(0.5, -110, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(15,15,15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

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
    FarmBtn.Text = _G.AutoFarm and "STOP" or "START AUTO FARM"
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

-- --- LÓGICA DE CLIQUE E QUEST ---
task.spawn(function()
    while true do
        task.wait(1)
        if _G.AutoFarm then
            pcall(function()
                local hrp = Player.Character.HumanoidRootPart
                local screenSize = Player.PlayerGui:FindFirstChildOfClass("ScreenGui").AbsoluteSize
                
                if not HasQuest() then
                    -- 1. VAI ATÉ O NPC
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.5)
                    
                    -- 2. ABRE O MENU (INTERAÇÃO)
                    local prompt = workspace:FindFirstChild("ProximityPrompt", true)
                    if prompt then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(2.2)
                        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    
                    -- 3. CLICA NO BOTÃO PELA POSIÇÃO QUE VOCÊ PASSOU
                    task.wait(0.5)
                    local clickX = screenSize.X * BUTTON_POS_X
                    local clickY = screenSize.Y * BUTTON_POS_Y
                    
                    VIM:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                    task.wait(0.1)
                    VIM:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
                    print("Tentando clicar na posição da Quest...")
                else
                    -- 4. FARM BANDIDOS
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
