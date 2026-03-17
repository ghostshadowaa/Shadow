local HttpService = game:GetService("HttpService")
local RbxAnalytics = game:GetService("RbxAnalyticsService")

local API_URL = "https://gerador.shardweb.app"
local playerHWID = RbxAnalytics:GetClientId()

local ScreenGui = script.Parent
local LoginFrame = ScreenGui:WaitForChild("LoginFrame")
local MainFrame = ScreenGui:WaitForChild("MainFrame")
local KeyInput = LoginFrame:FindFirstChildOfClass("TextBox")
local LoginBtn = LoginFrame:FindFirstChildOfClass("TextButton")

local function Verificar()
    local url = API_URL .. "?key=" .. KeyInput.Text .. "&hwid=" .. playerHWID
    LoginBtn.Text = "CARREGANDO..."
    
    local sucesso, resposta = pcall(function()
        return HttpService:GetAsync(url)
    end)
    
    if sucesso then
        local dados = HttpService:JSONDecode(resposta)
        if dados.status == "success" then
            LoginFrame.Visible = false
            MainFrame.Visible = true
            print("Logado!")
        else
            KeyInput.Text = ""
            KeyInput.PlaceholderText = dados.message
            LoginBtn.Text = "ERRO!"
            wait(1)
            LoginBtn.Text = "ENTRAR"
        end
    else
        LoginBtn.Text = "ERRO DE CONEXÃO"
        wait(1)
        LoginBtn.Text = "ENTRAR"
    end
end

LoginBtn.MouseButton1Click:Connect(Verificar)
