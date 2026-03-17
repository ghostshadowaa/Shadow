local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

-- CONFIGURAÇÃO DA API
local API_URL = "https://gerador.shardweb.app/verify"
local playerHWID = RbxAnalytics:GetClientId()

-- [Aqui viria a criação da sua UI: loginFrame, keyInput, loginBtn, etc.]

local function TentarLogar()
    local keyDigitada = keyInput.Text
    
    if keyDigitada == "" then
        keyInput.PlaceholderText = "DIGITE A KEY!"
        return
    end

    loginBtn.Text = "VERIFICANDO..."
    loginBtn.Active = false

    -- Faz a chamada para o seu Bot na Shardcloud
    local requestUrl = API_URL .. "?key=" .. keyDigitada .. "&hwid=" .. playerHWID
    
    local sucesso, resposta = pcall(function()
        return HttpService:GetAsync(requestUrl)
    end)

    if sucesso then
        local dados = HttpService:JSONDecode(resposta)
        
        if dados.status == "success" then
            print("✅ Acesso Liberado! Nível: " .. dados.tipo)
            
            -- Lógica de Permissões de Abas
            if dados.tipo == "adm" then
                -- Libera tudo (Ex: Fast Farm exclusivo para ADM)
                if tabButtons["Fast Farm"] then tabButtons["Fast Farm"].Visible = true end
            else
                -- Esconde abas pesadas para Free/Premium se desejar
                if tabButtons["Fast Farm"] then tabButtons["Fast Farm"].Visible = false end
            end

            -- FECHAR LOGIN E ABRIR O HUB
            loginFrame:TweenPosition(UDim2.new(0.5, 0, -1, 0), "In", "Sine", 0.5)
            wait(0.5)
            mainFrame.Visible = true -- Seu Hub principal
            
        else
            -- Erros enviados pelo Bot (Key Expirada, HWID Inválido, etc)
            keyInput.Text = ""
            keyInput.PlaceholderText = dados.message:upper()
            loginBtn.Text = "ENTRAR"
            loginBtn.Active = true
        end
    else
        -- Se o servidor estiver offline ou o link estiver errado
        keyInput.Text = ""
        keyInput.PlaceholderText = "ERRO DE CONEXÃO!"
        loginBtn.Text = "ENTRAR"
        loginBtn.Active = true
    end
end

-- Conectar o botão
loginBtn.MouseButton1Click:Connect(TentarLogar)
