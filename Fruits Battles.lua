local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local vim = game:GetService("VirtualInputManager")

-- Configurações de Localização
local npcPos = Vector3.new(-483.650757, 31.3953781, -811.273682)

-- Variáveis de Controle
_G.AutoFarm = true -- Mude para false para parar

-- Função para clicar no botão com segurança
local function clickAccept()
    -- Em vez de WaitForChild (que trava), usamos FindFirstChild
    local questOptions = player.PlayerGui:FindFirstChild("QuestOptions")
    if questOptions then
        local frame = questOptions:FindFirstChild("QuestFrame")
        if frame and frame.Visible then -- Só tenta se a janela estiver visível
            local btn = frame:FindFirstChild("Accept")
            if btn then
                local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2)
                local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)
                vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.1)
                vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
                return true
            end
        end
    end
    return false
end

-- Loop Principal
task.spawn(function()
    while _G.AutoFarm do
        -- 1. Verificar distância
        local dist = (rootPart.Position - npcPos).Magnitude
        
        if dist < 10 then
            -- 2. Interagir com o ProximityPrompt (Segurar E)
            print("Interagindo com NPC...")
            vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(2.2) -- Segura pelo tempo necessário
            vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            
            -- 3. Tentar aceitar a quest (várias vezes por 2 segundos)
            local startAttempt = tick()
            repeat
                local clicked = clickAccept()
                if clicked then 
                    print("Quest Aceita!")
                    break 
                end
                task.wait(0.5)
            until tick() - startAttempt > 3
            
            -- 4. Aqui você adicionaria a lógica de ir até os monstros
            -- Por enquanto, ele espera para não repetir o loop rápido demais
            task.wait(5) 
        else
            -- Se estiver longe, você pode adicionar um Tween para ir até o NPC
            print("Muito longe do NPC para interagir.")
            task.wait(2)
        end
    end
end)
