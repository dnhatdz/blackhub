local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HapticService = game:GetService("HapticService")

local LOCAL_PLAYER = Players.LocalPlayer

local CONFIG = {
	Accent = Color3.fromRGB(10, 132, 255),
	GlassTint = Color3.fromRGB(255, 255, 255),
	GlassTransparency = 0.94,
	GlassTint2 = Color3.fromRGB(180, 200, 230),
	Label = Color3.fromRGB(255, 255, 255),
	SecondaryLabel = Color3.fromRGB(180, 190, 210),
	Separator = Color3.fromRGB(255, 255, 255),
	Green = Color3.fromRGB(48, 209, 88),
	Red = Color3.fromRGB(255, 69, 58),
	Orange = Color3.fromRGB(255, 159, 10),
	Blue = Color3.fromRGB(10, 132, 255),
	TrackOff = Color3.fromRGB(255, 255, 255),
	CornerRadius = 18,
	RowRadius = 14,
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	Noise = "rbxassetid://243098098",
	Shadow = "rbxassetid://8992230677",
	GlassMask = "rbxassetid://5028857084",
}

local function newInstance(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local Spring = {}
Spring.__index = Spring

function Spring.new(value, stiffness, damping, mass)
	return setmetatable({
		value = value,
		target = value,
		velocity = 0,
		stiffness = stiffness or 220,
		damping = damping or 26,
		mass = mass or 1,
	}, Spring)
end

function Spring:Update(dt)
	local force = (self.target - self.value) * self.stiffness
	local damper = self.velocity * self.damping
	local accel = (force - damper) / self.mass
	self.velocity = self.velocity + accel * dt
	self.value = self.value + self.velocity * dt
	if math.abs(self.value - self.target) < 0.0005 and math.abs(self.velocity) < 0.0005 then
		self.value = self.target
		self.velocity = 0
	end
	return self.value
end

local function hapticSmall()
	pcall(function()
		if HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small) then
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.25)
			task.wait(0.05)
			HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end
	end)
end

local function makeGlassRow(parent, height)
	local row = newInstance("Frame", {
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height),
		ZIndex = 10,
		Parent = parent,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.RowRadius),
		Parent = row,
	})

	local grad = newInstance("Frame", {
		BackgroundColor3 = CONFIG.GlassTint2,
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,
		Parent = row,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.RowRadius),
		Parent = grad,
	})
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(0.5, 0.95),
			NumberSequenceKeypoint.new(1, 0.6),
		}),
		Parent = grad,
	})

	local stroke = newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.85,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = row,
	})

	local noise = newInstance("ImageLabel", {
		BackgroundTransparency = 1,
		Image = CONFIG.Noise,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.96,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(128, 128),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 10,
		Parent = row,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.RowRadius),
		Parent = noise,
	})

	return row, stroke, grad
end

function LiquidGlass.new(opts)
	local self = setmetatable({}, LiquidGlass)
	opts = opts or {}
	self._connections = {}
	self._springs = {}
	self._tabs = {}
	self._alive = true
	self._open = false
	self._dragging = false

	self.Title = opts.Title or "Settings"
	self.Author = opts.Author or ""
	self.Size = opts.Size or UDim2.fromOffset(420, 520)
	self.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self.Parent = opts.Parent or LOCAL_PLAYER:WaitForChild("PlayerGui")
	self.MobileButton = opts.MobileButton ~= false
	self.MobileButtonPosition = opts.MobileButtonPosition or UDim2.new(0, 20, 0.5, -25)

	self._scaleSpring = Spring.new(0.94)
	self._alphaSpring = Spring.new(0)
	self._blurSpring = Spring.new(0)

	self:_build()
	if self.MobileButton then
		self:_buildMobileButton()
	end
	self:_startLoop()
	self:_bindInput()
	return self
end

function LiquidGlass:_build()
	local gui = newInstance("ScreenGui", {
		Name = "LiquidGlassGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = self.Parent,
	})
	self.Gui = gui

	self.Backdrop = newInstance("Frame", {
		Name = "Backdrop",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		Parent = gui,
	})

	self.Shell = newInstance("Frame", {
		Name = "Shell",
		BackgroundTransparency = 1,
		Size = self.Size,
		Position = self.Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = gui,
	})

	self.Shadow = newInstance("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = CONFIG.Shadow,
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Size = UDim2.new(1, 80, 1, 80),
		Position = UDim2.new(0, -40, 0, -40),
		ZIndex = 0,
		Parent = self.Shell,
	})

	self.Panel = newInstance("Frame", {
		Name = "Panel",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = self.Shell,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 24),
		Parent = self.Panel,
	})

	self.GlassLayer = newInstance("Frame", {
		Name = "GlassLayer",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 24),
		Parent = self.GlassLayer,
	})
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(0.5, 0.92),
			NumberSequenceKeypoint.new(1, 0.55),
		}),
		Parent = self.GlassLayer,
	})

	self.GlassTintLayer = newInstance("Frame", {
		Name = "GlassTint",
		BackgroundColor3 = CONFIG.GlassTint2,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 24),
		Parent = self.GlassTintLayer,
	})
	newInstance("UIGradient", {
		Rotation = 45,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.85),
			NumberSequenceKeypoint.new(0.5, 0.98),
			NumberSequenceKeypoint.new(1, 0.85),
		}),
		Parent = self.GlassTintLayer,
	})

	self.Noise = newInstance("ImageLabel", {
		Name = "Noise",
		BackgroundTransparency = 1,
		Image = CONFIG.Noise,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(128, 128),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 5,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 24),
		Parent = self.Noise,
	})

	self.Specular = newInstance("Frame", {
		Name = "Specular",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0.35, 0),
		ZIndex = 6,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 24),
		Parent = self.Specular,
	})
	newInstance("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.82),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = self.Specular,
	})

	self.Edge = newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = self.Panel,
	})

	self.Header = newInstance("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 60),
		ZIndex = 10,
		Parent = self.Panel,
	})

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = CONFIG.FontBold,
		TextSize = 22,
		TextColor3 = CONFIG.Label,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(24, 20),
		Size = UDim2.new(1, -120, 0, 28),
		ZIndex = 10,
		Parent = self.Header,
	})

	if self.Author ~= "" then
		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = self.Author,
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.SecondaryLabel,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(24, 46),
			Size = UDim2.new(1, -120, 0, 14),
			ZIndex = 10,
			Parent = self.Header,
		})
	end

	local closeBtn = newInstance("TextButton", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.88,
		BorderSizePixel = 0,
		Text = "×",
		Font = CONFIG.FontBold,
		TextSize = 20,
		TextColor3 = CONFIG.Label,
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.new(1, -42, 0, 15),
		ZIndex = 10,
		Parent = self.Header,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = closeBtn,
	})
	closeBtn.MouseButton1Click:Connect(function()
		self:Close()
		hapticSmall()
	end)

	self.TabBar = newInstance("Frame", {
		Name = "TabBar",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 0.92,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -48, 0, 32),
		Position = UDim2.fromOffset(24, 66),
		ZIndex = 10,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 9),
		Parent = self.TabBar,
	})
	newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.9,
		Parent = self.TabBar,
	})

	self.TabIndicator = newInstance("Frame", {
		Name = "Indicator",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 0.78,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, -4),
		Position = UDim2.fromOffset(2, 2),
		ZIndex = 11,
		Parent = self.TabBar,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 7),
		Parent = self.TabIndicator,
	})

	self.Content = newInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -48, 1, -160),
		Position = UDim2.fromOffset(24, 110),
		ClipsDescendants = true,
		ZIndex = 10,
		Parent = self.Panel,
	})
end

function LiquidGlass:_buildMobileButton()
	local btn = newInstance("TextButton", {
		Name = "MobileToggle",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.fromOffset(52, 52),
		Position = self.MobileButtonPosition,
		AutoButtonColor = false,
		ZIndex = 99,
		Parent = self.Gui,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = btn,
	})
	newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.6,
		Parent = btn,
	})

	local noise = newInstance("ImageLabel", {
		BackgroundTransparency = 1,
		Image = CONFIG.Noise,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.94,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(64, 64),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 99,
		Parent = btn,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = noise,
	})

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = "☰",
		Font = CONFIG.FontBold,
		TextSize = 24,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 100,
		Parent = btn,
	})

	local scale = newInstance("UIScale", {
		Scale = 1,
		Parent = btn,
	})

	local dragging = false
	local dragStart, startPos
	local moved = false

	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = btn.Position
			TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quart), { Scale = 0.92 }):Play()
		end
	end)

	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
				moved = true
			end
			btn.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))

	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			if not moved then
				self:Toggle()
				hapticSmall()
			else
				self.MobileButtonPosition = btn.Position
			end
		end
	end))
end

function LiquidGlass:_startLoop()
	local last = tick()
	local conn = RunService.RenderStepped:Connect(function()
		if not self._alive then return end
		local now = tick()
		local dt = math.min(now - last, 0.05)
		last = now

		local s = self._scaleSpring:Update(dt)
		local a = self._alphaSpring:Update(dt)
		local b = self._blurSpring:Update(dt)

		self.Shell.Size = UDim2.new(
			self.Size.X.Scale * s,
			self.Size.X.Offset * s,
			self.Size.Y.Scale * s,
			self.Size.Y.Offset * s
		)

		self.Panel.BackgroundTransparency = 1 - 0.95 * a
		self.GlassLayer.BackgroundTransparency = 1 - 0.92 * a
		self.GlassTintLayer.BackgroundTransparency = 1 - 0.95 * a
		self.Noise.ImageTransparency = 1 - 0.06 * a
		self.Specular.BackgroundTransparency = 1 - 0.82 * a
		self.Edge.Transparency = 1 - 0.7 * a
		self.Shadow.ImageTransparency = 1 - 0.55 * a
		self.Backdrop.BackgroundTransparency = 1 - 0.45 * b

		for _, entry in ipairs(self._springs) do
			local v = entry.spring:Update(dt)
			entry.apply(v)
		end
	end)
	table.insert(self._connections, conn)
end

function LiquidGlass:_bindInput()
	local header = self.Header
	local shell = self.Shell
	local startPos, startMouse

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self._dragging = true
			startMouse = input.Position
			startPos = shell.Position
			self._scaleSpring.target = 1.01
		end
	end)

	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if not self._dragging then return end
		local delta = input.Position - startMouse
		shell.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end))

	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		if not self._dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self._dragging = false
			self._scaleSpring.target = 1
			self.Position = shell.Position
		end
	end))

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))
end

function LiquidGlass:Tab(name)
	local tab = {}
	tab.Name = name

	local tabCount = #self._tabs + 1

	local tabBtn = newInstance("TextButton", {
		BackgroundTransparency = 1,
		Text = name,
		Font = CONFIG.Font,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(180, 190, 210),
		Size = UDim2.new(1 / tabCount, 0, 1, 0),
		Position = UDim2.new((tabCount - 1) / tabCount, 0, 0, 0),
		AutoButtonColor = false,
		ZIndex = 12,
		Parent = self.TabBar,
	})

	local scroll = newInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = CONFIG.SecondaryLabel,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Visible = false,
		ZIndex = 10,
		Parent = self.Content,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = scroll,
	})
	newInstance("UIPadding", {
		PaddingRight = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 20),
		Parent = scroll,
	})

	tab._scroll = scroll
	tab._btn = tabBtn

	table.insert(self._tabs, tab)

	if #self._tabs == 1 then
		scroll.Visible = true
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	local function refreshTabLayout()
		local count = #self._tabs
		for i, t in ipairs(self._tabs) do
			t._btn.Size = UDim2.new(1 / count, 0, 1, 0)
			t._btn.Position = UDim2.new((i - 1) / count, 0, 0, 0)
		end
		local selectedIndex = 1
		for i, t in ipairs(self._tabs) do
			if t._scroll.Visible then
				selectedIndex = i
				break
			end
		end
		self.TabIndicator.Size = UDim2.new(1 / count, -4, 1, -4)
		self.TabIndicator.Position = UDim2.new((selectedIndex - 1) / count, 0, 0, 2)
	end

	tabBtn.MouseButton1Click:Connect(function()
		for _, t in ipairs(self._tabs) do
			t._scroll.Visible = false
			t._btn.TextColor3 = Color3.fromRGB(180, 190, 210)
		end
		scroll.Visible = true
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

		local count = #self._tabs
		local index = 1
		for i, t in ipairs(self._tabs) do
			if t == tab then
				index = i
				break
			end
		end

		TweenService:Create(self.TabIndicator, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Position = UDim2.new((index - 1) / count, 0, 0, 2),
		}):Play()
		hapticSmall()
	end)

	refreshTabLayout()

	local function makeRow(height)
		return makeGlassRow(scroll, height)
	end

	tab.Label = function(opts)
		return newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "",
			Font = CONFIG.FontBold,
			TextSize = 13,
			TextColor3 = CONFIG.SecondaryLabel,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 22),
			ZIndex = 11,
			Parent = scroll,
		})
	end

	tab.Separator = function()
		return newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 0, 1),
			Position = UDim2.fromOffset(16, 0),
			ZIndex = 11,
			Parent = scroll,
		})
	end

	tab.Button = function(opts)
		local holder, stroke = makeRow(52)
		local scale = newInstance("UIScale", { Scale = 1, Parent = holder })

		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Button",
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -60, 1, 0),
			ZIndex = 11,
			Parent = holder,
		})

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = "›",
			Font = CONFIG.FontBold,
			TextSize = 22,
			TextColor3 = CONFIG.SecondaryLabel,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -32, 0, 0),
			Size = UDim2.fromOffset(20, 52),
			ZIndex = 11,
			Parent = holder,
		})

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 12,
			Parent = holder,
		})

		local sp = Spring.new(0, 260, 24)
		table.insert(self._springs, {
			spring = sp,
			apply = function(v)
				holder.BackgroundTransparency = 0.94 - v * 0.1
			end,
		})
		holder.MouseEnter:Connect(function() sp.target = 1 end)
		holder.MouseLeave:Connect(function() sp.target = 0 end)

		btn.MouseButton1Down:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quart), { Scale = 0.96 }):Play()
		end)
		btn.MouseButton1Up:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			hapticSmall()
			if opts.Callback then
				pcall(opts.Callback)
			end
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Scale = 1 }):Play()
		end)
		return holder
	end

	tab.Toggle = function(opts)
		local holder = makeRow(52)
		local state = opts.Default or false

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Toggle",
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -90, 1, 0),
			ZIndex = 11,
			Parent = holder,
		})

		local pill = newInstance("Frame", {
			Name = "Pill",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = state and 0.85 or 0.88,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(56, 32),
			Position = UDim2.new(1, -72, 0.5, -16),
			ClipsDescendants = true,
			ZIndex = 11,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = pill,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.75,
			Parent = pill,
		})

		local pillGrad = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(180, 200, 230),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 11,
			Parent = pill,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = pillGrad,
		})
		newInstance("UIGradient", {
			Rotation = 135,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.7),
				NumberSequenceKeypoint.new(1, 0.95),
			}),
			Parent = pillGrad,
		})

		local knob = newInstance("Frame", {
			Name = "Knob",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(28, 28),
			Position = state and UDim2.fromOffset(26, 2) or UDim2.fromOffset(2, 2),
			ZIndex = 13,
			Parent = pill,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.5,
			Parent = knob,
		})

		local knobSpec = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.45, 0),
			ZIndex = 14,
			Parent = knob,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knobSpec,
		})
		newInstance("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = knobSpec,
		})

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 15,
			Parent = holder,
		})

		local function setState(newState, animate)
			state = newState
			local targetPos = state and UDim2.fromOffset(26, 2) or UDim2.fromOffset(2, 2)
			if animate then
				TweenService:Create(pill, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
					BackgroundTransparency = state and 0.85 or 0.88,
				}):Play()
				TweenService:Create(pillGrad, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
					BackgroundColor3 = state and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(180, 200, 230),
				}):Play()
				TweenService:Create(knob, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = targetPos,
				}):Play()
			else
				pillGrad.BackgroundColor3 = state and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(180, 200, 230)
				knob.Position = targetPos
			end
			if opts.Callback then
				pcall(opts.Callback, state)
			end
		end

		btn.MouseButton1Down:Connect(function()
			TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.fromOffset(32, 30),
			}):Play()
		end)
		btn.MouseButton1Up:Connect(function()
			TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(28, 28),
			}):Play()
			setState(not state, true)
			hapticSmall()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
				Size = UDim2.fromOffset(28, 28),
			}):Play()
		end)
		return holder
	end

	tab.Slider = function(opts)
		local min = opts.Min or 0
		local max = opts.Max or 100
		local value = opts.Default or min

		local holder = makeRow(64)
		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Slider",
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 10),
			Size = UDim2.new(1, -80, 0, 18),
			ZIndex = 11,
			Parent = holder,
		})
		local valueLbl = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = tostring(value),
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.SecondaryLabel,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -70, 0, 10),
			Size = UDim2.fromOffset(54, 18),
			ZIndex = 11,
			Parent = holder,
		})

		local track = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -32, 0, 6),
			Position = UDim2.new(0, 16, 1, -22),
			ZIndex = 11,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = track,
		})

		local fill = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.2,
			BorderSizePixel = 0,
			Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			ZIndex = 12,
			Parent = track,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = fill,
		})

		local knob = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(24, 24),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
			ZIndex = 13,
			Parent = track,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.4,
			Parent = knob,
		})

		local knobSpec = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.45, 0),
			ZIndex = 14,
			Parent = knob,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knobSpec,
		})
		newInstance("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Parent = knobSpec,
		})

		local dragging = false
		local function update(input)
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			value = min + (max - min) * rel
			value = math.floor(value * 100 + 0.5) / 100
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valueLbl.Text = tostring(value)
			if opts.Callback then
				pcall(opts.Callback, value)
			end
		end

		local hit = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.new(1, 0, 0, 34),
			Position = UDim2.new(0, 0, 1, -36),
			ZIndex = 15,
			Parent = holder,
		})

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(input)
				TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {
					Size = UDim2.fromOffset(28, 28),
				}):Play()
				hapticSmall()
			end
		end)

		table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end))

		table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				if dragging then
					dragging = false
					TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(24, 24),
					}):Play()
				end
			end
		end))

		return holder
	end

	tab.Input = function(opts)
		local holder = makeRow(52)
		local box = newInstance("TextBox", {
			BackgroundTransparency = 1,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or "Enter text",
			PlaceholderColor3 = CONFIG.SecondaryLabel,
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -32, 1, 0),
			ZIndex = 11,
			Parent = holder,
		})

		local focusStroke = newInstance("UIStroke", {
			Color = Color3.fromRGB(10, 132, 255),
			Thickness = 1.5,
			Transparency = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = holder,
		})

		box.Focused:Connect(function()
			TweenService:Create(focusStroke, TweenInfo.new(0.2), { Transparency = 0.1 }):Play()
		end)
		box.FocusLost:Connect(function()
			TweenService:Create(focusStroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
			if opts.Callback then
				pcall(opts.Callback, box.Text)
			end
		end)
		return holder
	end

	tab.Keybind = function(opts)
		local holder = makeRow(52)
		local current = opts.Default or Enum.KeyCode.F
		local picking = false

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Keybind",
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -110, 1, 0),
			ZIndex = 11,
			Parent = holder,
		})

		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Text = current.Name,
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.Label,
			Size = UDim2.fromOffset(80, 30),
			Position = UDim2.new(1, -96, 0.5, -15),
			ZIndex = 11,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = valueLbl,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.6,
			Parent = valueLbl,
		})

		valueLbl.MouseButton1Click:Connect(function()
			picking = true
			valueLbl.Text = "..."
		end)

		table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
			if picking then
				if input.UserInputType == Enum.UserInputType.Keyboard then
					current = input.KeyCode
					valueLbl.Text = current.Name
					picking = false
					if opts.Callback then
						pcall(opts.Callback, current)
					end
					return
				end
				return
			end
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current then
				if opts.Callback then
					pcall(opts.Callback, current)
				end
			end
		end))

		return holder
	end

	tab.Dropdown = function(opts)
		local values = opts.Values or {}
		local holder = makeRow(52)

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Dropdown",
			Font = CONFIG.Font,
			TextSize = 15,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -110, 1, 0),
			ZIndex = 11,
			Parent = holder,
		})

		local current = opts.Default
		if not current and values[1] then
			current = type(values[1]) == "table" and (values[1].Title or tostring(values[1])) or tostring(values[1])
		end

		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Text = tostring(current or "--"),
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromOffset(120, 30),
			Position = UDim2.new(1, -136, 0.5, -15),
			ZIndex = 11,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = valueLbl,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.6,
			Parent = valueLbl,
		})
		newInstance("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			Parent = valueLbl,
		})

		local itemHeight = 40
		local contentHeight = #values * itemHeight + 16
		local maxHeight = 260
		local finalHeight = math.min(contentHeight, maxHeight)

		local sheetGui = newInstance("ScreenGui", {
			Name = "LiquidSheet",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 150,
			Parent = self.Parent,
		})

		local sheetBackdrop = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 200,
			Parent = sheetGui,
		})

		local sheet = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, finalHeight + 40),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 201,
			Parent = sheetGui,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 20),
			Parent = sheet,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.7,
			Parent = sheet,
		})

		local sheetGrad = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(180, 200, 230),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 201,
			Parent = sheet,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 20),
			Parent = sheetGrad,
		})
		newInstance("UIGradient", {
			Rotation = 135,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.6),
				NumberSequenceKeypoint.new(1, 0.95),
			}),
			Parent = sheetGrad,
		})

		local handle = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(36, 5),
			Position = UDim2.new(0.5, -18, 0, 8),
			ZIndex = 202,
			Parent = sheet,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = handle,
		})

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Select",
			Font = CONFIG.FontBold,
			TextSize = 17,
			TextColor3 = CONFIG.Label,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(1, 0, 0, 24),
			ZIndex = 202,
			Parent = sheet,
		})

		local scroll = newInstance("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -24, 1, -64),
			Position = UDim2.new(0, 12, 0, 52),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = CONFIG.SecondaryLabel,
			ScrollBarImageTransparency = 0.5,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
			ZIndex = 202,
			Parent = sheet,
		})
		newInstance("UIListLayout", {
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = scroll,
		})
		newInstance("UIPadding", {
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 12),
			Parent = scroll,
		})

		local open = false

		local function closeSheet()
			open = false
			TweenService:Create(sheet, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.new(0, 0, 1, 0),
			}):Play()
			TweenService:Create(sheetBackdrop, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			}):Play()
			task.delay(0.28, function()
				if not open then
					sheet.Visible = false
					sheetBackdrop.Visible = false
				end
			end)
		end

		local function openSheet()
			open = true
			sheet.Visible = true
			sheetBackdrop.Visible = true
			sheet.Position = UDim2.new(0, 0, 1, 0)
			TweenService:Create(sheet, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 1, -10),
			}):Play()
			TweenService:Create(sheetBackdrop, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.45,
			}):Play()
			hapticSmall()
		end

		for _, v in ipairs(values) do
			local title = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
			local opt = newInstance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = title,
				Font = CONFIG.Font,
				TextSize = 15,
				TextColor3 = CONFIG.Label,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, itemHeight),
				AutoButtonColor = false,
				ZIndex = 203,
				Parent = scroll,
			})
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 10),
				Parent = opt,
			})
			newInstance("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
				Parent = opt,
			})
			opt.MouseEnter:Connect(function()
				TweenService:Create(opt, TweenInfo.new(0.15), { BackgroundTransparency = 0.9 }):Play()
			end)
			opt.MouseLeave:Connect(function()
				TweenService:Create(opt, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
			end)
			opt.MouseButton1Click:Connect(function()
				current = title
				valueLbl.Text = title
				if opts.Callback then
					pcall(opts.Callback, v)
				end
				hapticSmall()
				closeSheet()
			end)
		end

		valueLbl.MouseButton1Click:Connect(function()
			if open then
				closeSheet()
			else
				openSheet()
			end
		end)

		sheetBackdrop.MouseButton1Click:Connect(function()
			if open then
				closeSheet()
			end
		end)

		table.insert(self._connections, self.Gui.Destroying:Connect(function()
			sheetGui:Destroy()
		end))

		return holder
	end

	return tab
end

function LiquidGlass:Open()
	self._open = true
	self.Shell.Visible = true
	self._scaleSpring.value = 0.94
	self._scaleSpring.target = 1
	self._alphaSpring.value = 0
	self._alphaSpring.target = 1
	self._blurSpring.value = 0
	self._blurSpring.target = 1
	hapticSmall()
end

function LiquidGlass:Close()
	self._open = false
	self._scaleSpring.target = 0.94
	self._alphaSpring.target = 0
	self._blurSpring.target = 0
	task.delay(0.4, function()
		if not self._open then
			self.Shell.Visible = false
		end
	end)
	hapticSmall()
end

function LiquidGlass:Toggle()
	if self._open then
		self:Close()
	else
		self:Open()
	end
end

function LiquidGlass:Destroy()
	self._alive = false
	for _, c in ipairs(self._connections) do
		if c then
			c:Disconnect()
		end
	end
	self._connections = {}
	if self.Gui then
		self.Gui:Destroy()
	end
end

return LiquidGlass
