local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

-- CONFIGURAÇÃO DA API
local API_URL = "https://gerador.shardweb.app"
local playerHWID = RbxAnalytics:GetClientId()

-- REFERÊNCIAS DA UI (AJUSTE OS NOMES SE PRECISAR)
local ScreenGui = script.Parent
local LoginFrame = ScreenGui:FindFirstChild("LoginFrame") or ScreenGui:FindFirstChildWhichIsA("Frame") 
local MainFrame = ScreenGui:FindFirstChild("MainFrame") or ScreenGui:FindFirstChild("Container")
local KeyInput = LoginFrame:FindFirstChildWhichIsA("TextBox")
local LoginBtn = LoginFrame:FindFirstChildWhichIsA("TextButton")

-- GARANTE ESTADO INICIAL
if MainFrame then MainFrame.Visible = false end
if LoginFrame then LoginFrame.Visible = true end

local function LiberarAcesso(tipo)
    print("Sucesso! Nivel: " .. tipo)
    LoginFrame.Visible = false
    MainFrame.Visible = true
    -- Ativa o botão de abrir/fechar se existir
    local OpenBtn = ScreenGui:FindFirstChild("OpenButton") or ScreenGui:FindFirstChild("openBtn")
    if OpenBtn then OpenBtn.Visible = true end
end

local function Validar()
    local key = KeyInput.Text
    if key == "" then 
        KeyInput.PlaceholderText = "INSIRA A KEY!" 
        return 
    end

    LoginBtn.Text = "CARREGANDO..."
    LoginBtn.Active = false

    -- Tenta conectar (Tenta HTTPS e se falhar tenta HTTP)
    local url = API_URL .. "?key=" .. key .. "&hwid=" .. playerHWID
    
    local sucesso, resposta = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if sucesso then
        local ok, dados = pcall(function() return HttpService:JSONDecode(resposta) end)
        if ok and dados.status == "success" then
            LiberarAcesso(dados.tipo)
        else
            KeyInput.Text = ""
            KeyInput.PlaceholderText = dados and dados.message or "KEY INVALIDA"
            LoginBtn.Text = "ERRO!"
            wait(1.5)
            LoginBtn.Text = "ENTRAR"
            LoginBtn.Active = true
        end
    else
        -- Se o HTTPS da Shardcloud falhar, tenta sem o S
        warn("Erro na API, tentando fallback HTTP...")
        local urlFallback = url:gsub("https://", "http://")
        local suc2, res2 = pcall(function() return HttpService:GetAsync(urlFallback) end)
        
        if suc2 then
            local ok, dados = pcall(function() return HttpService:JSONDecode(res2) end)
            if ok and dados.status == "success" then
                LiberarAcesso(dados.tipo)
                return
            end
        end
        
        KeyInput.Text = ""
        KeyInput.PlaceholderText = "ERRO DE SERVIDOR!"
        LoginBtn.Text = "OFFLINE"
        wait(1.5)
        LoginBtn.Text = "ENTRAR"
        LoginBtn.Active = true
    end
end

LoginBtn.MouseButton1Click:Connect(Validar)
