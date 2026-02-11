local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local vim = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- ==================== CONFIGURAÇÕES ====================
local npcQuestCFrame = CFrame.new(-483.650757, 31.3953781, -811.273682)
local BANDITS_PATH = workspace:WaitForChild("Visuals"):WaitForChild("More"):WaitForChild("Npcs"):WaitForChild("Enemy"):WaitForChild("Bandits")
local ATTACK_RANGE = 12
local ATTACK_KEY = Enum.KeyCode.F -- Mude se o jogo usar outra tecla (Q, R, etc)
local QUEST_CHECK_INTERVAL = 0.5
local TOTAL_ENEMIES = 4

_G.AutoFarm = true
_G.DebugMode = true -- Mostra prints detalhados
_G.CurrentState = "INICIANDO"

-- Variáveis de controle
local enemiesKilled = 0
local isFarming = false
local currentTarget = nil

-- ==================== FUNÇÕES UTILITÁRIAS ====================

function log(msg)
    if _G.DebugMode then
        print("[" .. _G.CurrentState .. "] " .. msg)
    end
end

-- Tween seguro com verificação de distância
function tweenToTarget(target, speed)
    if not target or not target:IsA("BasePart") then return false end
    
    local distance = (rootPart.Position - target.Position).Magnitude
    if distance < 5 then return true end
    
    local timeToReach = math.clamp(distance / speed, 0.5, 4)
    local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
    
    -- Offset para não ficar dentro do NPC
    local offset = CFrame.new(0, 0, 6)
    local goal = {CFrame = target.CFrame * offset}
    
    local tween = TweenService:Create(rootPart, tweenInfo, goal)
    tween:Play()
    
    local completed = false
    tween.Completed:Connect(function() completed = true end)
    
    -- Cancela se demorar muito
    task.delay(5, function() 
        if not completed then 
            tween:Cancel() 
            log("Tween cancelado - timeout")
        end 
    end)
    
    tween.Completed:Wait()
    return true
end

-- ==================== SISTEMA DE QUEST ====================

function goToQuestNPC()
    _G.CurrentState = "INDO_NPC"
    log("Movendo até o NPC da missão...")
    
    tweenToTarget({Position = npcQuestCFrame.Position, CFrame = npcQuestCFrame}, 120)
    task.wait(0.5)
end

function interactWithNPC()
    _G.CurrentState = "INTERAGINDO"
    log("Segurando E por 2.2 segundos...")
    
    -- Segura E
    vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    
    -- Aguarda com verificação se o diálogo apareceu
    local heldTime = 0
    while heldTime < 2.2 do
        task.wait(0.1)
        heldTime += 0.1
        
        -- Se o GUI aparecer antes, pode soltar early
        local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
        if questGui and questGui:FindFirstChild("QuestFrame") then
            if questGui.QuestFrame.Visible then
                log("GUI detectado early!")
                break
            end
        end
    end
    
    vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    task.wait(0.3)
end

function clickAccept()
    _G.CurrentState = "ACEITANDO"
    log("Procurando botão Aceitar...")
    
    local startTime = tick()
    while tick() - startTime < 5 do
        local questOptions = player.PlayerGui:FindFirstChild("QuestOptions")
        if not questOptions then 
            task.wait(0.2) 
            continue 
        end
        
        local frame = questOptions:FindFirstChild("QuestFrame")
        if not frame or not frame.Visible then 
            task.wait(0.2) 
            continue 
        end
        
        local acceptBtn = frame:FindFirstChild("Accept")
        if acceptBtn and acceptBtn.Visible then
            -- Calcula centro absoluto considerando escala
            local absPos = acceptBtn.AbsolutePosition
            local absSize = acceptBtn.AbsoluteSize
            local centerX = absPos.X + (absSize.X / 2)
            local centerY = absPos.Y + (absSize.Y / 2)
            
            -- Clique seguro
            vim:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            
            log("✅ Botão Aceitar clicado!")
            enemiesKilled = 0 -- Reseta contador
            task.wait(1) -- Aguarda missão registrar
            return true
        end
        
        task.wait(0.2)
    end
    
    log("❌ Timeout - não achou botão Aceitar")
    return false
end

-- ==================== SISTEMA DE COMBATE ====================

function getAliveBandits()
    local alive = {}
    
    if not BANDITS_PATH or not BANDITS_PATH.Parent then
        log("⚠️ Path dos bandidos não encontrado!")
        return alive
    end
    
    for _, obj in ipairs(BANDITS_PATH:GetChildren()) do
        if obj:IsA("Model") then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:PrimaryPart
            
            if humanoid and hrp and humanoid.Health > 0 then
                table.insert(alive, {
                    Model = obj,
                    Humanoid = humanoid,
                    HRP = hrp,
                    Distance = (rootPart.Position - hrp.Position).Magnitude
                })
            end
        end
    end
    
    -- Ordena por distância (mais próximo primeiro)
    table.sort(alive, function(a, b) return a.Distance < b.Distance end)
    
    return alive
end

function equipWeapon()
    -- Se o jogo exigir equipar arma antes de atacar
    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                humanoid:EquipTool(tool)
                log("🔧 Equipou: " .. tool.Name)
                task.wait(0.3)
                return true
            end
        end
    end
    
    -- Verifica se já está equipado
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then return true end
    end
    
    return false
end

function attackBandit(banditData)
    if not banditData or not banditData.HRP or not banditData.Humanoid then return false end
    
    -- Verifica se ainda está vivo
    if banditData.Humanoid.Health <= 0 then return true end -- Considera como "já matei"
    
    -- Move até o alvo
    local dist = (rootPart.Position - banditData.HRP.Position).Magnitude
    
    if dist > ATTACK_RANGE then
        _G.CurrentState = "APROXIMANDO"
        tweenToTarget(banditData.HRP, 150)
    end
    
    -- Mira no alvo (lookAt)
    rootPart.CFrame = CFrame.lookAt(rootPart.Position, banditData.HRP.Position)
    
    -- Ataque (ajuste conforme o jogo)
    _G.CurrentState = "ATACANDO"
    
    -- Método 1: Tecla de ataque (mais comum em jogos de luta)
    vim:SendKeyEvent(true, ATTACK_KEY, false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, ATTACK_KEY, false, game)
    
    -- Método 2: Clicar no inimigo (descomente se necessário)
    --[[
    local screenPos = workspace.CurrentCamera:WorldToViewportPoint(banditData.HRP.Position)
    vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
    task.wait(0.05)
    vim:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
    --]]
    
    -- Verifica se matou
    task.wait(0.2)
    if banditData.Humanoid.Health <= 0 then
        enemiesKilled += 1
        log("💀 Bandido morto! " .. enemiesKilled .. "/" .. TOTAL_ENEMIES)
        return true
    end
    
    return false
end

function farmBandits()
    _G.CurrentState = "FARMANDO"
    log("Iniciando farm de bandidos...")
    
    local timeout = tick()
    
    while enemiesKilled < TOTAL_ENEMIES and _G.AutoFarm do
        -- Timeout de segurança (60 segundos para matar 4 bandidos)
        if tick() - timeout > 60 then
            log("⏰ Timeout no farm, reiniciando ciclo...")
            return false
        end
        
        local bandits = getAliveBandits()
        
        if #bandits == 0 then
            -- Verifica se realmente acabou ou se estão respawnando
            log("Nenhum bandido encontrado, verificando...")
            task.wait(1)
            
            -- Double check
            bandits = getAliveBandits()
            if #bandits == 0 then
                -- Pode ser que já matou todos ou estão respawnando
                if enemiesKilled >= TOTAL_ENEMIES then
                    log("✅ Todos os bandidos eliminados!")
                    return true
                else
                    log("⏳ Aguardando respawn...")
                    task.wait(2)
                end
            end
        else
            -- Ataca o mais próximo
            local target = bandits[1]
            local killed = attackBandit(target)
            
            if killed then
                timeout = tick() -- Reseta timeout ao matar
                task.wait(0.3) -- Pequena pausa entre kills
            else
                task.wait(0.1) -- Spam de ataque rápido
            end
        end
    end
    
    return enemiesKilled >= TOTAL_ENEMIES
end

-- ==================== LOOP PRINCIPAL ====================

function mainLoop()
    while _G.AutoFarm do
        local success, err = pcall(function()
            -- 1. Pegar Missão
            goToQuestNPC()
            interactWithNPC()
            
            if not clickAccept() then
                log("Falha ao aceitar, tentando novamente em 3s...")
                task.wait(3)
                return -- Continue para próxima iteração
            end
            
            -- 2. Farmar
            local completed = farmBandits()
            
            if completed then
                log("🎯 Ciclo completo! Retornando para nova missão...")
                task.wait(2)
            else
                log("⚠️ Ciclo incompleto, reiniciando...")
                task.wait(1)
            end
        end)
        
        if not success then
            warn("❌ ERRO: " .. tostring(err))
            task.wait(3)
        end
        
        task.wait(0.5)
    end
    
    log("🛑 AutoFarm desativado")
end

-- ==================== INICIALIZAÇÃO ====================

-- Aguarda personagem carregar completamente
task.wait(2)

log("🚀 AutoFarm FRUITS BATTLES iniciado!")
log("Config: " .. TOTAL_ENEMIES .. " bandidos | Range: " .. ATTACK_RANGE .. " | Tecla: " .. tostring(ATTACK_KEY))

-- Inicia em thread separada
task.spawn(mainLoop)

-- Comandos úteis no console:
-- _G.AutoFarm = false (para parar)
-- _G.DebugMode = false (para silenciar prints)
