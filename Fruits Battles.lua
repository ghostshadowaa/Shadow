-- Shadow Hub | Fruits Battles - Script Completo
-- Coloque este LocalScript no StarterGui > ScreenGui

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Criar a GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShadowHub"
screenGui.Parent = playerGui

-- Botão flutuante para abrir/fechar
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleHub"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -60, 0.5, -25)
toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "☰"
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 20
toggleButton.BorderSizePixel = 0
toggleButton.ZIndex = 10
toggleButton.Parent = screenGui

-- Frame principal do hub
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 255)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Título do hub
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 100)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Shadow Hub | Fruits Battles"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

-- Botão de Auto Farm
local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Name = "AutoFarm"
autoFarmButton.Size = UDim2.new(0.8, 0, 0, 50)
autoFarmButton.Position = UDim2.new(0.1, 0, 0.2, 0)
autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmButton.Text = "▶ INICIAR AUTO FARM"
autoFarmButton.Font = Enum.Font.GothamBold
autoFarmButton.TextSize = 14
autoFarmButton.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.Text = "🟢 PRONTO"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Contador de kills
local killCountLabel = Instance.new("TextLabel")
killCountLabel.Name = "KillCount"
killCountLabel.Size = UDim2.new(0.9, 0, 0, 30)
killCountLabel.Position = UDim2.new(0.05, 0, 0.8, 0)
killCountLabel.BackgroundTransparency = 1
killCountLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
killCountLabel.Text = "Bandidos: 0/4"
killCountLabel.Font = Enum.Font.Gotham
killCountLabel.TextSize = 12
killCountLabel.Parent = mainFrame

-- Efeitos nos botões
autoFarmButton.MouseEnter:Connect(function()
    autoFarmButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
end)

autoFarmButton.MouseLeave:Connect(function()
    if autoFarmButton.Text:find("PARAR") then
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    else
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    end
end)

toggleButton.MouseEnter:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(120, 120, 255)
end)

toggleButton.MouseLeave:Connect(function()
    toggleButton.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
end)

-- Botão para abrir/fechar o hub
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Variáveis do sistema
local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

-- Configurações
local questNPC_CFrame = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)
local banditsLocation = game.Workspace:FindFirstChild("Visuals") and 
                       game.Workspace.Visuals:FindFirstChild("More") and
                       game.Workspace.Visuals.More:FindFirstChild("Npcs") and
                       game.Workspace.Visuals.More.Npcs:FindFirstChild("Enemy") and
                       game.Workspace.Visuals.More.Npcs.Enemy:FindFirstChild("Bandits")

-- Variáveis de controle
local isRunning = false
local killCount = 0
local targetBandits = 4

-- Função para atualizar status
local function updateStatus(text, color)
    statusLabel.Text = text
    if color == "red" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif color == "yellow" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

-- Função para atualizar contador de kills
local function updateKillCount(count)
    killCount = count
    killCountLabel.Text = string.format("Bandidos: %d/4", killCount)
end

-- Função para teletransportar personagem (tween rápido)
local function teleportTo(cframe)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.Character or player.CharacterAdded:Wait()
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local distance = (humanoidRootPart.Position - cframe.Position).Magnitude
    
    -- Velocidade rápida: menor tempo para maior velocidade
    local speed = 200 -- Unidades por segundo
    local duration = math.min(distance / speed, 3) -- Máximo 3 segundos
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = cframe})
    tween:Play()
    
    -- Esperar completar
    local startTime = tick()
    while tick() - startTime < duration + 1 and tween.PlaybackState == Enum.PlaybackState.Playing do
        RunService.Heartbeat:Wait()
    end
    
    return true
end

-- Função para interagir com NPC por 2 segundos
local function interactWithNPC()
    updateStatus("🗣️ Falando com NPC...", "yellow")
    
    -- Procurar NPCs próximos
    local closestNPC = nil
    local closestDistance = math.huge
    
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
            local distance = (character.HumanoidRootPart.Position - npc:GetPivot().Position).Magnitude
            if distance < 30 and distance < closestDistance then
                closestNPC = npc
                closestDistance = distance
            end
        end
    end
    
    if closestNPC then
        -- Posicionar na frente do NPC
        teleportTo(closestNPC:GetPivot() * CFrame.new(0, 0, -4))
        wait(0.3)
        
        -- Virar para o NPC
        character.HumanoidRootPart.CFrame = CFrame.lookAt(
            character.HumanoidRootPart.Position,
            closestNPC:GetPivot().Position
        )
        
        -- Simular pressionar E para interagir
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
        
        updateStatus("💬 Dialogando...", "yellow")
        wait(2.5) -- Esperar 2.5 segundos para diálogo
        
        return true
    else
        -- Se não encontrar NPC, usar a posição fixa
        updateStatus("📍 Indo para local do NPC...", "yellow")
        teleportTo(questNPC_CFrame)
        wait(1)
        
        -- Tentar encontrar NPC novamente
        for _, npc in pairs(workspace:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Humanoid") then
                local distance = (character.HumanoidRootPart.Position - npc:GetPivot().Position).Magnitude
                if distance < 20 then
                    -- Simular E novamente
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
                    wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
                    wait(2)
                    return true
                end
            end
        end
    end
    
    return false
end

-- Função para aceitar quest via GUI
local function acceptQuest()
    updateStatus("✅ Tentando aceitar missão...", "yellow")
    
    -- Método 1: Procurar na PlayerGui
    for _, gui in pairs(player.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name:find("Quest") or gui.Name:find("Missão")) then
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("TextButton") and (child.Text:find("Accept") or child.Text:find("Aceitar") or child.Text:find("Iniciar")) then
                    -- Clicar no botão
                    fireclickdetector(child:FindFirstChildOfClass("ClickDetector") or 
                                     Instance.new("ClickDetector", child))
                    updateStatus("🎯 Missão aceita!", "green")
                    return true
                end
            end
        end
    end
    
    -- Método 2: Procurar em todos os botões
    for _, child in pairs(player.PlayerGui:GetDescendants()) do
        if child:IsA("TextButton") and (child.Text:lower():find("accept") or 
           child.Text:lower():find("aceitar") or child.Text:lower():find("iniciar")) then
            -- Simular clique
            child:FireEvent("MouseButton1Click")
            updateStatus("🎯 Missão aceita!", "green")
            return true
        end
    end
    
    -- Método 3: Tentar pressionar F (comum em muitos jogos)
    updateStatus("⌨️ Tentando F...", "yellow")
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, nil)
    wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, nil)
    wait(1)
    
    return false
end

-- Função para equipar Melee ou Sword
local function equipWeapon()
    updateStatus("⚔️ Equipando arma...", "yellow")
    
    -- Lista de prioridade de armas
    local weaponPriority = {"Melee", "Sword", "Katana", "Combat"}
    
    -- Verificar no inventário
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, weaponName in pairs(weaponPriority) do
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find(weaponName:lower()) then
                    -- Equipar a arma
                    character.Humanoid:EquipTool(item)
                    wait(0.5)
                    updateStatus("✅ " .. item.Name .. " equipada!", "green")
                    return item
                end
            end
        end
    end
    
    -- Verificar no personagem
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") then
            character.Humanoid:EquipTool(item)
            wait(0.5)
            updateStatus("✅ " .. item.Name .. " equipada!", "green")
            return item
        end
    end
    
    -- Tentar pegar arma do chão
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Tool") and (item.Name:lower():find("melee") or item.Name:lower():find("sword")) then
            teleportTo(item.Handle.CFrame)
            wait(0.5)
            firetouchinterest(character.HumanoidRootPart, item.Handle, 0)
            wait(0.1)
            firetouchinterest(character.HumanoidRootPart, item.Handle, 1)
            wait(0.5)
            character.Humanoid:EquipTool(item)
            return item
        end
    end
    
    updateStatus("⚠️ Nenhuma arma encontrada!", "red")
    return nil
end

-- Função para atacar bandidos
local function attackBandit(bandit)
    if not bandit or not bandit.Parent or not bandit:FindFirstChild("Humanoid") then
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        tool = equipWeapon()
        if not tool then return false end
    end
    
    -- Ir até o bandido
    teleportTo(bandit.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
    
    -- Autoclick loop
    local maxTime = 15 -- segundos máximo por bandido
    local startTime = tick()
    
    while bandit and bandit.Parent and bandit.Humanoid.Health > 0 and 
          tick() - startTime < maxTime and isRunning do
        
        -- Ativar a ferramenta (ataque)
        tool:Activate()
        
        -- Simular clique do mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        -- Manter posição próxima
        if character.HumanoidRootPart and bandit.HumanoidRootPart then
            local direction = (bandit.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Unit
            character.HumanoidRootPart.CFrame = CFrame.new(
                bandit.HumanoidRootPart.Position - direction * 5,
                bandit.HumanoidRootPart.Position
            )
        end
        
        wait(0.15)
    end
    
    -- Verificar se matou
    if bandit.Humanoid.Health <= 0 then
        updateKillCount(killCount + 1)
        updateStatus(string.format("☠️ Bandido %d/4 eliminado!", killCount), "green")
        return true
    end
    
    return false
end

-- Função para farmar bandidos
local function farmBandits()
    if not banditsLocation then
        -- Tentar encontrar bandidos de outra forma
        local enemies = {}
        for _, enemy in pairs(workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and 
               (enemy.Name:lower():find("bandit") or enemy.Name:lower():find("bandido")) then
                table.insert(enemies, enemy)
            end
        end
        
        if #enemies == 0 then
            updateStatus("❌ Nenhum bandido encontrado!", "red")
            return false
        end
        
        -- Atacar bandidos encontrados
        for i, bandit in pairs(enemies) do
            if not isRunning or killCount >= targetBandits then break end
            attackBandit(bandit)
        end
    else
        -- Usar localização específica
        local bandits = banditsLocation:GetChildren()
        
        for i, bandit in pairs(bandits) do
            if not isRunning or killCount >= targetBandits then break end
            
            if bandit:IsA("Model") and bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                updateStatus(string.format("⚔️ Atacando bandido %d...", i), "yellow")
                attackBandit(bandit)
            end
        end
    end
    
    return killCount >= targetBandits
end

-- Função principal de Auto Farm
local function startAutoFarm()
    equipWeapon() -- Equipar arma antes de começar
    
    while isRunning do
        -- Resetar contador
        updateKillCount(0)
        
        -- Etapa 1: Interagir com NPC
        interactWithNPC()
        
        -- Etapa 2: Aceitar quest
        acceptQuest()
        
        -- Pequena pausa
        wait(1)
        
        -- Etapa 3: Farmar bandidos
        local banditsKilled = 0
        while isRunning and killCount < targetBandits do
            if farmBandits() then
                banditsKilled = killCount
            end
            
            -- Se não matou ninguém, esperar um pouco
            if banditsKilled == 0 then
                wait(2)
                -- Tentar encontrar bandidos novamente
                for i = 1, 3 do
                    updateStatus("🔍 Procurando bandidos...", "yellow")
                    wait(1)
                end
            end
        end
        
        -- Se completou os 4 bandidos
        if killCount >= targetBandits then
            updateStatus("🎉 Missão completada! Reiniciando...", "green")
            wait(2) -- Pequena pausa antes de reiniciar
        end
        
        -- Verificar se deve continuar
        if not isRunning then break end
    end
end

-- Botão principal de Auto Farm
autoFarmButton.MouseButton1Click:Connect(function()
    if isRunning then
        -- Parar farm
        isRunning = false
        autoFarmButton.Text = "▶ INICIAR AUTO FARM"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        updateStatus("🛑 PARADO", "red")
    else
        -- Iniciar farm
        isRunning = true
        autoFarmButton.Text = "⏹️ PARAR AUTO FARM"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        updateStatus("🚀 INICIANDO...", "green")
        
        -- Iniciar em thread separada
        coroutine.wrap(function()
            startAutoFarm()
            
            -- Quando parar, resetar botão
            if not isRunning then
                autoFarmButton.Text = "▶ INICIAR AUTO FARM"
                autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
                updateStatus("🟢 PRONTO", "green")
            end
        end)()
    end
end)

-- Conectar evento de CharacterAdded
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(1)
    
    -- Se estava rodando, continuar
    if isRunning then
        updateStatus("♻️ Personagem respawnou, continuando...", "yellow")
        wait(2)
        equipWeapon()
    end
end)

-- Conectar evento de morte
if character:FindFirstChild("Humanoid") then
    character.Humanoid.Died:Connect(function()
        if isRunning then
            updateStatus("💀 Morreu, aguardando respawn...", "red")
        end
    end)
end

-- Inicialização
print("=====================================")
print("Shadow Hub | Fruits Battles Carregado")
print("Versão: 2.0 ")
print("=====================================")
print("NPC Location:", questNPC_CFrame)
print("Bandits Location:", banditsLocation)
print("=====================================")

-- Fechar hub quando pressionar ESC
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Escape then
        mainFrame.Visible = false
    end
end)