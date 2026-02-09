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
local safeYLevel = 35  -- Altura mínima segura para evitar água

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
-- SISTEMA DE INTERAÇÃO COM NPC
-- =====================================================================

local function findQuestNPC()
    updateStatus("🔍 Procurando NPC...", "blue")
    
    -- Procurar NPC na posição especificada
    local npcFound = nil
    local closestDistance = math.huge
    
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
            local distance = (questNPC_CFrame.Position - descendant:GetPivot().Position).Magnitude
            if distance < 25 and distance < closestDistance then
                npcFound = descendant
                closestDistance = distance
            end
        end
    end
    
    if npcFound then
        updateStatus(string.format("✅ NPC encontrado (%.1f unidades)", closestDistance), "green")
        return npcFound
    end
    
    -- Se não encontrou, criar ponto de interação na posição
    updateStatus("📍 Usando posição do NPC", "yellow")
    return nil
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
    
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        -- Posicionar na frente do NPC
        local npcPos = npc.HumanoidRootPart.Position
        local frontPosition = npcPos + (npc.HumanoidRootPart.CFrame.LookVector * -5)
        frontPosition = Vector3.new(frontPosition.X, safeYLevel, frontPosition.Z)
        
        safeTeleport(CFrame.new(frontPosition))
        
        -- Virar para o NPC
        character.HumanoidRootPart.CFrame = CFrame.lookAt(
            character.HumanoidRootPart.Position,
            Vector3.new(npcPos.X, character.HumanoidRootPart.Position.Y, npcPos.Z)
        )
        
        wait(0.5)
    end
    
    -- Segurar E por 3 segundos
    updateStatus("🗣️ Segurando E (3 segundos)...", "yellow")
    
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    
    local startTime = tick()
    while tick() - startTime < 3 and isRunning do
        local elapsed = tick() - startTime
        updateStatus(string.format("🗣️ Conversando... (%.1f/3s)", elapsed), "yellow")
        RunService.Heartbeat:Wait()
    end
    
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    
    updateStatus("✅ Conversa finalizada", "green")
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
    wait(2.5)
    
    -- Coordenadas do botão Aceitar: {0.756419659, 0}, {1.08244634, 0}
    -- Estas são coordenadas UDim2 (Scale, Offset)
    local screenSize = Camera.ViewportSize
    
    -- Calcular posição absoluta
    local buttonX = screenSize.X * 0.756419659
    local buttonY = screenSize.Y * 0.5  -- Posição central como fallback
    
    -- Se o segundo valor for muito grande, pode ser Offset
    if 1.08244634 > 10 then
        buttonY = 1.08244634
    else
        -- Posição típica de botões na parte inferior
        buttonY = screenSize.Y * 0.8
    end
    
    -- Garantir que está dentro da tela
    buttonX = math.clamp(buttonX, 50, screenSize.X - 50)
    buttonY = math.clamp(buttonY, 50, screenSize.Y - 50)
    
    updateStatus("🖱️ Clicando em Aceitar...", "yellow")
    
    -- Clicar na posição
    for i = 1, 3 do
        VirtualInputManager:SendMouseButtonEvent(buttonX, buttonY, 0, true, game, 1)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(buttonX, buttonY, 0, false, game, 1)
        wait(0.1)
    end
    
    updateStatus("✅ Missão aceita!", "green")
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
        
        -- Etapa 1: Interagir com NPC
        updateStatus("🗣️ Interagindo com NPC...", "blue")
        if not interactWithNPC() then
            updateStatus("❌ Falha na interação", "red")
            wait(3)
            continue
        end
        
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
                updateStatus("🌊 Sair da água...", "red")
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
print("SHADOW HUB | FRUITS BATTLES v2.0")
print("==========================================")
print("Status: ✅ Carregado com sucesso")
print("NPC Position: " .. tostring(questNPC_CFrame.Position))
print("Safe Height: " .. safeYLevel)
print("==========================================")
print("🔧 Sistema pronto para uso")
print("⏱️  Aguarde 2-3 segundos para inicialização completa")
print("==========================================")

-- Verificar recursos
wait(2)

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
print("3. O sistema fará automaticamente:")
print("   • Ir até o NPC")
print("   • Segurar E por 3 segundos")
print("   • Aceitar a missão")
print("   • Eliminar 4 bandidos")
print("   • Repetir o ciclo")
print("\n⚠️  MANTENHA-SE EM UM SERVIDOR PRIVADO")
print("==========================================")