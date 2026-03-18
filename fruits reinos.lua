local HttpService = game:GetService("HttpService")
local hwid = game:GetService("RbxAnalyticsService"):GetClientId()

-- [ INTERFACE SIMPLES ]
local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 300, 0, 160)
main.Position = UDim2.new(0.5, -150, 0.5, -80)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", main)

local box = Instance.new("TextBox", main)
box.PlaceholderText = "Insira a sua Key..."
box.Size = UDim2.new(0.8, 0, 0, 40)
box.Position = UDim2.new(0.1, 0, 0.25, 0)
box.Text = ""

local btn = Instance.new("TextButton", main)
btn.Text = "VERIFICAR KEY"
btn.Size = UDim2.new(0.8, 0, 0, 40)
btn.Position = UDim2.new(0.1, 0, 0.65, 0)
btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
btn.TextColor3 = Color3.new(1, 1, 1)

-- [ FUNÇÃO PARA PULAR O ERRO 403 ]
btn.MouseButton1Click:Connect(function()
    local user_key = box.Text
    btn.Text = "A CONECTAR..."
    
    -- URL da sua API
    local api_url = "http://adrian252.pythonanywhere.com/verify?key="..user_key.."&hwid="..hwid
    
    -- USANDO UM PROXY PARA EVITAR O 403 (O SEGREDO)
    local proxy_url = "https://api.allorigins.win/get?url=" .. HttpService:UrlEncode(api_url)
    
    local success, response = pcall(function()
        -- O Proxy devolve um JSON, precisamos de o decodificar
        local res = game:HttpGet(proxy_url)
        local data = HttpService:JSONDecode(res)
        return data.contents -- Aqui está o código Lua que o seu Python enviou
    end)

    if success and response then
        -- Tenta rodar o código que o Python enviou (loadstring)
        local func, err = loadstring(response)
        
        if func then
            btn.Text = "LIBERADO!"
            btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            task.wait(1)
            sg:Destroy()
            func() -- Roda o script de ADM/Premium/Free
        else
            btn.Text = "ERRO NO CÓDIGO"
            warn("O Python enviou um erro: "..tostring(err))
        end
    else
        btn.Text = "ERRO 403 / SITE OFF"
        warn("Erro ao conectar via Proxy: "..tostring(response))
    end
end)
