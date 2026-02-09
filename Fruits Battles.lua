local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local vim = game:GetService("VirtualInputManager")
local runService = game:GetService("RunService")

-- Configurações Globais
_G.AutoFarm = false
_G.DistanceNPC = 6 -- Distância para interagir

-- Caminho do botão que você passou
local questPath = player.PlayerGui:WaitForChild("QuestOptions"):WaitForChild("QuestFrame")
local acceptBtn = questPath:WaitForChild("Accept")

-- Posição do NPC
local npcPos = Vector3.new(-483.65, 31.40, -811.27)

-- ==========================================
-- LÓGICA DE INTERAÇÃO SUPREMA
-- ==========================================

local function interactNPC()
    -- 1. Teleport suave ou posicionamento
    rootPart.CFrame = CFrame.new(npcPos + Vector3.new(0, 3, 0)) -- Fica levemente acima para o Raycast do prompt não falhar
    task.wait(0.3)
    
    -- Forçar o olhar para baixo (onde o NPC está)
    rootPart.CFrame = CFrame.lookAt(rootPart.Position, npcPos)
    
    -- 2. Tentar disparar o ProximityPrompt de todas as formas
    local prompt = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and (v.Parent:GetPivot().Position - npcPos).Magnitude < 10 then
            prompt = v
            break
        end
    end

    if prompt then
        -- Método A: Simulação de Tecla Segurada
        vim:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        
        local start = tick()
        repeat 
            task.wait()
            -- Método B: Trigger Direto (Garante que funcione se a tecla falhar)
            prompt:InputHoldBegin() 
        until tick() - start >= 2.3 or not _G.AutoFarm
        
        vim:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        prompt:InputHoldEnd()
        
        -- 3. Auto Accept (Espera o frame aparecer e clica)
        task.wait(0.5)
        if questPath.Visible or acceptBtn.IsLoaded then
            local x = acceptBtn.AbsolutePosition.X + (acceptBtn.AbsoluteSize.X / 2)
            local y = acceptBtn.AbsolutePosition.Y + (acceptBtn.AbsoluteSize.Y / 2)
            
            -- Clica 3 vezes para garantir
            for i=1, 3 do
                vim:SendMouseButtonEvent(x, y, 0, true, game, 0)
                task.wait(0.05)
                vim:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
            print("Quest Aceita!")
        end
    end
end

-- ==========================================
-- INTERFACE ESTILO REDZ (TABS)
-- ==========================================

local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "ShadowHubRedz"

local Main = Instance.new("Frame", screenGui)
Main.Size = UDim2.new(0, 400, 0, 280)
Main.Position = UDim2.new(0.5, -200, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Barra de Abas (Lateral)
local TabFrame = Instance.new("Frame", Main)
TabFrame.Size = UDim2.new(0, 100, 1, -10)
TabFrame.Position = UDim2.new(0, 5, 0, 5)
TabFrame.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabFrame)
TabList.Padding = UDim.new(0, 5)

-- Container de Conteúdo
local ContentFrame = Instance.new("ScrollingFrame", Main)
ContentFrame.Size = UDim2.new(1, -120, 1, -20)
ContentFrame.Position = UDim2.new(0, 110, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 2

Instance.new("UIListLayout", ContentFrame).Padding = UDim.new(0, 10)

-- Função para Criar Aba
local function NewTab(name)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    return btn
end

-- Função para Criar Toggle
local function NewToggle(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = "  " .. text
    btn.TextXAlignment = "Left"
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    Instance.new("UICorner", btn)
    
    local status = Instance.new("Frame", btn)
    status.Size = UDim2.new(0, 8, 0, 8)
    status.Position = UDim2.new(1, -20, 0.5, -4)
    status.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", status).CornerRadius = UDim.new(1, 0)

    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        status.BackgroundColor3 = active and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
        callback(active)
    end)
end

-- ==========================================
-- CONFIGURAÇÃO DAS ABAS
-- ==========================================

local tabMain = NewTab("Auto Farm")

NewToggle(ContentFrame, "Auto Quest (Bandits)", function(v)
    _G.AutoFarm = v
    if v then
        task.spawn(function()
            while _G.AutoFarm do
                -- Lógica: Se não tem quest, vai pegar.
                -- (Você pode adicionar aqui a checagem se a quest já está ativa no seu jogo)
                interactNPC()
                
                -- Aqui entraria o seu código de ir matar os Bandidos
                print("Indo matar bandidos...")
                task.wait(5) 
            end
        end)
    end
end)

NewToggle(ContentFrame, "Anti-AFK", function(v)
    local vu = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if v then
            vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end
    end)
end)

print("Shadow Hub v3 pronto!")
