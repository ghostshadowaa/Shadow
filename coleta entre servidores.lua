-- Shadow Hub: V43 - Server Hop Sniper (SECRET & YOUTUBER GOD ONLY)
local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- CONFIGURAÇÕES ELITE
local TargetRarities = {"secret", "youtuber god"} -- Apenas os que você pediu
local WaitTimeBeforeHop = 5 -- Tempo que ele espera procurando antes de trocar de server

-- --- FUNÇÃO DE TROCAR DE SERVIDOR (SERVER HOP) ---
local function ServerHop()
    print("Shadow Hub: Procurando novo servidor...")
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)
    
    if success and result and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    end
end

-- --- FUNÇÃO DE COLETA AGRESSIVA ---
local function collectElite(target)
    pcall(function()
        local root = Player.Character:WaitForChild("HumanoidRootPart")
        local part = target:FindFirstChildWhichIsA("BasePart", true)
        
        if part and root then
            -- Teleport/Tween ultra rápido
            root.CFrame = part.CFrame * CFrame.new(0, 3, 0)
            
            -- Multi-coleta para garantir
            for i = 1, 5 do
                firetouchinterest(root, part, 0)
                firetouchinterest(root, part, 1)
                local prompt = target:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then prompt.HoldDuration = 0; fireproximityprompt(prompt) end
                task.wait(0.1)
            end
        end
    end)
end

-- --- SCANNER DE ELITE ---
local function ScanForElites()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("StringValue") then
            local text = string.lower(obj:IsA("TextLabel") and obj.Text or obj.Value)
            
            for _, rarity in ipairs(TargetRarities) do
                if string.find(text, rarity) then
                    local model = obj:FindFirstAncestorOfClass("Model")
                    if model then return model end
                end
            end
        end
    end
    return nil
end

-- --- INTERFACE MINIMALISTA ---
local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "ShadowHub_Hop"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 100); Main.Position = UDim2.new(0.5, -125, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", Main)
local s = Instance.new("UIStroke", Main); s.Color = Color3.fromRGB(0, 150, 255); s.Thickness = 2

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 1, 0); Status.Text = "BUSCANDO ELITES..."; Status.TextColor3 = Color3.new(1,1,1); Status.Font = Enum.Font.GothamBold; Status.BackgroundTransparency = 1

-- --- LÓGICA DE EXECUÇÃO ---
task.spawn(function()
    task.wait(2) -- Espera o mapa carregar um pouco
    
    local target = ScanForElites()
    if target then
        Status.Text = "ELITE ENCONTRADO! COLETANDO..."
        Status.TextColor3 = Color3.fromRGB(0, 255, 150)
        collectElite(target)
        task.wait(1)
    else
        Status.Text = "NADA ENCONTRADO.\nSALTANDO EM " .. WaitTimeBeforeHop .. "s"
        task.wait(WaitTimeBeforeHop)
    end
    
    ServerHop()
end)
