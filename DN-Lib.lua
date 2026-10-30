local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenPresets = {
	spring = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	soft = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	fast = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	pop = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	fade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	slide = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	island = TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}
local function Tween(instance, info, goal)
	return TweenService:Create(instance, info, goal)
end
local function MergeTable(base, override)
	local result = {}
	for k, v in pairs(base) do
		result[k] = v
	end
	if override then
		for k, v in pairs(override) do
			result[k] = v
		end
	end
	return result
end
local Colors = {
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
local neonElapsed = 0
local neonGradients = {}
local function TrackNeon(root)
	if not root then return end
	local function track(obj)
		if obj:IsA("UIGradient") and obj.Parent and obj.Parent:IsA("UIStroke") then
			neonGradients[obj] = true
		end
	end
	for _, obj in ipairs(root:GetDescendants()) do track(obj) end
	root.DescendantAdded:Connect(track)
end
task.defer(function()
	local player = game:GetService("Players").LocalPlayer
	TrackNeon(game:GetService("CoreGui"))
	TrackNeon(player and player:FindFirstChildOfClass("PlayerGui"))
end)
RunService.RenderStepped:Connect(function(dt)
	neonElapsed = (neonElapsed + dt * 42) % 360
	for gradient in pairs(neonGradients) do
		if gradient.Parent then
			gradient.Rotation = (neonElapsed + (gradient:GetAttribute("DNNeonOffset") or 0)) % 360
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(174, 75, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
			})
		else
			neonGradients[gradient] = nil
		end
	end
end)
local function MakeDraggable(dragTarget, moveTarget)
	local v = moveTarget or dragTarget
	local dragging = false
	local dragged = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	dragTarget.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragged = false
			dragStart = input.Position
			startPos = v.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	dragTarget.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			if delta.Magnitude > 6 then
				dragged = true
			end
			v.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	return function()
		return dragged
	end
end
local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function GetViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(1920, 1080)
end
return { CreateWindow = function(baseOptions, overrideOptions)
	local opts = MergeTable({
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
		IslandIcon = "",
		IslandEnabled = true,
		ToggleDefaultSize = UDim2.new(0, 48, 0, 48),
		ToggleSize = UDim2.new(0, 48, 0, 48),
	}, overrideOptions)
	local mobile = IsMobile()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DNHubUI"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local shadowImage = Instance.new("ImageLabel", screenGui)
	shadowImage.Image = "rbxassetid://8992230677"
	shadowImage.SliceCenter = Rect.new(99, 99, 99, 99)
	shadowImage.ScaleType = Enum.ScaleType.Slice
	shadowImage.ImageColor3 = Color3.new(0, 0, 0)
	shadowImage.ImageTransparency = 1
	shadowImage.BackgroundTransparency = 1
	shadowImage.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowImage.Position = UDim2.new(0.5, 0, 0.5, 0)
	shadowImage.Size = mobile and opts.MobileSize or opts.Size
	local uiScale = Instance.new("UIScale", shadowImage)
	uiScale.Scale = mobile and opts.MobileScale or 0.95
	local windowFrame = Instance.new("Frame", shadowImage)
	windowFrame.Name = "Window"
	windowFrame.BackgroundColor3 = Colors.bg
	windowFrame.BackgroundTransparency = 0.05
	windowFrame.BorderSizePixel = 0
	windowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	windowFrame.Size = UDim2.new(1, -120, 1, -120)
	Instance.new("UICorner", windowFrame).CornerRadius = UDim.new(0, 24)
	local windowStroke = Instance.new("UIStroke", windowFrame)
	windowStroke.Color = Color3.fromRGB(0, 235, 255)
	windowStroke.Transparency = 0.6
	windowStroke.Thickness = 1.5
	windowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local titleArea = Instance.new("Frame", windowFrame)
	titleArea.Name = "Top"
	titleArea.BackgroundTransparency = 1
	titleArea.Active = true
	titleArea.Size = UDim2.new(0, 179, 0, 85)
	local dotRed = Instance.new("Frame", titleArea)
	dotRed.BackgroundColor3 = Colors.red
	dotRed.BorderSizePixel = 0
	dotRed.Size = UDim2.new(0, 12, 0, 12)
	dotRed.Position = UDim2.new(0, 18, 0, 20)
	Instance.new("UICorner", dotRed).CornerRadius = UDim.new(1, 0)
	local dotAmber = Instance.new("Frame", titleArea)
	dotAmber.BackgroundColor3 = Colors.amber
	dotAmber.BorderSizePixel = 0
	dotAmber.Size = UDim2.new(0, 12, 0, 12)
	dotAmber.Position = UDim2.new(0, 38, 0, 20)
	Instance.new("UICorner", dotAmber).CornerRadius = UDim.new(1, 0)
	local dotGreen = Instance.new("Frame", titleArea)
	dotGreen.BackgroundColor3 = Colors.green
	dotGreen.BorderSizePixel = 0
	dotGreen.Size = UDim2.new(0, 12, 0, 12)
	dotGreen.Position = UDim2.new(0, 58, 0, 20)
	Instance.new("UICorner", dotGreen).CornerRadius = UDim.new(1, 0)
	local titleLabel = Instance.new("TextLabel", titleArea)
	titleLabel.Name = "Title"
	titleLabel.Text = opts.Title
	titleLabel.TextColor3 = Colors.title
	titleLabel.TextTransparency = 0.05
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -20, 0, 18)
	titleLabel.Position = UDim2.new(0, 18, 0, 48)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	local subTitleLabel = Instance.new("TextLabel", titleArea)
	subTitleLabel.Name = "SubTitle"
	subTitleLabel.Text = opts.SubTitle
	subTitleLabel.TextColor3 = Colors.desc
	subTitleLabel.TextTransparency = 0.25
	subTitleLabel.TextSize = 11
	subTitleLabel.Font = Enum.Font.GothamMedium
	subTitleLabel.BackgroundTransparency = 1
	subTitleLabel.Size = UDim2.new(1, -20, 0, 14)
	subTitleLabel.Position = UDim2.new(0, 18, 0, 66)
	subTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	local headerRight = Instance.new("Frame", windowFrame)
	headerRight.Name = "Top_2"
	headerRight.BackgroundTransparency = 1
	headerRight.BorderSizePixel = 0
	headerRight.Size = UDim2.new(1, -183, 0, 85)
	headerRight.Position = UDim2.new(0, 180, 0, 0)
	local gameBadge = Instance.new("Frame", headerRight)
	gameBadge.Name = "NameGame"
	gameBadge.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	gameBadge.BackgroundTransparency = 0.5
	gameBadge.BorderSizePixel = 0
	gameBadge.AnchorPoint = Vector2.new(0, 0.5)
	gameBadge.AutomaticSize = Enum.AutomaticSize.X
	gameBadge.Size = UDim2.new(0, 0, 0, 25)
	gameBadge.Position = UDim2.new(0, 20, 0.25, 0)
	Instance.new("UICorner", gameBadge).CornerRadius = UDim.new(0, 24)
	local gameBadgePadding = Instance.new("UIPadding", gameBadge)
	gameBadgePadding.PaddingLeft = UDim.new(0, 12)
	gameBadgePadding.PaddingRight = UDim.new(0, 12)
	local gameText = Instance.new("TextLabel", gameBadge)
	gameText.Name = "Game"
	gameText.Text = opts.Game
	gameText.TextColor3 = Colors.fg
	gameText.TextSize = 10
	gameText.Font = Enum.Font.GothamBold
	gameText.BackgroundTransparency = 1
	gameText.AutomaticSize = Enum.AutomaticSize.X
	gameText.Size = UDim2.new(0, 0, 1, 0)
	gameText.Position = UDim2.new(0, 0, 0, 0)
	local versionBadge = Instance.new("Frame", headerRight)
	versionBadge.Name = "VersionFrame"
	versionBadge.BackgroundColor3 = Colors.fg
	versionBadge.BackgroundTransparency = 0.85
	versionBadge.BorderSizePixel = 0
	versionBadge.AnchorPoint = Vector2.new(0, 0.5)
	versionBadge.AutomaticSize = Enum.AutomaticSize.X
	versionBadge.Size = UDim2.new(0, 0, 0, 25)
	versionBadge.Position = UDim2.new(0, 20, 0.65, 0)
	Instance.new("UICorner", versionBadge).CornerRadius = UDim.new(0, 24)
	local versionBadgePadding = Instance.new("UIPadding", versionBadge)
	versionBadgePadding.PaddingLeft = UDim.new(0, 12)
	versionBadgePadding.PaddingRight = UDim.new(0, 12)
	local versionText = Instance.new("TextLabel", versionBadge)
	versionText.Name = "Version"
	versionText.Text = opts.Version
	versionText.TextColor3 = Colors.fg
	versionText.TextSize = 10
	versionText.Font = Enum.Font.GothamBold
	versionText.BackgroundTransparency = 1
	versionText.AutomaticSize = Enum.AutomaticSize.X
	versionText.Size = UDim2.new(0, 0, 1, 0)
	versionText.Position = UDim2.new(0, 0, 0, 0)
	local controlsFrame = Instance.new("Frame", headerRight)
	controlsFrame.Name = "ControlsFrame"
	controlsFrame.BackgroundTransparency = 1
	controlsFrame.BorderSizePixel = 0
	controlsFrame.AnchorPoint = Vector2.new(0, 0.5)
	controlsFrame.Size = UDim2.new(0, 190, 0, 45)
	controlsFrame.Position = UDim2.new(1, -200, 0.5, 0)
	Instance.new("UIPadding", controlsFrame).PaddingRight = UDim.new(0, 4)
	local controlsLayout = Instance.new("UIListLayout", controlsFrame)
	controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlsLayout.Padding = UDim.new(0, 8)
	controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	controlsLayout.FillDirection = Enum.FillDirection.Horizontal
	local minimizeBtn = Instance.new("TextButton", controlsFrame)
	minimizeBtn.Name = "BtnMinimize"
	minimizeBtn.AutoButtonColor = false
	minimizeBtn.BackgroundColor3 = Colors.fg
	minimizeBtn.BackgroundTransparency = 0.93
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
	minimizeBtn.LayoutOrder = 1
	minimizeBtn.Text = ""
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 7)
	local minimizeStroke = Instance.new("UIStroke", minimizeBtn)
	minimizeStroke.Color = Color3.fromRGB(0, 235, 255)
	minimizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local minimizeGradient = Instance.new("UIGradient", minimizeStroke)
	minimizeGradient.Rotation = 90
	minimizeGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local minimizeBar = Instance.new("Frame", minimizeBtn)
	minimizeBar.Name = "Bar"
	minimizeBar.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	minimizeBar.BorderSizePixel = 0
	minimizeBar.AnchorPoint = Vector2.new(0.5, 0.5)
	minimizeBar.Size = UDim2.new(0, 11, 0, 1)
	minimizeBar.Position = UDim2.new(0.5, 0, 0.5, 0)
	local maximizeBtn = Instance.new("TextButton", controlsFrame)
	maximizeBtn.Name = "BtnMaximize"
	maximizeBtn.AutoButtonColor = false
	maximizeBtn.BackgroundColor3 = Colors.fg
	maximizeBtn.BackgroundTransparency = 0.93
	maximizeBtn.BorderSizePixel = 0
	maximizeBtn.Size = UDim2.new(0, 26, 0, 26)
	maximizeBtn.LayoutOrder = 2
	maximizeBtn.Text = ""
	Instance.new("UICorner", maximizeBtn).CornerRadius = UDim.new(0, 7)
	local maximizeStroke = Instance.new("UIStroke", maximizeBtn)
	maximizeStroke.Color = Color3.fromRGB(0, 235, 255)
	maximizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local maximizeGradient = Instance.new("UIGradient", maximizeStroke)
	maximizeGradient.Rotation = 90
	maximizeGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local maximizeBox = Instance.new("Frame", maximizeBtn)
	maximizeBox.Name = "Box"
	maximizeBox.BackgroundTransparency = 1
	maximizeBox.BorderSizePixel = 0
	maximizeBox.AnchorPoint = Vector2.new(0.5, 0.5)
	maximizeBox.Size = UDim2.new(0, 10, 0, 10)
	maximizeBox.Position = UDim2.new(0.5, 0, 0.5, 0)
	Instance.new("UICorner", maximizeBox).CornerRadius = UDim.new(0, 3)
	local maximizeBoxStroke = Instance.new("UIStroke", maximizeBox)
	maximizeBoxStroke.Color = Color3.fromRGB(255, 200, 130)
	maximizeBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local closeBtn = Instance.new("TextButton", controlsFrame)
	closeBtn.Name = "BtnClose"
	closeBtn.AutoButtonColor = false
	closeBtn.BackgroundColor3 = Colors.fg
	closeBtn.BackgroundTransparency = 0.93
	closeBtn.BorderSizePixel = 0
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.LayoutOrder = 3
	closeBtn.Text = ""
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)
	local closeStroke = Instance.new("UIStroke", closeBtn)
	closeStroke.Color = Color3.fromRGB(0, 235, 255)
	closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local closeGradient = Instance.new("UIGradient", closeStroke)
	closeGradient.Rotation = 90
	closeGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local closeCross = Instance.new("Frame", closeBtn)
	closeCross.Name = "Cross"
	closeCross.BackgroundTransparency = 1
	closeCross.BorderSizePixel = 0
	closeCross.AnchorPoint = Vector2.new(0.5, 0.5)
	closeCross.Size = UDim2.new(0, 11, 0, 11)
	closeCross.Position = UDim2.new(0.5, 0, 0.5, 0)
	local crossBar1 = Instance.new("Frame", closeCross)
	crossBar1.Name = "Bar1"
	crossBar1.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	crossBar1.BackgroundTransparency = 0.25
	crossBar1.BorderSizePixel = 0
	crossBar1.AnchorPoint = Vector2.new(0.5, 0.5)
	crossBar1.Size = UDim2.new(0, 11, 0, 1)
	crossBar1.Position = UDim2.new(0.5, 0, 0.5, 0)
	crossBar1.Rotation = 45
	Instance.new("UICorner", crossBar1).CornerRadius = UDim.new(1, 0)
	local crossBar2 = Instance.new("Frame", closeCross)
	crossBar2.Name = "Bar2"
	crossBar2.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	crossBar2.BackgroundTransparency = 0.25
	crossBar2.BorderSizePixel = 0
	crossBar2.AnchorPoint = Vector2.new(0.5, 0.5)
	crossBar2.Size = UDim2.new(0, 11, 0, 1)
	crossBar2.Position = UDim2.new(0.5, 0, 0.5, 0)
	crossBar2.Rotation = -45
	Instance.new("UICorner", crossBar2).CornerRadius = UDim.new(1, 0)
	local minimized = false
	local maximized = false
	local responsiveScale = 0.95
	local ApplyResponsiveSize
	local responsiveElements = {}
	local elementLayoutSnapshots = setmetatable({}, { __mode = "k" })
	local ApplyElementMobileLayout
	local floatToggle = { frame = Instance.new("Frame", screenGui) }
	floatToggle.frame.Name = "FrameToggleUI"
	floatToggle.frame.Size = opts.ToggleSize
	floatToggle.frame.BackgroundColor3 = Color3.fromRGB(18, 12, 6)
	floatToggle.frame.BackgroundTransparency = 0.1
	floatToggle.frame.BorderSizePixel = 0
	floatToggle.frame.AnchorPoint = Vector2.new(0.5, 0.5)
	floatToggle.frame.Position = UDim2.new(0.2, 0, 0.2, 0)
	floatToggle.frame.Visible = false
	floatToggle.frame.ZIndex = 1000
	floatToggle.frame.Active = true
	Instance.new("UICorner", floatToggle.frame).CornerRadius = UDim.new(1, 0)
	local floatToggleStroke = Instance.new("UIStroke", floatToggle.frame)
	floatToggleStroke.Color = Color3.fromRGB(0, 235, 255)
	floatToggleStroke.Thickness = 2
	floatToggleStroke.Transparency = 0
	floatToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local floatToggleGradient = Instance.new("UIGradient", floatToggleStroke)
	floatToggleGradient.Rotation = 90
	floatToggleGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(174, 75, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255)),
	})
	floatToggle.click = Instance.new("ImageButton", floatToggle.frame)
	floatToggle.click.Name = "ClickUI"
	floatToggle.click.Size = UDim2.new(1, -8, 1, -8)
	floatToggle.click.Image = "rbxassetid://12359659240"
	floatToggle.click.AnchorPoint = Vector2.new(0.5, 0.5)
	floatToggle.click.Position = UDim2.new(0.5, 0, 0.5, 0)
	floatToggle.click.BackgroundColor3 = Color3.new(1, 1, 1)
	floatToggle.click.BackgroundTransparency = 1
	floatToggle.click.BorderSizePixel = 0
	floatToggle.click.AutoButtonColor = false
	floatToggle.click.ZIndex = 1001
	floatToggle.click.ImageColor3 = Color3.fromRGB(255, 255, 255)
	floatToggle.click.ScaleType = Enum.ScaleType.Fit
	Instance.new("UICorner", floatToggle.click).CornerRadius = UDim.new(1, 0)
	closeBtn.MouseButton1Click:Connect(function()
		Tween(uiScale, TweenPresets.fast, { Scale = mobile and opts.MobileScale or 0.95 }):Play()
		Tween(shadowImage, TweenPresets.fade, { ImageTransparency = 1 }):Play()
		task.wait(0.35)
		screenGui:Destroy()
	end)
	local function minimizeWindow()
		if minimized then return end
		minimized = true
		Tween(uiScale, TweenPresets.fast, { Scale = responsiveScale * 0.85 }):Play()
		Tween(shadowImage, TweenPresets.fade, { ImageTransparency = 1 }):Play()
		task.wait(0.25)
		shadowImage.Visible = false
		floatToggle.frame.Visible = true
	end
	local function restoreWindow()
		if not minimized then return end
		minimized = false
		floatToggle.frame.Visible = false
		shadowImage.Visible = true
		Tween(uiScale, TweenPresets.pop, { Scale = responsiveScale }):Play()
		Tween(shadowImage, TweenPresets.fade, { ImageTransparency = 0.4 }):Play()
	end
	minimizeBtn.MouseButton1Click:Connect(minimizeWindow)
	maximizeBtn.MouseButton1Click:Connect(function()
		maximized = not maximized
		if ApplyResponsiveSize then ApplyResponsiveSize() end
	end)
	floatToggle.dragged = MakeDraggable(floatToggle.frame, floatToggle.click)
	floatToggle.click.Activated:Connect(function()
		if floatToggle.dragged() then return end
		local spin = Tween(floatToggle.click, TweenInfo.new(0.85, Enum.EasingStyle.Quad), { Rotation = 360 })
		spin:Play()
		spin.Completed:Once(function()
			floatToggle.click.Rotation = 0
		end)
		if minimized then restoreWindow() else minimizeWindow() end
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == opts.MinimizeKey then
			if minimized then restoreWindow() else minimizeWindow() end
		end
	end)
	local horizontalDivider = Instance.new("Frame", windowFrame)
	horizontalDivider.Name = "HDivider"
	horizontalDivider.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	horizontalDivider.BackgroundTransparency = 0.85
	horizontalDivider.BorderSizePixel = 0
	horizontalDivider.Size = UDim2.new(1, 0, 0, 1)
	horizontalDivider.Position = UDim2.new(0, 0, 0, 85)
	local verticalDivider = Instance.new("ImageLabel", windowFrame)
	verticalDivider.Name = "VDivider"
	verticalDivider.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	verticalDivider.ScaleType = Enum.ScaleType.Stretch
	verticalDivider.ImageColor3 = Color3.fromRGB(0, 235, 255)
	verticalDivider.ImageTransparency = 0.85
	verticalDivider.BackgroundTransparency = 1
	verticalDivider.BorderSizePixel = 0
	verticalDivider.Size = UDim2.new(0, 1, 1, 0)
	verticalDivider.Position = UDim2.new(0, 179, 0, 0)
	local tabFrame = Instance.new("Frame", windowFrame)
	tabFrame.Name = "TabFrame"
	tabFrame.BackgroundTransparency = 1
	tabFrame.Size = UDim2.new(0, 179, 1, -87)
	tabFrame.Position = UDim2.new(0, 0, 0, 86)
	local tabScroll = Instance.new("ScrollingFrame", tabFrame)
	tabScroll.Name = "TabScroll"
	tabScroll.BackgroundTransparency = 1
	tabScroll.BorderSizePixel = 0
	tabScroll.Size = UDim2.new(1, -4, 1, -4)
	tabScroll.Position = UDim2.new(0, 0, 0, 0)
	tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabScroll.ScrollBarThickness = 3
	tabScroll.ScrollBarImageTransparency = 0.65
	local tabPadding = Instance.new("UIPadding", tabScroll)
	tabPadding.PaddingTop = UDim.new(0, 8)
	tabPadding.PaddingBottom = UDim.new(0, 8)
	tabPadding.PaddingLeft = UDim.new(0, 8)
	tabPadding.PaddingRight = UDim.new(0, 8)
	local tabListLayout = Instance.new("UIListLayout", tabScroll)
	tabListLayout.Padding = UDim.new(0, 4)
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local contentLayout = Instance.new("Frame", windowFrame)
	contentLayout.Name = "Layout"
	contentLayout.BackgroundTransparency = 1
	contentLayout.Size = UDim2.new(1, -180, 1, -87)
	contentLayout.Position = UDim2.new(0, 180, 0, 86)
	local pageLayoutFrame = Instance.new("Frame", contentLayout)
	pageLayoutFrame.Name = "RealLayout"
	pageLayoutFrame.BackgroundTransparency = 1
	pageLayoutFrame.Size = UDim2.new(1, 0, 1, 0)
	pageLayoutFrame.ClipsDescendants = true
	local pageLayout = Instance.new("UIPageLayout", pageLayoutFrame)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.FillDirection = Enum.FillDirection.Horizontal
	pageLayout.EasingStyle = Enum.EasingStyle.Quint
	pageLayout.EasingDirection = Enum.EasingDirection.Out
	pageLayout.TweenTime = 0.5
	local dropdownZone = Instance.new("CanvasGroup", windowFrame)
	dropdownZone.Name = "DropdownZone"
	dropdownZone.Visible = false
	dropdownZone.GroupTransparency = 1
	dropdownZone.ZIndex = 50
	dropdownZone.BackgroundColor3 = Color3.new(0, 0, 0)
	dropdownZone.BackgroundTransparency = 0.4
	dropdownZone.BorderSizePixel = 0
	dropdownZone.AnchorPoint = Vector2.new(0.5, 0.5)
	dropdownZone.Position = UDim2.new(0.5, 0, 0.5, 0)
	dropdownZone.Size = UDim2.new(1, 0, 1, 0)
	Instance.new("UICorner", dropdownZone).CornerRadius = UDim.new(0, 14)
	local dropdownBackdrop = Instance.new("TextButton", dropdownZone)
	dropdownBackdrop.Name = "Backdrop"
	dropdownBackdrop.AutoButtonColor = false
	dropdownBackdrop.ZIndex = 0
	dropdownBackdrop.BackgroundTransparency = 1
	dropdownBackdrop.Size = UDim2.new(1, 0, 1, 0)
	dropdownBackdrop.Text = ""
	local dropdownPanel = Instance.new("Frame", dropdownZone)
	dropdownPanel.Name = "RealDropdown"
	dropdownPanel.ZIndex = 2
	dropdownPanel.BackgroundColor3 = Colors.bg
	dropdownPanel.BackgroundTransparency = 0.02
	dropdownPanel.BorderSizePixel = 0
	dropdownPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	dropdownPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
	dropdownPanel.Size = UDim2.new(1, -150, 1, -100)
	Instance.new("UICorner", dropdownPanel).CornerRadius = UDim.new(0, 14)
	local dropdownPanelStroke = Instance.new("UIStroke", dropdownPanel)
	dropdownPanelStroke.Color = Color3.fromRGB(0, 235, 255)
	dropdownPanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dropdownPanelGradient = Instance.new("UIGradient", dropdownPanelStroke)
	dropdownPanelGradient.Rotation = 90
	dropdownPanelGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local dropdownHeading = Instance.new("TextLabel", dropdownPanel)
	dropdownHeading.Name = "Heading"
	dropdownHeading.Text = "Dropdown"
	dropdownHeading.TextColor3 = Colors.title
	dropdownHeading.TextTransparency = 0.05
	dropdownHeading.TextSize = 14
	dropdownHeading.Font = Enum.Font.GothamBold
	dropdownHeading.BackgroundTransparency = 1
	dropdownHeading.Size = UDim2.new(1, -150, 0, 20)
	dropdownHeading.Position = UDim2.new(0, 85, 0, 15)
	dropdownHeading.TextXAlignment = Enum.TextXAlignment.Left
	dropdownHeading.Visible = false
	local ddDotRed = Instance.new("Frame", dropdownPanel)
	ddDotRed.BackgroundColor3 = Colors.red
	ddDotRed.BorderSizePixel = 0
	ddDotRed.Size = UDim2.new(0, 12, 0, 12)
	ddDotRed.Position = UDim2.new(0, 18, 0, 20)
	Instance.new("UICorner", ddDotRed).CornerRadius = UDim.new(1, 0)
	local ddDotAmber = Instance.new("Frame", dropdownPanel)
	ddDotAmber.BackgroundColor3 = Colors.amber
	ddDotAmber.BorderSizePixel = 0
	ddDotAmber.Size = UDim2.new(0, 12, 0, 12)
	ddDotAmber.Position = UDim2.new(0, 38, 0, 20)
	Instance.new("UICorner", ddDotAmber).CornerRadius = UDim.new(1, 0)
	local ddDotGreen = Instance.new("Frame", dropdownPanel)
	ddDotGreen.BackgroundColor3 = Colors.green
	ddDotGreen.BorderSizePixel = 0
	ddDotGreen.Size = UDim2.new(0, 12, 0, 12)
	ddDotGreen.Position = UDim2.new(0, 58, 0, 20)
	Instance.new("UICorner", ddDotGreen).CornerRadius = UDim.new(1, 0)
	local dropdownClose = Instance.new("TextButton", dropdownPanel)
	dropdownClose.Name = "CloseDropdown"
	dropdownClose.AutoButtonColor = false
	dropdownClose.BackgroundColor3 = Colors.fg
	dropdownClose.BackgroundTransparency = 0.93
	dropdownClose.BorderSizePixel = 0
	dropdownClose.Text = ""
	dropdownClose.Size = UDim2.new(0, 26, 0, 26)
	dropdownClose.Position = UDim2.new(1, -36, 0, 12)
	Instance.new("UICorner", dropdownClose).CornerRadius = UDim.new(0, 7)
	local dropdownCloseStroke = Instance.new("UIStroke", dropdownClose)
	dropdownCloseStroke.Color = Color3.fromRGB(0, 235, 255)
	dropdownCloseStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dropdownCloseGradient = Instance.new("UIGradient", dropdownCloseStroke)
	dropdownCloseGradient.Rotation = 90
	dropdownCloseGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local dropdownCloseCross = Instance.new("Frame", dropdownClose)
	dropdownCloseCross.BackgroundTransparency = 1
	dropdownCloseCross.AnchorPoint = Vector2.new(0.5, 0.5)
	dropdownCloseCross.Size = UDim2.new(0, 11, 0, 11)
	dropdownCloseCross.Position = UDim2.new(0.5, 0, 0.5, 0)
	local ddCrossBar1 = Instance.new("Frame", dropdownCloseCross)
	ddCrossBar1.BackgroundColor3 = Color3.fromRGB(255, 200, 130)
	ddCrossBar1.BackgroundTransparency = 0.25
	ddCrossBar1.BorderSizePixel = 0
	ddCrossBar1.AnchorPoint = Vector2.new(0.5, 0.5)
	ddCrossBar1.Size = UDim2.new(0, 11, 0, 1)
	ddCrossBar1.Position = UDim2.new(0.5, 0, 0.5, 0)
	ddCrossBar1.Rotation = 45
	Instance.new("UICorner", ddCrossBar1).CornerRadius = UDim.new(1, 0)
	local ddCrossBar2 = ddCrossBar1:Clone()
	ddCrossBar2.Parent = dropdownCloseCross
	ddCrossBar2.Rotation = -45
	local dropdownSearch = Instance.new("TextBox", dropdownPanel)
	dropdownSearch.Name = "DropdownSearch"
	dropdownSearch.ZIndex = 3
	dropdownSearch.ClearTextOnFocus = false
	dropdownSearch.PlaceholderText = "Search options..."
	dropdownSearch.Text = ""
	dropdownSearch.TextColor3 = Colors.title
	dropdownSearch.PlaceholderColor3 = Colors.desc
	dropdownSearch.TextSize = 12
	dropdownSearch.Font = Enum.Font.Gotham
	dropdownSearch.TextXAlignment = Enum.TextXAlignment.Left
	dropdownSearch.BackgroundColor3 = Colors.fg
	dropdownSearch.BackgroundTransparency = 0.93
	dropdownSearch.BorderSizePixel = 0
	dropdownSearch.Size = UDim2.new(1, -145, 0, 30)
	dropdownSearch.Position = UDim2.new(0, 85, 0, 12)
	Instance.new("UICorner", dropdownSearch).CornerRadius = UDim.new(0, 7)
	local dropdownSearchPadding = Instance.new("UIPadding", dropdownSearch)
	dropdownSearchPadding.PaddingLeft = UDim.new(0, 10)
	dropdownSearchPadding.PaddingRight = UDim.new(0, 10)
	local dropdownSearchStroke = Instance.new("UIStroke", dropdownSearch)
	dropdownSearchStroke.Color = Color3.fromRGB(0, 235, 255)
	dropdownSearchStroke.Transparency = 0.45
	dropdownSearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dropdownList = Instance.new("ScrollingFrame", dropdownPanel)
	dropdownList.Name = "ListDropdown"
	dropdownList.BackgroundColor3 = Colors.fg
	dropdownList.BackgroundTransparency = 0.96
	dropdownList.BorderSizePixel = 0
	dropdownList.Size = UDim2.new(1, -40, 1, -78)
	dropdownList.Position = UDim2.new(0, 20, 0, 58)
	dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
	dropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	dropdownList.ScrollBarThickness = 3
	dropdownList.ScrollBarImageTransparency = 0.6
	dropdownList.ScrollingDirection = Enum.ScrollingDirection.Y
	dropdownList.Selectable = false
	Instance.new("UICorner", dropdownList).CornerRadius = UDim.new(0, 10)
	local dropdownListStroke = Instance.new("UIStroke", dropdownList)
	dropdownListStroke.Color = Color3.fromRGB(0, 235, 255)
	dropdownListStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dropdownListGradient = Instance.new("UIGradient", dropdownListStroke)
	dropdownListGradient.Rotation = 90
	dropdownListGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.72), NumberSequenceKeypoint.new(1, 0.92) })
	local dropdownListPadding = Instance.new("UIPadding", dropdownList)
	dropdownListPadding.PaddingTop = UDim.new(0, 8)
	dropdownListPadding.PaddingRight = UDim.new(0, 8)
	dropdownListPadding.PaddingLeft = UDim.new(0, 8)
	dropdownListPadding.PaddingBottom = UDim.new(0, 8)
	local dropdownListLayout = Instance.new("UIListLayout", dropdownList)
	dropdownListLayout.Padding = UDim.new(0, 5)
	dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	local dropdownTemplate = Instance.new("TextButton", dropdownList)
	dropdownTemplate.Name = "Template"
	dropdownTemplate.Visible = false
	dropdownTemplate.LayoutOrder = 9999
	dropdownTemplate.AutoButtonColor = false
	dropdownTemplate.BackgroundColor3 = Colors.fg
	dropdownTemplate.BackgroundTransparency = 0.95
	dropdownTemplate.BorderSizePixel = 0
	dropdownTemplate.Size = UDim2.new(1, 0, 0, 34)
	dropdownTemplate.Text = "Option 1"
	dropdownTemplate.TextXAlignment = Enum.TextXAlignment.Left
	dropdownTemplate.TextColor3 = Colors.title
	dropdownTemplate.TextTransparency = 0.15
	dropdownTemplate.TextSize = 13
	dropdownTemplate.Font = Enum.Font.GothamMedium
	Instance.new("UICorner", dropdownTemplate)
	local dropdownTemplateStroke = Instance.new("UIStroke", dropdownTemplate)
	dropdownTemplateStroke.Color = Color3.fromRGB(0, 235, 255)
	dropdownTemplateStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local dropdownTemplateGradient = Instance.new("UIGradient", dropdownTemplateStroke)
	dropdownTemplateGradient.Rotation = 90
	dropdownTemplateGradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.85) })
	local dropdownTemplatePadding = Instance.new("UIPadding", dropdownTemplate)
	dropdownTemplatePadding.PaddingLeft = UDim.new(0, 12)
	dropdownTemplatePadding.PaddingRight = UDim.new(0, 12)
	local templateTick = Instance.new("Frame", dropdownTemplate)
	templateTick.Name = "Tick"
	templateTick.Visible = false
	templateTick.BackgroundTransparency = 1
	templateTick.AnchorPoint = Vector2.new(1, 0.5)
	templateTick.Size = UDim2.new(0, 12, 0, 10)
	templateTick.Position = UDim2.new(1, 0, 0.5, 0)
	local tickShort = Instance.new("Frame", templateTick)
	tickShort.Name = "Short"
	tickShort.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	tickShort.BackgroundTransparency = 0.05
	tickShort.BorderSizePixel = 0
	tickShort.AnchorPoint = Vector2.new(0.5, 0.5)
	tickShort.Size = UDim2.new(0, 6, 0, 1)
	tickShort.Position = UDim2.new(0, 3, 0, 7)
	tickShort.Rotation = 45
	Instance.new("UICorner", tickShort).CornerRadius = UDim.new(1, 0)
	local tickLong = Instance.new("Frame", templateTick)
	tickLong.Name = "Long"
	tickLong.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	tickLong.BackgroundTransparency = 0.05
	tickLong.BorderSizePixel = 0
	tickLong.AnchorPoint = Vector2.new(0.5, 0.5)
	tickLong.Size = UDim2.new(0, 11, 0, 1)
	tickLong.Position = UDim2.new(0, 7, 0, 4)
	tickLong.Rotation = -45
	Instance.new("UICorner", tickLong).CornerRadius = UDim.new(1, 0)
	Instance.new("UIScale", dropdownPanel)
	local activeDropdownSearchRefresh = nil

dropdownSearch:GetPropertyChangedSignal("Text"):Connect(function()
	if activeDropdownSearchRefresh then
		activeDropdownSearchRefresh()
	end
end)

local function closeDropdownPanel()
		dropdownZone.Visible = false
		activeDropdownSearchRefresh = nil
		Tween(dropdownZone, TweenPresets.fade, { GroupTransparency = 1 }):Play()
		Tween(dropdownPanel:FindFirstChildOfClass("UIScale"), TweenPresets.pop, { Scale = 0.95 }):Play()
	end
	dropdownClose.MouseButton1Click:Connect(closeDropdownPanel)
	dropdownBackdrop.MouseButton1Click:Connect(closeDropdownPanel)
	local dynamicIsland = Instance.new("TextButton", screenGui)
	dynamicIsland.Name = "DynamicIsland"
	dynamicIsland.AutoButtonColor = false
	dynamicIsland.BackgroundColor3 = Colors.island
	dynamicIsland.BorderSizePixel = 0
	dynamicIsland.ZIndex = 500
	dynamicIsland.AnchorPoint = Vector2.new(0.5, 0)
	dynamicIsland.Size = opts.IslandDefaultSize
	dynamicIsland.Position = UDim2.new(0.5, 0, 0, 10)
	dynamicIsland.ClipsDescendants = false
	dynamicIsland.Text = ""
	dynamicIsland.Visible = opts.IslandEnabled
	Instance.new("UICorner", dynamicIsland).CornerRadius = UDim.new(0, 14)
	local islandStroke = Instance.new("UIStroke", dynamicIsland)
	islandStroke.Color = Color3.fromRGB(0, 235, 255)
	islandStroke.Thickness = 1
	islandStroke.Transparency = 0.5
	local islandCompact = Instance.new("CanvasGroup", dynamicIsland)
	islandCompact.Name = "Compact"
	islandCompact.ZIndex = 2
	islandCompact.Size = UDim2.new(1, 0, 1, 0)
	islandCompact.BackgroundTransparency = 1
	local compactLayout = Instance.new("UIListLayout", islandCompact)
	compactLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	compactLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	compactLayout.Padding = UDim.new(0, 6)
	compactLayout.SortOrder = Enum.SortOrder.LayoutOrder
	compactLayout.FillDirection = Enum.FillDirection.Horizontal
	local compactGlyph = Instance.new("Frame", islandCompact)
	compactGlyph.Name = "Glyph"
	compactGlyph.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	compactGlyph.BorderSizePixel = 0
	compactGlyph.Size = UDim2.new(0, 8, 0, 8)
	compactGlyph.LayoutOrder = 1
	compactGlyph.Visible = true
	Instance.new("UICorner", compactGlyph).CornerRadius = UDim.new(1, 0)
	local compactLabel = Instance.new("TextLabel", islandCompact)
	compactLabel.Name = "Label"
	compactLabel.TextSize = 11
	compactLabel.Font = Enum.Font.GothamBold
	compactLabel.TextColor3 = Colors.title
	compactLabel.BackgroundTransparency = 1
	compactLabel.Size = UDim2.new(0, 0, 0, 14)
	compactLabel.Text = ""
	compactLabel.LayoutOrder = 2
	compactLabel.TextXAlignment = Enum.TextXAlignment.Left
	compactLabel.AutomaticSize = Enum.AutomaticSize.X
	local compactStatus = Instance.new("TextLabel", islandCompact)
	compactStatus.Name = "Status"
	compactStatus.TextSize = 11
	compactStatus.Font = Enum.Font.GothamBold
	compactStatus.TextColor3 = Colors.green
	compactStatus.BackgroundTransparency = 1
	compactStatus.Size = UDim2.new(0, 0, 0, 14)
	compactStatus.Text = ""
	compactStatus.LayoutOrder = 3
	compactStatus.TextXAlignment = Enum.TextXAlignment.Left
	compactStatus.AutomaticSize = Enum.AutomaticSize.X
	compactStatus.Visible = false
	local compactWave = Instance.new("Frame", islandCompact)
	compactWave.Name = "MiniWave"
	compactWave.BackgroundTransparency = 1
	compactWave.Size = UDim2.new(0, 24, 0, 10)
	compactWave.LayoutOrder = 4
	compactWave.Visible = true
	local compactWaveLayout = Instance.new("UIListLayout", compactWave)
	compactWaveLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	compactWaveLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	compactWaveLayout.Padding = UDim.new(0, 2)
	compactWaveLayout.SortOrder = Enum.SortOrder.LayoutOrder
	compactWaveLayout.FillDirection = Enum.FillDirection.Horizontal
	local compactWaveBars = {}
	for i = 1, 4 do
		local bar = Instance.new("Frame", compactWave)
		bar.Name = "B" .. i
		bar.BackgroundColor3 = Colors.green
		bar.BorderSizePixel = 0
		bar.Size = UDim2.new(0, 2, 0, math.random(3, 8))
		bar.LayoutOrder = i
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
		table.insert(compactWaveBars, bar)
	end
	local islandExpanded = Instance.new("CanvasGroup", dynamicIsland)
	islandExpanded.Name = "Expanded"
	islandExpanded.Visible = false
	islandExpanded.GroupTransparency = 1
	islandExpanded.ZIndex = 3
	islandExpanded.Size = UDim2.new(1, 0, 1, 0)
	islandExpanded.BackgroundTransparency = 1
	local expandedThumb = Instance.new("Frame", islandExpanded)
	expandedThumb.Name = "Thumb"
	expandedThumb.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
	expandedThumb.BorderSizePixel = 0
	expandedThumb.ClipsDescendants = true
	expandedThumb.Size = UDim2.new(0, 50, 0, 50)
	expandedThumb.Position = UDim2.new(0, 16, 0, 16)
	Instance.new("UICorner", expandedThumb).CornerRadius = UDim.new(0, 12)
	local expandedThumbGradient = Instance.new("UIGradient", expandedThumb)
	expandedThumbGradient.Rotation = 55
	expandedThumbGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 235, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(174, 75, 255)),
	})
	local expandedIcon = Instance.new("ImageLabel", expandedThumb)
	expandedIcon.Name = "Img"
	expandedIcon.ZIndex = 2
	expandedIcon.ScaleType = Enum.ScaleType.Crop
	expandedIcon.ImageTransparency = 0
	expandedIcon.AnchorPoint = Vector2.new(0, 0)
	expandedIcon.Size = UDim2.new(1, 0, 1, 0)
	expandedIcon.Position = UDim2.new(0, 0, 0, 0)
	expandedIcon.BackgroundTransparency = 1
	expandedIcon.Visible = false
	Instance.new("UICorner", expandedIcon).CornerRadius = UDim.new(0, 12)
	
	local function setIslandIcon(image)
		if type(image) == "number" then
			image = "rbxassetid://" .. tostring(image)
		elseif type(image) ~= "string" then
			return false
		end
		if image ~= "" and string.match(image, "^%d+$") then
			image = "rbxassetid://" .. image
		end
		opts.IslandIcon = image
		expandedIcon.Image = image
		local hasImage = image ~= ""
		expandedIcon.Visible = hasImage
		expandedThumb.BackgroundTransparency = hasImage and 1 or 0
		expandedThumbGradient.Transparency = NumberSequence.new(hasImage and 1 or 0)
		return true
	end
	
	setIslandIcon(opts.IslandIcon)
	local expandedTimer = Instance.new("TextLabel", islandExpanded)
	expandedTimer.Name = "Mono"
	expandedTimer.Text = "00:00"
	expandedTimer.TextColor3 = Colors.fg
	expandedTimer.TextSize = 10
	expandedTimer.Font = Enum.Font.Code
	expandedTimer.BackgroundTransparency = 1
	expandedTimer.Size = UDim2.new(0, 50, 0, 14)
	expandedTimer.Position = UDim2.new(0, 78, 0, 18)
	local expandedMark = Instance.new("TextLabel", islandExpanded)
	expandedMark.Name = "Mark"
	expandedMark.Text = "● READY"
	expandedMark.TextColor3 = Colors.red
	expandedMark.TextSize = 9
	expandedMark.Font = Enum.Font.GothamBold
	expandedMark.BackgroundTransparency = 1
	expandedMark.Size = UDim2.new(0, 50, 0, 12)
	expandedMark.Position = UDim2.new(0, 78, 0, 32)
	local expandedTitle = Instance.new("TextLabel", islandExpanded)
	expandedTitle.Name = "Title"
	expandedTitle.Text = "DN Hub"
	expandedTitle.TextColor3 = Colors.title
	expandedTitle.TextTransparency = 0.05
	expandedTitle.TextSize = 12
	expandedTitle.Font = Enum.Font.GothamBold
	expandedTitle.BackgroundTransparency = 1
	expandedTitle.Size = UDim2.new(0, 180, 0, 14)
	expandedTitle.Position = UDim2.new(0, 78, 0, 50)
	expandedTitle.TextXAlignment = Enum.TextXAlignment.Left
	local expandedSub = Instance.new("TextLabel", islandExpanded)
	expandedSub.Name = "Sub"
	expandedSub.Text = "Tap to view active tasks"
	expandedSub.TextColor3 = Colors.desc
	expandedSub.TextTransparency = 0.25
	expandedSub.TextSize = 10
	expandedSub.Font = Enum.Font.GothamMedium
	expandedSub.BackgroundTransparency = 1
	expandedSub.Size = UDim2.new(0, 180, 0, 12)
	expandedSub.Position = UDim2.new(0, 78, 0, 63)
	expandedSub.TextXAlignment = Enum.TextXAlignment.Left
	local expandedWave = Instance.new("Frame", islandExpanded)
	expandedWave.Name = "Wave"
	expandedWave.BackgroundTransparency = 1
	expandedWave.Size = UDim2.new(0, 50, 0, 22)
	expandedWave.Position = UDim2.new(1, -60, 0, 38)
	local expandedWaveLayout = Instance.new("UIListLayout", expandedWave)
	expandedWaveLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	expandedWaveLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	expandedWaveLayout.Padding = UDim.new(0, 4)
	expandedWaveLayout.SortOrder = Enum.SortOrder.LayoutOrder
	expandedWaveLayout.FillDirection = Enum.FillDirection.Horizontal
	local expandedWaveBars = {}
	for i = 1, 5 do
		local bar = Instance.new("Frame", expandedWave)
		bar.Name = "B" .. i
		bar.BackgroundColor3 = Colors.green
		bar.BorderSizePixel = 0
		bar.Size = UDim2.new(0, 3, 0, math.random(8, 18))
		bar.LayoutOrder = i
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
		table.insert(expandedWaveBars, bar)
	end
	local islandStartTime = os.clock()
	local islandExpandedState = false
	local islandAnimating = false
	local currentTitle = ""
	local currentSub = ""
	local function expandIsland()
		if islandAnimating then return end
		islandExpandedState = true
		islandAnimating = true
		islandExpanded.Visible = true
		Tween(dynamicIsland, TweenPresets.island, { Size = opts.IslandExpandedSize }):Play()
		Tween(islandStroke, TweenPresets.island, { Transparency = 0.3 }):Play()
		Tween(islandCompact, TweenPresets.fade, { GroupTransparency = 1 }):Play()
		task.spawn(function()
			task.wait(0.35)
			Tween(islandExpanded, TweenPresets.fade, { GroupTransparency = 0 }):Play()
			task.wait(0.4)
			islandAnimating = false
		end)
	end
	local function collapseIsland()
		if islandAnimating then return end
		islandExpandedState = false
		islandAnimating = true
		Tween(islandExpanded, TweenPresets.fade, { GroupTransparency = 1 }):Play()
		task.spawn(function()
			task.wait(0.3)
			islandExpanded.Visible = false
			Tween(dynamicIsland, TweenPresets.island, { Size = opts.IslandDefaultSize }):Play()
			Tween(islandStroke, TweenPresets.island, { Transparency = 0.5 }):Play()
			Tween(islandCompact, TweenPresets.fade, { GroupTransparency = 0 }):Play()
			task.wait(0.4)
			islandAnimating = false
		end)
	end
	local islandDragged = false
	local islandPressPosition = nil
	local islandStartPosition = nil
	dynamicIsland.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			islandDragged = false
			islandPressPosition = input.Position
			islandStartPosition = dynamicIsland.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if islandPressPosition and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - islandPressPosition
			if delta.Magnitude > 6 then
				islandDragged = true
			end
			if islandDragged then
				dynamicIsland.Position = UDim2.new(
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
	dynamicIsland.MouseButton1Click:Connect(function()
		if islandDragged then return end
		if islandExpandedState then collapseIsland() else expandIsland() end
	end)
	task.spawn(function()
		while task.wait(0.3) do
			for _, bar in ipairs(expandedWaveBars) do
				Tween(bar, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 3, 0, math.random(8, 18)) }):Play()
			end
		end
	end)
	task.spawn(function()
		while task.wait(0.25) do
			for _, bar in ipairs(compactWaveBars) do
				Tween(bar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 2, 0, math.random(3, 8)) }):Play()
			end
		end
	end)
	task.spawn(function()
		while dynamicIsland.Parent do
			local cyan = Color3.fromRGB(0, 235, 255)
			local purple = Color3.fromRGB(174, 75, 255)
			local blend = (math.sin(os.clock() * 1.4) + 1) * 0.5
			local glow = cyan:Lerp(purple, blend)
			Tween(islandStroke, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Color = glow, Transparency = 0.18 }):Play()
			for i, bar in ipairs(expandedWaveBars) do
				bar.BackgroundColor3 = i % 2 == 0 and purple or cyan
			end
			compactGlyph.BackgroundColor3 = glow
			task.wait(0.12)
		end
	end)
	task.spawn(function()
		while dynamicIsland.Parent do
			local elapsed = math.max(0, math.floor(os.clock() - islandStartTime))
			expandedTimer.Text = string.format("%02d:%02d", math.floor(elapsed / 60), elapsed % 60)
			task.wait(1)
		end
	end)
	local titleDragging = false
	local titleStartPosition = nil
	local titleStartInput = nil
	titleArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			titleDragging = true
			titleStartInput = input.Position
			titleStartPosition = shadowImage.Position
		end
	end)
	titleArea.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			titleDragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if titleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - titleStartInput
			shadowImage.Position = UDim2.new(titleStartPosition.X.Scale, titleStartPosition.X.Offset + delta.X, titleStartPosition.Y.Scale, titleStartPosition.Y.Offset + delta.Y)
		end
	end)
	ApplyResponsiveSize = function()
		local viewport = GetViewportSize()
		local isSmall = viewport.X < 900 or viewport.Y < 600
		local baseSize = mobile and opts.MobileSize or opts.Size
		local baseWidth = baseSize.X.Scale * viewport.X + baseSize.X.Offset
		local baseHeight = baseSize.Y.Scale * viewport.Y + baseSize.Y.Offset
		local safeWidth = math.max(viewport.X - 24, 1)
		local safeHeight = math.max(viewport.Y - 24, 1)
		local fitScale = math.min(safeWidth / math.max(baseWidth, 1), safeHeight / math.max(baseHeight, 1))
		local preferredScale = mobile and opts.MobileScale or 0.95
		if maximized then
			responsiveScale = math.clamp(fitScale, 0.35, 3.5)
		else
			responsiveScale = math.clamp(math.min(fitScale, 1) * preferredScale, 0.35, math.max(preferredScale, 0.35))
		end
		shadowImage.Size = baseSize
		uiScale.Scale = responsiveScale
		if mobile or isSmall then
			windowFrame.Size = UDim2.new(1, -20, 1, -20)
			headerRight.Position = UDim2.new(0, 86, 0, 0)
			headerRight.Size = UDim2.new(1, -86, 0, 62)
			horizontalDivider.Position = UDim2.new(0, 0, 0, 62)
			tabFrame.Position = UDim2.new(0, 0, 0, 63)
			tabFrame.Size = UDim2.new(0, 86, 1, -63)
			contentLayout.Position = UDim2.new(0, 86, 0, 63)
			contentLayout.Size = UDim2.new(1, -86, 1, -63)
			verticalDivider.Position = UDim2.new(0, 85, 0, 0)
			dotRed.Size = UDim2.new(0, 9, 0, 9)
			dotRed.Position = UDim2.new(0, 10, 0, 14)
			dotAmber.Size = UDim2.new(0, 9, 0, 9)
			dotAmber.Position = UDim2.new(0, 25, 0, 14)
			dotGreen.Size = UDim2.new(0, 9, 0, 9)
			dotGreen.Position = UDim2.new(0, 40, 0, 14)
			titleLabel.TextSize = 11
			titleLabel.Size = UDim2.new(1, -12, 0, 14)
			titleLabel.Position = UDim2.new(0, 10, 0, 34)
			subTitleLabel.TextSize = 9
			subTitleLabel.Size = UDim2.new(1, -12, 0, 12)
			subTitleLabel.Position = UDim2.new(0, 10, 0, 48)
			gameBadge.Size = UDim2.new(0, 64, 0, 20)
			gameBadge.Position = UDim2.new(0, 10, 0.28, 0)
			gameText.TextSize = 9
			versionBadge.Size = UDim2.new(0, 64, 0, 20)
			versionBadge.Position = UDim2.new(0, 10, 0.72, 0)
			versionText.TextSize = 9
			controlsFrame.Size = UDim2.new(0, 96, 0, 34)
			controlsFrame.Position = UDim2.new(1, -100, 0.5, 0)
			controlsLayout.Padding = UDim.new(0, 5)
			minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
			maximizeBtn.Size = UDim2.new(0, 24, 0, 24)
			closeBtn.Size = UDim2.new(0, 24, 0, 24)
			tabScroll.ScrollBarThickness = 2
			tabPadding.PaddingTop = UDim.new(0, 6)
			tabPadding.PaddingBottom = UDim.new(0, 6)
			tabPadding.PaddingLeft = UDim.new(0, 5)
			tabPadding.PaddingRight = UDim.new(0, 5)
			tabListLayout.Padding = UDim.new(0, 3)
			dropdownPanel.Size = UDim2.new(1, -20, 1, -30)
			dropdownHeading.TextSize = 12
			dropdownHeading.Size = UDim2.new(1, -90, 0, 16)
			dropdownHeading.Position = UDim2.new(0, 62, 0, 12)
			ddDotRed.Size = UDim2.new(0, 9, 0, 9)
			ddDotRed.Position = UDim2.new(0, 12, 0, 15)
			ddDotAmber.Size = UDim2.new(0, 9, 0, 9)
			ddDotAmber.Position = UDim2.new(0, 27, 0, 15)
			ddDotGreen.Size = UDim2.new(0, 9, 0, 9)
			ddDotGreen.Position = UDim2.new(0, 42, 0, 15)
			dropdownClose.Size = UDim2.new(0, 24, 0, 24)
			dropdownClose.Position = UDim2.new(1, -30, 0, 10)
			dropdownList.Size = UDim2.new(1, -20, 1, -56)
			dropdownList.Position = UDim2.new(0, 10, 0, 42)
			dropdownTemplate.Size = UDim2.new(1, 0, 0, 32)
			dropdownTemplate.TextSize = 12
		else
			windowFrame.Size = UDim2.new(1, -120, 1, -120)
			headerRight.Size = UDim2.new(1, -183, 0, 85)
			headerRight.Position = UDim2.new(0, 180, 0, 0)
			tabFrame.Size = UDim2.new(0, 179, 1, -87)
			tabFrame.Position = UDim2.new(0, 0, 0, 86)
			contentLayout.Size = UDim2.new(1, -180, 1, -87)
			contentLayout.Position = UDim2.new(0, 180, 0, 86)
			verticalDivider.Position = UDim2.new(0, 179, 0, 0)
			horizontalDivider.Position = UDim2.new(0, 0, 0, 85)
			titleLabel.TextSize = 14
			titleLabel.Size = UDim2.new(1, -20, 0, 18)
			titleLabel.Position = UDim2.new(0, 18, 0, 48)
			subTitleLabel.TextSize = 11
			subTitleLabel.Size = UDim2.new(1, -20, 0, 14)
			subTitleLabel.Position = UDim2.new(0, 18, 0, 66)
			dotRed.Size = UDim2.new(0, 12, 0, 12)
			dotRed.Position = UDim2.new(0, 18, 0, 20)
			dotAmber.Size = UDim2.new(0, 12, 0, 12)
			dotAmber.Position = UDim2.new(0, 38, 0, 20)
			dotGreen.Size = UDim2.new(0, 12, 0, 12)
			dotGreen.Position = UDim2.new(0, 58, 0, 20)
			gameBadge.AutomaticSize = Enum.AutomaticSize.X
			gameBadge.Size = UDim2.new(0, 0, 0, 25)
			gameBadge.Position = UDim2.new(0, 20, 0.25, 0)
			gameText.TextSize = 10
			versionBadge.AutomaticSize = Enum.AutomaticSize.X
			versionBadge.Size = UDim2.new(0, 0, 0, 25)
			versionBadge.Position = UDim2.new(0, 20, 0.65, 0)
			versionText.TextSize = 10
			controlsFrame.Size = UDim2.new(0, 190, 0, 45)
			controlsFrame.Position = UDim2.new(1, -200, 0.5, 0)
			controlsLayout.Padding = UDim.new(0, 8)
			minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
			maximizeBtn.Size = UDim2.new(0, 26, 0, 26)
			closeBtn.Size = UDim2.new(0, 26, 0, 26)
			tabScroll.ScrollBarThickness = 3
			tabPadding.PaddingTop = UDim.new(0, 8)
			tabPadding.PaddingBottom = UDim.new(0, 8)
			tabPadding.PaddingLeft = UDim.new(0, 8)
			tabPadding.PaddingRight = UDim.new(0, 8)
			tabListLayout.Padding = UDim.new(0, 4)
			dropdownPanel.Size = UDim2.new(1, -150, 1, -100)
			dropdownHeading.TextSize = 14
			dropdownHeading.Size = UDim2.new(1, -150, 0, 20)
			dropdownHeading.Position = UDim2.new(0, 85, 0, 15)
			ddDotRed.Size = UDim2.new(0, 12, 0, 12)
			ddDotRed.Position = UDim2.new(0, 18, 0, 20)
			ddDotAmber.Size = UDim2.new(0, 12, 0, 12)
			ddDotAmber.Position = UDim2.new(0, 38, 0, 20)
			ddDotGreen.Size = UDim2.new(0, 12, 0, 12)
			ddDotGreen.Position = UDim2.new(0, 58, 0, 20)
			dropdownClose.Size = UDim2.new(0, 26, 0, 26)
			dropdownClose.Position = UDim2.new(1, -36, 0, 12)
			dropdownList.Size = UDim2.new(1, -40, 1, -70)
			dropdownList.Position = UDim2.new(0, 20, 0, 50)
			dropdownTemplate.Size = UDim2.new(1, 0, 0, 34)
			dropdownTemplate.TextSize = 13
		end
		if maximized then
			windowFrame.Size = UDim2.new(1, -20, 1, -20)
		end
		for index = #responsiveElements, 1, -1 do
			local element = responsiveElements[index]
			if element.Parent then
				ApplyElementMobileLayout(element)
			else
				table.remove(responsiveElements, index)
			end
		end
	end
	ApplyElementMobileLayout = function(element)
		if not elementLayoutSnapshots[element] then
			local snapshot = { Objects = {} }
			local function capture(object)
				local props = {}
				if object:IsA("GuiObject") then
					props.Size = object.Size
					props.Position = object.Position
					props.AnchorPoint = object.AnchorPoint
				end
				if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
					props.TextSize = object.TextSize
				end
				snapshot.Objects[object] = props
			end
			capture(element)
			for _, object in ipairs(element:GetDescendants()) do capture(object) end
			elementLayoutSnapshots[element] = snapshot
			table.insert(responsiveElements, element)
		end
		local compact = mobile or GetViewportSize().X < 900 or GetViewportSize().Y < 600
		local snapshot = elementLayoutSnapshots[element]
		if not compact then
			for object, props in pairs(snapshot.Objects) do
				if object.Parent then
					if props.Size then object.Size = props.Size end
					if props.Position then object.Position = props.Position end
					if props.AnchorPoint then object.AnchorPoint = props.AnchorPoint end
					if props.TextSize then object.TextSize = props.TextSize end
				end
			end
			return
		end
		local function layoutTextBlock(frame, hasDesc)
			if not frame then return end
			frame.Position = UDim2.new(0, 10, 0.5, 0)
			frame.Size = UDim2.new(1, -100, 0, hasDesc and 36 or 24)
			local title = frame:FindFirstChild("Title")
			if title then
				title.TextSize = 11
				title.Size = UDim2.new(1, 0, 0, 12)
			end
			local desc = frame:FindFirstChild("Desc")
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
						track.AnchorPoint = Vector2.new(1, 0.5)
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
		elseif element.Name == "Dropdown" or element.Name == "Textbox" or element.Name == "MultiDropdown" then
			local tb = element:FindFirstChild("TextBlock")
			local hasDesc = tb and tb:FindFirstChild("Desc") ~= nil
			if tb then
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
			element.Size = UDim2.new(1, 0, 0, hasDesc and 80 or 66)
			local field = element:FindFirstChild("Field")
			if field then
				field.Size = UDim2.new(1, -20, 0, 28)
				field.Position = UDim2.new(0, 10, 1, -6)
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
	ApplyResponsiveSize()
	local viewportConn
	viewportConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if opts.AutoScale then
			ApplyResponsiveSize()
		end
	end)
	screenGui.AncestryChanged:Connect(function()
		if not screenGui.Parent then
			if viewportConn then viewportConn:Disconnect() end
		end
	end)
	screenGui.Parent = opts.Parent
	Tween(uiScale, TweenPresets.spring, { Scale = responsiveScale }):Play()
	Tween(shadowImage, TweenPresets.soft, { ImageTransparency = 0.4 }):Play()
	return {
		_gui = screenGui,
		_window = windowFrame,
		_pageLayout = pageLayout,
		_tabScroll = tabScroll,
		_tabList = tabListLayout,
		_tabs = {},
		_dropZone = dropdownZone,
		_realDrop = dropdownPanel,
		_listDrop = dropdownList,
		_dropTmpl = dropdownTemplate,
		_dropHeading = dropdownHeading,
		_island = dynamicIsland,
		_islandTitle = expandedTitle,
		_islandSub = expandedSub,
		_islandMono = expandedTimer,
		_islandMark = expandedMark,
		_mobileToggle = floatToggle.frame,
		_clickUI = floatToggle.click,
		ApplyResponsive = ApplyResponsiveSize,
		ToggleUI = function()
			if minimized then restoreWindow() else minimizeWindow() end
		end,
		SetIslandIcon = function(_, image)
			return setIslandIcon(image)
		end,
		SetIslandEnabled = function(_, enabled)
			opts.IslandEnabled = enabled
			dynamicIsland.Visible = enabled
		end,
		GetIslandEnabled = function()
			return opts.IslandEnabled
		end,
		SetIslandDefaultSize = function(_, size)
			if typeof(size) == "UDim2" then
				opts.IslandDefaultSize = size
				if not islandExpandedState then
					dynamicIsland.Size = size
				end
			end
		end,
		SetIslandExpandedSize = function(_, size)
			if typeof(size) == "UDim2" then
				opts.IslandExpandedSize = size
				if islandExpandedState then
					dynamicIsland.Size = size
				end
			end
		end,
		SetToggleSize = function(_, size)
			if typeof(size) == "UDim2" then
				opts.ToggleSize = size
				floatToggle.frame.Size = size
			end
		end,
		GetIslandPosition = function()
			return dynamicIsland.Position
		end,
		SetIslandPosition = function(_, pos)
			if typeof(pos) == "UDim2" then
				dynamicIsland.Position = pos
			end
		end,
		SetTask = function(_, taskTable)
			local t = MergeTable({ Current = "", Previous = "" }, taskTable)
			currentTitle = t.Current
			currentSub = t.Previous
			expandedTitle.Text = currentTitle ~= "" and currentTitle or "DN Hub"
			expandedSub.Text = currentSub ~= "" and currentSub or "No previous task"
		end,
		SetIslandText = function(_, textTable)
			local t = MergeTable({ Title = "", Status = nil }, textTable)
			if islandExpandedState then
				collapseIsland()
				task.wait(0.7)
			end
			if t.Title ~= "" or t.Status then
				compactGlyph.Visible = false
				compactWave.Visible = false
				compactLabel.Text = t.Title
				if t.Status then
					compactStatus.Visible = true
					compactStatus.Text = t.Status
					if t.Status == "ON" then
						compactStatus.TextColor3 = Colors.green
					elseif t.Status == "OFF" then
						compactStatus.TextColor3 = Colors.red
					else
						compactStatus.TextColor3 = Colors.title
					end
				else
					compactStatus.Visible = false
				end
				task.wait(0.05)
				local defaultSize = opts.IslandDefaultSize
				Tween(dynamicIsland, TweenPresets.pop, {
					Size = UDim2.new(0, math.max(defaultSize.X.Offset, compactLabel.TextBounds.X + (t.Status and compactStatus.TextBounds.X + 8 or 0) + 44), 0, defaultSize.Y.Offset),
				}):Play()
			else
				compactLabel.Text = ""
				compactStatus.Visible = false
				compactGlyph.Visible = true
				compactWave.Visible = true
				Tween(dynamicIsland, TweenPresets.pop, { Size = opts.IslandDefaultSize }):Play()
			end
		end,
		Notify = function(_, notifyTable)
			local t = MergeTable({ Title = "Notification", Description = "", Status = nil, Duration = 3 }, notifyTable)
			Tween(compactGlyph, TweenPresets.fade, { BackgroundTransparency = 1 }):Play()
			for _, bar in ipairs(compactWaveBars) do
				Tween(bar, TweenPresets.fade, { BackgroundTransparency = 1 }):Play()
			end
			compactLabel.Text = t.Title
			compactLabel.TextTransparency = 1
			Tween(compactLabel, TweenPresets.fade, { TextTransparency = 0 }):Play()
			if t.Status then
				compactStatus.Visible = true
				compactStatus.Text = t.Status
				compactStatus.TextTransparency = 1
				if t.Status == "ON" or t.Status == "Loaded!" then
					compactStatus.TextColor3 = Colors.green
				elseif t.Status == "OFF" then
					compactStatus.TextColor3 = Colors.red
				else
					compactStatus.TextColor3 = Colors.title
				end
				Tween(compactStatus, TweenPresets.fade, { TextTransparency = 0 }):Play()
			else
				compactStatus.Visible = false
			end
			task.wait(0.05)
			local defaultSize = opts.IslandDefaultSize
			Tween(dynamicIsland, TweenPresets.pop, {
				Size = UDim2.new(0, math.max(defaultSize.X.Offset, compactLabel.TextBounds.X + (t.Status and compactStatus.TextBounds.X + 8 or 0) + 44), 0, defaultSize.Y.Offset),
			}):Play()
			task.wait(t.Duration)
			Tween(compactLabel, TweenPresets.fade, { TextTransparency = 1 }):Play()
			if t.Status then
				Tween(compactStatus, TweenPresets.fade, { TextTransparency = 1 }):Play()
			end
			task.wait(0.3)
			Tween(dynamicIsland, TweenPresets.pop, { Size = defaultSize }):Play()
			task.wait(0.2)
			compactLabel.Text = ""
			compactLabel.TextTransparency = 0
			compactStatus.Text = ""
			compactStatus.TextTransparency = 0
			compactStatus.Visible = false
			Tween(compactGlyph, TweenPresets.fade, { BackgroundTransparency = 0 }):Play()
			for _, bar in ipairs(compactWaveBars) do
				Tween(bar, TweenPresets.fade, { BackgroundTransparency = 0 }):Play()
			end
		end,
		AddTab = function(windowRef, tabOptions)
			local tabCfg = MergeTable({ Title = "Tab", Icon = "" }, tabOptions)
			local layoutOrder = #windowRef._tabs + 1
			local isSmallScreen = mobile or GetViewportSize().X < 900
			local tabBtn = Instance.new("TextButton", windowRef._tabScroll)
			tabBtn.Name = "Tab" .. layoutOrder
			tabBtn.LayoutOrder = layoutOrder
			tabBtn.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
			tabBtn.BackgroundTransparency = 1
			tabBtn.BorderSizePixel = 0
			tabBtn.Size = UDim2.new(1, 0, 0, isSmallScreen and 34 or 39)
			tabBtn.Text = ""
			tabBtn.AutoButtonColor = false
			tabBtn.ClipsDescendants = true
			tabBtn.Selectable = false
			Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)
			local tabStroke = Instance.new("UIStroke", tabBtn)
			tabStroke.Color = Color3.fromRGB(0, 235, 255)
			tabStroke.Transparency = 1
			tabStroke.Thickness = 1
			tabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			local tabIcon = Instance.new("ImageLabel", tabBtn)
			tabIcon.Name = "Icon"
			tabIcon.BackgroundTransparency = 1
			tabIcon.AnchorPoint = Vector2.new(0, 0.5)
			tabIcon.Size = UDim2.new(0, isSmallScreen and 16 or 20, 0, isSmallScreen and 16 or 20)
			tabIcon.Position = UDim2.new(0, isSmallScreen and 7 or 10, 0.5, 0)
			tabIcon.Image = tabCfg.Icon
			tabIcon.ImageTransparency = 0.5
			tabIcon.ImageColor3 = Color3.fromRGB(255, 180, 60)
			local tabLabel = Instance.new("TextLabel", tabBtn)
			tabLabel.Name = "Label"
			tabLabel.Text = tabCfg.Title
			tabLabel.TextColor3 = Colors.title
			tabLabel.TextTransparency = 0.5
			tabLabel.TextSize = isSmallScreen and 10 or 12
			tabLabel.Font = Enum.Font.GothamBold
			tabLabel.BackgroundTransparency = 1
			tabLabel.AnchorPoint = Vector2.new(0, 0.5)
			tabLabel.Size = UDim2.new(1, isSmallScreen and -30 or -40, 1, 0)
			tabLabel.Position = UDim2.new(0, isSmallScreen and 28 or 40, 0.5, 0)
			tabLabel.TextXAlignment = Enum.TextXAlignment.Left
			tabLabel.TextWrapped = false
			tabLabel.TextTruncate = Enum.TextTruncate.AtEnd
			tabLabel.TextScaled = true
			local tabTextConstraint = Instance.new("UITextSizeConstraint", tabLabel)
			tabTextConstraint.MinTextSize = 8
			tabTextConstraint.MaxTextSize = 12
			local tabPage = Instance.new("ScrollingFrame", windowRef._window:FindFirstChild("Layout").RealLayout)
			tabPage.Name = "Page" .. layoutOrder
			tabPage.LayoutOrder = layoutOrder
			tabPage.BackgroundTransparency = 1
			tabPage.BorderSizePixel = 0
			tabPage.Size = UDim2.new(1, 0, 1, 0)
			tabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
			tabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
			tabPage.ScrollBarThickness = 3
			tabPage.ScrollBarImageTransparency = 0.65
			local pagePadding = Instance.new("UIPadding", tabPage)
			pagePadding.PaddingTop = UDim.new(0, isSmallScreen and 6 or 8)
			pagePadding.PaddingRight = UDim.new(0, isSmallScreen and 5 or 8)
			pagePadding.PaddingLeft = UDim.new(0, isSmallScreen and 5 or 8)
			pagePadding.PaddingBottom = UDim.new(0, isSmallScreen and 6 or 8)
			local pageList = Instance.new("UIListLayout", tabPage)
			pageList.Padding = UDim.new(0, isSmallScreen and 4 or 6)
			pageList.SortOrder = Enum.SortOrder.LayoutOrder
			local tabData = {
				_order = layoutOrder,
				_btn = tabBtn,
				_icon = tabIcon,
				_lbl = tabLabel,
				_stroke = tabStroke,
				_page = tabPage,
				_list = pageList,
				_window = windowRef,
				_count = 0,
				_next = function(self)
					self._count = self._count + 1
					return self._count
				end,
			}
			table.insert(windowRef._tabs, tabData)
			local function selectTab()
				for _, tab in ipairs(windowRef._tabs) do
					if tab == tabData then
						Tween(tab._btn, TweenPresets.fast, { BackgroundTransparency = 0.9 }):Play()
						Tween(tab._stroke, TweenPresets.fast, { Transparency = 0.7 }):Play()
						Tween(tab._lbl, TweenPresets.fast, { TextTransparency = 0.1 }):Play()
						Tween(tab._icon, TweenPresets.fast, { ImageTransparency = 0 }):Play()
					else
						Tween(tab._btn, TweenPresets.fast, { BackgroundTransparency = 1 }):Play()
						Tween(tab._stroke, TweenPresets.fast, { Transparency = 1 }):Play()
						Tween(tab._lbl, TweenPresets.fast, { TextTransparency = 0.5 }):Play()
						Tween(tab._icon, TweenPresets.fast, { ImageTransparency = 0.5 }):Play()
					end
				end
				windowRef._pageLayout:JumpTo(tabData._page)
			end
			tabBtn.MouseButton1Click:Connect(selectTab)
			if layoutOrder == 1 then selectTab() end
			tabData.AddToggle = function(tabRef, toggleOptions)
				local tg = MergeTable({
					Title = "Toggle",
					Description = "",
					Default = false,
					Callback = function() end,
				}, toggleOptions)
				local row = Instance.new("TextButton", tabRef._page)
				row.Name = "Toggle"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, tg.Description ~= "" and 52 or 41)
				row.Text = ""
				row.AutoButtonColor = false
				row.Selectable = false
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0.5)
				textBlock.Position = UDim2.new(0, 11, 0.5, 0)
				textBlock.Size = UDim2.new(0, 316, 0, tg.Description ~= "" and 36 or 25)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = tg.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				titleLbl.TextYAlignment = Enum.TextYAlignment.Top
				titleLbl.TextWrapped = true
				if tg.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = tg.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 22)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
					descLbl.TextYAlignment = Enum.TextYAlignment.Top
					descLbl.TextWrapped = true
				end
				local switch = Instance.new("Frame", row)
				switch.Name = "Switch"
				switch.BorderSizePixel = 0
				switch.AnchorPoint = Vector2.new(1, 0.5)
				switch.Size = UDim2.new(0, 32, 0, 18)
				switch.Position = UDim2.new(1, -11, 0.5, 0)
				Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
				local switchStroke = Instance.new("UIStroke", switch)
				switchStroke.Color = Colors.fg
				switchStroke.Thickness = 0.5
				switchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local knob = Instance.new("Frame", switch)
				knob.Name = "Knob"
				knob.BorderSizePixel = 0
				knob.BackgroundColor3 = Colors.fg
				knob.AnchorPoint = Vector2.new(0, 0.5)
				knob.Size = UDim2.new(0, 14, 0, 14)
				knob.Position = UDim2.new(0, tg.Default and 16 or 2, 0.5, 0)
				Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
				local state = tg.Default
				switch.BackgroundColor3 = state and Colors.green or Colors.fg
				switch.BackgroundTransparency = state and 0 or 0.88
				switchStroke.Transparency = state and 1 or 0.85
				local function flip()
					state = not state
					Tween(knob, TweenPresets.spring, { Position = UDim2.new(0, state and 16 or 2, 0.5, 0) }):Play()
					Tween(switch, TweenPresets.soft, { BackgroundColor3 = state and Colors.green or Colors.fg, BackgroundTransparency = state and 0 or 0.88 }):Play()
					Tween(switchStroke, TweenPresets.soft, { Transparency = state and 1 or 0.85 }):Play()
					pcall(tg.Callback, state)
				end
				row.MouseButton1Click:Connect(flip)
				ApplyElementMobileLayout(row)
				return {
					Value = state,
					SetValue = function(_, newVal)
						if newVal ~= state then flip() end
					end,
				}
			end
			tabData.AddButton = function(tabRef, buttonOptions)
				local bt = MergeTable({
					Title = "Button",
					Description = "",
					Callback = function() end,
				}, buttonOptions)
				local row = Instance.new("TextButton", tabRef._page)
				row.Name = "Button"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, bt.Description ~= "" and 52 or 41)
				row.Text = ""
				row.AutoButtonColor = false
				row.Selectable = false
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0.5)
				textBlock.Position = UDim2.new(0, 11, 0.5, 0)
				textBlock.Size = UDim2.new(0, 316, 0, bt.Description ~= "" and 36 or 25)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = bt.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				titleLbl.TextYAlignment = Enum.TextYAlignment.Top
				titleLbl.TextWrapped = true
				if bt.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = bt.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 22)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
					descLbl.TextYAlignment = Enum.TextYAlignment.Top
					descLbl.TextWrapped = true
				end
				local caret = Instance.new("Frame", row)
				caret.Name = "Caret"
				caret.BackgroundTransparency = 1
				caret.AnchorPoint = Vector2.new(1, 0.5)
				caret.Size = UDim2.new(0, 12, 0, 12)
				caret.Position = UDim2.new(1, -11, 0.5, 0)
				local caretA = Instance.new("Frame", caret)
				caretA.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
				caretA.BorderSizePixel = 0
				caretA.AnchorPoint = Vector2.new(0.5, 0.5)
				caretA.Size = UDim2.new(0, 6, 0, 1)
				caretA.Position = UDim2.new(0.5, 0, 0.5, -2)
				caretA.Rotation = 45
				Instance.new("UICorner", caretA).CornerRadius = UDim.new(1, 0)
				local caretB = Instance.new("Frame", caret)
				caretB.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
				caretB.BorderSizePixel = 0
				caretB.AnchorPoint = Vector2.new(0.5, 0.5)
				caretB.Size = UDim2.new(0, 6, 0, 1)
				caretB.Position = UDim2.new(0.5, 0, 0.5, -2)
				caretB.Rotation = -45
				Instance.new("UICorner", caretB).CornerRadius = UDim.new(1, 0)
				row.MouseButton1Click:Connect(function()
					pcall(bt.Callback)
				end)
				ApplyElementMobileLayout(row)
				return { Frame = row }
			end
			tabData.AddSeparator = function(tabRef, sepOptions)
				local sp = MergeTable({ Title = "" }, sepOptions)
				local holder = Instance.new("Frame", tabRef._page)
				holder.Name = "Separator"
				holder.LayoutOrder = tabRef:_next()
				holder.BackgroundTransparency = 1
				holder.Size = UDim2.new(1, 0, 0, 20)
				local line = Instance.new("Frame", holder)
				line.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
				line.BackgroundTransparency = 0.75
				line.BorderSizePixel = 0
				line.AnchorPoint = Vector2.new(0, 0.5)
				line.Size = UDim2.new(1, 0, 0, 1)
				line.Position = UDim2.new(0, 0, 0.5, 0)
				if sp.Title ~= "" then
					local lbl = Instance.new("TextLabel", holder)
					lbl.Name = "Label"
					lbl.Text = sp.Title
					lbl.TextColor3 = Colors.desc
					lbl.TextTransparency = 0.3
					lbl.TextSize = 10
					lbl.Font = Enum.Font.GothamBold
					lbl.BackgroundTransparency = 1
					lbl.AnchorPoint = Vector2.new(0, 0.5)
					lbl.Size = UDim2.new(0, 200, 0, 16)
					lbl.Position = UDim2.new(0, 4, 0.5, 0)
					lbl.TextXAlignment = Enum.TextXAlignment.Left
					line.Position = UDim2.new(0, 0, 0.5, 0)
					line.Size = UDim2.new(1, -210, 0, 1)
					line.Position = UDim2.new(0, 210, 0.5, 0)
				end
				return { Frame = holder }
			end
			tabData.AddSlider = function(tabRef, sliderOptions)
				local sl = MergeTable({
					Title = "Slider",
					Description = "",
					Min = 0,
					Max = 100,
					Default = 50,
					Suffix = "",
					Callback = function() end,
				}, sliderOptions)
				local row = Instance.new("TextButton", tabRef._page)
				row.Name = "Slider"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, sl.Description ~= "" and 60 or 48)
				row.Text = ""
				row.AutoButtonColor = false
				row.Selectable = false
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0)
				textBlock.Position = UDim2.new(0, 11, 0, 7)
				textBlock.Size = UDim2.new(0, 316, 0, 25)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = sl.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				if sl.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = sl.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 14)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
				end
				local valueText = Instance.new("TextLabel", row)
				valueText.Name = "ValueText"
				valueText.Text = tostring(sl.Default) .. sl.Suffix
				valueText.TextColor3 = Colors.title
				valueText.TextSize = 11
				valueText.Font = Enum.Font.GothamBold
				valueText.BackgroundTransparency = 1
				valueText.AnchorPoint = Vector2.new(1, 0)
				valueText.Size = UDim2.new(0, 80, 0, 14)
				valueText.Position = UDim2.new(1, -11, 0, 7)
				valueText.TextXAlignment = Enum.TextXAlignment.Right
				local track = Instance.new("Frame", row)
				track.Name = "Track"
				track.BackgroundColor3 = Colors.fg
				track.BackgroundTransparency = 0.85
				track.BorderSizePixel = 0
				track.AnchorPoint = Vector2.new(0, 1)
				track.Size = UDim2.new(1, -22, 0, 4)
				track.Position = UDim2.new(0, 11, 1, -10)
				Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
				local fill = Instance.new("Frame", track)
				fill.Name = "Fill"
				fill.BackgroundColor3 = Color3.fromRGB(0, 235, 255)
				fill.BorderSizePixel = 0
				local initialRel = math.clamp((sl.Default - sl.Min) / (sl.Max - sl.Min), 0, 1)
				fill.Size = UDim2.new(initialRel, 0, 1, 0)
				Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
				local thumb = Instance.new("Frame", track)
				thumb.Name = "Thumb"
				thumb.BackgroundColor3 = Colors.fg
				thumb.BorderSizePixel = 0
				thumb.AnchorPoint = Vector2.new(0.5, 0.5)
				thumb.Size = UDim2.new(0, 12, 0, 12)
				thumb.Position = UDim2.new(initialRel, 0, 0.5, 0)
				thumb.ZIndex = 3
				Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
				local thumbStroke = Instance.new("UIStroke", thumb)
				thumbStroke.Color = Colors.blue
				thumbStroke.Thickness = 1.5
				thumbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local currentValue = sl.Default
				local dragging = false
				local function updateFromX(xPos)
					local rel = math.clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local val = math.floor(sl.Min + rel * (sl.Max - sl.Min) + 0.5)
					if val ~= currentValue then
						currentValue = val
						valueText.Text = tostring(val) .. sl.Suffix
						Tween(fill, TweenPresets.fast, { Size = UDim2.new(rel, 0, 1, 0) }):Play()
						Tween(thumb, TweenPresets.fast, { Position = UDim2.new(rel, 0, 0.5, 0) }):Play()
						pcall(sl.Callback, val)
					end
				end
				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateFromX(input.Position.X)
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateFromX(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				ApplyElementMobileLayout(row)
				return {
					Value = currentValue,
					SetValue = function(_, newVal)
						local clamped = math.clamp(newVal, sl.Min, sl.Max)
						local rel = (clamped - sl.Min) / (sl.Max - sl.Min)
						currentValue = clamped
						valueText.Text = tostring(clamped) .. sl.Suffix
						Tween(fill, TweenPresets.fast, { Size = UDim2.new(rel, 0, 1, 0) }):Play()
						Tween(thumb, TweenPresets.fast, { Position = UDim2.new(rel, 0, 0.5, 0) }):Play()
					end,
				}
			end
			tabData.AddTextbox = function(tabRef, textboxOptions)
				local tb = MergeTable({
					Title = "Textbox",
					Description = "",
					Placeholder = "",
					Default = "",
					Callback = function() end,
				}, textboxOptions)
				local row = Instance.new("Frame", tabRef._page)
				row.Name = "Textbox"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, tb.Description ~= "" and 66 or 56)
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0)
				textBlock.Position = UDim2.new(0, 11, 0, 7)
				textBlock.Size = UDim2.new(1, -22, 0, 24)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = tb.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				if tb.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = tb.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 14)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
				end
				local field = Instance.new("TextBox", row)
				field.Name = "Field"
				field.ClearTextOnFocus = false
				field.PlaceholderText = tb.Placeholder
				field.Text = tb.Default
				field.TextColor3 = Colors.title
				field.PlaceholderColor3 = Colors.desc
				field.TextSize = 11
				field.Font = Enum.Font.Gotham
				field.TextXAlignment = Enum.TextXAlignment.Left
				field.BackgroundColor3 = Colors.fg
				field.BackgroundTransparency = 0.93
				field.BorderSizePixel = 0
				field.AnchorPoint = Vector2.new(0, 1)
				field.Size = UDim2.new(1, -22, 0, 26)
				field.Position = UDim2.new(0, 11, 1, -6)
				Instance.new("UICorner", field).CornerRadius = UDim.new(0, 6)
				local fieldPad = Instance.new("UIPadding", field)
				fieldPad.PaddingLeft = UDim.new(0, 10)
				fieldPad.PaddingRight = UDim.new(0, 10)
				local fieldStroke = Instance.new("UIStroke", field)
				fieldStroke.Color = Color3.fromRGB(0, 235, 255)
				fieldStroke.Transparency = 0.6
				fieldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				field.FocusLost:Connect(function()
					pcall(tb.Callback, field.Text)
				end)
				ApplyElementMobileLayout(row)
				return {
					Frame = row,
					GetValue = function()
						return field.Text
					end,
					SetValue = function(_, newText)
						field.Text = tostring(newText or "")
					end,
				}
			end
			tabData.AddDropdown = function(tabRef, dropdownOptions)
				local dd = MergeTable({
					Title = "Dropdown",
					Description = "",
					Options = {},
					Default = "",
					Multi = false,
					Callback = function() end,
				}, dropdownOptions)
				local row = Instance.new("TextButton", tabRef._page)
				row.Name = "Dropdown"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, dd.Description ~= "" and 66 or 56)
				row.Text = ""
				row.AutoButtonColor = false
				row.Selectable = false
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0)
				textBlock.Position = UDim2.new(0, 11, 0, 7)
				textBlock.Size = UDim2.new(1, -22, 0, 24)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = dd.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				if dd.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = dd.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 14)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
				end
				local field = Instance.new("TextButton", row)
				field.Name = "Field"
				field.AutoButtonColor = false
				field.BackgroundColor3 = Colors.fg
				field.BackgroundTransparency = 0.93
				field.BorderSizePixel = 0
				field.AnchorPoint = Vector2.new(0, 1)
				field.Size = UDim2.new(1, -22, 0, 26)
				field.Position = UDim2.new(0, 11, 1, -6)
				field.Text = ""
				Instance.new("UICorner", field).CornerRadius = UDim.new(0, 6)
				local fieldStroke = Instance.new("UIStroke", field)
				fieldStroke.Color = Color3.fromRGB(0, 235, 255)
				fieldStroke.Transparency = 0.6
				fieldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local selLbl = Instance.new("TextLabel", field)
				selLbl.Name = "Selected"
				selLbl.BackgroundTransparency = 1
				selLbl.Text = (dd.Default ~= "" and dd.Default) or (dd.Options[1] or "Select...")
				selLbl.TextColor3 = Colors.title
				selLbl.TextSize = 11
				selLbl.Font = Enum.Font.GothamMedium
				selLbl.TextXAlignment = Enum.TextXAlignment.Left
				selLbl.Size = UDim2.new(1, -30, 1, 0)
				selLbl.Position = UDim2.new(0, 9, 0, 0)
				selLbl.TextTruncate = Enum.TextTruncate.AtEnd
				local arrow = Instance.new("TextLabel", field)
				arrow.Name = "Arrow"
				arrow.BackgroundTransparency = 1
				arrow.Text = "▼"
				arrow.TextColor3 = Color3.fromRGB(0, 235, 255)
				arrow.TextSize = 10
				arrow.Font = Enum.Font.GothamBold
				arrow.AnchorPoint = Vector2.new(1, 0.5)
				arrow.Size = UDim2.new(0, 16, 1, 0)
				arrow.Position = UDim2.new(1, -6, 0.5, 0)
				local selectedValues = {}
				if dd.Multi then
					if type(dd.Default) == "table" then
						for _, v in ipairs(dd.Default) do
							selectedValues[v] = true
						end
					end
				end
				local function refreshSingleLabel()
					if dd.Multi then
						local names = {}
						for _, opt in ipairs(dd.Options) do
							if selectedValues[opt] then table.insert(names, opt) end
						end
						if #names == 0 then
							selLbl.Text = "Select..."
						elseif #names <= 2 then
							selLbl.Text = table.concat(names, ", ")
						else
							selLbl.Text = names[1] .. " +" .. tostring(#names - 1)
						end
					else
						selLbl.Text = dd.Default ~= "" and dd.Default or (dd.Options[1] or "Select...")
					end
				end
				field.MouseButton1Click:Connect(function()
					windowRef._dropZone.Visible = true
					windowRef._dropZone.GroupTransparency = 1
					windowRef._realDrop:FindFirstChildOfClass("UIScale").Scale = 0.95
					Tween(windowRef._dropZone, TweenPresets.fade, { GroupTransparency = 0 }):Play()
					Tween(windowRef._realDrop:FindFirstChildOfClass("UIScale"), TweenPresets.pop, { Scale = 1 }):Play()
					for _, c in ipairs(windowRef._listDrop:GetChildren()) do
						if c:IsA("TextButton") and c ~= windowRef._dropTmpl then c:Destroy() end
					end
					windowRef._dropHeading.Text = dd.Title
					windowRef._dropHeading.Visible = false
					local term = ""
					local function rebuildList()
						for _, c in ipairs(windowRef._listDrop:GetChildren()) do
							if c:IsA("TextButton") and c ~= windowRef._dropTmpl then c:Destroy() end
						end
						for _, opt in ipairs(dd.Options) do
							if term == "" or string.find(string.lower(opt), term, 1, true) then
								local clone = windowRef._dropTmpl:Clone()
								clone.Name = opt
								clone.Visible = true
								clone.Text = opt
								clone.LayoutOrder = 1
								clone.Parent = windowRef._listDrop
								local tick = clone:FindFirstChild("Tick")
								if tick then
									if dd.Multi then
										tick.Visible = selectedValues[opt] == true
									else
										tick.Visible = (selLbl.Text == opt)
									end
								end
								clone.MouseButton1Click:Connect(function()
									if dd.Multi then
										selectedValues[opt] = not selectedValues[opt]
										refreshSingleLabel()
										local out = {}
										for _, o in ipairs(dd.Options) do
											if selectedValues[o] then table.insert(out, o) end
										end
										pcall(dd.Callback, out)
										if tick then tick.Visible = selectedValues[opt] == true end
									else
										selLbl.Text = opt
										pcall(dd.Callback, opt)
										closeDropdownPanel()
									end
								end)
							end
						end
					end
					windowRef._gui:FindFirstChild("DNHubUI", true)
					activeDropdownSearchRefresh = function()
						term = string.lower(dropdownSearch.Text or "")
						rebuildList()
					end
					dropdownSearch.Text = ""
					activeDropdownSearchRefresh()
				end)
				refreshSingleLabel()
				ApplyElementMobileLayout(row)
				return {
					Frame = row,
					GetValue = function()
						if dd.Multi then
							local out = {}
							for _, o in ipairs(dd.Options) do
								if selectedValues[o] then table.insert(out, o) end
							end
							return out
						end
						return selLbl.Text
					end,
					SetValue = function(_, values)
						if dd.Multi then
							selectedValues = {}
							if type(values) == "table" then
								for _, v in ipairs(values) do
									if table.find(dd.Options, v) then selectedValues[v] = true end
								end
							end
						else
							selLbl.Text = tostring(values or "")
						end
						refreshSingleLabel()
					end,
				}
			end
			tabData.AddMultiDropdown = function(tabRef, dropdownOptions)
				local dd = MergeTable({
					Title = "Multi Dropdown",
					Description = "",
					Options = {},
					Default = {},
					Callback = function() end,
				}, dropdownOptions)
				local row = Instance.new("TextButton", tabRef._page)
				row.Name = "MultiDropdown"
				row.LayoutOrder = tabRef:_next()
				row.BackgroundColor3 = Colors.fg
				row.BackgroundTransparency = 0.95
				row.BorderSizePixel = 0
				row.Size = UDim2.new(1, 0, 0, dd.Description ~= "" and 66 or 56)
				row.Text = ""
				row.AutoButtonColor = false
				row.Selectable = false
				Instance.new("UICorner", row)
				local rowStroke = Instance.new("UIStroke", row)
				rowStroke.Color = Color3.fromRGB(0, 235, 255)
				rowStroke.Transparency = 0.85
				rowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local textBlock = Instance.new("Frame", row)
				textBlock.Name = "TextBlock"
				textBlock.BackgroundTransparency = 1
				textBlock.AnchorPoint = Vector2.new(0, 0)
				textBlock.Position = UDim2.new(0, 11, 0, 7)
				textBlock.Size = UDim2.new(1, -22, 0, 24)
				local titleLbl = Instance.new("TextLabel", textBlock)
				titleLbl.Name = "Title"
				titleLbl.Text = dd.Title
				titleLbl.TextColor3 = Colors.title
				titleLbl.TextTransparency = 0.08
				titleLbl.TextSize = 12
				titleLbl.Font = Enum.Font.GothamBold
				titleLbl.BackgroundTransparency = 1
				titleLbl.Size = UDim2.new(1, 0, 0, 12)
				titleLbl.TextXAlignment = Enum.TextXAlignment.Left
				if dd.Description ~= "" then
					local descLbl = Instance.new("TextLabel", textBlock)
					descLbl.Name = "Desc"
					descLbl.Text = dd.Description
					descLbl.TextColor3 = Colors.desc
					descLbl.TextTransparency = 0.2
					descLbl.TextSize = 11
					descLbl.Font = Enum.Font.Gotham
					descLbl.BackgroundTransparency = 1
					descLbl.Size = UDim2.new(1, 0, 0, 14)
					descLbl.Position = UDim2.new(0, 0, 0, 14)
					descLbl.TextXAlignment = Enum.TextXAlignment.Left
				end
				local field = Instance.new("TextButton", row)
				field.Name = "Field"
				field.AutoButtonColor = false
				field.BackgroundColor3 = Colors.fg
				field.BackgroundTransparency = 0.93
				field.BorderSizePixel = 0
				field.AnchorPoint = Vector2.new(0, 1)
				field.Size = UDim2.new(1, -22, 0, 26)
				field.Position = UDim2.new(0, 11, 1, -6)
				field.Text = ""
				Instance.new("UICorner", field).CornerRadius = UDim.new(0, 6)
				local fieldStroke = Instance.new("UIStroke", field)
				fieldStroke.Color = Color3.fromRGB(0, 235, 255)
				fieldStroke.Transparency = 0.6
				fieldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				local selLbl = Instance.new("TextLabel", field)
				selLbl.Name = "Selected"
				selLbl.BackgroundTransparency = 1
				selLbl.TextColor3 = Colors.title
				selLbl.TextSize = 11
				selLbl.Font = Enum.Font.GothamMedium
				selLbl.TextXAlignment = Enum.TextXAlignment.Left
				selLbl.Size = UDim2.new(1, -30, 1, 0)
				selLbl.Position = UDim2.new(0, 9, 0, 0)
				selLbl.TextTruncate = Enum.TextTruncate.AtEnd
				local arrow = Instance.new("TextLabel", field)
				arrow.Name = "Arrow"
				arrow.BackgroundTransparency = 1
				arrow.Text = "▼"
				arrow.TextColor3 = Color3.fromRGB(0, 235, 255)
				arrow.TextSize = 10
				arrow.Font = Enum.Font.GothamBold
				arrow.AnchorPoint = Vector2.new(1, 0.5)
				arrow.Size = UDim2.new(0, 16, 1, 0)
				arrow.Position = UDim2.new(1, -6, 0.5, 0)
				local selectedValues = {}
				if type(dd.Default) == "table" then
					for _, v in ipairs(dd.Default) do
						selectedValues[v] = true
					end
				end
				local function refreshLabel()
					local names = {}
					for _, opt in ipairs(dd.Options) do
						if selectedValues[opt] then table.insert(names, opt) end
					end
					if #names == 0 then
						selLbl.Text = "Select..."
					elseif #names <= 2 then
						selLbl.Text = table.concat(names, ", ")
					else
						selLbl.Text = names[1] .. " +" .. tostring(#names - 1)
					end
				end
				refreshLabel()
				local function getSelectedArray()
					local out = {}
					for _, option in ipairs(dd.Options) do
						if selectedValues[option] then table.insert(out, option) end
					end
					return out
				end
				
				local function rebuildMultiList()
					for _, child in ipairs(windowRef._listDrop:GetChildren()) do
						if child:IsA("TextButton") and child ~= windowRef._dropTmpl then child:Destroy() end
					end
					local term = string.lower(dropdownSearch.Text or "")
					for index, option in ipairs(dd.Options) do
						if term == "" or string.find(string.lower(option), term, 1, true) then
							local item = windowRef._dropTmpl:Clone()
							item.Name = option
							item.Visible = true
							item.Text = option
							item.LayoutOrder = index
							item.Parent = windowRef._listDrop
							local tick = item:FindFirstChild("Tick")
							if tick then tick.Visible = selectedValues[option] == true end
							item.MouseButton1Click:Connect(function()
								selectedValues[option] = not selectedValues[option]
								refreshLabel()
								if tick then tick.Visible = selectedValues[option] == true end
								pcall(dd.Callback, getSelectedArray())
							end)
						end
					end
				end
				
				field.MouseButton1Click:Connect(function()
					windowRef._dropZone.Visible = true
					windowRef._dropZone.GroupTransparency = 1
					windowRef._realDrop:FindFirstChildOfClass("UIScale").Scale = 0.95
					Tween(windowRef._dropZone, TweenPresets.fade, { GroupTransparency = 0 }):Play()
					Tween(windowRef._realDrop:FindFirstChildOfClass("UIScale"), TweenPresets.pop, { Scale = 1 }):Play()
					windowRef._dropHeading.Text = dd.Title
					windowRef._dropHeading.Visible = false
					activeDropdownSearchRefresh = rebuildMultiList
					dropdownSearch.Text = ""
					rebuildMultiList()
				end)
				ApplyElementMobileLayout(row)
				return {
					Frame = row,
					GetValue = function()
						return getSelectedArray()
					end,
					SetValue = function(_, values)
						selectedValues = {}
						if type(values) == "table" then
							for _, v in ipairs(values) do
								if table.find(dd.Options, v) then selectedValues[v] = true end
							end
						end
						refreshLabel()
						if windowRef._dropZone.Visible and activeDropdownSearchRefresh == rebuildMultiList then rebuildMultiList() end
					end,
				}
			end
			return tabData
		end,
	}
end }
