local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local MAX_DISTANCE = 5000

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BasicESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
	Name.TextXAlignment = Enum.TextXAlignment.Center
	Name.Parent = Box

	local Distance = Instance.new("TextLabel")
	Distance.Size = UDim2.new(1, 100, 0, 18)
	Distance.Position = UDim2.new(0, -50, 1, 3)
	Distance.BackgroundTransparency = 1
	Distance.TextColor3 = Color3.fromRGB(255, 255, 255)
	Distance.TextStrokeTransparency = 0.4
	Distance.TextSize = 13
	Distance.Font = Enum.Font.Gotham
	Distance.TextXAlignment = Enum.TextXAlignment.Center
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

local function hideAll()
	for _, Data in pairs(ESPObjects) do
		Data.Box.Visible = false
	end
end

local function getBounds(character, camera)
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
		local Screen = camera:WorldToViewportPoint(World)

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

for _, player in ipairs(Players:GetPlayers()) do
	createESP(player)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.PageDown then
		ESPEnabled = not ESPEnabled

		if not ESPEnabled then
			hideAll()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		return
	end

	local Camera = workspace.CurrentCamera
	local Character = LocalPlayer.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	if not Camera or not Root then
		hideAll()
		return
	end

	for Player, Data in pairs(ESPObjects) do
		local TargetCharacter = Player.Character
		local TargetRoot = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
		local Humanoid = TargetCharacter and TargetCharacter:FindFirstChildOfClass("Humanoid")

		Data.Box.Visible = false

		if TargetRoot and Humanoid and Humanoid.Health > 0 then
			local Distance = (Root.Position - TargetRoot.Position).Magnitude

			if Distance <= MAX_DISTANCE then
				local ScreenPosition = Camera:WorldToViewportPoint(TargetRoot.Position)

				if ScreenPosition.Z > 0 then
					local MinX, MinY, MaxX, MaxY = getBounds(TargetCharacter, Camera)

					if MinX then
						Data.Box.Position = UDim2.fromOffset(MinX, MinY)
						Data.Box.Size = UDim2.fromOffset(MaxX - MinX, MaxY - MinY)

						Data.Name.Text = Player.DisplayName
						Data.Distance.Text = math.floor(Distance) .. " studs"

						Data.Box.Visible = true
					end
				end
			end
		end
	end
end)
