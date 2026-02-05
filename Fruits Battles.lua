-- Shadow Hub V34 - Adrian PRO (Sequential Flow)
local Player = game.Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

_G.AutoFarm = false
_G.SelectedWeapon = "Melee" 

-- CFRAMES
local NPC_QUEST_CFRAME = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_SPAWN_CFRAME = CFrame.new(-450, 31, -750) 

-- COORDENADAS DO BOTÃO (Baseado no seu Gacha)
local BUTTON_X_RATIO = 0.756419659
local BUTTON_Y_RATIO = 1.08244634 -- Se for maior que 1, o script ajusta para o limite da tela

-- --- FUNÇÕES ---
local function HasQuest()
    local success, result = pcall(function()
        -- Verifica se a interface de missão está ativa
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
local sg = Instance.new("ScreenGui", Player.PlayerGui); sg.Name = "ShadowHub_V34"; sg.ResetOnSpawn = false
local Main = Instance.new("Frame", sg)
Main.Size = UDim2.new(0, 220, 0, 150); Main.Position = UDim2.new(0.5, -110, 0.4, 0); Main.BackgroundColor3 = Color3.fromRGB(10,10,15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main)

local WepBtn = Instance.new("TextButton", Main)
WepBtn.Size = UDim2.new(1, -20, 0, 40); WepBtn.Position = UDim2.new(0, 10, 0, 45); WepBtn.Text = "WEAPON: MELEE"
WepBtn.BackgroundColor3 = Color3.fromRGB(30,30,40); WepBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", WepBtn)

WepBtn.MouseButton1Click:Connect(function()
    _G.SelectedWeapon = (_G.SelectedWeapon == "Melee") and "Sword" or "Melee"
    WepBtn.Text = "WEAPON: " .. _G.SelectedWeapon:upper()
end)

local FarmBtn = Instance.new("TextButton", Main)
FarmBtn.Size = UDim2.new(1, -20, 0, 50); FarmBtn.Position = UDim2.new(0, 10, 0, 90); FarmBtn.Text = "ATIVAR AUTO FARM"
FarmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); FarmBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", FarmBtn)

FarmBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    FarmBtn.Text = _G.AutoFarm and "FARM ATIVO" or "ATIVAR AUTO FARM"
    FarmBtn.BackgroundColor3 = _G.AutoFarm and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 255)
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

-- --- PROCESSO SEQUENCIAL (NPC -> VERIFICAÇÃO -> BANDIDOS) ---
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoFarm then
            pcall(function()
                local char = Player.Character
                local hrp = char:WaitForChild("HumanoidRootPart")
                
                -- PASSO 1: ACEITAR MISSÃO
                if not HasQuest() then
                    -- Ir até o NPC
                    hrp.CFrame = NPC_QUEST_CFRAME
                    task.wait(0.5)
                    
                    -- Interagir (Proximity Prompt)
                    local prompt = workspace:FindFirstChildOfClass("ProximityPrompt", true)
                    if prompt then
                        if fireproximityprompt then fireproximityprompt(prompt) end
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(2.2)
                        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                    
                    -- Clicar no botão de aceitar (Usando suas coordenadas)
                    task.wait(0.5)
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    local clickX = viewportSize.X * BUTTON_X_RATIO
                    local clickY = viewportSize.Y * (BUTTON_Y_RATIO > 1 and 0.9 or BUTTON_Y_RATIO) -- Ajuste de segurança
                    
                    VIM:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                    task.wait(0.1)
                    VIM:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
                    
                    task.wait(1) -- Espera o servidor processar a missão
                
                -- PASSO 2: VERIFICAÇÃO CONCLUÍDA -> IR ATÉ OS BANDIDOS
                else
                    local folder = workspace:FindFirstChild("Bandits", true)
                    local target = nil
                    
                    if folder then
                        for _, v in pairs(folder:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                                target = v
                                break
                            end
                        end
                    end
                    
                    if target then
                        EquipWeapon()
                        -- Ataca o bandido até ele morrer ou a missão acabar
                        repeat
                            if not _G.AutoFarm or not HasQuest() then break end
                            hrp.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                            task.wait()
                        until not target.Parent or target.Humanoid.Health <= 0
                    else
                        -- Se não houver bandidos, aguarda no local de spawn deles
                        hrp.CFrame = BANDITS_SPAWN_CFRAME
                    end
                end
            end)
        end
    end
end)
