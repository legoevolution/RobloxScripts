local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESP_ENABLED = false
local TOGGLE_KEY = Enum.KeyCode.PageUp
local MAX_DISTANCE = 5000

local BOX_COLOR = Color3.fromRGB(255, 255, 255)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local BOX_THICKNESS = 2

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BoxESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ESPObjects = {}

local function createESP(player)
	if player == LocalPlayer or ESPObjects[player] then
		return
	end

	local box = Instance.new("Frame")
	box.Name = "ESPBox"
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 0
	box.Visible = false
	box.Parent = ScreenGui

	local stroke = Instance.new("UIStroke")
	stroke.Color = BOX_COLOR
	stroke.Thickness = BOX_THICKNESS
	stroke.Transparency = 0
	stroke.Parent = box

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Size = UDim2.new(1, 100, 0, 18)
	nameLabel.Position = UDim2.new(0, -50, 0, -21)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.TextColor3 = TEXT_COLOR
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.Parent = box

	local distanceLabel = Instance.new("TextLabel")
	distanceLabel.Name = "Distance"
	distanceLabel.BackgroundTransparency = 1
	distanceLabel.Size = UDim2.new(1, 100, 0, 18)
	distanceLabel.Position = UDim2.new(0, -50, 1, 3)
	distanceLabel.Font = Enum.Font.Gotham
	distanceLabel.TextSize = 13
	distanceLabel.TextColor3 = TEXT_COLOR
	distanceLabel.TextStrokeTransparency = 0.5
	distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
	distanceLabel.Parent = box

	ESPObjects[player] = {
		Box = box,
		Name = nameLabel,
		Distance = distanceLabel
	}
end

local function removeESP(player)
	local data = ESPObjects[player]

	if data then
		data.Box:Destroy()
		ESPObjects[player] = nil
	end
end

local function getScreenBounds(character)
	local cf, size = character:GetBoundingBox()

	local x = size.X / 2
	local y = size.Y / 2
	local z = size.Z / 2

	local corners = {
		Vector3.new(-x, -y, -z),
		Vector3.new(-x, -y, z),
		Vector3.new(-x, y, -z),
		Vector3.new(-x, y, z),
		Vector3.new(x, -y, -z),
		Vector3.new(x, -y, z),
		Vector3.new(x, y, -z),
		Vector3.new(x, y, z)
	}

	local minX = math.huge
	local minY = math.huge
	local maxX = -math.huge
	local maxY = -math.huge
	local pointsInFront = 0

	for _, offset in ipairs(corners) do
		local worldPosition = cf:PointToWorldSpace(offset)
		local screenPosition =
			Camera:WorldToViewportPoint(worldPosition)

		if screenPosition.Z > 0 then
			pointsInFront += 1

			minX = math.min(minX, screenPosition.X)
			minY = math.min(minY, screenPosition.Y)
			maxX = math.max(maxX, screenPosition.X)
			maxY = math.max(maxY, screenPosition.Y)
		end
	end

	if pointsInFront == 0 then
		return nil
	end

	return minX, minY, maxX, maxY
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		createESP(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)

RunService.RenderStepped:Connect(function()
	local myCharacter = LocalPlayer.Character
	local myRoot =
		myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")

	if not ESP_ENABLED or not myRoot then
		for _, data in pairs(ESPObjects) do
			data.Box.Visible = false
		end

		return
	end

	for player, data in pairs(ESPObjects) do
		local character = player.Character

		local root =
			character and character:FindFirstChild("HumanoidRootPart")

		local humanoid =
			character and character:FindFirstChildOfClass("Humanoid")

		if root and humanoid and humanoid.Health > 0 then
			local distance =
				(myRoot.Position - root.Position).Magnitude

			if distance <= MAX_DISTANCE then
				local rootScreen =
					Camera:WorldToViewportPoint(root.Position)

				if rootScreen.Z > 0 then
					local minX, minY, maxX, maxY =
						getScreenBounds(character)

					if minX then
						local width = maxX - minX
						local height = maxY - minY

						data.Box.Position =
							UDim2.fromOffset(minX, minY)

						data.Box.Size =
							UDim2.fromOffset(width, height)

						data.Name.Text = player.DisplayName
						data.Distance.Text =
							math.floor(distance) .. " studs"

						data.Box.Visible = true
					else
						data.Box.Visible = false
					end
				else
					data.Box.Visible = false
				end
			else
				data.Box.Visible = false
			end
		else
			data.Box.Visible = false
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == TOGGLE_KEY then
		ESP_ENABLED = not ESP_ENABLED

		if not ESP_ENABLED then
			for _, data in pairs(ESPObjects) do
				data.Box.Visible = false
			end
		end
	end
end)
