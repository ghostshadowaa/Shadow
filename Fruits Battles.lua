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
local Camera = workspace.CurrentCamera

-- Configurações
local questNPC_CFrame = CFrame.new(-483.6507568359375, 31.39537811279297, -811.273681640625)
local banditsLocation = game.Workspace:FindFirstChild("Visuals") and 
                       game.Workspace.Visuals:FindFirstChild("More") and
                       game.Workspace.Visuals.More:FindFirstChild("Npcs") and
                       game.Workspace.Visuals.More.Npcs:FindFirstChild("Enemy") and
                       game.Workspace.Visuals.More.Npcs.Enemy:FindFirstChild("Bandits")

-- Posição do botão Aceitar (em coordenadas de tela)
local acceptButtonPosition = Vector2.new(0.756419659 * 1000, 1.08244634 * 1000)
-- Nota: Multiplicando por 1000 pois as coordenadas parecem ser em escala 0-1

-- Variáveis de controle
local isRunning = false
local killCount = 0
local targetBandits = 4
local isInteracting = false

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
    
    -- Verificar se já está próximo
    local distance = (humanoidRootPart.Position - cframe.Position).Magnitude
    if distance < 10 then
        return true
    end
    
    -- Velocidade rápida: menor tempo para maior velocidade
    local speed = 100 -- Unidades por segundo
    local duration = math.min(distance / speed, 2) -- Máximo 2 segundos
    
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = cframe})
    tween:Play()
    
    -- Esperar completar
    local startTime = tick()
    while tick() - startTime < duration + 0.5 and tween.PlaybackState == Enum.PlaybackState.Playing do
        RunService.Heartbeat:Wait()
    end
    
    return true
end

-- Função para encontrar NPC mais próximo da posição fornecida
local function findClosestNPC(position)
    local closestNPC = nil
    local closestDistance = math.huge
    
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            local npcPos = npc:GetPivot().Position
            local distance = (position - npcPos).Magnitude
            
            -- Verificar se é um NPC de quest (pode ter nome específico)
            if distance < 50 and distance < closestDistance then
                closestNPC = npc
                closestDistance = distance
            end
        end
    end
    
    return closestNPC
end

-- Função para interagir com NPC segurando E por 3 segundos
local function interactWithNPC()
    if isInteracting then return false end
    isInteracting = true
    
    updateStatus("📍 Indo até o NPC...", "yellow")
    
    -- Ir até a posição do NPC
    teleportTo(questNPC_CFrame)
    
    -- Procurar NPC mais próximo
    local npc = findClosestNPC(questNPC_CFrame.Position)
    
    if not npc then
        updateStatus("❌ NPC não encontrado!", "red")
        isInteracting = false
        return false
    end
    
    -- Posicionar na frente do NPC
    updateStatus("🚶 Posicionando...", "yellow")
    local npcCFrame = npc:GetPivot()
    teleportTo(npcCFrame * CFrame.new(2, 2, -5))
    
    -- Virar para o NPC
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        character.HumanoidRootPart.Position,
        Vector3.new(npcCFrame.X, character.HumanoidRootPart.Position.Y, npcCFrame.Z)
    )
    
    wait(0.5)
    
    -- Segurar tecla E por 3 segundos (SEM SOLTAR)
    updateStatus("🗣️ Conversando com NPC (3s)...", "yellow")
    
    -- Pressionar E e segurar por 3 segundos
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
    
    -- Manter pressionado por 3 segundos
    local startTime = tick()
    while tick() - startTime < 3 and isRunning do
        updateStatus(string.format("🗣️ Conversando... (%.1fs/3s)", tick() - startTime), "yellow")
        RunService.Heartbeat:Wait()
    end
    
    -- Soltar E após 3 segundos
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
    
    updateStatus("✅ Conversa concluída!", "green")
    wait(0.5)
    
    isInteracting = false
    return true
end

-- Função para clicar no botão Aceitar na posição específica
local function clickAcceptButton()
    updateStatus("🖱️ Clicando em Aceitar...", "yellow")
    
    -- Usar as coordenadas fornecidas
    -- {0.756419659, 0}, {1.08244634, 0}
    -- Aparentemente são coordenadas UDim2: ScaleX=0.756, OffsetX=0, ScaleY=1.082, OffsetY=0
    -- Vamos converter para posição absoluta da tela
    
    local screenSize = Camera.ViewportSize
    local absoluteX = screenSize.X * 0.756419659
    local absoluteY = screenSize.Y * 1.08244634
    
    -- Ajustar se as coordenadas estiverem fora da tela
    absoluteX = math.clamp(absoluteX, 0, screenSize.X)
    absoluteY = math.clamp(absoluteY, 0, screenSize.Y)
    
    print(string.format("Clicando na posição: X=%.0f, Y=%.0f", absoluteX, absoluteY))
    
    -- Clicar e segurar por um breve momento
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)
    wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0)
    
    -- Fazer clique duplo para garantir
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, true, game, 0)
    wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(absoluteX, absoluteY, 0, false, game, 0)
    
    return true
end

-- Função para aceitar quest clicando na posição específica
local function acceptQuest()
    updateStatus("⏳ Aguardando janela da missão...", "yellow")
    
    -- Aguardar a janela aparecer
    wait(2)
    
    -- Tentar várias vezes clicar no botão
    for attempt = 1, 5 do
        if not isRunning then break end
        
        updateStatus(string.format("🖱️ Tentativa %d/5 de aceitar...", attempt), "yellow")
        
        clickAcceptButton()
        
        -- Verificar se a missão foi aceita (pelo contador resetar)
        wait(1)
        
        -- Se o script continuar, assumimos que funcionou
        updateStatus("✅ Missão aceita!", "green")
        return true
    end
    
    updateStatus("⚠️ Não conseguiu aceitar a missão", "red")
    return false
end

-- Função para equipar Melee ou Sword
local function equipWeapon()
    updateStatus("⚔️ Equipando arma...", "yellow")
    
    -- Lista de prioridade de armas
    local weaponPriority = {"Melee", "Sword"}
    
    -- Verificar no inventário primeiro
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
        if item:IsA("Tool") and (item.Name:lower():find("melee") or item.Name:lower():find("sword")) then
            character.Humanoid:EquipTool(item)
            wait(0.5)
            updateStatus("✅ " .. item.Name .. " equipada!", "green")
            return item
        end
    end
    
    updateStatus("⚠️ Nenhuma arma Melee/Sword encontrada", "red")
    return nil
end

-- Função para encontrar bandidos
local function findBandits()
    -- Tentar primeiro pela localização específica
    if banditsLocation then
        local bandits = {}
        for _, child in pairs(banditsLocation:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 then
                table.insert(bandits, child)
            end
        end
        return bandits
    end
    
    -- Se não encontrar, procurar por modelos com "Bandit" no nome
    local allBandits = {}
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") and 
           descendant.Humanoid.Health > 0 and descendant.Name:lower():find("bandit") then
            table.insert(allBandits, descendant)
        end
    end
    return allBandits
end

-- Função para atacar um bandido específico
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
    teleportTo(bandit.HumanoidRootPart.CFrame * CFrame.new(0, 0, 8))
    
    -- Autoclick loop
    local maxTime = 8 -- segundos máximo por bandido
    local startTime = tick()
    
    while bandit and bandit.Parent and bandit.Humanoid.Health > 0 and 
          tick() - startTime < maxTime and isRunning do
        
        -- Calcular posição para atacar
        if character.HumanoidRootPart and bandit.HumanoidRootPart then
            local direction = (bandit.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Unit
            character.HumanoidRootPart.CFrame = CFrame.new(
                bandit.HumanoidRootPart.Position - direction * 5,
                bandit.HumanoidRootPart.Position
            )
        end
        
        -- Ativar a ferramenta (ataque)
        tool:Activate()
        
        -- Simular clique do mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        wait(0.1)
    end
    
    -- Verificar se matou
    if bandit.Humanoid.Health <= 0 then
        updateKillCount(killCount + 1)
        updateStatus(string.format("☠️ Bandido %d/4 eliminado!", killCount), "green")
        return true
    end
    
    return false
end

-- Função principal de farm de bandidos
local function farmBandits()
    updateStatus("🔍 Procurando bandidos...", "yellow")
    
    local bandits = findBandits()
    local killedThisCycle = 0
    
    while isRunning and killCount < targetBandits and #bandits > 0 do
        for _, bandit in pairs(bandits) do
            if not isRunning or killCount >= targetBandits then break end
            
            if bandit.Humanoid.Health > 0 then
                updateStatus(string.format("⚔️ Atacando bandido (%d/%d)...", killCount + 1, targetBandits), "yellow")
                
                if attackBandit(bandit) then
                    killedThisCycle = killedThisCycle + 1
                    wait(0.3) -- Pequena pausa entre bandidos
                end
            end
        end
        
        -- Se não matou ninguém neste ciclo, esperar e procurar novamente
        if killedThisCycle == 0 then
            updateStatus("⏳ Aguardando bandidos...", "yellow")
            wait(2)
        end
        
        -- Atualizar lista de bandidos
        bandits = findBandits()
        killedThisCycle = 0
        
        wait(0.5)
    end
    
    return killCount >= targetBandits
end

-- Função principal de Auto Farm
local function startAutoFarm()
    updateStatus("🚀 Iniciando Auto Farm...", "green")
    
    while isRunning do
        -- Resetar contador de kills
        updateKillCount(0)
        
        -- Equipar arma antes de começar
        equipWeapon()
        
        -- Etapa 1: Conversar com NPC (segurando E por 3s)
        if not interactWithNPC() then
            updateStatus("❌ Falha ao interagir com NPC", "red")
            wait(2)
            continue
        end
        
        -- Pequena pausa para a janela aparecer
        wait(1)
        
        -- Etapa 2: Aceitar quest clicando na posição específica
        if not acceptQuest() then
            updateStatus("❌ Falha ao aceitar missão", "red")
            wait(2)
            continue
        end
        
        wait(1) -- Pequena pausa
        
        -- Etapa 3: Farmar bandidos
        updateStatus("🎯 Iniciando eliminação de bandidos...", "green")
        
        while isRunning and killCount < targetBandits do
            farmBandits()
            
            -- Se ainda não completou, esperar um pouco
            if killCount < targetBandits then
                updateStatus(string.format("⏳ Aguardando... (%d/%d)", killCount, targetBandits), "yellow")
                wait(1)
            end
        end
        
        -- Se completou a missão
        if killCount >= targetBandits then
            updateStatus("🎉 Missão completada! Reiniciando...", "green")
            wait(3) -- Pausa antes de reiniciar
        end
        
        -- Pequena pausa entre ciclos
        if isRunning then
            wait(1)
        end
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

-- Fechar hub quando pressionar ESC
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Escape then
        mainFrame.Visible = false
    end
end)

-- Inicialização
print("=====================================")
print("Shadow Hub | Fruits Battles Carregado")
print("Versão: 4.0 - Posição Específica do Botão")
print("=====================================")
print("NPC Location:", questNPC_CFrame)
print("Botão Aceitar Posição:", acceptButtonPosition)
print("=====================================")