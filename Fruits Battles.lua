local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

-- Posição do NPC que você passou
local npcPos = Vector3.new(-483.65, 31.40, -811.27)

local function interagirEAceitar()
    -- 1. Tenta encontrar o ProximityPrompt perto da posição
    local prompt = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local dist = (v.Parent:GetPivot().Position - npcPos).Magnitude
            if dist < 10 then
                prompt = v
                break
            end
        end
    end

    if prompt then
        print("NPC encontrado, segurando E...")
        -- Simula segurar a tecla E
        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(2.2) -- O tempo que você disse que precisa segurar
        vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        
        -- 2. Procura o botão de aceitar SEM travar o script (sem WaitForChild infinito)
        task.wait(0.5)
        local questOptions = player.PlayerGui:FindFirstChild("QuestOptions")
        if questOptions then
            local frame = questOptions:FindFirstChild("QuestFrame")
            if frame then
                local accept = frame:FindFirstChild("Accept")
                if accept and accept.Visible then
                    -- Clica no botão
                    local x = accept.AbsolutePosition.X + (accept.AbsoluteSize.X / 2)
                    local y = accept.AbsolutePosition.Y + (accept.AbsoluteSize.Y / 2)
                    vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
                    task.wait(0.1)
                    vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
                    print("Quest aceita com sucesso!")
                end
            end
        end
    else
        print("Erro: NPC não encontrado perto da posição informada.")
    end
end
