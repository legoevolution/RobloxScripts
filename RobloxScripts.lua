local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ESPEnabled = false
local MenuOpen = false

local Settings = {
	MaxDistance = 5000,

	ShowBox = true,
	ShowName = true,
	ShowDistance = true,

	BoxColor = Color3.fromRGB(255,255,255),
	NameColor = Color3.fromRGB(255,255,255),
	DistanceColor = Color3.fromRGB(255,255,255)
}

local Gui = Instance.new("ScreenGui")
Gui.Name = "ESP"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = Player:WaitForChild("PlayerGui")

local Menu = Instance.new("Frame")
Menu.Size = UDim2.fromOffset(350,410)
Menu.Position = UDim2.new(.5,-175,.5,-205)
Menu.BackgroundColor3 = Color3.fromRGB(20,20,20)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = Gui

Instance.new("UICorner",Menu).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,45)
Title.BackgroundTransparency = 1
Title.Text = "ESP SETTINGS"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Menu

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,25)
Status.Position = UDim2.fromOffset(0,42)
Status.BackgroundTransparency = 1
Status.Text = "ESP: OFF"
Status.TextColor3 = Color3.new(1,1,1)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 14
Status.Parent = Menu

local function button(text,y)
	local B = Instance.new("TextButton")

	B.Size = UDim2.new(1,-30,0,38)
	B.Position = UDim2.fromOffset(15,y)
	B.BackgroundColor3 = Color3.fromRGB(45,45,45)
	B.TextColor3 = Color3.new(1,1,1)
	B.Text = text
	B.Font = Enum.Font.Gotham
	B.TextSize = 14
	B.Parent = Menu

	Instance.new("UICorner",B).CornerRadius = UDim.new(0,7)

	return B
end

local BoxButton = button("Box: ON",75)
local NameButton = button("Name: ON",120)
local DistanceButton = button("Distance: ON",165)

local BoxColorButton = button("Box Color: WHITE",220)
local NameColorButton = button("Name Color: WHITE",265)
local DistanceColorButton = button("Distance Color: WHITE",310)

local Help = Instance.new("TextLabel")
Help.Size = UDim2.new(1,-20,0,45)
Help.Position = UDim2.fromOffset(10,360)
Help.BackgroundTransparency = 1
Help.Text = "PageUp = Menu   |   PageDown = ESP"
Help.TextColor3 = Color3.fromRGB(170,170,170)
Help.Font = Enum.Font.Gotham
Help.TextSize = 13
Help.Parent = Menu

local Colors = {
	{"WHITE",Color3.fromRGB(255,255,255)},
	{"RED",Color3.fromRGB(255,70,70)},
	{"GREEN",Color3.fromRGB(70,255,100)},
	{"BLUE",Color3.fromRGB(70,150,255)},
	{"YELLOW",Color3.fromRGB(255,230,70)},
	{"PURPLE",Color3.fromRGB(190,80,255)},
	{"PINK",Color3.fromRGB(255,90,190)},
	{"CYAN",Color3.fromRGB(70,255,255)}
}

local function nextColor(current)
	for i,data in ipairs(Colors) do
		if data[2] == current then
			local nextIndex = i + 1

			if nextIndex > #Colors then
				nextIndex = 1
			end

			return Colors[nextIndex][1],Colors[nextIndex][2]
		end
	end

	return "WHITE",Colors[1][2]
end

BoxButton.MouseButton1Click:Connect(function()
	Settings.ShowBox = not Settings.ShowBox
	BoxButton.Text = "Box: " .. (Settings.ShowBox and "ON" or "OFF")
end)

NameButton.MouseButton1Click:Connect(function()
	Settings.ShowName = not Settings.ShowName
	NameButton.Text = "Name: " .. (Settings.ShowName and "ON" or "OFF")
end)

DistanceButton.MouseButton1Click:Connect(function()
	Settings.ShowDistance = not Settings.ShowDistance
	DistanceButton.Text = "Distance: " .. (Settings.ShowDistance and "ON" or "OFF")
end)

BoxColorButton.MouseButton1Click:Connect(function()
	local Name,Color = nextColor(Settings.BoxColor)

	Settings.BoxColor = Color
	BoxColorButton.Text = "Box Color: " .. Name
	BoxColorButton.TextColor3 = Color
end)

NameColorButton.MouseButton1Click:Connect(function()
	local Name,Color = nextColor(Settings.NameColor)

	Settings.NameColor = Color
	NameColorButton.Text = "Name Color: " .. Name
	NameColorButton.TextColor3 = Color
end)

DistanceColorButton.MouseButton1Click:Connect(function()
	local Name,Color = nextColor(Settings.DistanceColor)

	Settings.DistanceColor = Color
	DistanceColorButton.Text = "Distance Color: " .. Name
	DistanceColorButton.TextColor3 = Color
end)

local Objects = {}

local function createESP(P)
	if P == Player or Objects[P] then
		return
	end

	local Box = Instance.new("Frame")
	Box.BackgroundTransparency = 1
	Box.BorderSizePixel = 0
	Box.Visible = false
	Box.Parent = Gui

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 2
	Stroke.Parent = Box

	local Name = Instance.new("TextLabel")
	Name.Size = UDim2.new(1,100,0,18)
	Name.Position = UDim2.new(0,-50,0,-21)
	Name.BackgroundTransparency = 1
	Name.TextStrokeTransparency = .4
	Name.Font = Enum.Font.GothamBold
	Name.TextSize = 14
	Name.Parent = Box

	local Distance = Instance.new("TextLabel")
	Distance.Size = UDim2.new(1,100,0,18)
	Distance.Position = UDim2.new(0,-50,1,3)
	Distance.BackgroundTransparency = 1
	Distance.TextStrokeTransparency = .4
	Distance.Font = Enum.Font.Gotham
	Distance.TextSize = 13
	Distance.Parent = Box

	Objects[P] = {
		Box = Box,
		Stroke = Stroke,
		Name = Name,
		Distance = Distance
	}
end

local function removeESP(P)
	if Objects[P] then
		Objects[P].Box:Destroy()
		Objects[P] = nil
	end
end

for _,P in ipairs(Players:GetPlayers()) do
	createESP(P)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

local function bounds(Character)
	local CF,Size = Character:GetBoundingBox()

	local X,Y,Z = Size.X/2,Size.Y/2,Size.Z/2

	local Corners = {
		Vector3.new(-X,-Y,-Z),
		Vector3.new(-X,-Y,Z),
		Vector3.new(-X,Y,-Z),
		Vector3.new(-X,Y,Z),
		Vector3.new(X,-Y,-Z),
		Vector3.new(X,-Y,Z),
		Vector3.new(X,Y,-Z),
		Vector3.new(X,Y,Z)
	}

	local MinX,MinY = math.huge,math.huge
	local MaxX,MaxY = -math.huge,-math.huge
	local Valid = 0

	for _,Offset in ipairs(Corners) do
		local Screen = Camera:WorldToViewportPoint(
			CF:PointToWorldSpace(Offset)
		)

		if Screen.Z > 0 then
			Valid += 1

			MinX = math.min(MinX,Screen.X)
			MinY = math.min(MinY,Screen.Y)
			MaxX = math.max(MaxX,Screen.X)
			MaxY = math.max(MaxY,Screen.Y)
		end
	end

	if Valid == 0 then
		return
	end

	return MinX,MinY,MaxX,MaxY
end

local function hideAll()
	for _,Data in pairs(Objects) do
		Data.Box.Visible = false
	end
end

UIS.InputBegan:Connect(function(Input,Processed)
	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.PageUp then
		MenuOpen = not MenuOpen
		Menu.Visible = MenuOpen
	end

	if Input.KeyCode == Enum.KeyCode.PageDown then
		ESPEnabled = not ESPEnabled

		Status.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"

		if not ESPEnabled then
			hideAll()
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not ESPEnabled then
		return
	end

	local Character = Player.Character
	local Root = Character and Character:FindFirstChild("HumanoidRootPart")

	if not Root then
		hideAll()
		return
	end

	for P,Data in pairs(Objects) do
		local Character = P.Character
		local TargetRoot = Character and Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

		if TargetRoot and Humanoid and Humanoid.Health > 0 then
			local Studs = (Root.Position - TargetRoot.Position).Magnitude

			if Studs <= Settings.MaxDistance then
				local Screen = Camera:WorldToViewportPoint(TargetRoot.Position)

				if Screen.Z > 0 then
					local MinX,MinY,MaxX,MaxY = bounds(Character)

					if MinX then
						Data.Box.Position = UDim2.fromOffset(MinX,MinY)
						Data.Box.Size = UDim2.fromOffset(MaxX-MinX,MaxY-MinY)

						Data.Stroke.Color = Settings.BoxColor
						Data.Stroke.Enabled = Settings.ShowBox

						Data.Name.Text = P.DisplayName
						Data.Name.TextColor3 = Settings.NameColor
						Data.Name.Visible = Settings.ShowName

						Data.Distance.Text = math.floor(Studs) .. " studs"
						Data.Distance.TextColor3 = Settings.DistanceColor
						Data.Distance.Visible = Settings.ShowDistance

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
