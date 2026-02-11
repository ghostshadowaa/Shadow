-- Shadow Hub | Steal a Classic
-- Versão: 5.0 (Mobile Draggable + Circle Update)

local Player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Variáveis de controle
local noclipActive = false
local antiHitActive = false
local isTweening = false
local baseCFrame = nil

-- Detectar Base inicial
local function setBase()
	local char = Player.Character or Player.CharacterAdded:Wait()
	baseCFrame = char:WaitForChild("HumanoidRootPart").CFrame
end
setBase()

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- 1. BOTÃO REDONDO E MOVÍVEL
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 60, 0, 60) -- Tamanho igual para ser círculo
OpenBtn.Position = UDim2.new(0, 10, 0.5, -30)
OpenBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
OpenBtn.Text = "SH"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
OpenBtn.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0) -- Faz o botão ser um círculo
CircleCorner.Parent = OpenBtn

-- Lógica para arrastar o botão (Draggable)
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

OpenBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = OpenBtn.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

OpenBtn.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- 2. FRAME DO MENU
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 320)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "Shadow Hub | Steal a Classic"
Title.TextColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Função auxiliar para criar botões
local function createButton(text, pos, parent)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 45)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.Parent = parent
	Instance.new("UICorner", btn)
	return btn
end

local BaseBtn = createButton("Voltar para Base (Tween)", UDim2.new(0.05, 0, 0.2, 0), MainFrame)
local NoclipBtn = createButton("Atravessar parede: OFF", UDim2.new(0.05, 0, 0.4, 0), MainFrame)
local AntiHitBtn = createButton("Anti-Hit: OFF", UDim2.new(0.05, 0, 0.6, 0), MainFrame)

--- LÓGICA DAS FUNÇÕES ---

OpenBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

BaseBtn.MouseButton1Click:Connect(function()
	local char = Player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root and not isTweening then
		isTweening = true
		local distance = (root.Position - baseCFrame.Position).Magnitude
		local tween = TweenService:Create(root, TweenInfo.new(distance/50, Enum.EasingStyle.Linear), {CFrame = baseCFrame})
		tween:Play()
		tween.Completed:Connect(function() isTweening = false end)
	end
end)

NoclipBtn.MouseButton1Click:Connect(function()
	noclipActive = not noclipActive
	NoclipBtn.Text = noclipActive and "Atravessar parede: ON" or "Atravessar parede: OFF"
	NoclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 30)
end)

AntiHitBtn.MouseButton1Click:Connect(function()
	antiHitActive = not antiHitActive
	AntiHitBtn.Text = antiHitActive and "Anti-Hit: ON" or "Anti-Hit: OFF"
	AntiHitBtn.BackgroundColor3 = antiHitActive and Color3.fromRGB(255, 85, 0) or Color3.fromRGB(30, 30, 30)
end)

RunService.Stepped:Connect(function()
	if noclipActive or isTweening or antiHitActive then
		if Player.Character then
			for _, part in pairs(Player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)
