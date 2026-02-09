-- Shadow Hub | Fruits Battles - Script Completo com ProximityPrompt
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
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
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
title.TextSize = 18
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
autoFarmButton.TextSize = 16
autoFarmButton.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0.9, 0, 0, 30)
statusLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
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
killCountLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
killCountLabel.BackgroundTransparency = 1
killCountLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
killCountLabel.Text = "Bandidos: 0/4"
killCountLabel.Font = Enum.Font.Gotham
killCountLabel.TextSize = 12
killCountLabel.Parent = mainFrame

-- Contador de ciclos
local cycleCountLabel = Instance.new("TextLabel")
cycleCountLabel.Name = "CycleCount"
cycleCountLabel.Size = UDim2.new(0.9, 0, 0, 30)
cycleCountLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
cycleCountLabel.BackgroundTransparency = 1
cycleCountLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
cycleCountLabel.Text = "Ciclos: 0"
cycleCountLabel.Font = Enum.Font.Gotham
cycleCountLabel.TextSize = 12
cycleCountLabel.Parent = mainFrame

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

-- =====================================================================
-- SISTEMA PRINCIPAL
-- =====================================================================

local character = player.Character or player.CharacterAdded:Wait()
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ProximityPromptService = game:GetService("ProximityPromptService")

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
local cycleCount = 0
local targetBandits = 4
local isInteracting = false
local safeYLevel = 35

-- =====================================================================
-- FUNÇÕES UTILITÁRIAS
-- =====================================================================

local function updateStatus(text, color)
    statusLabel.Text = text
    if color == "red" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    elseif color == "yellow" then
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    elseif color == "blue" then
        statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    else
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
end

local function updateKillCount(count)
    killCount = count
    killCountLabel.Text = string.format("Bandidos: %d/4", killCount)
end

local function updateCycleCount(count)
    cycleCount = count
    cycleCountLabel.Text = string.format("Ciclos: %d", cycleCount)
end

-- =====================================================================
-- SISTEMA DE MOVIMENTO SEGURO
-- =====================================================================

local function safeTeleport(cframe)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.Character or player.CharacterAdded:Wait()
        wait(1)
    end
    
    local humanoidRootPart = character.HumanoidRootPart
    
    -- Verificar se já está próximo
    local distance = (humanoidRootPart.Position - cframe.Position).Magnitude
    if distance < 10 then
        return true
    end
    
    -- Garantir que não estamos na água
    if humanoidRootPart.Position.Y < safeYLevel then
        humanoidRootPart.CFrame = CFrame.new(
            humanoidRootPart.Position.X,
            safeYLevel,
            humanoidRootPart.Position.Z
        )
        wait(0.3)
    end
    
    -- Ajustar altura do destino
    local targetPos = cframe.Position
    if targetPos.Y < safeYLevel then
        targetPos = Vector3.new(targetPos.X, safeYLevel, targetPos.Z)
    end
    
    -- Criar CFrame seguro
    local safeCFrame = CFrame.new(targetPos) * CFrame.Angles(0, humanoidRootPart.CFrame.Rotation.Y, 0)
    
    -- Movimento suave em 2 etapas
    local speed = 80
    local duration = math.min(distance / speed, 4)
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = safeCFrame})
    
    tween:Play()
    
    local startTime = tick()
    while tick() - startTime < duration + 1 and tween.PlaybackState == Enum.PlaybackState.Playing do
        if not isRunning then break end
        RunService.Heartbeat:Wait()
    end
    
    return true
end

-- =====================================================================
-- SISTEMA DE INTERAÇÃO COM NPC VIA PROXIMITYPROMPT
-- =====================================================================

local function findQuestNPC()
    updateStatus("🔍 Procurando NPC com ProximityPrompt...", "blue")
    
    local npcFound = nil
    local closestDistance = math.huge
    
    -- Procurar por modelos com ProximityPrompt
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") then
            -- Verificar se tem ProximityPrompt
            local prompt = descendant:FindFirstChildWhichIsA("ProximityPrompt")
            if prompt then
                local distance = (questNPC_CFrame.Position - descendant:GetPivot().Position).Magnitude
                if distance < 50 and distance < closestDistance then
                    npcFound = descendant
                    closestDistance = distance
                end
            end
        end
    end
    
    -- Se não encontrou com prompt, procurar qualquer NPC perto da posição
    if not npcFound then
        for _, descendant in pairs(workspace:GetDescendants()) do
            if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
                local distance = (questNPC_CFrame.Position - descendant:GetPivot().Position).Magnitude
                if distance < 30 and distance < closestDistance then
                    npcFound = descendant
                    closestDistance = distance
                end
            end
        end
    end
    
    if npcFound then
        updateStatus(string.format("✅ NPC encontrado (%.1f unidades)", closestDistance), "green")
        return npcFound
    end
    
    updateStatus("❌ NPC não encontrado", "red")
    return nil
end

local function getProximityPrompt(model)
    -- Procurar por ProximityPrompt no modelo
    local prompt = model:FindFirstChildWhichIsA("ProximityPrompt")
    
    -- Se não encontrar no modelo, procurar nos descendentes
    if not prompt then
        for _, descendant in pairs(model:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                prompt = descendant
                break
            end
        end
    end
    
    return prompt
end

local function interactWithProximityPrompt(npc)
    if not npc then return false end
    
    local prompt = getProximityPrompt(npc)
    
    if not prompt then
        updateStatus("❌ NPC não tem ProximityPrompt", "red")
        return false
    end
    
    updateStatus("🎯 Encontrou ProximityPrompt", "green")
    
    -- Posicionar dentro do alcance do prompt
    local npcPosition = npc:GetPivot().Position
    local promptRange = prompt.MaxActivationDistance or 10
    
    -- Calcular posição dentro do alcance
    local offsetDirection = (character.HumanoidRootPart.Position - npcPosition).Unit
    if offsetDirection.Magnitude == 0 then
        offsetDirection = Vector3.new(1, 0, 0)  -- Direção padrão se estiver na mesma posição
    end
    
    local targetPosition = npcPosition + (offsetDirection * math.min(promptRange * 0.8, 5))
    targetPosition = Vector3.new(targetPosition.X, safeYLevel, targetPosition.Z)
    
    safeTeleport(CFrame.new(targetPosition))
    
    -- Virar para o NPC
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        character.HumanoidRootPart.Position,
        Vector3.new(npcPosition.X, character.HumanoidRootPart.Position.Y, npcPosition.Z)
    )
    
    wait(0.5)
    
    -- Acionar o ProximityPrompt
    updateStatus("🤝 Interagindo com NPC...", "yellow")
    
    -- Método 1: Simular pressionar a tecla de ativação
    local activationKey = prompt.KeyboardKeyCode or Enum.KeyCode.E
    
    -- Pressionar e segurar a tecla pelo tempo necessário
    local holdDuration = prompt.HoldDuration or 0
    
    if holdDuration > 0 then
        updateStatus(string.format("⏳ Segurando %s por %.1fs...", tostring(activationKey), holdDuration), "yellow")
        
        -- Pressionar a tecla
        VirtualInputManager:SendKeyEvent(true, activationKey, false, nil)
        
        -- Esperar o tempo de segurar
        local startTime = tick()
        while tick() - startTime < holdDuration and isRunning do
            updateStatus(string.format("⏳ Segurando... (%.1f/%.1fs)", tick() - startTime, holdDuration), "yellow")
            RunService.Heartbeat:Wait()
        end
        
        -- Soltar a tecla
        VirtualInputManager:SendKeyEvent(false, activationKey, false, nil)
    else
        updateStatus(string.format("🖱️ Pressionando %s...", tostring(activationKey)), "yellow")
        
        -- Pressionar rapidamente para prompts instantâneos
        VirtualInputManager:SendKeyEvent(true, activationKey, false, nil)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, activationKey, false, nil)
    end
    
    -- Método alternativo: Acionar o evento Triggered diretamente
    if prompt then
        updateStatus("⚡ Ativando ProximityPrompt...", "blue")
        
        -- Criar uma cópia segura do evento
        local success, err = pcall(function()
            -- Tentar acionar o prompt
            prompt:InputHoldBegin()
            if holdDuration > 0 then
                wait(holdDuration)
            end
            prompt:InputHoldEnd()
        end)
        
        if not success then
            updateStatus("⚠️ Método alternativo falhou, tentando trigger direto...", "yellow")
            
            -- Tentar método mais direto
            local success2 = pcall(function()
                prompt.Triggered:Fire(player)
            end)
            
            if not success2 then
                updateStatus("❌ Não conseguiu ativar o prompt", "red")
                return false
            end
        end
    end
    
    -- Esperar um pouco para a interação completar
    wait(1)
    
    updateStatus("✅ Interação concluída", "green")
    return true
end

local function interactWithNPC()
    if isInteracting then return false end
    isInteracting = true
    
    updateStatus("📍 Indo até o NPC...", "yellow")
    
    -- Ir para a posição do NPC
    safeTeleport(questNPC_CFrame)
    wait(0.5)
    
    -- Encontrar NPC
    local npc = findQuestNPC()
    
    if not npc then
        updateStatus("❌ NPC não encontrado na posição", "red")
        
        -- Tentar usar a posição exata
        updateStatus("📍 Usando posição exata...", "yellow")
        
        -- Posicionar na posição do NPC e tentar interagir
        character.HumanoidRootPart.CFrame = CFrame.new(
            questNPC_CFrame.Position.X,
            safeYLevel,
            questNPC_CFrame.Position.Z
        )
        
        wait(1)
        
        -- Tentar encontrar NPC novamente
        npc = findQuestNPC()
    end
    
    if npc then
        -- Interagir usando ProximityPrompt
        local success = interactWithProximityPrompt(npc)
        
        if not success then
            updateStatus("🔄 Tentando método alternativo...", "yellow")
            
            -- Método de fallback: Simular E por 3 segundos
            updateStatus("🗣️ Segurando E por 3 segundos...", "yellow")
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
            
            local startTime = tick()
            while tick() - startTime < 3 and isRunning do
                updateStatus(string.format("🗣️ Segurando E... (%.1f/3s)", tick() - startTime), "yellow")
                RunService.Heartbeat:Wait()
            end
            
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
        end
    else
        -- Se não encontrou NPC, tentar interagir na posição
        updateStatus("📍 Tentando interagir na posição...", "yellow")
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
        wait(3)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    end
    
    wait(0.5)
    isInteracting = false
    return true
end

-- =====================================================================
-- SISTEMA DE ACEITAR QUEST
-- =====================================================================

local function acceptQuest()
    updateStatus("⏳ Aguardando janela da missão...", "yellow")
    
    -- Aguardar janela aparecer
    local maxWaitTime = 5
    local startTime = tick()
    
    while tick() - startTime < maxWaitTime and isRunning do
        -- Verificar se apareceu alguma GUI
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                -- Procurar por botões de aceitar
                for _, descendant in pairs(gui:GetDescendants()) do
                    if descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
                        local buttonText = (descendant.Text or ""):lower()
                        local buttonName = descendant.Name:lower()
                        
                        if buttonText:find("aceitar") or buttonText:find("accept") or 
                           buttonText:find("iniciar") or buttonText:find("start") or
                           buttonName:find("accept") or buttonName:find("aceitar") then
                            
                            updateStatus("✅ Janela encontrada!", "green")
                            
                            -- Clicar no botão
                            local absolutePosition = descendant.AbsolutePosition
                            local absoluteSize = descendant.AbsoluteSize
                            local centerX = absolutePosition.X + absoluteSize.X / 2
                            local centerY = absolutePosition.Y + absoluteSize.Y / 2
                            
                            for i = 1, 3 do
                                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                                wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                                wait(0.1)
                            end
                            
                            updateStatus("🎯 Missão aceita!", "green")
                            return true
                        end
                    end
                end
            end
        end
        
        wait(0.1)
    end
    
    -- Se não encontrou pela GUI, tentar clicar na posição fornecida
    updateStatus("📍 Clicando na posição do botão...", "yellow")
    
    local screenSize = Camera.ViewportSize
    local buttonX = screenSize.X * 0.756419659
    local buttonY = screenSize.Y * 0.8  -- Posição típica de botões
    
    -- Garantir que está dentro da tela
    buttonX = math.clamp(buttonX, 50, screenSize.X - 50)
    buttonY = math.clamp(buttonY, 50, screenSize.Y - 50)
    
    for i = 1, 3 do
        VirtualInputManager:SendMouseButtonEvent(buttonX, buttonY, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(buttonX, buttonY, 0, false, game, 1)
        wait(0.1)
    end
    
    updateStatus("✅ Missão aceita (posição)", "green")
    return true
end

-- =====================================================================
-- SISTEMA DE EQUIPAMENTO
-- =====================================================================

local function equipWeapon()
    updateStatus("⚔️ Buscando arma...", "yellow")
    
    -- Prioridade: Melee > Sword
    local weaponPriority = {"Melee", "Sword"}
    
    -- Verificar no inventário
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, weaponName in pairs(weaponPriority) do
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name:lower(), weaponName:lower()) then
                    character.Humanoid:EquipTool(tool)
                    wait(0.5)
                    updateStatus("✅ " .. tool.Name .. " equipada", "green")
                    return tool
                end
            end
        end
    end
    
    -- Verificar no personagem
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.find(tool.Name:lower(), "melee") or string.find(tool.Name:lower(), "sword")) then
            character.Humanoid:EquipTool(tool)
            wait(0.5)
            updateStatus("✅ " .. tool.Name .. " equipada", "green")
            return tool
        end
    end
    
    updateStatus("⚠️ Nenhuma arma encontrada", "yellow")
    return nil
end

-- =====================================================================
-- SISTEMA DE COMBATE
-- =====================================================================

local function findBandits()
    local bandits = {}
    
    -- Método 1: Localização específica
    if banditsLocation then
        for _, enemy in pairs(banditsLocation:GetChildren()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                table.insert(bandits, enemy)
            end
        end
    end
    
    -- Método 2: Busca por nome
    if #bandits == 0 then
        for _, enemy in pairs(workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                if string.find(enemy.Name:lower(), "bandit") or string.find(enemy.Name:lower(), "bandido") then
                    table.insert(bandits, enemy)
                end
            end
        end
    end
    
    return bandits
end

local function attackEnemy(enemy)
    if not enemy or not enemy.Parent or not enemy:FindFirstChild("Humanoid") then
        return false
    end
    
    -- Equipar arma se necessário
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        tool = equipWeapon()
        if not tool then return false end
    end
    
    -- Ir até o inimigo
    local enemyPos = enemy.HumanoidRootPart.Position
    local safePos = Vector3.new(enemyPos.X, math.max(enemyPos.Y, safeYLevel), enemyPos.Z)
    
    safeTeleport(CFrame.new(safePos) * CFrame.new(0, 0, 8))
    wait(0.3)
    
    -- Sistema de ataque
    local maxAttackTime = 10
    local startTime = tick()
    local attacks = 0
    
    while enemy and enemy.Parent and enemy.Humanoid.Health > 0 and 
          tick() - startTime < maxAttackTime and isRunning do
        
        -- Posicionar corretamente
        if character.HumanoidRootPart and enemy.HumanoidRootPart then
            local enemyPos = enemy.HumanoidRootPart.Position
            local safeEnemyPos = Vector3.new(enemyPos.X, math.max(enemyPos.Y, safeYLevel), enemyPos.Z)
            local direction = (safeEnemyPos - character.HumanoidRootPart.Position).Unit
            
            character.HumanoidRootPart.CFrame = CFrame.new(
                safeEnemyPos - direction * 4,
                safeEnemyPos
            )
        end
        
        -- Atacar
        for i = 1, 5 do
            if not isRunning then break end
            if tool then
                tool:Activate()
            end
            
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.03)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            wait(0.05)
            
            attacks = attacks + 1
            if attacks % 20 == 0 then
                updateStatus(string.format("⚔️ Atacando... (%d golpes)", attacks), "yellow")
            end
        end
        
        wait(0.1)
    end
    
    -- Verificar se matou
    if enemy.Humanoid.Health <= 0 then
        updateKillCount(killCount + 1)
        updateStatus(string.format("☠️ Bandido %d/4 eliminado", killCount), "green")
        return true
    end
    
    return false
end

local function farmBandits()
    updateStatus("🔍 Procurando bandidos...", "yellow")
    
    local bandits = findBandits()
    
    if #bandits == 0 then
        updateStatus("❌ Nenhum bandido encontrado", "red")
        return false
    end
    
    updateStatus(string.format("✅ %d bandidos encontrados", #bandits), "green")
    
    for _, bandit in pairs(bandits) do
        if not isRunning or killCount >= targetBandits then break end
        
        if bandit.Humanoid.Health > 0 then
            updateStatus(string.format("⚔️ Atacando bandido (%d/%d)...", killCount + 1, targetBandits), "yellow")
            attackEnemy(bandit)
            wait(0.5)
        end
    end
    
    return killCount >= targetBandits
end

-- =====================================================================
-- SISTEMA PRINCIPAL DE AUTO FARM
-- =====================================================================

local function mainFarmLoop()
    updateStatus("🚀 Iniciando ciclo de farm...", "green")
    
    while isRunning do
        -- Resetar contador de kills
        updateKillCount(0)
        
        -- Etapa 1: Interagir com NPC via ProximityPrompt
        updateStatus("🗣️ Interagindo com NPC...", "blue")
        if not interactWithNPC() then
            updateStatus("❌ Falha na interação", "red")
            wait(3)
            continue
        end
        
        -- Pequena pausa para a janela aparecer
        wait(2)
        
        -- Etapa 2: Aceitar quest
        updateStatus("✅ Aceitando missão...", "yellow")
        acceptQuest()
        
        -- Pequena pausa
        wait(1)
        
        -- Etapa 3: Equipar arma
        equipWeapon()
        
        -- Etapa 4: Farmar bandidos
        updateStatus("🎯 Eliminando bandidos...", "green")
        
        local startFarmTime = tick()
        while isRunning and killCount < targetBandits do
            farmBandits()
            
            -- Se demorar muito, verificar novamente
            if tick() - startFarmTime > 60 then
                updateStatus("⚠️ Demorando muito, reiniciando...", "yellow")
                break
            end
            
            wait(1)
        end
        
        -- Verificar se completou
        if killCount >= targetBandits then
            updateCycleCount(cycleCount + 1)
            updateStatus(string.format("🎉 Ciclo %d completado!", cycleCount), "green")
            wait(3)  -- Pausa entre ciclos
        end
    end
end

-- =====================================================================
-- CONTROLES PRINCIPAIS
-- =====================================================================

autoFarmButton.MouseButton1Click:Connect(function()
    if isRunning then
        -- Parar
        isRunning = false
        autoFarmButton.Text = "▶ INICIAR AUTO FARM"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
        updateStatus("🛑 PARADO", "red")
    else
        -- Iniciar
        isRunning = true
        autoFarmButton.Text = "⏹️ PARAR AUTO FARM"
        autoFarmButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        updateStatus("🚀 INICIANDO...", "green")
        
        -- Resetar contadores
        updateKillCount(0)
        
        -- Iniciar em thread separada
        coroutine.wrap(function()
            mainFarmLoop()
            
            -- Quando terminar
            if not isRunning then
                autoFarmButton.Text = "▶ INICIAR AUTO FARM"
                autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
                updateStatus("🟢 PRONTO", "green")
            end
        end)()
    end
end)

-- =====================================================================
-- SISTEMA DE SEGURANÇA
-- =====================================================================

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    wait(1)
    
    if isRunning then
        updateStatus("♻️ Personagem respawnou, continuando...", "yellow")
        wait(2)
        equipWeapon()
    end
end)

-- Sistema anti-água
coroutine.wrap(function()
    while true do
        wait(2)
        if character and character:FindFirstChild("HumanoidRootPart") then
            local pos = character.HumanoidRootPart.Position
            if pos.Y < 0 then  -- Se estiver na água
                updateStatus("🌊 Saindo da água...", "red")
                character.HumanoidRootPart.CFrame = CFrame.new(pos.X, safeYLevel, pos.Z)
            end
        end
    end
end)()

-- Fechar hub com ESC
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Escape then
        mainFrame.Visible = false
    end
end)

-- =====================================================================
-- INICIALIZAÇÃO
-- =====================================================================

print("==========================================")
print("SHADOW HUB | FRUITS BATTLES v3.0")
print("==========================================")
print("Status: ✅ Carregado com sucesso")
print("NPC Position: " .. tostring(questNPC_CFrame.Position))
print("Safe Height: " .. safeYLevel)
print("ProximityPrompt: ✅ Sistema implementado")
print("==========================================")
print("🎮 SISTEMA DE PROXIMITYPROMPT ATIVADO")
print("⏱️  Tempo de inicialização: 3-5 segundos")
print("==========================================")

-- Verificar recursos
wait(3)

if not character:FindFirstChild("HumanoidRootPart") then
    updateStatus("⚠️ Personagem não carregado", "red")
    wait(3)
    updateStatus("🟢 PRONTO", "green")
else
    updateStatus("✅ Sistema inicializado", "green")
end

-- Instruções no output
print("\n🎮 INSTRUÇÕES:")
print("1. Clique no botão ☰ para abrir o hub")
print("2. Clique em 'INICIAR AUTO FARM' para começar")
print("3. O sistema agora usa ProximityPrompt para interagir")
print("4. Funciona com prompts que requerem segurar E")
print("\n⚙️  SISTEMA OTIMIZADO:")
print("• ProximityPrompt detection ✅")
print("• Hold duration support ✅")
print("• Multiple interaction methods ✅")
print("• Water protection ✅")
print("\n⚠️  MANTENHA-SE EM UM SERVIDOR PRIVADO")
print("==========================================")