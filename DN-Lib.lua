local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local tbl = {
	spring = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	soft = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	fast = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	pop = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	fade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	slide = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	island = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}
local function fn(arg, arg2, arg3)
	return TweenService:Create(arg, arg2, arg3)
end
local function fn2(arg, arg2)
	local tbl2 = {}
	for k, v in pairs(arg) do
		tbl2[k] = v
	end
	if arg2 then
		for k, v in pairs(arg2) do
			tbl2[k] = v
		end
	end
	return tbl2
end
local tbl2 = {
	bg = Color3.fromRGB(24, 18, 10),
	fg = Color3.fromRGB(255, 245, 230),
	title = Color3.fromRGB(255, 225, 180),
	desc = Color3.fromRGB(190, 155, 110),
	green = Color3.fromRGB(60, 210, 90),
	blue = Color3.fromRGB(0, 235, 255),
	red = Color3.fromRGB(240, 70, 60),
	amber = Color3.fromRGB(174, 75, 255),
	dim = Color3.fromRGB(50, 35, 90),
	island = Color3.fromRGB(18, 12, 6),
}
local __neonElapsed = 0
local __neonGradients = {}
local function __trackNeon(root)
	if not root then return end
	local function track(obj)
		if obj:IsA("UIGradient") and obj.Parent and obj.Parent:IsA("UIStroke") then
			__neonGradients[obj] = true
		end
	end
	for _, obj in ipairs(root:GetDescendants()) do track(obj) end
	root.DescendantAdded:Connect(track)
end
task.defer(function()
	local player = game:GetService("Players").LocalPlayer
	__trackNeon(game:GetService("CoreGui"))
	__trackNeon(player and player:FindFirstChildOfClass("PlayerGui"))
end)
RunService.RenderStepped:Connect(function(dt)
	__neonElapsed = (__neonElapsed + dt * 42) % 360
	for gradient in pairs(__neonGradients) do
		if gradient.Parent then
			gradient.Rotation = (__neonElapsed + (gradient:GetAttribute("DNNeonOffset") or 0)) % 360
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(174, 75, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
			})
		else
			__neonGradients[gradient] = nil
		end
	end
end)
local function fn3(arg, arg2)
	local v = arg2 or arg
	local flag = false
	local flag2 = false
	local v2 = nil
	local position = nil
	local position2 = nil
	v.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			flag = true
			flag2 = false
			position = input.Position
			position2 = arg.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					flag = false
				end
			end)
		end
	end)
	v.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			v2 = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == v2 and flag then
			local n = input.Position - position
			if n.Magnitude > 6 then
				flag2 = true
			end
			arg.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)
	return function()
		return flag2
	end
end
local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end
return { CreateWindow = function(arg, arg2)
	local v = fn2({
		Title = "DN Hub",
		SubTitle = "v1.0",
		Size = UDim2.new(0, 750, 0, 500),
		Parent = game:GetService("CoreGui"),
		MinimizeKey = Enum.KeyCode.F,
		Game = "",
		Version = "",
		MobileScale = 0.85,
		MobileSize = UDim2.new(0, 420, 0, 320),
		AutoScale = true,
		IslandDefaultSize = UDim2.new(0, 80, 0, 24),
		IslandExpandedSize = UDim2.new(0, 300, 0, 84),
		IslandEnabled = true,
		ToggleDefaultSize = UDim2.new(0, 48, 0, 48),
		ToggleSize = UDim2.new(0, 48, 0, 48),
	}, arg2)
	local mobile = isMobile()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DNHubUI"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local imageLabel = Instance.new("ImageLabel", screenGui)
	imageLabel.Image = "rbxassetid://8992230677"
	imageLabel.SliceCenter = Rect.new(99, 99, 99, 99)
	imageLabel.ScaleType = Enum.ScaleType.Slice
	imageLabel.ImageColor3 = Color3.new(0, 0, 0)
	imageLabel.ImageTransparency = 1
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel.Size = mobile and v.MobileSize or v.Size
	local uiScale = Instance.new("UIScale", imageLabel)
	uiScale.Scale = mobile and v.MobileScale or 0.95
	local frame = Instance.new("Frame", imageLabel)
	frame.Name = "Window"
	frame.BackgroundColor3 = tbl2.bg
	frame.BackgroundTransparency = 0.05
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(1, -120, 1, -120)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 24)
	local uiStroke = Instance.new("UIStroke", frame)
	uiStroke.Color = Color3.fromRGB(0, 235, 255)
	uiStroke.Transparency = 0.6
	uiStroke.Thickness = 1.5
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local frame2 = Instance.new("Frame", frame)
	frame2.Name = "Top"
	frame2.BackgroundTransparency = 1
	frame2.Size = UDim2.new(0, 179, 0, 85)
	local frame3 = Instance.new("Frame", frame2)
	frame3.BackgroundColor3 = tbl2.red
	frame3.BorderSizePixel = 0
	frame3.Size = UDim2.new(0, 12, 0, 12)
	frame3.Position = UDim2.new(0, 18, 0, 20)
	Instance.new("UICorner", frame3).CornerRadius = UDim.new(1, 0)
	local frame4 = Instance.new("Frame", frame2)
	frame4.BackgroundColor3 = tbl2.amber
	frame4.BorderSizePixel = 0
	frame4.Size = UDim2.new(0, 12, 0, 12)
	frame4.Position = UDim2.new(0, 38, 0, 20)
	Instance.new("UICorner", frame4).CornerRadius = UDim.new(1, 0)
	local frame5 = Instance.new("Frame", frame2)
	frame5.BackgroundColor3 = tbl2.green
	frame5.BorderSizePixel = 0
	frame5.Size = UDim2.new(0, 12, 0, 12)
	frame5.Position = UDim2.new(0, 58, 0, 20)
	Instance.new("UICorner", frame5).CornerRadius = UDim.new(1, 0)
	local textLabel = Instance.new("TextLabel", frame2)
	textLabel.Name = "Title"
	textLabel.Text = v.Title
	textLabel.TextColor3 = tbl2.title
	textLabel.TextTransparency = 0.05
	textLabel.TextSize = 14
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, -20, 0, 18)
	textLabel.Position = UDim2.new(0, 18, 0, 48)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	local textLabel2 = Instance.new("TextLabel", frame2)
	textLabel2.Name = "SubTitle"
	textLabel2.Text = v.SubTitle
	textLabel2.TextColor3 = tbl2.desc
	textLabel2.TextTransparency = 0.25
	textLabel2.TextSize = 11
	textLabel2.Font = Enum.Font.GothamMedium
	textLabel2.BackgroundTransparency = 1
	textLabel2.Size = UDim2.new(1, -20, 0, 14)
	textLabel2.Position = UDim2.new(0, 18, 0, 66)
	textLabel2.TextXAlignment = Enum.TextXAlignment.Left
	local frame6 = Instance.new("Frame", frame)
	frame6.Name = "Top_2"
	frame6.BackgroundTransparency = 1
	frame6.BorderSizePixel = 0
	frame6.Size = UDim2.new(1, -183, 0, 85)
	frame6.Position = UDim2.new(0, 180, 0, 0)
	local frame7 = Instance.new("Frame", frame6)
	frame7.Name = "NameGame"
	frame7.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame7.BackgroundTransparency = 0.5
	frame7.BorderSizePixel = 0
	frame7.AnchorPoint = Vector2.new(0, 0.5)
	frame7.AutomaticSize = Enum.AutomaticSize.X
	frame7.Size = UDim2.new(0, 0, 0, 25)
	frame7.Position = UDim2.new(0, 20, 0.25, 0)
	Instance.new("UICorner", frame7).CornerRadius = UDim.new(0, 24)
	local frame7Padding = Instance.new("UIPadding", frame7)
	frame7Padding.PaddingLeft = UDim.new(0, 12)
	frame7Padding.PaddingRight = UDim.new(0, 12)
	local textLabel3 = Instance.new("TextLabel", frame7)
	textLabel3.Name = "Game"
	textLabel3.Text = v.Game
	textLabel3.TextColor3 = tbl2.fg
	textLabel3.TextSize = 10
	textLabel3.Font = Enum.Font.GothamBold
	textLabel3.BackgroundTransparency = 1
	textLabel3.AutomaticSize = Enum.AutomaticSize.X
	textLabel3.Size = UDim2.new(0, 0, 1, 0)
	textLabel3.Position = UDim2.new(0, 0, 0, 0)
	local frame8 = Instance.new("Frame", frame6)
	frame8.Name = "VersionFrame"
	frame8.BackgroundColor3 = tbl2.fg
	frame8.BackgroundTransparency = 0.85
	frame8.BorderSizePixel = 0
	frame8.AnchorPoint = Vector2.new(0, 0.5)
	frame8.AutomaticSize = Enum.AutomaticSize.X
	frame8.Size = UDim2.new(0, 0, 0, 25)
	frame8.Position = UDim2.new(0, 20, 0.65, 0)
	Instance.new("UICorner", frame8).CornerRadius = UDim.new(0, 24)
	local frame8Padding = Instance.new("UIPadding", frame8)
	frame8Padding.PaddingLeft = UDim.new(0, 12)
	frame8Padding.PaddingRight = UDim.new(0, 12)
	local textLabel4 = Instance.new("TextLabel", frame8)
	textLabel4.Name = "Version"
	textLabel4.Text = v.Version
	textLabel4.TextColor3 = tbl2.fg
	textLabel4.TextSize = 10
	textLabel4.Font = Enum.Font.GothamBold
	textLabel4.BackgroundTransparency = 1
	textLabel4.AutomaticSize = Enum.AutomaticSize.X
	textLabel4.Size = UDim2.new(0, 0, 1, 0)
	textLabel4.Position = UDim2.new(0, 0, 0, 0)
	local frame9 = Instance.new("Frame", frame6)
	frame9.Name = "ControlsFrame"
	frame9.BackgroundTransparency = 1
	frame9.BorderSizePixel = 0
	frame9.AnchorPoint = Vector2.new(0, 0.5)
	frame9.Size = UDim2.new(0, 190, 0, 45)
	frame9.Position = UDim2.new(1, -200, 0.5, 0)
	Instance.new("UIPadding", frame9).PaddingRight = UDim.new(0, 4)
	local uiListLayout = Instance.new("UIListLayout", frame9)
	uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout.Padding = UDim.new(0, 8)
	uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout.FillDirection = Enum.FillDirection.Horizontal
	local textButton = Instance.new("TextButton", frame9)
	textButton.Name = "BtnMinimize"
	textButton.AutoButtonColor = false
	textButton.BackgroundColor3 = tbl2.fg
	textButton.BackgroundTransparency = 0.93
	textButton.BorderSizePixel = 0
	textButton.Size = UDim2.new(0, 26, 0, 26)
	textButton.LayoutOrder = 1
	textButton.Text = ""
	Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 7)
	local uiStroke2 = Instance.new("UIStroke", textButton)
	uiStroke2.Color = Color3.fromRGB(0, 235, 255)
	uiStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient = Instance.new("UIGradient", uiStroke2)
	uiGradient.Rotation = 90
	uiGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local frame10 = Instance.new("Frame", textButton)
	frame10.Name = "Bar"
	frame10.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	frame10.BorderSizePixel = 0
	frame10.AnchorPoint = Vector2.new(0.5, 0.5)
	frame10.Size = UDim2.new(0, 11, 0, 1)
	frame10.Position = UDim2.new(0.5, 0, 0.5, 0)
	local textButton2 = Instance.new("TextButton", frame9)
	textButton2.Name = "BtnMaximize"
	textButton2.AutoButtonColor = false
	textButton2.BackgroundColor3 = tbl2.fg
	textButton2.BackgroundTransparency = 0.93
	textButton2.BorderSizePixel = 0
	textButton2.Size = UDim2.new(0, 26, 0, 26)
	textButton2.LayoutOrder = 2
	textButton2.Text = ""
	Instance.new("UICorner", textButton2).CornerRadius = UDim.new(0, 7)
	local uiStroke3 = Instance.new("UIStroke", textButton2)
	uiStroke3.Color = Color3.fromRGB(0, 235, 255)
	uiStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient2 = Instance.new("UIGradient", uiStroke3)
	uiGradient2.Rotation = 90
	uiGradient2.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local frame11 = Instance.new("Frame", textButton2)
	frame11.Name = "Box"
	frame11.BackgroundTransparency = 1
	frame11.BorderSizePixel = 0
	frame11.AnchorPoint = Vector2.new(0.5, 0.5)
	frame11.Size = UDim2.new(0, 10, 0, 10)
	frame11.Position = UDim2.new(0.5, 0, 0.5, 0)
	Instance.new("UICorner", frame11).CornerRadius = UDim.new(0, 3)
	local uiStroke4 = Instance.new("UIStroke", frame11)
	uiStroke4.Color = Color3.fromRGB(255, 200, 130)
	uiStroke4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local textButton3 = Instance.new("TextButton", frame9)
	textButton3.Name = "BtnClose"
	textButton3.AutoButtonColor = false
	textButton3.BackgroundColor3 = tbl2.fg
	textButton3.BackgroundTransparency = 0.93
	textButton3.BorderSizePixel = 0
	textButton3.Size = UDim2.new(0, 26, 0, 26)
	textButton3.LayoutOrder = 3
	textButton3.Text = ""
	Instance.new("UICorner", textButton3).CornerRadius = UDim.new(0, 7)
	local uiStroke5 = Instance.new("UIStroke", textButton3)
	uiStroke5.Color = Color3.fromRGB(0, 235, 255)
	uiStroke5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient3 = Instance.new("UIGradient", uiStroke5)
	uiGradient3.Rotation = 90
	uiGradient3.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local frame12 = Instance.new("Frame", textButton3)
	frame12.Name = "Cross"
	frame12.BackgroundTransparency = 1
	frame12.BorderSizePixel = 0
	frame12.AnchorPoint = Vector2.new(0.5, 0.5)
	frame12.Size = UDim2.new(0, 11, 0, 11)
	frame12.Position = UDim2.new(0.5, 0, 0.5, 0)
	local frame13 = Instance.new("Frame", frame12)
	frame13.Name = "Bar1"
	frame13.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	frame13.BackgroundTransparency = 0.25
	frame13.BorderSizePixel = 0
	frame13.AnchorPoint = Vector2.new(0.5, 0.5)
	frame13.Size = UDim2.new(0, 11, 0, 1)
	frame13.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame13.Rotation = 45
	Instance.new("UICorner", frame13).CornerRadius = UDim.new(1, 0)
	local frame14 = Instance.new("Frame", frame12)
	frame14.Name = "Bar2"
	frame14.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	frame14.BackgroundTransparency = 0.25
	frame14.BorderSizePixel = 0
	frame14.AnchorPoint = Vector2.new(0.5, 0.5)
	frame14.Size = UDim2.new(0, 11, 0, 1)
	frame14.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame14.Rotation = -45
	Instance.new("UICorner", frame14).CornerRadius = UDim.new(1, 0)
	local flag = false
	local tbl3 = { frame = Instance.new("Frame", screenGui) }
	tbl3.frame.Name = "FrameToggleUI"
	tbl3.frame.Size = v.ToggleSize
	tbl3.frame.BackgroundColor3 = Color3.fromRGB(18, 12, 6)
	tbl3.frame.BackgroundTransparency = 0.1
	tbl3.frame.BorderSizePixel = 0
	tbl3.frame.AnchorPoint = Vector2.new(0.5, 0.5)
	tbl3.frame.Position = UDim2.new(0.2, 0, 0.2, 0)
	tbl3.frame.Visible = false
	tbl3.frame.ZIndex = 1000
	tbl3.frame.Active = true
	Instance.new("UICorner", tbl3.frame).CornerRadius = UDim.new(1, 0)
	local uiStrokeFrame = Instance.new("UIStroke", tbl3.frame)
	uiStrokeFrame.Color = Color3.fromRGB(0, 235, 255)
	uiStrokeFrame.Thickness = 2
	uiStrokeFrame.Transparency = 0
	uiStrokeFrame.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradientFrame = Instance.new("UIGradient", uiStrokeFrame)
	uiGradientFrame.Rotation = 90
	uiGradientFrame.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(174, 75, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
	})
	tbl3.click = Instance.new("ImageButton", tbl3.frame)
	tbl3.click.Name = "ClickUI"
	tbl3.click.Size = UDim2.new(1, -8, 1, -8)
	tbl3.click.Image = "rbxassetid://12359659240"
	tbl3.click.AnchorPoint = Vector2.new(0.5, 0.5)
	tbl3.click.Position = UDim2.new(0.5, 0, 0.5, 0)
	tbl3.click.BackgroundColor3 = Color3.new(1, 1, 1)
	tbl3.click.BackgroundTransparency = 1
	tbl3.click.BorderSizePixel = 0
	tbl3.click.AutoButtonColor = false
	tbl3.click.ZIndex = 1001
	tbl3.click.ImageColor3 = Color3.fromRGB(255, 255, 255)
	tbl3.click.ScaleType = Enum.ScaleType.Fit
	Instance.new("UICorner", tbl3.click).CornerRadius = UDim.new(1, 0)
	textButton3.MouseButton1Click:Connect(function()
		fn(uiScale, tbl.fast, { Scale = mobile and v.MobileScale or 0.95 }):Play()
		fn(imageLabel, tbl.fade, { ImageTransparency = 1 }):Play()
		task.wait(0.35)
		screenGui:Destroy()
	end)
	local function fn4()
		if flag then return end
		flag = true
		fn(uiScale, tbl.fast, { Scale = mobile and v.MobileScale - 0.1 or 0.85 }):Play()
		fn(imageLabel, tbl.fade, { ImageTransparency = 1 }):Play()
		task.wait(0.25)
		imageLabel.Visible = false
		tbl3.frame.Visible = true
	end
	local function fn5()
		if not flag then return end
		flag = false
		tbl3.frame.Visible = false
		imageLabel.Visible = true
		fn(uiScale, tbl.pop, { Scale = mobile and v.MobileScale or 1 }):Play()
		fn(imageLabel, tbl.fade, { ImageTransparency = 0.4 }):Play()
	end
	textButton.MouseButton1Click:Connect(fn4)
	tbl3.dragged = fn3(tbl3.frame, tbl3.click)
	tbl3.click.Activated:Connect(function()
		if tbl3.dragged() then return end
		local v2 = fn(tbl3.click, TweenInfo.new(0.85, Enum.EasingStyle.Quad), { Rotation = 360 })
		v2:Play()
		v2.Completed:Once(function()
			tbl3.click.Rotation = 0
		end)
		if flag then fn5() else fn4() end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == v.MinimizeKey then
			if flag then fn5() else fn4() end
		end
	end)
	fn3(imageLabel, frame2)
	local frame15 = Instance.new("Frame", frame)
	frame15.Name = "HDivider"
	frame15.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame15.BackgroundTransparency = 0.85
	frame15.BorderSizePixel = 0
	frame15.Size = UDim2.new(1, 0, 0, 1)
	frame15.Position = UDim2.new(0, 0, 0, 85)
	local imageLabel2 = Instance.new("ImageLabel", frame)
	imageLabel2.Name = "VDivider"
	imageLabel2.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	imageLabel2.ScaleType = Enum.ScaleType.Stretch
	imageLabel2.ImageColor3 = Color3.fromRGB(0, 235, 255)
	imageLabel2.ImageTransparency = 0.85
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.BorderSizePixel = 0
	imageLabel2.Size = UDim2.new(0, 1, 1, 0)
	imageLabel2.Position = UDim2.new(0, 179, 0, 0)
	local frame16 = Instance.new("Frame", frame)
	frame16.Name = "TabFrame"
	frame16.BackgroundTransparency = 1
	frame16.Size = UDim2.new(0, 179, 1, -87)
	frame16.Position = UDim2.new(0, 0, 0, 86)
	local scrollingFrame = Instance.new("ScrollingFrame", frame16)
	scrollingFrame.Name = "TabScroll"
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.Size = UDim2.new(1, -4, 1, -4)
	scrollingFrame.Position = UDim2.new(0, 0, 0, 0)
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollBarThickness = 3
	scrollingFrame.ScrollBarImageTransparency = 0.65
	local uiPadding = Instance.new("UIPadding", scrollingFrame)
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.PaddingLeft = UDim.new(0, 8)
	uiPadding.PaddingRight = UDim.new(0, 8)
	local uiListLayout2 = Instance.new("UIListLayout", scrollingFrame)
	uiListLayout2.Padding = UDim.new(0, 4)
	uiListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
	local frame17 = Instance.new("Frame", frame)
	frame17.Name = "Layout"
	frame17.BackgroundTransparency = 1
	frame17.Size = UDim2.new(1, -180, 1, -87)
	frame17.Position = UDim2.new(0, 180, 0, 86)
	local frame18 = Instance.new("Frame", frame17)
	frame18.Name = "RealLayout"
	frame18.BackgroundTransparency = 1
	frame18.Size = UDim2.new(1, 0, 1, 0)
	frame18.ClipsDescendants = true
	local uiPageLayout = Instance.new("UIPageLayout", frame18)
	uiPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uiPageLayout.FillDirection = Enum.FillDirection.Horizontal
	uiPageLayout.EasingStyle = Enum.EasingStyle.Quint
	uiPageLayout.EasingDirection = Enum.EasingDirection.Out
	uiPageLayout.TweenTime = 0.5
	local canvasGroup = Instance.new("CanvasGroup", frame)
	canvasGroup.Name = "DropdownZone"
	canvasGroup.Visible = false
	canvasGroup.GroupTransparency = 1
	canvasGroup.ZIndex = 50
	canvasGroup.BackgroundColor3 = Color3.new(0, 0, 0)
	canvasGroup.BackgroundTransparency = 0.4
	canvasGroup.BorderSizePixel = 0
	canvasGroup.AnchorPoint = Vector2.new(0.5, 0.5)
	canvasGroup.Position = UDim2.new(0.5, 0, 0.5, 0)
	canvasGroup.Size = UDim2.new(1, 0, 1, 0)
	Instance.new("UICorner", canvasGroup).CornerRadius = UDim.new(0, 14)
	local textButton4 = Instance.new("TextButton", canvasGroup)
	textButton4.Name = "Backdrop"
	textButton4.AutoButtonColor = false
	textButton4.ZIndex = 0
	textButton4.BackgroundTransparency = 1
	textButton4.Size = UDim2.new(1, 0, 1, 0)
	textButton4.Text = ""
	local frame19 = Instance.new("Frame", canvasGroup)
	frame19.Name = "RealDropdown"
	frame19.ZIndex = 2
	frame19.BackgroundColor3 = tbl2.bg
	frame19.BackgroundTransparency = 0.02
	frame19.BorderSizePixel = 0
	frame19.AnchorPoint = Vector2.new(0.5, 0.5)
	frame19.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame19.Size = UDim2.new(1, -150, 1, -100)
	Instance.new("UICorner", frame19).CornerRadius = UDim.new(0, 14)
	local uiStroke6 = Instance.new("UIStroke", frame19)
	uiStroke6.Color = Color3.fromRGB(0, 235, 255)
	uiStroke6.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient4 = Instance.new("UIGradient", uiStroke6)
	uiGradient4.Rotation = 90
	uiGradient4.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local textLabel5 = Instance.new("TextLabel", frame19)
	textLabel5.Name = "Heading"
	textLabel5.Text = "Dropdown"
	textLabel5.TextColor3 = tbl2.title
	textLabel5.TextTransparency = 0.05
	textLabel5.TextSize = 14
	textLabel5.Font = Enum.Font.GothamBold
	textLabel5.BackgroundTransparency = 1
	textLabel5.Size = UDim2.new(1, -150, 0, 20)
	textLabel5.Position = UDim2.new(0, 85, 0, 15)
	textLabel5.Visible = false
	local frame20 = Instance.new("Frame", frame19)
	frame20.BackgroundColor3 = tbl2.red
	frame20.BorderSizePixel = 0
	frame20.Size = UDim2.new(0, 12, 0, 12)
	frame20.Position = UDim2.new(0, 18, 0, 20)
	Instance.new("UICorner", frame20).CornerRadius = UDim.new(1, 0)
	local frame21 = Instance.new("Frame", frame19)
	frame21.BackgroundColor3 = tbl2.amber
	frame21.BorderSizePixel = 0
	frame21.Size = UDim2.new(0, 12, 0, 12)
	frame21.Position = UDim2.new(0, 38, 0, 20)
	Instance.new("UICorner", frame21).CornerRadius = UDim.new(1, 0)
	local frame22 = Instance.new("Frame", frame19)
	frame22.BackgroundColor3 = tbl2.green
	frame22.BorderSizePixel = 0
	frame22.Size = UDim2.new(0, 12, 0, 12)
	frame22.Position = UDim2.new(0, 58, 0, 20)
	Instance.new("UICorner", frame22).CornerRadius = UDim.new(1, 0)
	local textButton5 = Instance.new("TextButton", frame19)
	textButton5.Name = "CloseDropdown"
	textButton5.AutoButtonColor = false
	textButton5.BackgroundColor3 = tbl2.fg
	textButton5.BackgroundTransparency = 0.93
	textButton5.BorderSizePixel = 0
	textButton5.Text = ""
	textButton5.Size = UDim2.new(0, 26, 0, 26)
	textButton5.Position = UDim2.new(1, -36, 0, 12)
	Instance.new("UICorner", textButton5).CornerRadius = UDim.new(0, 7)
	local uiStroke7 = Instance.new("UIStroke", textButton5)
	uiStroke7.Color = Color3.fromRGB(0, 235, 255)
	uiStroke7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient5 = Instance.new("UIGradient", uiStroke7)
	uiGradient5.Rotation = 90
	uiGradient5.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local frame23 = Instance.new("Frame", textButton5)
	frame23.BackgroundTransparency = 1
	frame23.AnchorPoint = Vector2.new(0.5, 0.5)
	frame23.Size = UDim2.new(0, 11, 0, 11)
	frame23.Position = UDim2.new(0.5, 0, 0.5, 0)
	local frame24 = Instance.new("Frame", frame23)
	frame24.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	frame24.BackgroundTransparency = 0.25
	frame24.BorderSizePixel = 0
	frame24.AnchorPoint = Vector2.new(0.5, 0.5)
	frame24.Size = UDim2.new(0, 11, 0, 1)
	frame24.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame24.Rotation = 45
	Instance.new("UICorner", frame24).CornerRadius = UDim.new(1, 0)
	local clone = frame24:Clone()
	clone.Parent = frame23
	clone.Rotation = -45
	local scrollingFrame2 = Instance.new("ScrollingFrame", frame19)
	scrollingFrame2.Name = "ListDropdown"
	scrollingFrame2.BackgroundColor3 = tbl2.fg
	scrollingFrame2.BackgroundTransparency = 0.96
	scrollingFrame2.BorderSizePixel = 0
	scrollingFrame2.Size = UDim2.new(1, -40, 1, -78)
	scrollingFrame2.Position = UDim2.new(0, 20, 0, 58)
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollingFrame2.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame2.ScrollBarThickness = 3
	scrollingFrame2.ScrollBarImageTransparency = 0.6
	scrollingFrame2.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame2.Selectable = false
	Instance.new("UICorner", scrollingFrame2).CornerRadius = UDim.new(0, 10)
	local searchBox = Instance.new("TextBox", frame19)
	searchBox.Name = "DropdownSearch"
	searchBox.ZIndex = 3
	searchBox.ClearTextOnFocus = false
	searchBox.PlaceholderText = "Search options..."
	searchBox.Text = ""
	searchBox.TextColor3 = tbl2.title
	searchBox.PlaceholderColor3 = tbl2.desc
	searchBox.TextSize = 12
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.BackgroundColor3 = tbl2.fg
	searchBox.BackgroundTransparency = 0.93
	searchBox.BorderSizePixel = 0
	searchBox.Size = UDim2.new(1, -145, 0, 30)
	searchBox.Position = UDim2.new(0, 85, 0, 12)
	Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 7)
	local searchPadding = Instance.new("UIPadding", searchBox)
	searchPadding.PaddingLeft = UDim.new(0, 10)
	searchPadding.PaddingRight = UDim.new(0, 10)
	local searchStroke = Instance.new("UIStroke", searchBox)
	searchStroke.Color = Color3.fromRGB(0, 235, 255)
	searchStroke.Transparency = 0.45
	searchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiStroke8 = Instance.new("UIStroke", scrollingFrame2)
	uiStroke8.Color = Color3.fromRGB(0, 235, 255)
	uiStroke8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient6 = Instance.new("UIGradient", uiStroke8)
	uiGradient6.Rotation = 90
	uiGradient6.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(1, 0.92) })
	local uiPadding2 = Instance.new("UIPadding", scrollingFrame2)
	uiPadding2.PaddingTop = UDim.new(0, 8)
	uiPadding2.PaddingRight = UDim.new(0, 8)
	uiPadding2.PaddingLeft = UDim.new(0, 8)
	uiPadding2.PaddingBottom = UDim.new(0, 8)
	local uiListLayout3 = Instance.new("UIListLayout", scrollingFrame2)
	uiListLayout3.Padding = UDim.new(0, 5)
	uiListLayout3.SortOrder = Enum.SortOrder.LayoutOrder
	local textButton6 = Instance.new("TextButton", scrollingFrame2)
	textButton6.Name = "Template"
	textButton6.Visible = false
	textButton6.LayoutOrder = 9999
	textButton6.AutoButtonColor = false
	textButton6.BackgroundColor3 = tbl2.fg
	textButton6.BackgroundTransparency = 0.95
	textButton6.BorderSizePixel = 0
	textButton6.Size = UDim2.new(1, 0, 0, 34)
	textButton6.Text = "Option 1"
	textButton6.TextXAlignment = Enum.TextXAlignment.Left
	textButton6.TextColor3 = tbl2.title
	textButton6.TextTransparency = 0.15
	textButton6.TextSize = 13
	textButton6.Font = Enum.Font.GothamMedium
	Instance.new("UICorner", textButton6)
	local uiStroke9 = Instance.new("UIStroke", textButton6)
	uiStroke9.Color = Color3.fromRGB(0, 235, 255)
	uiStroke9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local uiGradient7 = Instance.new("UIGradient", uiStroke9)
	uiGradient7.Rotation = 90
	uiGradient7.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local uiPadding3 = Instance.new("UIPadding", textButton6)
	uiPadding3.PaddingLeft = UDim.new(0, 12)
	uiPadding3.PaddingRight = UDim.new(0, 12)
	local frame25 = Instance.new("Frame", textButton6)
	frame25.Name = "Tick"
	frame25.Visible = false
	frame25.BackgroundTransparency = 1
	frame25.AnchorPoint = Vector2.new(1, 0.5)
	frame25.Size = UDim2.new(0, 12, 0, 10)
	frame25.Position = UDim2.new(1, 0, 0.5, 0)
	local frame26 = Instance.new("Frame", frame25)
	frame26.Name = "Short"
	frame26.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame26.BackgroundTransparency = 0.05
	frame26.BorderSizePixel = 0
	frame26.AnchorPoint = Vector2.new(0.5, 0.5)
	frame26.Size = UDim2.new(0, 6, 0, 1)
	frame26.Position = UDim2.new(0, 3, 0, 7)
	frame26.Rotation = 45
	Instance.new("UICorner", frame26).CornerRadius = UDim.new(1, 0)
	local frame27 = Instance.new("Frame", frame25)
	frame27.Name = "Long"
	frame27.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame27.BackgroundTransparency = 0.05
	frame27.BorderSizePixel = 0
	frame27.AnchorPoint = Vector2.new(0.5, 0.5)
	frame27.Size = UDim2.new(0, 11, 0, 1)
	frame27.Position = UDim2.new(0, 7, 0, 4)
	frame27.Rotation = -45
	Instance.new("UICorner", frame27).CornerRadius = UDim.new(1, 0)
	Instance.new("UIScale", frame19)
	local function fn6()
		canvasGroup.Visible = false
		fn(canvasGroup, tbl.fade, { GroupTransparency = 1 }):Play()
		fn(frame19:FindFirstChildOfClass("UIScale"), tbl.pop, { Scale = 0.95 }):Play()
	end
	textButton5.MouseButton1Click:Connect(fn6)
	textButton4.MouseButton1Click:Connect(fn6)
	local textButton7 = Instance.new("TextButton", screenGui)
	textButton7.Name = "DynamicIsland"
	textButton7.AutoButtonColor = false
	textButton7.BackgroundColor3 = tbl2.island
	textButton7.BorderSizePixel = 0
	textButton7.ZIndex = 500
	textButton7.AnchorPoint = Vector2.new(0.5, 0)
	textButton7.Size = v.IslandDefaultSize
	textButton7.Position = UDim2.new(0.5, 0, 0, 10)
	textButton7.ClipsDescendants = false
	textButton7.Text = ""
	textButton7.Visible = v.IslandEnabled
	Instance.new("UICorner", textButton7).CornerRadius = UDim.new(0, 14)
	local uiStrokeIsland = Instance.new("UIStroke", textButton7)
	uiStrokeIsland.Color = Color3.fromRGB(0, 235, 255)
	uiStrokeIsland.Thickness = 1
	uiStrokeIsland.Transparency = 0.5
	local v2 = uiStrokeIsland
	local canvasGroup2 = Instance.new("CanvasGroup", textButton7)
	canvasGroup2.Name = "Compact"
	canvasGroup2.ZIndex = 2
	canvasGroup2.Size = UDim2.new(1, 0, 1, 0)
	canvasGroup2.BackgroundTransparency = 1
	local uiListLayout4 = Instance.new("UIListLayout", canvasGroup2)
	uiListLayout4.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout4.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout4.Padding = UDim.new(0, 6)
	uiListLayout4.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout4.FillDirection = Enum.FillDirection.Horizontal
	local frame28 = Instance.new("Frame", canvasGroup2)
	frame28.Name = "Glyph"
	frame28.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame28.BorderSizePixel = 0
	frame28.Size = UDim2.new(0, 8, 0, 8)
	frame28.LayoutOrder = 1
	frame28.Visible = true
	Instance.new("UICorner", frame28).CornerRadius = UDim.new(1, 0)
	local textLabel6 = Instance.new("TextLabel", canvasGroup2)
	textLabel6.Name = "Label"
	textLabel6.TextSize = 11
	textLabel6.Font = Enum.Font.GothamBold
	textLabel6.TextColor3 = tbl2.title
	textLabel6.BackgroundTransparency = 1
	textLabel6.Size = UDim2.new(0, 0, 0, 14)
	textLabel6.Text = ""
	textLabel6.LayoutOrder = 2
	textLabel6.TextXAlignment = Enum.TextXAlignment.Left
	textLabel6.AutomaticSize = Enum.AutomaticSize.X
	local textLabel7 = Instance.new("TextLabel", canvasGroup2)
	textLabel7.Name = "Status"
	textLabel7.TextSize = 11
	textLabel7.Font = Enum.Font.GothamBold
	textLabel7.TextColor3 = tbl2.green
	textLabel7.BackgroundTransparency = 1
	textLabel7.Size = UDim2.new(0, 0, 0, 14)
	textLabel7.Text = ""
	textLabel7.LayoutOrder = 3
	textLabel7.TextXAlignment = Enum.TextXAlignment.Left
	textLabel7.AutomaticSize = Enum.AutomaticSize.X
	textLabel7.Visible = false
	local frame29 = Instance.new("Frame", canvasGroup2)
	frame29.Name = "MiniWave"
	frame29.BackgroundTransparency = 1
	frame29.Size = UDim2.new(0, 24, 0, 10)
	frame29.LayoutOrder = 4
	frame29.Visible = true
	local uiListLayout5 = Instance.new("UIListLayout", frame29)
	uiListLayout5.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout5.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout5.Padding = UDim.new(0, 2)
	uiListLayout5.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout5.FillDirection = Enum.FillDirection.Horizontal
	local tbl4 = {}
	for i = 1, 4 do
		local frame30 = Instance.new("Frame", frame29)
		frame30.Name = "B" .. i
		frame30.BackgroundColor3 = tbl2.green
		frame30.BorderSizePixel = 0
		frame30.Size = UDim2.new(0, 2, 0, math.random(3, 8))
		frame30.LayoutOrder = i
		Instance.new("UICorner", frame30).CornerRadius = UDim.new(1, 0)
		table.insert(tbl4, frame30)
	end
	local canvasGroup3 = Instance.new("CanvasGroup", textButton7)
	canvasGroup3.Name = "Expanded"
	canvasGroup3.Visible = false
	canvasGroup3.GroupTransparency = 1
	canvasGroup3.ZIndex = 3
	canvasGroup3.Size = UDim2.new(1, 0, 1, 0)
	canvasGroup3.BackgroundTransparency = 1
	local frame30 = Instance.new("Frame", canvasGroup3)
	frame30.Name = "Thumb"
	frame30.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	frame30.BorderSizePixel = 0
	frame30.Size = UDim2.new(0, 50, 0, 50)
	frame30.Position = UDim2.new(0, 16, 0, 16)
	Instance.new("UICorner", frame30).CornerRadius = UDim.new(0, 12)
	local uiGradient8 = Instance.new("UIGradient", frame30)
	uiGradient8.Rotation = 55
	uiGradient8.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 235, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(174, 75, 255)),
	})
	local imageLabel3 = Instance.new("ImageLabel", frame30)
	imageLabel3.Name = "Img"
	imageLabel3.ZIndex = 2
	imageLabel3.ScaleType = Enum.ScaleType.Fit
	imageLabel3.ImageTransparency = 0.05
	imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel3.Size = UDim2.new(0, 26, 0, 26)
	imageLabel3.Position = UDim2.new(0.5, 0, 0.5, 0)
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Visible = false
	local textLabel8 = Instance.new("TextLabel", canvasGroup3)
	textLabel8.Name = "Mono"
	textLabel8.Text = "00:00"
	textLabel8.TextColor3 = tbl2.fg
	textLabel8.TextSize = 10
	textLabel8.Font = Enum.Font.Code
	textLabel8.BackgroundTransparency = 1
	textLabel8.Size = UDim2.new(0, 50, 0, 14)
	textLabel8.Position = UDim2.new(0, 78, 0, 18)
	local textLabel9 = Instance.new("TextLabel", canvasGroup3)
	textLabel9.Name = "Mark"
	textLabel9.Text = "● READY"
	textLabel9.TextColor3 = tbl2.red
	textLabel9.TextSize = 9
	textLabel9.Font = Enum.Font.GothamBold
	textLabel9.BackgroundTransparency = 1
	textLabel9.Size = UDim2.new(0, 50, 0, 12)
	textLabel9.Position = UDim2.new(0, 78, 0, 32)
	local textLabel10 = Instance.new("TextLabel", canvasGroup3)
	textLabel10.Name = "Title"
	textLabel10.Text = "DN Hub"
	textLabel10.TextColor3 = tbl2.title
	textLabel10.TextTransparency = 0.05
	textLabel10.TextSize = 12
	textLabel10.Font = Enum.Font.GothamBold
	textLabel10.BackgroundTransparency = 1
	textLabel10.Size = UDim2.new(0, 180, 0, 14)
	textLabel10.Position = UDim2.new(0, 78, 0, 50)
	textLabel10.TextXAlignment = Enum.TextXAlignment.Left
	local textLabel11 = Instance.new("TextLabel", canvasGroup3)
	textLabel11.Name = "Sub"
	textLabel11.Text = "Tap to view active tasks"
	textLabel11.TextColor3 = tbl2.desc
	textLabel11.TextTransparency = 0.25
	textLabel11.TextSize = 10
	textLabel11.Font = Enum.Font.GothamMedium
	textLabel11.BackgroundTransparency = 1
	textLabel11.Size = UDim2.new(0, 180, 0, 12)
	textLabel11.Position = UDim2.new(0, 78, 0, 63)
	textLabel11.TextXAlignment = Enum.TextXAlignment.Left
	local frame31 = Instance.new("Frame", canvasGroup3)
	frame31.Name = "Wave"
	frame31.BackgroundTransparency = 1
	frame31.Size = UDim2.new(0, 50, 0, 22)
	frame31.Position = UDim2.new(1, -60, 0, 38)
	local uiListLayout6 = Instance.new("UIListLayout", frame31)
	uiListLayout6.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiListLayout6.VerticalAlignment = Enum.VerticalAlignment.Center
	uiListLayout6.Padding = UDim.new(0, 4)
	uiListLayout6.SortOrder = Enum.SortOrder.LayoutOrder
	uiListLayout6.FillDirection = Enum.FillDirection.Horizontal
	local tbl5 = {}
	for i = 1, 5 do
		local frame32 = Instance.new("Frame", frame31)
		frame32.Name = "B" .. i
		frame32.BackgroundColor3 = tbl2.green
		frame32.BorderSizePixel = 0
		frame32.Size = UDim2.new(0, 3, 0, math.random(8, 18))
		frame32.LayoutOrder = i
		Instance.new("UICorner", frame32).CornerRadius = UDim.new(1, 0)
		table.insert(tbl5, frame32)
	end
	local islandStartedAt = os.clock()
	local flag2 = false
	local flag3 = false
	local str = ""
	local str2 = ""
	local function fn7()
		if flag3 then return end
		flag2 = true
		flag3 = true
		canvasGroup3.Visible = true
		fn(textButton7, tbl.island, { Size = v.IslandExpandedSize }):Play()
		fn(v2, tbl.island, { Transparency = 0.3 }):Play()
		fn(canvasGroup2, tbl.fade, { GroupTransparency = 1 }):Play()
		task.spawn(function()
			task.wait(0.35)
			fn(canvasGroup3, tbl.fade, { GroupTransparency = 0 }):Play()
			task.wait(0.4)
			flag3 = false
		end)
	end
	local function fn8()
		if flag3 then return end
		flag2 = false
		flag3 = true
		fn(canvasGroup3, tbl.fade, { GroupTransparency = 1 }):Play()
		task.spawn(function()
			task.wait(0.3)
			canvasGroup3.Visible = false
			fn(textButton7, tbl.island, { Size = v.IslandDefaultSize }):Play()
			fn(v2, tbl.island, { Transparency = 0.5 }):Play()
			fn(canvasGroup2, tbl.fade, { GroupTransparency = 0 }):Play()
			task.wait(0.4)
			flag3 = false
		end)
	end
	local islandDragged = false
	local islandPressPosition = nil
	local islandStartPosition = nil
	textButton7.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			islandDragged = false
			islandPressPosition = input.Position
			islandStartPosition = textButton7.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if islandPressPosition and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - islandPressPosition
			if delta.Magnitude > 6 then
				islandDragged = true
			end
			if islandDragged then
				textButton7.Position = UDim2.new(
					islandStartPosition.X.Scale,
					islandStartPosition.X.Offset + delta.X,
					islandStartPosition.Y.Scale,
					islandStartPosition.Y.Offset + delta.Y
				)
			end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			islandPressPosition = nil
			task.wait(0.05)
			islandDragged = false
		end
	end)
	textButton7.MouseButton1Click:Connect(function()
		if islandDragged then return end
		if flag2 then fn8() else fn7() end
	end)
	task.spawn(function()
		while task.wait(0.3) do
			for _, v3 in ipairs(tbl5) do
				fn(v3, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 3, 0, math.random(8, 18)) }):Play()
			end
		end
	end)
	task.spawn(function()
		while task.wait(0.25) do
			for _, v3 in ipairs(tbl4) do
				fn(v3, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 2, 0, math.random(3, 8)) }):Play()
			end
		end
	end)
	task.spawn(function()
		local hue = 0.48
		while textButton7.Parent do
			hue = (hue + 0.003) % 1
			local cyan = Color3.fromRGB(0, 235, 255)
			local purple = Color3.fromRGB(174, 75, 255)
			local blend = (math.sin(os.clock() * 1.4) + 1) * 0.5
			local glow = cyan:Lerp(purple, blend)
			fn(v2, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Color = glow, Transparency = 0.18}):Play()
			for i, bar in ipairs(tbl5) do
				bar.BackgroundColor3 = i % 2 == 0 and purple or cyan
			end
			frame28.BackgroundColor3 = glow
			task.wait(0.12)
		end
	end)
	task.spawn(function()
		while textButton7.Parent do
			local elapsed = math.max(0, math.floor(os.clock() - islandStartedAt))
			textLabel8.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
			task.wait(1)
		end
	end)
	local flag4 = false
	local position = nil
	local position2 = nil
	frame2.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			flag4 = true
			position = input.Position
			position2 = imageLabel.Position
		end
	end)
	frame2.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			flag4 = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if flag4 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local n = input.Position - position
			imageLabel.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n.X, position2.Y.Scale, position2.Y.Offset + n.Y)
		end
	end)
	local function applyResponsiveSize()
		local viewport = getViewportSize()
		local isSmall = viewport.X < 900 or viewport.Y < 600
		if mobile or isSmall then
			local w = math.clamp(viewport.X * 0.92, 320, 520)
			local h = math.clamp(viewport.Y * 0.78, 280, 420)
			imageLabel.Size = UDim2.new(0, w, 0, h)
			uiScale.Scale = math.clamp(math.min(viewport.X / 750, viewport.Y / 500), 0.6, 0.9)
			frame.Size = UDim2.new(1, -20, 1, -20)
			frame6.Position = UDim2.new(0, 86, 0, 0)
			frame6.Size = UDim2.new(1, -86, 0, 62)
			frame15.Position = UDim2.new(0, 0, 0, 62)
			frame16.Position = UDim2.new(0, 0, 0, 63)
			frame16.Size = UDim2.new(0, 86, 1, -63)
			frame17.Position = UDim2.new(0, 86, 0, 63)
			frame17.Size = UDim2.new(1, -86, 1, -63)
			imageLabel2.Position = UDim2.new(0, 85, 0, 0)
			frame3.Size = UDim2.new(0, 9, 0, 9)
			frame3.Position = UDim2.new(0, 10, 0, 14)
			frame4.Size = UDim2.new(0, 9, 0, 9)
			frame4.Position = UDim2.new(0, 25, 0, 14)
			frame5.Size = UDim2.new(0, 9, 0, 9)
			frame5.Position = UDim2.new(0, 40, 0, 14)
			textLabel.TextSize = 11
			textLabel.Size = UDim2.new(1, -12, 0, 14)
			textLabel.Position = UDim2.new(0, 10, 0, 34)
			textLabel2.TextSize = 9
			textLabel2.Size = UDim2.new(1, -12, 0, 12)
			textLabel2.Position = UDim2.new(0, 10, 0, 48)
			frame7.Size = UDim2.new(0, 64, 0, 20)
			frame7.Position = UDim2.new(0, 10, 0.28, 0)
			textLabel3.TextSize = 9
			frame8.Size = UDim2.new(0, 64, 0, 20)
			frame8.Position = UDim2.new(0, 10, 0.72, 0)
			textLabel4.TextSize = 9
			frame9.Size = UDim2.new(0, 96, 0, 34)
			frame9.Position = UDim2.new(1, -100, 0.5, 0)
			uiListLayout.Padding = UDim.new(0, 5)
			textButton.Size = UDim2.new(0, 24, 0, 24)
			textButton2.Size = UDim2.new(0, 24, 0, 24)
			textButton3.Size = UDim2.new(0, 24, 0, 24)
			scrollingFrame.ScrollBarThickness = 2
			uiPadding.PaddingTop = UDim.new(0, 6)
			uiPadding.PaddingBottom = UDim.new(0, 6)
			uiPadding.PaddingLeft = UDim.new(0, 5)
			uiPadding.PaddingRight = UDim.new(0, 5)
			uiListLayout2.Padding = UDim.new(0, 3)
			frame19.Size = UDim2.new(1, -20, 1, -30)
			textLabel5.TextSize = 12
			textLabel5.Size = UDim2.new(1, -90, 0, 16)
			textLabel5.Position = UDim2.new(0, 62, 0, 12)
			frame20.Size = UDim2.new(0, 9, 0, 9)
			frame20.Position = UDim2.new(0, 12, 0, 15)
			frame21.Size = UDim2.new(0, 9, 0, 9)
			frame21.Position = UDim2.new(0, 27, 0, 15)
			frame22.Size = UDim2.new(0, 9, 0, 9)
			frame22.Position = UDim2.new(0, 42, 0, 15)
			textButton5.Size = UDim2.new(0, 24, 0, 24)
			textButton5.Position = UDim2.new(1, -30, 0, 10)
			scrollingFrame2.Size = UDim2.new(1, -20, 1, -56)
			scrollingFrame2.Position = UDim2.new(0, 10, 0, 42)
			textButton6.Size = UDim2.new(1, 0, 0, 32)
			textButton6.TextSize = 12
		else
			imageLabel.Size = v.Size
			uiScale.Scale = 0.95
			frame.Size = UDim2.new(1, -120, 1, -120)
			frame6.Size = UDim2.new(1, -183, 0, 85)
			frame6.Position = UDim2.new(0, 180, 0, 0)
			frame16.Size = UDim2.new(0, 179, 1, -87)
			frame16.Position = UDim2.new(0, 0, 0, 86)
			frame17.Size = UDim2.new(1, -180, 1, -87)
			frame17.Position = UDim2.new(0, 180, 0, 86)
			imageLabel2.Position = UDim2.new(0, 179, 0, 0)
			frame15.Position = UDim2.new(0, 0, 0, 85)
			textLabel.TextSize = 14
			textLabel.Size = UDim2.new(1, -20, 0, 18)
			textLabel.Position = UDim2.new(0, 18, 0, 48)
			textLabel2.TextSize = 11
			textLabel2.Size = UDim2.new(1, -20, 0, 14)
			textLabel2.Position = UDim2.new(0, 18, 0, 66)
			frame3.Size = UDim2.new(0, 12, 0, 12)
			frame3.Position = UDim2.new(0, 18, 0, 20)
			frame4.Size = UDim2.new(0, 12, 0, 12)
			frame4.Position = UDim2.new(0, 38, 0, 20)
			frame5.Size = UDim2.new(0, 12, 0, 12)
			frame5.Position = UDim2.new(0, 58, 0, 20)
			frame7.AutomaticSize = Enum.AutomaticSize.X
	frame7.Size = UDim2.new(0, 0, 0, 25)
			frame7.Position = UDim2.new(0, 20, 0.25, 0)
			textLabel3.TextSize = 10
			frame8.AutomaticSize = Enum.AutomaticSize.X
	frame8.Size = UDim2.new(0, 0, 0, 25)
			frame8.Position = UDim2.new(0, 20, 0.65, 0)
			textLabel4.TextSize = 10
			frame9.Size = UDim2.new(0, 190, 0, 45)
			frame9.Position = UDim2.new(1, -200, 0.5, 0)
			uiListLayout.Padding = UDim.new(0, 8)
			textButton.Size = UDim2.new(0, 26, 0, 26)
			textButton2.Size = UDim2.new(0, 26, 0, 26)
			textButton3.Size = UDim2.new(0, 26, 0, 26)
			scrollingFrame.ScrollBarThickness = 3
			uiPadding.PaddingTop = UDim.new(0, 8)
			uiPadding.PaddingBottom = UDim.new(0, 8)
			uiPadding.PaddingLeft = UDim.new(0, 8)
			uiPadding.PaddingRight = UDim.new(0, 8)
			uiListLayout2.Padding = UDim.new(0, 4)
			frame19.Size = UDim2.new(1, -150, 1, -100)
			textLabel5.TextSize = 14
			textLabel5.Size = UDim2.new(1, -150, 0, 20)
			textLabel5.Position = UDim2.new(0, 85, 0, 15)
			frame20.Size = UDim2.new(0, 12, 0, 12)
			frame20.Position = UDim2.new(0, 18, 0, 20)
			frame21.Size = UDim2.new(0, 12, 0, 12)
			frame21.Position = UDim2.new(0, 38, 0, 20)
			frame22.Size = UDim2.new(0, 12, 0, 12)
			frame22.Position = UDim2.new(0, 58, 0, 20)
			textButton5.Size = UDim2.new(0, 26, 0, 26)
			textButton5.Position = UDim2.new(1, -36, 0, 12)
			scrollingFrame2.Size = UDim2.new(1, -40, 1, -70)
			scrollingFrame2.Position = UDim2.new(0, 20, 0, 50)
			textButton6.Size = UDim2.new(1, 0, 0, 34)
			textButton6.TextSize = 13
		end
	end
	local function applyElementMobileLayout(element, tab)
		if not (mobile or getViewportSize().X < 900) then return end
		local isMobileLayout = true
		local function layoutTextBlock(frame32, hasDesc, height)
			if not frame32 then return end
			frame32.Position = UDim2.new(0, 10, 0.5, 0)
			frame32.Size = UDim2.new(1, -100, 0, hasDesc and 36 or 24)
			local title = frame32:FindFirstChild("Title")
			if title then
				title.TextSize = 11
				title.Size = UDim2.new(1, 0, 0, 12)
			end
			local desc = frame32:FindFirstChild("Desc")
			if desc then
				desc.TextSize = 10
				desc.Size = UDim2.new(1, 0, 0, 20)
				desc.Position = UDim2.new(0, 0, 0, 13)
			end
		end
		if element.Name == "Toggle" or element.Name == "Button" or element.Name == "Slider" or element.Name == "Keybind" then
			local tb = element:FindFirstChild("TextBlock")
			if tb then
				local hasDesc = tb:FindFirstChild("Desc") ~= nil
				if element.Name == "Slider" then
					tb.Size = UDim2.new(1, -120, 0, hasDesc and 36 or 24)
					tb.Position = UDim2.new(0, 10, 0.5, 0)
					local title = tb:FindFirstChild("Title")
					if title then title.TextSize = 11 end
					local desc = tb:FindFirstChild("Desc")
					if desc then desc.TextSize = 10 end
					local vt = element:FindFirstChild("ValueText")
					if vt then
						vt.TextSize = 10
						vt.Size = UDim2.new(0, 44, 0, 12)
						vt.Position = UDim2.new(1, -10, 0.5, -4)
					end
					local track = element:FindFirstChild("Track")
					if track then
						track.Size = UDim2.new(0, 100, 0, 5)
						track.Position = UDim2.new(1, -10, 0.5, 5)
					end
				elseif element.Name == "Keybind" then
					tb.Size = UDim2.new(1, -80, 0, 24)
					tb.Position = UDim2.new(0, 10, 0.5, 0)
					local title = tb:FindFirstChild("Title")
					if title then title.TextSize = 11 end
					local desc = tb:FindFirstChild("Desc")
					if desc then
						desc.TextSize = 10
						desc.Position = UDim2.new(0, 0, 0, 13)
					end
					local pill = element:FindFirstChild("Pill")
					if pill then
						pill.Size = UDim2.new(0, 50, 0, 21)
						pill.Position = UDim2.new(1, -10, 0.5, 0)
						local key = pill:FindFirstChild("Key")
						if key then key.TextSize = 10 end
					end
				else
					layoutTextBlock(tb, hasDesc)
				end
			end
			if element.Name == "Toggle" then
				local sw = element:FindFirstChild("Switch")
				if sw then
					sw.Size = UDim2.new(0, 30, 0, 17)
					sw.Position = UDim2.new(1, -10, 0.5, 0)
					local knob = sw:FindFirstChild("Knob")
					if knob then
						knob.Size = UDim2.new(0, 13, 0, 13)
					end
				end
			end
		elseif element.Name == "Dropdown" or element.Name == "Textbox" then
			local tb = element:FindFirstChild("TextBlock")
			if tb then
				local hasDesc = tb:FindFirstChild("Desc") ~= nil
				tb.Position = UDim2.new(0, 10, 0, 7)
				tb.Size = UDim2.new(1, -20, 0, hasDesc and 36 or 24)
				local title = tb:FindFirstChild("Title")
				if title then title.TextSize = 11 end
				local desc = tb:FindFirstChild("Desc")
				if desc then
					desc.TextSize = 10
					desc.Position = UDim2.new(0, 0, 0, 13)
				end
			end
			local field = element:FindFirstChild("Field")
			if field then
				field.Size = UDim2.new(1, -20, 0, 28)
				field.Position = UDim2.new(0, 10, 1, -35)
				local selected = field:FindFirstChild("Selected")
				if selected then
					selected.TextSize = 11
					selected.Size = UDim2.new(1, -30, 1, 0)
					selected.Position = UDim2.new(0, 9, 0, 0)
				end
				local box = field:FindFirstChild("Box")
				if box then
					box.TextSize = 11
				end
			end
		end
	end
	applyResponsiveSize()
	local conn
	conn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if v.AutoScale then
			applyResponsiveSize()
		end
	end)
	screenGui.AncestryChanged:Connect(function()
		if not screenGui.Parent then
			if conn then conn:Disconnect() end
		end
	end)
	screenGui.Parent = v.Parent
	fn(uiScale, tbl.spring, { Scale = mobile and v.MobileScale or 1 }):Play()
	fn(imageLabel, tbl.soft, { ImageTransparency = 0.4 }):Play()
	return {
		_gui = screenGui,
		_window = frame,
		_pageLayout = uiPageLayout,
		_tabScroll = scrollingFrame,
		_tabList = uiListLayout2,
		_tabs = {},
		_dropZone = canvasGroup,
		_realDrop = frame19,
		_listDrop = scrollingFrame2,
		_dropTmpl = textButton6,
		_dropHeading = textLabel5,
		_island = textButton7,
		_islandTitle = textLabel10,
		_islandSub = textLabel11,
		_islandMono = textLabel8,
		_islandMark = textLabel9,
		_mobileToggle = tbl3.frame,
		_clickUI = tbl3.click,
		ApplyResponsive = applyResponsiveSize,
		ToggleUI = function()
			if flag then fn5() else fn4() end
		end,
		SetIslandEnabled = function(arg3, enabled)
			v.IslandEnabled = enabled
			textButton7.Visible = enabled
		end,
		GetIslandEnabled = function()
			return v.IslandEnabled
		end,
		SetIslandDefaultSize = function(arg3, size)
			if typeof(size) == "UDim2" then
				v.IslandDefaultSize = size
				if not flag2 then
					textButton7.Size = size
				end
			end
		end,
		SetIslandExpandedSize = function(arg3, size)
			if typeof(size) == "UDim2" then
				v.IslandExpandedSize = size
				if flag2 then
					textButton7.Size = size
				end
			end
		end,
		SetToggleSize = function(arg3, size)
			if typeof(size) == "UDim2" then
				v.ToggleSize = size
				tbl3.frame.Size = size
			end
		end,
		GetIslandPosition = function()
			return textButton7.Position
		end,
		SetIslandPosition = function(arg3, pos)
			if typeof(pos) == "UDim2" then
				textButton7.Position = pos
			end
		end,
		SetTask = function(arg3, arg4)
			local v3 = fn2({ Current = "", Previous = "" }, arg4)
			str = v3.Current
			str2 = v3.Previous
			textLabel10.Text = str ~= "" and str or "DN Hub"
			textLabel11.Text = str2 ~= "" and str2 or "No previous task"
		end,
		SetIslandText = function(arg3, arg4)
			local v3 = fn2({ Title = "", Status = nil }, arg4)
			if flag2 then
				fn8()
				task.wait(0.7)
			end
			if v3.Title ~= "" or v3.Status then
				frame28.Visible = false
				frame29.Visible = false
				textLabel6.Text = v3.Title
				if v3.Status then
					textLabel7.Visible = true
					textLabel7.Text = v3.Status
					if v3.Status == "ON" then
						textLabel7.TextColor3 = tbl2.green
					elseif v3.Status == "OFF" then
						textLabel7.TextColor3 = tbl2.red
					else
						textLabel7.TextColor3 = tbl2.title
					end
				else
					textLabel7.Visible = false
				end
				task.wait(0.05)
				local defaultSize = v.IslandDefaultSize
				fn(textButton7, tbl.pop, {
					Size = UDim2.new(0, math.max(defaultSize.X.Offset, textLabel6.TextBounds.X + (v3.Status and textLabel7.TextBounds.X + 8 or 0) + 44), 0, defaultSize.Y.Offset),
				}):Play()
			else
				textLabel6.Text = ""
				textLabel7.Visible = false
				frame28.Visible = true
				frame29.Visible = true
				fn(textButton7, tbl.pop, { Size = v.IslandDefaultSize }):Play()
			end
		end,
		Notify = function(arg3, arg4)
			local v3 = fn2({ Title = "Notification", Description = "", Status = nil, Duration = 3 }, arg4)
			fn(frame28, tbl.fade, { BackgroundTransparency = 1 }):Play()
			for _, v4 in ipairs(tbl4) do
				fn(v4, tbl.fade, { BackgroundTransparency = 1 }):Play()
			end
			textLabel6.Text = v3.Title
			textLabel6.TextTransparency = 1
			fn(textLabel6, tbl.fade, { TextTransparency = 0 }):Play()
			if v3.Status then
				textLabel7.Visible = true
				textLabel7.Text = v3.Status
				textLabel7.TextTransparency = 1
				if v3.Status == "ON" then
					textLabel7.TextColor3 = tbl2.green
				elseif v3.Status == "OFF" then
					textLabel7.TextColor3 = tbl2.red
				else
					textLabel7.TextColor3 = tbl2.title
				end
				fn(textLabel7, tbl.fade, { TextTransparency = 0 }):Play()
			else
				textLabel7.Visible = false
			end
			task.wait(0.05)
			local defaultSize = v.IslandDefaultSize
			fn(textButton7, tbl.pop, {
				Size = UDim2.new(0, math.max(defaultSize.X.Offset, textLabel6.TextBounds.X + (v3.Status and textLabel7.TextBounds.X + 8 or 0) + 44), 0, defaultSize.Y.Offset),
			}):Play()
			task.wait(v3.Duration)
			fn(textLabel6, tbl.fade, { TextTransparency = 1 }):Play()
			if v3.Status then
				fn(textLabel7, tbl.fade, { TextTransparency = 1 }):Play()
			end
			task.wait(0.3)
			fn(textButton7, tbl.pop, { Size = defaultSize }):Play()
			task.wait(0.2)
			textLabel6.Text = ""
			textLabel6.TextTransparency = 0
			textLabel7.Text = ""
			textLabel7.TextTransparency = 0
			textLabel7.Visible = false
			fn(frame28, tbl.fade, { BackgroundTransparency = 0 }):Play()
			for _, v4 in ipairs(tbl4) do
				fn(v4, tbl.fade, { BackgroundTransparency = 0 }):Play()
			end
		end,
		AddTab = function(arg3, arg4)
			local v3 = fn2({ Title = "Tab", Icon = "" }, arg4)
			local layoutOrder = #arg3._tabs + 1
			local isSmallScreen = mobile or getViewportSize().X < 900
			local textButton8 = Instance.new("TextButton", arg3._tabScroll)
			textButton8.Name = "Tab" .. layoutOrder
			textButton8.LayoutOrder = layoutOrder
			textButton8.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
			textButton8.BackgroundTransparency = 1
			textButton8.BorderSizePixel = 0
			textButton8.Size = UDim2.new(1, 0, 0, isSmallScreen and 34 or 39)
			textButton8.Text = ""
			textButton8.AutoButtonColor = false
			textButton8.Selectable = false
			Instance.new("UICorner", textButton8).CornerRadius = UDim.new(0, 10)
			local uiStroke10 = Instance.new("UIStroke", textButton8)
			uiStroke10.Color = Color3.fromRGB(0, 235, 255)
			uiStroke10.Transparency = 1
			uiStroke10.Thickness = 1
			uiStroke10.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local imageLabel4 = Instance.new("ImageLabel", textButton8)
			imageLabel4.Name = "Icon"
			imageLabel4.BackgroundTransparency = 1
			imageLabel4.AnchorPoint = Vector2.new(0, 0.5)
			imageLabel4.Size = UDim2.new(0, isSmallScreen and 16 or 20, 0, isSmallScreen and 16 or 20)
			imageLabel4.Position = UDim2.new(0, isSmallScreen and 7 or 10, 0.5, 0)
			imageLabel4.Image = v3.Icon
			imageLabel4.ImageTransparency = 0.5
			imageLabel4.ImageColor3 = Color3.fromRGB(255, 180, 60)
			local textLabel12 = Instance.new("TextLabel", textButton8)
			textLabel12.Name = "Label"
			textLabel12.Text = v3.Title
			textLabel12.TextColor3 = tbl2.title
			textLabel12.TextTransparency = 0.5
			textLabel12.TextSize = isSmallScreen and 10 or 12
			textLabel12.Font = Enum.Font.GothamBold
			textLabel12.BackgroundTransparency = 1
			textLabel12.AnchorPoint = Vector2.new(0, 0.5)
			textLabel12.Size = UDim2.new(1, isSmallScreen and -30 or -40, 1, 0)
			textLabel12.Position = UDim2.new(0, isSmallScreen and 28 or 40, 0.5, 0)
			textLabel12.TextXAlignment = Enum.TextXAlignment.Left
			local scrollingFrame3 = Instance.new("ScrollingFrame", arg3._window:FindFirstChild("Layout").RealLayout)
			scrollingFrame3.Name = "Page" .. layoutOrder
			scrollingFrame3.LayoutOrder = layoutOrder
			scrollingFrame3.BackgroundTransparency = 1
			scrollingFrame3.BorderSizePixel = 0
			scrollingFrame3.Size = UDim2.new(1, 0, 1, 0)
			scrollingFrame3.CanvasSize = UDim2.new(0, 0, 0, 0)
			scrollingFrame3.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame3.ScrollBarThickness = 3
			scrollingFrame3.ScrollBarImageTransparency = 0.65
			local uiPadding4 = Instance.new("UIPadding", scrollingFrame3)
			uiPadding4.PaddingTop = UDim.new(0, isSmallScreen and 6 or 8)
			uiPadding4.PaddingRight = UDim.new(0, isSmallScreen and 5 or 8)
			uiPadding4.PaddingLeft = UDim.new(0, isSmallScreen and 5 or 8)
			uiPadding4.PaddingBottom = UDim.new(0, isSmallScreen and 6 or 8)
			local uiListLayout7 = Instance.new("UIListLayout", scrollingFrame3)
			uiListLayout7.Padding = UDim.new(0, isSmallScreen and 4 or 6)
			uiListLayout7.SortOrder = Enum.SortOrder.LayoutOrder
			local tbl6 = {
				_order = layoutOrder,
				_btn = textButton8,
				_icon = imageLabel4,
				_lbl = textLabel12,
				_stroke = uiStroke10,
				_page = scrollingFrame3,
				_list = uiListLayout7,
				_window = arg3,
				_count = 0,
				_next = function(arg5)
					arg5._count = arg5._count + 1
					return arg5._count
				end,
			}
			table.insert(arg3._tabs, tbl6)
			local function fn9()
				for _, tab in ipairs(arg3._tabs) do
					if tab == tbl6 then
						fn(tab._btn, tbl.fast, { BackgroundTransparency = 0.9 }):Play()
						fn(tab._stroke, tbl.fast, { Transparency = 0.7 }):Play()
						fn(tab._lbl, tbl.fast, { TextTransparency = 0.1 }):Play()
						fn(tab._icon, tbl.fast, { ImageTransparency = 0 }):Play()
					else
						fn(tab._btn, tbl.fast, { BackgroundTransparency = 1 }):Play()
						fn(tab._stroke, tbl.fast, { Transparency = 1 }):Play()
						fn(tab._lbl, tbl.fast, { TextTransparency = 0.5 }):Play()
						fn(tab._icon, tbl.fast, { ImageTransparency = 0.5 }):Play()
					end
				end
				arg3._pageLayout:JumpTo(tbl6._page)
			end
			textButton8.MouseButton1Click:Connect(fn9)
			if layoutOrder == 1 then fn9() end
			tbl6.AddToggle = function(arg5, arg6)
				local v4 = fn2({
					Title = "Toggle",
					Description = "",
					Default = false,
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Toggle"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, v4.Description ~= "" and 52 or 41)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0.5)
				frame32.Position = UDim2.new(0, 11, 0.5, 0)
				frame32.Size = UDim2.new(0, 316, 0, v4.Description ~= "" and 36 or 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 22)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local frame33 = Instance.new("Frame", textButton9)
				frame33.Name = "Switch"
				frame33.BorderSizePixel = 0
				frame33.AnchorPoint = Vector2.new(1, 0.5)
				frame33.Size = UDim2.new(0, 32, 0, 18)
				frame33.Position = UDim2.new(1, -11, 0.5, 0)
				Instance.new("UICorner", frame33).CornerRadius = UDim.new(1, 0)
				local uiStroke12 = Instance.new("UIStroke", frame33)
				uiStroke12.Color = tbl2.fg
				uiStroke12.Thickness = 0.5
				uiStroke12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame34 = Instance.new("Frame", frame33)
				frame34.Name = "Knob"
				frame34.BorderSizePixel = 0
				frame34.BackgroundColor3 = tbl2.fg
				frame34.AnchorPoint = Vector2.new(0, 0.5)
				frame34.Size = UDim2.new(0, 14, 0, 14)
				frame34.Position = UDim2.new(0, v4.Default and 16 or 2, 0.5, 0)
				Instance.new("UICorner", frame34).CornerRadius = UDim.new(1, 0)
				local default = v4.Default
				frame33.BackgroundColor3 = default and tbl2.green or tbl2.fg				frame33.BackgroundTransparency = default and 0 or 0.88
				uiStroke12.Transparency = default and 1 or 0.85
				local function fn10()
					default = not default
					fn(frame34, tbl.spring, { Position = UDim2.new(0, default and 16 or 2, 0.5, 0) }):Play()
					fn(frame33, tbl.soft, { BackgroundColor3 = default and tbl2.green or tbl2.fg, BackgroundTransparency = default and 0 or 0.88 }):Play()
					fn(uiStroke12, tbl.soft, { Transparency = default and 1 or 0.85 }):Play()
					pcall(v4.Callback, default)
				end
				textButton9.MouseButton1Click:Connect(fn10)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
				return {
					Value = default,
					SetValue = function(arg7, arg8)
						if arg8 ~= default then fn10() end
					end,
				}
			end
			tbl6.AddButton = function(arg5, arg6)
				local v4 = fn2({
					Title = "Button",
					Description = "",
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Button"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, v4.Description ~= "" and 52 or 41)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0.5)
				frame32.Position = UDim2.new(0, 11, 0.5, 0)
				frame32.Size = UDim2.new(0, 316, 0, v4.Description ~= "" and 36 or 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 22)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local frame33 = Instance.new("Frame", textButton9)
				frame33.Name = "Caret"
				frame33.BackgroundTransparency = 1
				frame33.AnchorPoint = Vector2.new(1, 0.5)
				frame33.Size = UDim2.new(0, 7, 0, 9)
				frame33.Position = UDim2.new(1, -11, 0.5, 0)
				local frame34 = Instance.new("Frame", frame33)
				frame34.BackgroundTransparency = 1
				frame34.Size = UDim2.new(1, 0, 1, 0)
				local frame35 = Instance.new("Frame", frame34)
				frame35.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
				frame35.BackgroundTransparency = 0.35
				frame35.BorderSizePixel = 0
				frame35.AnchorPoint = Vector2.new(0.5, 0.5)
				frame35.Size = UDim2.new(0, 1, 0, 5)
				frame35.Position = UDim2.new(0, 2, 0, 2)
				frame35.Rotation = -45
				Instance.new("UICorner", frame35).CornerRadius = UDim.new(1, 0)
				local clone2 = frame35:Clone()
				clone2.Parent = frame34
				clone2.Position = UDim2.new(0, 2, 0, 7)
				clone2.Rotation = 45
				textButton9.MouseEnter:Connect(function()
					fn(textButton9, tbl.fade, { BackgroundTransparency = 0.92 }):Play()
				end)
				textButton9.MouseLeave:Connect(function()
					fn(textButton9, tbl.fade, { BackgroundTransparency = 0.95 }):Play()
				end)
				textButton9.MouseButton1Click:Connect(function()
					fn(textButton9, tbl.fade, { BackgroundTransparency = 0.88 }):Play()
					task.wait(0.1)
					fn(textButton9, tbl.fade, { BackgroundTransparency = 0.92 }):Play()
					pcall(v4.Callback)
				end)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
			end
			tbl6.AddLabel = function(arg5, arg6)
				local v4 = fn2({ Title = "Label" }, arg6)
				local frame32 = Instance.new("Frame", arg5._page)
				frame32.Name = "Label"
				frame32.LayoutOrder = arg5:_next()
				frame32.BackgroundTransparency = 1
				frame32.Size = UDim2.new(1, 0, 0, 20)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = isSmallScreen and 11 or 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 1, 0)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
			end
			tbl6.AddParagraph = function(arg5, arg6)
				local v4 = fn2({ Title = "Paragraph", Content = "" }, arg6)
				local frame32 = Instance.new("Frame", arg5._page)
				frame32.Name = "Paragraph"
				frame32.LayoutOrder = arg5:_next()
				frame32.BackgroundColor3 = tbl2.fg
				frame32.BackgroundTransparency = 0.95
				frame32.BorderSizePixel = 0
				frame32.Size = UDim2.new(1, 0, 0, 54)
				Instance.new("UICorner", frame32)
				local uiStroke11 = Instance.new("UIStroke", frame32)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = isSmallScreen and 11 or 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Position = UDim2.new(0, isSmallScreen and 9 or 11, 0, 9)
				textLabel13.Size = UDim2.new(1, isSmallScreen and -18 or -22, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				local textLabel14 = Instance.new("TextLabel", frame32)
				textLabel14.Name = "Desc"
				textLabel14.Text = v4.Content
				textLabel14.TextColor3 = tbl2.desc
				textLabel14.TextTransparency = 0.2
				textLabel14.TextSize = isSmallScreen and 10 or 11
				textLabel14.Font = Enum.Font.Gotham
				textLabel14.BackgroundTransparency = 1
				textLabel14.Position = UDim2.new(0, isSmallScreen and 9 or 11, 0, 23)
				textLabel14.Size = UDim2.new(1, isSmallScreen and -18 or -22, 1, -27)
				textLabel14.TextXAlignment = Enum.TextXAlignment.Left
				textLabel14.TextYAlignment = Enum.TextYAlignment.Top
				textLabel14.TextWrapped = true
			end
			tbl6.AddSeparator = function(arg5, arg6)
				local v4 = fn2({ Title = "" }, arg6)
				local frame32 = Instance.new("Frame", arg5._page)
				frame32.Name = "Separator"
				frame32.LayoutOrder = arg5:_next()
				frame32.BackgroundTransparency = 1
				frame32.Size = UDim2.new(1, 0, 0, 20)
				if v4.Title ~= "" then
					local textLabel13 = Instance.new("TextLabel", frame32)
					textLabel13.Name = "Label"
					textLabel13.Text = v4.Title
					textLabel13.TextColor3 = Color3.fromRGB(255, 180, 60)
					textLabel13.TextTransparency = 0.3
					textLabel13.TextSize = isSmallScreen and 9 or 10
					textLabel13.Font = Enum.Font.GothamBold
					textLabel13.BackgroundTransparency = 1
					textLabel13.Size = UDim2.new(0, isSmallScreen and 80 or 108, 0, 11)
					textLabel13.Position = UDim2.new(0, 0, 0.5, -5)
					textLabel13.TextXAlignment = Enum.TextXAlignment.Left
					local frame33 = Instance.new("Frame", frame32)
					frame33.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
					frame33.BackgroundTransparency = 0.7
					frame33.BorderSizePixel = 0
					frame33.Size = UDim2.new(1, isSmallScreen and -88 or -117, 0, 1)
					frame33.Position = UDim2.new(0, isSmallScreen and 88 or 117, 0.5, 0)
				else
					local frame33 = Instance.new("Frame", frame32)
					frame33.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
					frame33.BackgroundTransparency = 0.7
					frame33.BorderSizePixel = 0
					frame33.Size = UDim2.new(1, 0, 0, 1)
					frame33.Position = UDim2.new(0, 0, 0.5, 0)
				end
			end
			tbl6.AddSlider = function(arg5, arg6)
				local v4 = fn2({
					Title = "Slider",
					Description = "",
					Min = 0,
					Max = 100,
					Default = 50,
					Suffix = "",
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Slider"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, v4.Description ~= "" and 52 or 41)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0.5)
				frame32.Position = UDim2.new(0, 11, 0.5, 0)
				frame32.Size = UDim2.new(0, 219, 0, v4.Description ~= "" and 36 or 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 22)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local textLabel14 = Instance.new("TextLabel", textButton9)
				textLabel14.Name = "ValueText"
				textLabel14.TextColor3 = tbl2.title
				textLabel14.TextSize = 11
				textLabel14.Font = Enum.Font.GothamBold
				textLabel14.BackgroundTransparency = 1
				textLabel14.AnchorPoint = Vector2.new(1, 1)
				textLabel14.Size = UDim2.new(0, 63, 0, 13)
				textLabel14.Position = UDim2.new(1, -13, 0.5, -5)
				textLabel14.TextXAlignment = Enum.TextXAlignment.Right
				local frame33 = Instance.new("Frame", textButton9)
				frame33.Name = "Track"
				frame33.BackgroundColor3 = tbl2.fg
				frame33.BackgroundTransparency = 0.86
				frame33.BorderSizePixel = 0
				frame33.AnchorPoint = Vector2.new(1, 0.5)
				frame33.Size = UDim2.new(0, 117, 0, 5)
				frame33.Position = UDim2.new(1, -13, 0.5, 5)
				Instance.new("UICorner", frame33).CornerRadius = UDim.new(1, 0)
				local frame34 = Instance.new("Frame", frame33)
				frame34.Name = "Fill"
				frame34.BackgroundColor3 = tbl2.blue
				frame34.BorderSizePixel = 0
				frame34.Size = UDim2.new((v4.Default - v4.Min) / (v4.Max - v4.Min), 0, 1, 0)
				Instance.new("UICorner", frame34).CornerRadius = UDim.new(1, 0)
				local frame35 = Instance.new("Frame", frame33)
				frame35.Name = "Knob"
				frame35.BackgroundColor3 = tbl2.fg
				frame35.BorderSizePixel = 0
				frame35.ZIndex = 3
				frame35.AnchorPoint = Vector2.new(0.5, 0.5)
				frame35.Size = UDim2.new(0, 13, 0, 13)
				frame35.Position = UDim2.new((v4.Default - v4.Min) / (v4.Max - v4.Min), 0, 0.5, 0)
				Instance.new("UICorner", frame35).CornerRadius = UDim.new(1, 0)
				local uiStroke12 = Instance.new("UIStroke", frame35)
				uiStroke12.Transparency = 0.75
				uiStroke12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local default = v4.Default
				local suffix = v4.Suffix
				textLabel14.Text = tostring(default) .. suffix
				local flag5 = false
				local function fn10(arg7)
					local n = math.clamp((arg7.Position.X - frame33.AbsolutePosition.X) / frame33.AbsoluteSize.X, 0, 1)
					default = math.floor(v4.Min + (v4.Max - v4.Min) * n)
					local suffix2 = v4.Suffix
					textLabel14.Text = tostring(default) .. suffix2
					fn(frame34, tbl.fade, { Size = UDim2.new(n, 0, 1, 0) }):Play()
					fn(frame35, tbl.fade, { Position = UDim2.new(n, 0, 0.5, 0) }):Play()
				end
				frame33.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						flag5 = true
						fn10(input)
					end
				end)
				frame33.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						flag5 = false
						pcall(v4.Callback, default)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if flag5 and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						fn10(input)
					end
				end)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
				return {
					Value = default,
					SetValue = function(arg7, arg8)
						default = math.clamp(arg8, v4.Min, v4.Max)
						local suffix2 = v4.Suffix
						textLabel14.Text = tostring(default) .. suffix2
						fn(frame34, tbl.soft, { Size = UDim2.new((default - v4.Min) / (v4.Max - v4.Min), 0, 1, 0) }):Play()
						fn(frame35, tbl.soft, { Position = UDim2.new((default - v4.Min) / (v4.Max - v4.Min), 0, 0.5, 0) }):Play()
					end,
				}
			end
			tbl6.AddDropdown = function(arg5, arg6)
				local v4 = fn2({
					Title = "Dropdown",
					Description = "",
					Options = { "Option 1" },
					Default = "Option 1",
					Multi = false,
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Dropdown"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, v4.Description ~= "" and 77 or 66)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0)
				frame32.Position = UDim2.new(0, 11, 0, 9)
				frame32.Size = UDim2.new(1, -22, 0, v4.Description ~= "" and 36 or 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 22)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local frame33 = Instance.new("Frame", textButton9)
				frame33.Name = "Field"
				frame33.BackgroundColor3 = tbl2.fg
				frame33.BackgroundTransparency = 0.93
				frame33.BorderSizePixel = 0
				frame33.Size = UDim2.new(1, -22, 0, 29)
				frame33.Position = UDim2.new(0, 11, 1, -38)
				Instance.new("UICorner", frame33).CornerRadius = UDim.new(0, 7)
				local uiStroke12 = Instance.new("UIStroke", frame33)
				uiStroke12.Color = Color3.fromRGB(0, 235, 255)
				uiStroke12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local uiGradient9 = Instance.new("UIGradient", uiStroke12)
				uiGradient9.Rotation = 90
				uiGradient9.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
				local uiGradient10 = Instance.new("UIGradient", frame33)
				uiGradient10.Rotation = 90
				uiGradient10.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.35) })
				local textLabel14 = Instance.new("TextLabel", frame33)
				textLabel14.Name = "Selected"
				textLabel14.Text = v4.Multi and "None" or tostring(v4.Default or "None")
				textLabel14.TextColor3 = tbl2.title
				textLabel14.TextTransparency = 0.15
				textLabel14.TextSize = 12
				textLabel14.Font = Enum.Font.GothamMedium
				textLabel14.BackgroundTransparency = 1
				textLabel14.Size = UDim2.new(1, -36, 1, 0)
				textLabel14.Position = UDim2.new(0, 11, 0, 0)
				textLabel14.TextXAlignment = Enum.TextXAlignment.Left
				local frame34 = Instance.new("Frame", frame33)
				frame34.Name = "Caret"
				frame34.BackgroundTransparency = 1
				frame34.AnchorPoint = Vector2.new(1, 0.5)
				frame34.Size = UDim2.new(0, 11, 0, 13)
				frame34.Position = UDim2.new(1, -7, 0.5, 0)
				local frame35 = Instance.new("Frame", frame34)
				frame35.Name = "Up"
				frame35.BackgroundTransparency = 1
				frame35.Size = UDim2.new(1, 0, 0, 5)
				frame35.Position = UDim2.new(0, 0, 0, 0)
				local frame36 = Instance.new("Frame", frame35)
				frame36.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
				frame36.BackgroundTransparency = 0.35
				frame36.BorderSizePixel = 0
				frame36.AnchorPoint = Vector2.new(0.5, 0.5)
				frame36.Size = UDim2.new(0, 1, 0, 4)
				frame36.Position = UDim2.new(0, 3, 0.5, 0)
				frame36.Rotation = 45
				Instance.new("UICorner", frame36).CornerRadius = UDim.new(1, 0)
				local clone2 = frame36:Clone()
				clone2.Parent = frame35
				clone2.Position = UDim2.new(0, 8, 0.5, 0)
				clone2.Rotation = -45
				local frame37 = Instance.new("Frame", frame34)
				frame37.Name = "Down"
				frame37.BackgroundTransparency = 1
				frame37.Size = UDim2.new(1, 0, 0, 5)
				frame37.Position = UDim2.new(0, 0, 1, -5)
				local frame38 = Instance.new("Frame", frame37)
				frame38.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
				frame38.BackgroundTransparency = 0.35
				frame38.BorderSizePixel = 0
				frame38.AnchorPoint = Vector2.new(0.5, 0.5)
				frame38.Size = UDim2.new(0, 1, 0, 4)
				frame38.Position = UDim2.new(0, 3, 0.5, 0)
				frame38.Rotation = -45
				Instance.new("UICorner", frame38).CornerRadius = UDim.new(1, 0)
				local clone3 = frame38:Clone()
				clone3.Parent = frame37
				clone3.Position = UDim2.new(0, 8, 0.5, 0)
				clone3.Rotation = 45
				local default = v4.Multi and {} or v4.Default
				if v4.Multi and type(v4.Default) == "table" then
					for _, v5 in ipairs(v4.Default) do
						default[v5] = true
					end
				end
				local function fn10()
					if v4.Multi then
						local tbl7 = {}
						for k, v5 in pairs(default) do
							if v5 then table.insert(tbl7, k) end
						end
						textLabel14.Text = #tbl7 > 0 and table.concat(tbl7, ", ") or "None"
					else
						textLabel14.Text = default
					end
				end
				fn10()
				local searchBox = arg5._window._dropZone:FindFirstChild("DropdownSearch", true)
				local optionButtons = {}
				local function filterDropdownOptions()
					local query = string.lower(searchBox and searchBox.Text or "")
					for _, optionButton in ipairs(optionButtons) do
						optionButton.Visible = query == "" or string.find(string.lower(optionButton.Text), query, 1, true) ~= nil
					end
				end
				if searchBox then searchBox:GetPropertyChangedSignal("Text"):Connect(filterDropdownOptions) end
				textButton9.MouseButton1Click:Connect(function()
					arg5._window._dropHeading.Text = v4.Title
					arg5._window._dropZone.Visible = true
					fn(arg5._window._dropZone, tbl.soft, { GroupTransparency = 0 }):Play()
					fn(arg5._window._realDrop:FindFirstChildOfClass("UIScale"), tbl.pop, { Scale = 1 }):Play()
					for _, child in ipairs(arg5._window._listDrop:GetChildren()) do
						if child:IsA("TextButton") and child.Name ~= "Template" then
							child:Destroy()
						end
					end
					if searchBox then searchBox.Text = "" end
					optionButtons = {}
					for i, option in ipairs(v4.Options) do
						local clone4 = arg5._window._dropTmpl:Clone()
						clone4.Name = "Option" .. i
						clone4.Text = option
						clone4.Visible = true
						clone4.LayoutOrder = i
						clone4.Parent = arg5._window._listDrop
						table.insert(optionButtons, clone4)
						local tick = clone4:FindFirstChild("Tick")
						if tick then
							if v4.Multi then
								tick.Visible = default[option] == true
							else
								tick.Visible = option == default
							end
						end
						clone4.MouseButton1Click:Connect(function()
							if v4.Multi then
								default[option] = not default[option]
								if tick then tick.Visible = default[option] end
								fn10()
								pcall(v4.Callback, default)
							else
								default = option
								textLabel14.Text = option
								for _, child in ipairs(arg5._window._listDrop:GetChildren()) do
									if child:IsA("TextButton") and child.Name ~= "Template" then
										local tick2 = child:FindFirstChild("Tick")
										if tick2 then
											tick2.Visible = child.Text == option
										end
									end
								end
								pcall(v4.Callback, option)
							end
						end)
						clone4.MouseEnter:Connect(function()
							fn(clone4, tbl.fade, { BackgroundTransparency = 0.92 }):Play()
						end)
						clone4.MouseLeave:Connect(function()
							fn(clone4, tbl.fade, { BackgroundTransparency = 0.95 }):Play()
						end)
					end
				end)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
				return {
					Value = default,
					SetValue = function(arg7, arg8)
						if v4.Multi then
							default = {}
							if type(arg8) == "table" then
								for _, v5 in ipairs(arg8) do
									default[v5] = true
								end
							end
						else
							default = arg8
						end
						fn10()
					end,
					RefreshOptions = function(arg7, newOptions, newDefault)
						if type(newOptions) ~= "table" then return end
						v4.Options = newOptions
						if newDefault ~= nil then
							if v4.Multi then
								default = {}
								if type(newDefault) == "table" then
									for _, v5 in ipairs(newDefault) do
										default[v5] = true
									end
								end
							else
								default = newDefault
							end
						end
						fn10()
					end,
				}
			end
			tbl6.AddMultiDropdown = function(arg5, arg6)
				local config = fn2({ Multi = true }, arg6)
				config.Multi = true
				return arg5:AddDropdown(config)
			end
			tbl6.AddTextbox = function(arg5, arg6)
				local v4 = fn2({
					Title = "Textbox",
					Description = "",
					Placeholder = "Enter text...",
					Default = "",
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Textbox"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, v4.Description ~= "" and 77 or 66)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0)
				frame32.Position = UDim2.new(0, 11, 0, 9)
				frame32.Size = UDim2.new(1, -22, 0, v4.Description ~= "" and 36 or 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 22)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local frame33 = Instance.new("Frame", textButton9)
				frame33.Name = "Field"
				frame33.BackgroundColor3 = tbl2.fg
				frame33.BackgroundTransparency = 0.93
				frame33.BorderSizePixel = 0
				frame33.Size = UDim2.new(1, -22, 0, 29)
				frame33.Position = UDim2.new(0, 11, 1, -38)
				Instance.new("UICorner", frame33).CornerRadius = UDim.new(0, 7)
				local uiStroke12 = Instance.new("UIStroke", frame33)
				uiStroke12.Color = Color3.fromRGB(0, 235, 255)
				uiStroke12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local uiGradient9 = Instance.new("UIGradient", uiStroke12)
				uiGradient9.Rotation = 90
				uiGradient9.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
				local uiGradient10 = Instance.new("UIGradient", frame33)
				uiGradient10.Rotation = 90
				uiGradient10.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.35) })
				local uiPadding5 = Instance.new("UIPadding", frame33)
				uiPadding5.PaddingLeft = UDim.new(0, 11)
				uiPadding5.PaddingRight = UDim.new(0, 11)
				local textBox = Instance.new("TextBox", frame33)
				textBox.Name = "Box"
				textBox.Text = v4.Default
				textBox.PlaceholderText = v4.Placeholder
				textBox.TextColor3 = tbl2.title
				textBox.TextTransparency = 0.15
				textBox.PlaceholderColor3 = tbl2.desc
				textBox.TextSize = 12
				textBox.Font = Enum.Font.GothamMedium
				textBox.BackgroundTransparency = 1
				textBox.Size = UDim2.new(1, 0, 1, 0)
				textBox.TextXAlignment = Enum.TextXAlignment.Left
				textBox.ClearTextOnFocus = false
				textBox.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						pcall(v4.Callback, textBox.Text)
					end
				end)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
				return {
					Value = textBox.Text,
					SetValue = function(arg7, text)
						textBox.Text = text
					end,
				}
			end
			tbl6.AddKeybind = function(arg5, arg6)
				local v4 = fn2({
					Title = "Keybind",
					Description = "",
					Default = "RightShift",
					Callback = function() end,
				}, arg6)
				local textButton9 = Instance.new("TextButton", arg5._page)
				textButton9.Name = "Keybind"
				textButton9.LayoutOrder = arg5:_next()
				textButton9.BackgroundColor3 = tbl2.fg
				textButton9.BackgroundTransparency = 0.95
				textButton9.BorderSizePixel = 0
				textButton9.Size = UDim2.new(1, 0, 0, 41)
				textButton9.Text = ""
				textButton9.AutoButtonColor = false
				textButton9.Selectable = false
				Instance.new("UICorner", textButton9)
				local uiStroke11 = Instance.new("UIStroke", textButton9)
				uiStroke11.Color = Color3.fromRGB(0, 235, 255)
				uiStroke11.Transparency = 0.85
				uiStroke11.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local frame32 = Instance.new("Frame", textButton9)
				frame32.Name = "TextBlock"
				frame32.BackgroundTransparency = 1
				frame32.AnchorPoint = Vector2.new(0, 0.5)
				frame32.Position = UDim2.new(0, 11, 0.5, 0)
				frame32.Size = UDim2.new(0, 287, 0, 25)
				local textLabel13 = Instance.new("TextLabel", frame32)
				textLabel13.Name = "Title"
				textLabel13.Text = v4.Title
				textLabel13.TextColor3 = tbl2.title
				textLabel13.TextTransparency = 0.08
				textLabel13.TextSize = 12
				textLabel13.Font = Enum.Font.GothamBold
				textLabel13.BackgroundTransparency = 1
				textLabel13.Size = UDim2.new(1, 0, 0, 12)
				textLabel13.TextXAlignment = Enum.TextXAlignment.Left
				textLabel13.TextYAlignment = Enum.TextYAlignment.Top
				textLabel13.TextWrapped = true
				if v4.Description ~= "" then
					local textLabel14 = Instance.new("TextLabel", frame32)
					textLabel14.Name = "Desc"
					textLabel14.Text = v4.Description
					textLabel14.TextColor3 = tbl2.desc
					textLabel14.TextTransparency = 0.2
					textLabel14.TextSize = 11
					textLabel14.Font = Enum.Font.Gotham
					textLabel14.BackgroundTransparency = 1
					textLabel14.Size = UDim2.new(1, 0, 0, 11)
					textLabel14.Position = UDim2.new(0, 0, 0, 14)
					textLabel14.TextXAlignment = Enum.TextXAlignment.Left
					textLabel14.TextYAlignment = Enum.TextYAlignment.Top
					textLabel14.TextWrapped = true
				end
				local textButton10 = Instance.new("TextButton", textButton9)
				textButton10.Name = "Pill"
				textButton10.AutoButtonColor = false
				textButton10.BackgroundColor3 = tbl2.fg
				textButton10.BackgroundTransparency = 0.93
				textButton10.BorderSizePixel = 0
				textButton10.AnchorPoint = Vector2.new(1, 0.5)
				textButton10.Size = UDim2.new(0, 61, 0, 23)
				textButton10.Position = UDim2.new(1, -11, 0.5, 0)
				textButton10.Text = ""
				Instance.new("UICorner", textButton10).CornerRadius = UDim.new(0, 6)
				local uiStroke12 = Instance.new("UIStroke", textButton10)
				uiStroke12.Color = Color3.fromRGB(0, 235, 255)
				uiStroke12.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local uiGradient9 = Instance.new("UIGradient", uiStroke12)
				uiGradient9.Rotation = 90
				uiGradient9.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
				local uiGradient10 = Instance.new("UIGradient", textButton10)
				uiGradient10.Rotation = 90
				uiGradient10.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.35) })
				local textLabel14 = Instance.new("TextLabel", textButton10)
				textLabel14.Name = "Key"
				textLabel14.Text = v4.Default
				textLabel14.TextColor3 = tbl2.title
				textLabel14.TextTransparency = 0.15
				textLabel14.TextSize = 11
				textLabel14.Font = Enum.Font.GothamMedium
				textLabel14.BackgroundTransparency = 1
				textLabel14.Size = UDim2.new(1, 0, 1, 0)
				local default = v4.Default
				local flag5 = false
				textButton10.MouseButton1Click:Connect(function()
					if flag5 then return end
					flag5 = true
					textLabel14.Text = "..."
					fn(textButton10, tbl.fade, { BackgroundTransparency = 0.85 }):Play()
				end)
				UserInputService.InputBegan:Connect(function(input)
					if not flag5 then return end
					if input.UserInputType == Enum.UserInputType.Keyboard then
						default = input.KeyCode.Name
						textLabel14.Text = default
						flag5 = false
						fn(textButton10, tbl.fade, { BackgroundTransparency = 0.93 }):Play()
						pcall(v4.Callback, default)
					end
				end)
				if isSmallScreen then
					applyElementMobileLayout(textButton9, arg5)
				end
				return {
					Value = default,
					SetKey = function(arg7, text)
						default = text
						textLabel14.Text = text
					end,
				}
			end
			return tbl6
		end,
	}
end }
