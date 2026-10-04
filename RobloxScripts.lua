local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local MenuOpen = false
local MAX_DISTANCE = 5000

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ESPMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Menu = Instance.new("Frame")
Menu.Size = UDim2.fromOffset(280, 180)
Menu.Position = UDim2.new(0.5, -140, 0.5, -90)
Menu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(80, 80, 80)
MenuStroke.Thickness = 1
MenuStroke.Parent = Menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "ESP POWER"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(1, -30, 0, 45)
Toggle.Position = UDim2.new(0, 15, 0, 55)
Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Toggle.Text = "ESP: OFF"
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.TextSize = 16
Toggle.Font = Enum.Font.GothamBold
Toggle.AutoButtonColor = true
Toggle.Parent = Menu

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = Toggle

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 50)
Info.Position = UDim2.new(0, 10, 0, 115)
Info.BackgroundTransparency = 1
Info.Text = "White Box + Name + Distance\nPageUp closes this menu"
Info.TextColor3 = Color3.fromRGB(180, 180, 180)
Info.TextSize = 13
Info.Font = Enum.Font.Gotham
Info.Parent = Menu

local ESPObjects = {}

local function createESP(player)
	if player == LocalPlayer or ESPObjects[player] then
		return
	end

	local Box = Instance.new("Frame")
	Box.BackgroundTransparency = 1
	Box.BorderSizePixel = 0
	Box.Visible = false
	Box.Parent = ScreenGui

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(255, 255, 255)
	Stroke.Thickness = 2
	Stroke.Parent = Box

	local Name = Instance.new("TextLabel")
	Name.Size = UDim2.new(1, 100, 0, 18)
	Name.Position = UDim2.new(0, -50, 0, -21)
	Name.BackgroundTransparency = 1
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextStrokeTransparency = 0.4
	Name.TextSize = 14
	Name.Font = Enum.Font.GothamBold
	Name.Parent = Box

	local Distance = Instance.new("TextLabel")
	Distance.Size = UDim2.new(1, 100, 0, 18)
	Distance.Position = UDim2.new(0, -50, 1, 3)
	Distance.BackgroundTransparency = 1
	Distance.TextColor3 = Color3.fromRGB(255, 255, 255)
	Distance.TextStrokeTransparency = 0.4
	Distance.TextSize = 13
	Distance.Font = Enum.Font.Gotham
	Distance.Parent = Box

	ESPObjects[player] = {
		Box = Box,
		Name = Name,
		Distance = Distance
	}
end

local function removeESP(player)
	local Data = ESPObjects[player]

	if Data then
		Data.Box:Destroy()
		ESPObjects[player] = nil
	end
end

local function getBounds(character)
	local CF, Size = character:GetBoundingBox()

	local X = Size.X / 2
	local Y = Size.Y / 2
	local Z = Size.Z / 2

	local Corners = {
		Vector3.new(-X, -Y, -Z),
		Vector3.new(-X, -Y, Z),
		Vector3.new(-X, Y, -Z),
		Vector3.new(-X, Y, Z),
		Vector3.new(X, -Y, -Z),
		Vector3.new(X, -Y, Z),
		Vector3.new(X, Y, -Z),
		Vector3.new(X, Y, Z)
	}

	local MinX = math.huge
	local MinY = math.huge
	local MaxX = -math.huge
	local MaxY = -math.huge
	local Valid = 0

	for _, Offset in ipairs(Corners) do
		local World = CF:PointToWorldSpace(Offset)
		local Screen = Camera:WorldToViewportPoint(World)

		if Screen.Z > 0 then
			Valid += 1

			MinX = math.min(MinX, Screen.X)
			MinY = math.min(MinY, Screen.Y)
			MaxX = math.max(MaxX, Screen.X)
			MaxY = math.max(MaxY, Screen.Y)
		end
	end

	if Valid == 0 then
		return nil
	end

	return MinX, MinY, MaxX, MaxY
end

for _, Player in ipairs(Players:GetPlayers()) do
	createESP(Player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

Toggle.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled

	if ESPEnabled then
		Toggle.Text = "ESP: ON"
		Toggle.BackgroundColor3 = Color3.fromRGB(40, 100, 55)
	else
		Toggle.Text = "ESP: OFF"
		Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

		for _, Data in pairs(ESPObjects) do
			Data.Box.Visible = false
		end
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.PageUp then
		MenuOpen = not MenuOpen
		Menu.Visible = MenuOpen
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		return
	end

	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		return
	end

	for Player, Data in pairs(ESPObjects) do
		local TargetCharacter = Player.Character
		local TargetRoot = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
		local Humanoid = TargetCharacter and TargetCharacter:FindFirstChildOfClass("Humanoid")

		if TargetRoot and Humanoid and Humanoid.Health > 0 then
			local Distance = (Root.Position - TargetRoot.Position).Magnitude

			if Distance <= MAX_DISTANCE then
				local ScreenPosition = Camera:WorldToViewportPoint(TargetRoot.Position)

				if ScreenPosition.Z > 0 then
					local MinX, MinY, MaxX, MaxY = getBounds(TargetCharacter)

					if MinX then
						Data.Box.Position = UDim2.fromOffset(MinX, MinY)
						Data.Box.Size = UDim2.fromOffset(MaxX - MinX, MaxY - MinY)

						Data.Name.Text = Player.DisplayName
						Data.Distance.Text = math.floor(Distance) .. " studs"

						Data.Box.Visible = true
					else
						Data.Box.Visible = false
					end
				else
					Data.Box.Visible = false
				end
			else
				Data.Box.Visible = false
			end
		else
			Data.Box.Visible = false
		end
	end
end)
