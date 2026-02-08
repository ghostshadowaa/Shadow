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
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 255)
mainFrame.Visible = false
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

-- Botão de Auto Quest
local autoQuestButton = Instance.new("TextButton")
autoQuestButton.Name = "AutoQuest"
autoQuestButton.Size = UDim2.new(0.8, 0, 0, 40)
autoQuestButton.Position = UDim2.new(0.1, 0, 0, 50)
autoQuestButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
autoQuestButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoQuestButton.Text = "Iniciar Auto Quest"
autoQuestButton.Font = Enum.Font.Gotham
autoQuestButton.TextSize = 14
autoQuestButton.Parent = mainFrame

-- Botão de Auto Farm
local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Name = "AutoFarm"
autoFarmButton.Size = UDim2.new(0.8, 0, 0, 40)
autoFarmButton.Position = UDim2.new(0.1, 0, 0, 100)
autoFarmButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
autoFarmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmButton.Text = "Auto Farm Bandits"
autoFarmButton.Font = Enum.Font.Gotham
autoFarmButton.TextSize = 14
autoFarmButton.Parent = mainFrame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
statusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Status: Pronto"
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = mainFrame

-- Efeitos visuais nos botões
local function setupButtonEffects(button)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    end)
end

setupButtonEffects(autoQuestButton)
setupButtonEffects(autoFarmButton)
setupButtonEffects(toggleButton)

-- Variáveis do sistema
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
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

local WEAPONS = {"Katana", "Dual Katana", "Triplo Katana", "Night Blade", "Combat"}

-- Variáveis de controle
local isRunning = false
local isFarming = false
local selectedWeapon = nil
local currentConnection = nil

-- Função para atualizar status
local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

-- Função para fazer o botão flutuante arrastável
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X,
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Função para teletransportar personagem (tween rápido)
local function teleportTo(cframe)
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        character = player.Character or player.CharacterAdded:Wait()
    end
    
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local distance = (humanoidRootPart.Position - cframe.Position).Magnitude
    
    -- Velocidade rápida: menor tempo para maior velocidade
    local speed = 150 -- Unidades por segundo
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(
        math.min(duration, 5), -- Limitar a 5 segundos máximo
        Enum.EasingStyle.Linear
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = cframe})
    tween:Play()
    
    -- Esperar completar ou timeout
    local startTime = tick()
    while tick() - startTime < 6 and tween.PlaybackState == Enum.PlaybackState.Playing do
        updateStatus("Movendo... " .. math.floor((tick() - startTime)) .. "s")
        wait(0.1)
    end
    
    return true
end

-- Função para interagir com NPC por 2 segundos
local function interactWithNPC()
    updateStatus("Interagindo com NPC...")
    
    -- Procurar NPC próximo
    local npc = nil
    local closestDistance = math.huge
    
    for _, descendant in pairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
            local distance = (character.HumanoidRootPart.Position - descendant:GetPivot().Position).Magnitude
            if distance < 50 and distance < closestDistance then
                npc = descendant
                closestDistance = distance
            end
        end
    end
    
    if npc then
        -- Posicionar perto do NPC
        character.HumanoidRootPart.CFrame = npc:GetPivot() * CFrame.new(0, 0, -3)
        wait(0.5)
        
        -- Simular pressionar E para interagir
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, nil)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, nil)
        
        updateStatus("Dialogando...")
        wait(2) -- Esperar 2 segundos para diálogo
        
        return true
    end
    
    return false
end

-- Função para aceitar quest via GUI
local function acceptQuest()
    updateStatus("Tentando aceitar quest...")
    
    -- Procurar a GUI da quest
    for i = 1, 10 do
        local questFrame = player.PlayerGui:FindFirstChild("QuestFrame")
        if questFrame then
            local questOptions = questFrame:FindFirstChild("QuestOptions")
            if questOptions then
                local acceptButton = questOptions:FindFirstChild("Accept")
                if acceptButton then
                    -- Simular clique
                    if acceptButton:IsA("TextButton") then
                        acceptButton:FireEvent("MouseButton1Click")
                        updateStatus("Quest aceita!")
                        return true
                    end
                end
            end
        end
        wait(0.5)
    end
    
    updateStatus("Não encontrou botão de aceitar")
    return false
end

-- Função para verificar armas no inventário
local function getAvailableWeapons()
    local backpack = player:FindFirstChild("Backpack")
    local weaponsFound = {}
    
    if backpack then
        for _, weaponName in pairs(WEAPONS) do
            local weapon = backpack:FindFirstChild(weaponName)
            if weapon then
                table.insert(weaponsFound, weaponName)
            end
        end
    end
    
    -- Verificar também na mão do personagem
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            for _, weaponName in pairs(WEAPONS) do
                if string.find(tool.Name:lower(), weaponName:lower()) then
                    if not table.find(weaponsFound, weaponName) then
                        table.insert(weaponsFound, weaponName)
                    end
                end
            end
        end
    end
    
    return weaponsFound
end

-- Interface de seleção de arma
local function showWeaponSelection()
    updateStatus("Selecionando arma...")
    
    local availableWeapons = getAvailableWeapons()
    
    if #availableWeapons == 0 then
        updateStatus("Nenhuma arma encontrada!")
        return nil
    end
    
    -- Criar GUI de seleção
    local selectionGui = Instance.new("ScreenGui")
    selectionGui.Name = "WeaponSelection"
    selectionGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(100, 100, 255)
    frame.Parent = selectionGui
    
    local title = Instance.new("TextLabel")
    title.Text = "Selecione sua arma:"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.TextColor3 = Color3.white
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = frame
    
    closeButton.MouseButton1Click:Connect(function()
        selectionGui:Destroy()
    end)
    
    local yOffset = 40
    local weaponButtons = {}
    
    for _, weaponName in pairs(availableWeapons) do
        local button = Instance.new("TextButton")
        button.Text = weaponName
        button.Size = UDim2.new(0.8, 0, 0, 30)
        button.Position = UDim2.new(0.1, 0, 0, yOffset)
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        button.TextColor3 = Color3.white
        button.Font = Enum.Font.Gotham
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            selectedWeapon = weaponName
            selectionGui:Destroy()
            updateStatus("Arma selecionada: " .. weaponName)
        end)
        
        table.insert(weaponButtons, button)
        yOffset = yOffset + 35
    end
    
    -- Esperar seleção ou fechar
    local connection
    connection = selectionGui.Destroying:Connect(function()
        if connection then connection:Disconnect() end
    end)
    
    while selectionGui.Parent do
        wait()
    end
    
    return selectedWeapon
end

-- Função para equipar arma
local function selectWeapon(weaponName)
    local backpack = player:FindFirstChild("Backpack")
    
    -- Procurar no backpack
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(item.Name:lower(), weaponName:lower()) then
                humanoid:EquipTool(item)
                wait(0.5)
                return item
            end
        end
    end
    
    -- Procurar no chão (Workspace)
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Tool") and string.find(item.Name:lower(), weaponName:lower()) then
            character.HumanoidRootPart.CFrame = item.Handle.CFrame
            wait(0.5)
            firetouchinterest(character.HumanoidRootPart, item.Handle, 0)
            wait(0.1)
            firetouchinterest(character.HumanoidRootPart, item.Handle, 1)
            wait(0.5)
            return item
        end
    end
    
    return nil
end

-- Função para atacar inimigos com autoclick
local function autoAttack(target)
    if not target or not target.Parent or not target:FindFirstChild("Humanoid") then
        return false
    end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        updateStatus("Nenhuma arma equipada!")
        return false
    end
    
    -- Trazer inimigo (bring)
    character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    
    -- Autoclick loop
    local startTime = tick()
    while target and target.Parent and target.Humanoid.Health > 0 and tick() - startTime < 10 do
        if not isRunning then break end
        
        -- Ativar a ferramenta
        tool:Activate()
        
        -- Simular clique do mouse
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        
        -- Manter posição próxima
        if character.HumanoidRootPart and target.HumanoidRootPart then
            character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        end
        
        wait(0.2)
    end
    
    return target.Humanoid.Health <= 0
end

-- Função principal de farm de bandidos
local function farmBandits()
    if not banditsLocation then
        updateStatus("Local dos bandidos não encontrado!")
        return
    end
    
    updateStatus("Fazendo farm de bandidos...")
    
    while isRunning do
        local bandits = banditsLocation:GetChildren()
        
        for _, bandit in pairs(bandits) do
            if not isRunning then break end
            
            if bandit:FindFirstChild("Humanoid") and bandit.Humanoid.Health > 0 then
                updateStatus("Atacando bandido...")
                
                -- Ir até o bandido
                teleportTo(bandit.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                
                -- Atacar
                autoAttack(bandit)
                
                wait(0.5)
            end
        end
        
        if #banditsLocation:GetChildren() == 0 then
            updateStatus("Todos bandidos derrotados! Esperando respawn...")
            wait(5)
        else
            wait(1)
        end
    end
end

-- Função principal de Auto Quest
autoQuestButton.MouseButton1Click:Connect(function()
    if isRunning then
        isRunning = false
        autoQuestButton.Text = "Iniciar Auto Quest"
        updateStatus("Parado")
        return
    end
    
    isRunning = true
    autoQuestButton.Text = "Parando Auto Quest..."
    
    -- Iniciar em uma nova thread para não travar a GUI
    coroutine.wrap(function()
        -- Etapa 1: Ir até o NPC de quest
        updateStatus("Indo até o NPC...")
        if teleportTo(questNPC_CFrame) then
            wait(1)
            
            -- Etapa 2: Interagir com NPC
            if interactWithNPC() then
                
                -- Etapa 3: Aceitar quest
                if acceptQuest() then
                    wait(1)
                    
                    -- Etapa 4: Ir até os bandidos
                    if banditsLocation then
                        local firstBandit = banditsLocation:FindFirstChildOfClass("Model")
                        if firstBandit and firstBandit:FindFirstChild("HumanoidRootPart") then
                            updateStatus("Indo até os bandidos...")
                            teleportTo(firstBandit.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10))
                            
                            -- Etapa 5: Verificar e selecionar arma
                            local chosenWeapon = showWeaponSelection()
                            if chosenWeapon then
                                updateStatus("Equipando " .. chosenWeapon .. "...")
                                if selectWeapon(chosenWeapon) then
                                    -- Etapa 6: Farm automático
                                    farmBandits()
                                else
                                    updateStatus("Falha ao equipar arma!")
                                end
                            else
                                updateStatus("Nenhuma arma selecionada!")
                            end
                        else
                            updateStatus("Nenhum bandido encontrado!")
                        end
                    else
                        updateStatus("Local dos bandidos não encontrado!")
                    end
                else
                    updateStatus("Falha ao aceitar quest!")
                end
            else
                updateStatus("Falha ao interagir com NPC!")
            end
        else
            updateStatus("Falha ao chegar no NPC!")
        end
        
        isRunning = false
        autoQuestButton.Text = "Iniciar Auto Quest"
        updateStatus("Pronto")
    end)()
end)

-- Função de Auto Farm simples
autoFarmButton.MouseButton1Click:Connect(function()
    if isFarming then
        isFarming = false
        autoFarmButton.Text = "Auto Farm Bandits"
        updateStatus("Farm parado")
        return
    end
    
    isFarming = true
    autoFarmButton.Text = "Parando Farm..."
    
    coroutine.wrap(function()
        -- Verificar e selecionar arma primeiro
        local chosenWeapon = showWeaponSelection()
        if chosenWeapon then
            selectWeapon(chosenWeapon)
            
            while isFarming do
                farmBandits()
                wait(1)
            end
        else
            updateStatus("Nenhuma arma selecionada!")
            isFarming = false
            autoFarmButton.Text = "Auto Farm Bandits"
        end
    end)()
end)

-- Botão para abrir/fechar o hub
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Conectar evento de CharacterAdded para atualizar referências
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
end)

-- Inicialização
updateStatus("Pronto")

print("Shadow Hub | Fruits Battles carregado com sucesso!")
print("NPC Quest Location: " .. tostring(questNPC_CFrame))
print("Bandits Location: " .. tostring(banditsLocation))