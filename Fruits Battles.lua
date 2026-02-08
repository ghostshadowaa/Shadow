--[[ 
    SHADOW HUB - AUTO FARM BANDITS (DELTA EXECUTOR)
    Configurado para Missão: Levels. 0+
    Inimigos: Bandits
]]

local LMG2L = {};
local player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- 1. ESTRUTURA DA GUI (Convertida para o seu formato LMG2L)
LMG2L["ScreenGui_1"] = Instance.new("ScreenGui", CoreGui);
LMG2L["ScreenGui_1"]["Name"] = "ShadowHub_BanditFarm";

-- Painel Principal
LMG2L["PainelHub_8"] = Instance.new("Frame", LMG2L["ScreenGui_1"]);
LMG2L["PainelHub_8"]["Visible"] = false;
LMG2L["PainelHub_8"]["BackgroundColor3"] = Color3.fromRGB(0, 8, 75);
LMG2L["PainelHub_8"]["Size"] = UDim2.new(0, 300, 0, 200);
LMG2L["PainelHub_8"]["Position"] = UDim2.new(0.5, -150, 0.5, -100);
Instance.new("UICorner", LMG2L["PainelHub_8"]);

-- Botão Auto Farm
local btnFarm = Instance.new("TextButton", LMG2L["PainelHub_8"])
btnFarm.Size = UDim2.new(0, 200, 0, 40)
btnFarm.Position = UDim2.new(0, 50, 0, 30)
btnFarm.Text = "Auto Farm Bandits: OFF"
btnFarm.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
btnFarm.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", btnFarm)

-- Botão Abrir (Círculo Flutuante)
LMG2L["BotaoAbrir_d"] = Instance.new("ImageButton", LMG2L["ScreenGui_1"]);
LMG2L["BotaoAbrir_d"]["Visible"] = true;
LMG2L["BotaoAbrir_d"]["Image"] = [[rbxassetid://128327214285742]];
LMG2L["BotaoAbrir_d"]["Size"] = UDim2.new(0, 50, 0, 50);
LMG2L["BotaoAbrir_d"]["Position"] = UDim2.new(0, 10, 0, 10);
LMG2L["BotaoAbrir_d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
Instance.new("UICorner", LMG2L["BotaoAbrir_d"]).CornerRadius = UDim.new(1, 0);

-----------------------------------------------------------
-- 2. CONFIGURAÇÕES DA MISSÃO E CFRAMES
-----------------------------------------------------------
local farmAtivo = false
local npcQuestCFrame = CFrame.new(-483.656006, 32.7710686, -810.33313)
local nomeMissao = "Levels. 0+"
local pastaInimigos = workspace:WaitForChild("Visuals"):WaitForChild("More"):WaitForChild("Npcs"):WaitForChild("Enemy"):WaitForChild("Bandits")

-- Função para verificar se já estamos na missão (ajuste conforme a lógica do seu jogo)
local function temMissaoAtiva()
    -- Se o frame de aceitar não está visível, assumimos que já pegamos ou precisamos pegar
    local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
    if questGui and questGui.QuestFrame.Visible then
        return false
    end
    return true
end

-- Função para atacar
local function atacar()
    local tool = player.Character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-----------------------------------------------------------
-- 3. LOOP PRINCIPAL DO AUTO FARM
-----------------------------------------------------------
task.spawn(function()
    while true do
        if farmAtivo then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root then
                -- PASSO 1: Verificar/Pegar Missão
                local questGui = player.PlayerGui:FindFirstChild("QuestOptions")
                
                if questGui and questGui.QuestFrame.Visible then
                    -- Clicar em Accept
                    local acceptBtn = questGui.QuestFrame:FindFirstChild("Accept")
                    if acceptBtn then
                        if firesignal then
                            firesignal(acceptBtn.MouseButton1Click)
                        else
                            -- Fallback para mobile se firesignal falhar
                            local pos = acceptBtn.AbsolutePosition
                            game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X + 30, pos.Y + 30, 0, true, game, 1)
                            game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X + 30, pos.Y + 30, 0, false, game, 1)
                        end
                    end
                else
                    -- Verificar se precisa ir ao NPC (distância simples ou lógica de GUI)
                    -- Aqui você pode adicionar uma checagem de texto na GUI para saber se já completou
                    
                    -- Procurar Inimigo Vivo
                    local alvo = nil
                    for _, v in pairs(pastaInimigos:GetChildren()) do
                        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                            alvo = v
                            break
                        end
                    end
                    
                    if alvo then
                        -- Teleporta para o Inimigo (atrás/em cima dele para não levar dano)
                        root.CFrame = alvo.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        atacar()
                    else
                        -- Se não tem inimigo, vai para o NPC pegar missão (caso não tenha)
                        root.CFrame = npcQuestCFrame
                        -- Interagir com ProximityPrompt do NPC
                        for _, p in pairs(workspace:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p:IsDescendantOf(workspace) and (p.Parent.Position - npcQuestCFrame.Position).Magnitude < 10 then
                                if fireproximityprompt then
                                    fireproximityprompt(p)
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-----------------------------------------------------------
-- 4. CONEXÕES
-----------------------------------------------------------
btnFarm.MouseButton1Click:Connect(function()
    farmAtivo = not farmAtivo
    btnFarm.Text = farmAtivo and "Auto Farm Bandits: ON" or "Auto Farm Bandits: OFF"
    btnFarm.BackgroundColor3 = farmAtivo and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(30, 30, 30)
end)

LMG2L["BotaoAbrir_d"].MouseButton1Click:Connect(function()
    LMG2L["PainelHub_8"].Visible = not LMG2L["PainelHub_8"].Visible
end)

print("Shadow Auto-Farm Bandits v1.0 Carregado!")