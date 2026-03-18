-- SHADOW HUB PRO V6 (STRICT ADM ACCESS + FAST FARM)

jogadores locais = jogo:GetService ("Jogadores")
local RunService = jogo:GetService ("RunService")
local VIM = jogo:GetService ("VirtualInputManager")

jogador local = Players.LocalPlayer
local playerGui = jogador:WaitForChild ("PlayerGui")

-- ==================== CONFIG GLOBAL =================
getgenv().Config = {
    AutoFarmBoss = false,
    SelectedBoss = "Sanji",
    SelectedWeapon = "Arma",
    UserLevel = "Nenhum",
    Visível = verdadeiro
O}

local BossList = {"Sanji", "Zoro", "Barba Negra", "Roger"}

-- =================== GUI BASE =================
local gui = Instance.new ("ScreenGui", playerGui)
gui.Name = "ShadowHub_V6"
gui.ResetOnSpawn = false

local function Canto (o, r)
    local c = Instância.novo("UICorner", o)
    c.CornerRadius = UDim.new (0, r ou 8)
fim fim

-- QUADRO PRINCIPAL
local main = Instância.novo ("Moldura", gui)
main.Size = UDim2.new (0, 520, 0, 340)
main.Position = UDim2.new (0.5, -260, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Canto (principal)

-- TELA DE LOGIN
login localFrame = Instância.new("Frame", main)
loginFrame.Size = UDim2.new (1, 0, 1, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
loginFrame.ZIndex = 10

chave localInput = Instância.new("TextBox", loginFrame)
keyInput.Size = UDim2.new (0, 300, 0, 45)
keyInput.Position = UDim2.new (0.5, -150, 0.4, -22)
keyInput.PlaceholderText = "Insira sua Chave (Adm_, Premium_ ou Free_)"
keyInput.Text = ""
keyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyInput.TextColor3 = Color3.new(1, 1, 1)
Canto (chaveInput)

login localBtn = Instance.new ("ButtonTexto", loginFrame)
loginBtn.Size = UDim2.new (0, 150, 0, 40)
loginBtn.Position = UDim2.new (0.5, -75, 0.6, 0)
loginBtn.Text = "Verificar Acesso"
loginBtn.FundoColor3 = Color3.fromRGB(255, 60, 60)
loginBtn.TextColor3 = Color3.new (1, 1, 1)
Cantinho (loginBtn)

-- ESTRUTURA DO CUBO
barra lateral local = Instância.new("Moldura", main)
sidebar.Size = UDim2.new (0, 130, 1, 0)
barra lateral.FundoCor3 = Cor3.deRGB(22, 22, 22)
sidebar.Visible = false
Canto (barra lateral)

container local = Instância.novo("Moldura", principal)
container.Position = UDim2.new (0, 140, 0, 10)
container.Size = UDim2.new(1, -150, 1, -20)
container.FundoTransparência = 1
container.Visible = false

local openBtn = Instância.new("TextButton", gui)
openBtn.Size = UDim2.new (0, 45, 0, 45)
openBtn.Position = UDim2.new (0, 20, 0, 150)
openBtn.Text = "SH"
openBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
openBtn.TextColor3 = Color3.new (1, 1, 1)
openBtn.Visible = false
Canto (openBtn, 10)

páginas locais = {}
aba localButtons = {}

função local CreateTab (nome, ícone)
    local p = Instância.new("ScrollingFrame", container)
    p.Tamanho = UDim2.new (1, 0, 1, 0)
    p.AntecedentesTransparência = 1
    p.Visível = falso
    p.ScrollBarEspessura = 0
    Instância.new ("UIListLayout", p).Padding = UDim.new (0, 8)
    páginas[nome] = p

    local btn = Instância.new("ButtonTexto", barra lateral)
    btn.Size = UDim2.new (1, -10, 0, 35)
    btn.Text = ícone .. " ".. nome (name)
    btn.FundoColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new (1, 1, 1)
    btn.Font = "GothamBold"
    Esquina (btn, 6)
    
    tabButtons[nome] = btn

    btn.MouseButton1Clique em:Connect(function()
        for _, v em pares (páginas) do v.Visible = fim falso
        p.Visível = verdadeiro
    fim)
    retorno p
fim fim

-- ABAS
fazenda localTab = CreateTab ("Fazenda", " ⁇ ️")
config localTab = CreateTab ("Config", " ⁇ ️")
local fastFarmTab = CreateTab ("Fast Farm", "⚡")

-- ====================== FAZENDA CONTEÚDO =================

função local AçãoBtn (pai, texto, chefe)
    local b = Instance.new ("ButtonTexto", pai)
    b.Tamanho = UDim2.new (1, -5, 0, 40)
    b.Texto = texto
    b. BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    b.TextoCor3 = Cor3.new (1, 1, 1)
    Canto (b)
    b.MouseButton1Clique em:Connect(function()
        getgenv().Config.SelectedBoss = chefe
        getgenv().Config.AutoFarmBoss = true
    fim)
fim fim

AçãoBtn (fazendaTab, "Fazenda Barba Negra (Capa)", "Barba Negra")
ActionBtn (farmTab, "Farm Roger (Capa)", "Roger")

-- CONFIGURAR ARMA
para _, w em pares ({"Melee", "Sword"}) do
    local wb = Instance.new ("ButtonTexto", configTab)
    wb.Size = UDim2.new (1, -5, 0, 40)
    wb.Texto = "Arma: "..
    wb.FundoColor3 = Color3.fromRGB(35, 35, 35)
    wb.TextColor3 = Color3.new (1, 1, 1)
    Canto (wb)
    wb.MouseButton1Clique em:Connect(function() getgenv().Config.SelectedWeapon = w end)
fim fim

-- ABA EXCLUSIVA ADM (FAST FARM)
local admBtn = Instance.new ("ButtonTexto", fastFarmTab)
admBtn.Tamanho = UDim2.new(1, -5, 0, 50)
admBtn.Text = "AUTO FARM ADMIN BOSS (ULTRA)"
admBtn.FundoColor3 = Color3.fromRGB(255, 60, 60)
admBtn.TextColor3 = Color3.new (1, 1, 1)
Canto (admBtn)

admBtn.MouseButton1Clique em:Connect(function()
    getgenv().Config.SelectedBoss = "Chefe Admin"
    getgenv().Config.AutoFarmBoss = true
fim)

-- =================== SISTEMA DE ACESSO =================

loginBtn.MouseButton1Clique em:Connect(function()
    chave local = chaveInput.Texto
    
    if string.sub(chave, 1, 5) == "Free_" then
        getgenv().Config.UserLevel = "Grátis"
    elseif string.sub(chave, 1, 8) == "Premium_" then
        getgenv().Config.UserLevel = "Premium"
    elseif string.sub(chave, 1, 4) == "Adm_" then
        getgenv().Config.UserLevel = "Admin"
    else
        keyInput.Text = ""
        keyInput.PlaceholderText = "CHAVE INVÁLIDA!"
        retorno
    fim fim

    -- Liberação da UI
    loginFrame.Visible = false
    sidebar.Visível = true
    container.Visible = true
    openBtn.Visible = true
    páginas.Fazenda.Visível = true

    -- REGRA DE OURO: Esconder "Fast Farm" se não for ADM
    se getgenv().Config.UserLevel ~= "Admin" então
        tabButtons["Fast Farm"].Visível = false
    fim fim
fim)

-- =================== LÓGICA DE EXECUÇÃO =================

task.spawn(function()
    while task.wait() fazer
        se getgenv().Config.AutoFarmBoss então
            pcall(função()
                chefe local = nulo
                para _, v em pares (espaço de trabalho:GetDescendants()) fazer
                    if v.Name == getgenv().Config.SelectedBoss e v:FindFirstChild("Humanoid") e v.Humanoid.Health > 0 então
                        boss = v quebra
                    fim fim
                fim fim
                
                se chefe e jogador.Personagem: FindFirstChild ("HumanoidRootPart") então
                    player.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 7, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    local tool = player.Backpack: FindFirstChild (getgenv().Config.SelectedWeapon) ou player.Character: FindFirstChild(getgenv().Config.SelectedArma)
                    se ferramenta então ferramenta.Parent = player.Character end
                    VIM:SendMouseButtonEvent (0, 0, 0, true, jogo, 0)
                    VIM:SendMouseButtonEvent (0, 0, 0, false, jogo, 0)
                fim fim
            fim)
        fim fim
    fim fim
fim)

openBtn.MouseButton1Clique em:Connect(function()
    main.Visible = não principal.Visível
fim)