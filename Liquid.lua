local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LOCAL_PLAYER = Players.LocalPlayer

local CONFIG = {
	Accent = Color3.fromRGB(0, 145, 255),
	Background = Color3.fromRGB(16, 16, 16),
	Dialog = Color3.fromRGB(26, 26, 26),
	PanelBackground = Color3.fromRGB(0, 0, 0),
	PanelBackgroundTransparency = 0.55,
	ElementBackground = Color3.fromRGB(30, 30, 34),
	ElementBackgroundTransparency = 0,
	ElementTitle = Color3.fromRGB(255, 255, 255),
	ElementDesc = Color3.fromRGB(220, 225, 235),
	TabBackground = Color3.fromRGB(255, 255, 255),
	TabBackgroundActive = Color3.fromRGB(60, 60, 65),
	TabText = Color3.fromRGB(255, 255, 255),
	TabTextTransparency = 0.45,
	TabTextTransparencyActive = 0,
	Toggle = Color3.fromRGB(51, 199, 89),
	Slider = Color3.fromRGB(0, 145, 255),
	SliderThumb = Color3.fromRGB(255, 255, 255),
	Outline = Color3.fromRGB(255, 255, 255),
	GlassTint = Color3.fromRGB(255, 255, 255),
	GlassTransparency = 0.97,
	CornerRadius = 16,
	ElementRadius = 12,
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	Noise = "rbxassetid://243098098",
	Shadow = "rbxassetid://8992230677",
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

function LiquidGlass.new(opts)
	local self = setmetatable({}, LiquidGlass)
	opts = opts or {}
	self._connections = {}
	self._springs = {}
	self._tabs = {}
	self._alive = true
	self._open = false
	self._dragging = false

	self.Title = opts.Title or "WindUI"
	self.Author = opts.Author or ""
	self.Size = opts.Size or UDim2.fromOffset(580, 460)
	self.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self.Parent = opts.Parent or LOCAL_PLAYER:WaitForChild("PlayerGui")
	self.SideBarWidth = opts.SideBarWidth or 200
	self.MobileButton = opts.MobileButton ~= false
	self.MobileButtonPosition = opts.MobileButtonPosition or UDim2.new(0, 20, 0.5, -25)

	self._scaleSpring = Spring.new(0.95)
	self._alphaSpring = Spring.new(0)

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
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Size = UDim2.new(1, 80, 1, 80),
		Position = UDim2.new(0, -40, 0, -40),
		ZIndex = 0,
		Parent = self.Shell,
	})

	self.Panel = newInstance("Frame", {
		Name = "Panel",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = self.Shell,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.Panel,
	})

	self.GlassLayer = newInstance("Frame", {
		Name = "GlassLayer",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.GlassLayer,
	})
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(0.5, 0.99),
			NumberSequenceKeypoint.new(1, 0.94),
		}),
		Parent = self.GlassLayer,
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
		ZIndex = 4,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.Noise,
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
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 10,
		Parent = self.Panel,
	})

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = CONFIG.FontBold,
		TextSize = 16,
		TextColor3 = CONFIG.ElementTitle,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 14),
		Size = UDim2.new(1, -120, 0, 20),
		ZIndex = 10,
		Parent = self.Header,
	})

	if self.Author ~= "" then
		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = self.Author,
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.ElementDesc,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(20, 30),
			Size = UDim2.new(1, -120, 0, 14),
			ZIndex = 10,
			Parent = self.Header,
		})
	end

	local minBtn = newInstance("TextButton", {
		BackgroundColor3 = Color3.fromRGB(255, 200, 80),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.new(1, -52, 0, 19),
		ZIndex = 10,
		Parent = self.Header,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = minBtn })
	minBtn.MouseButton1Click:Connect(function() self:Toggle() end)

	local closeBtn = newInstance("TextButton", {
		BackgroundColor3 = Color3.fromRGB(255, 90, 95),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.fromOffset(13, 13),
		Position = UDim2.new(1, -30, 0, 19),
		ZIndex = 10,
		Parent = self.Header,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = closeBtn })
	closeBtn.MouseButton1Click:Connect(function() self:Close() end)

	self.SidebarBackground = newInstance("Frame", {
		Name = "SidebarBg",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(0, self.SideBarWidth, 1, -52),
		Position = UDim2.new(0, 0, 0, 52),
		ZIndex = 9,
		Parent = self.Panel,
	})

	self.SidebarContainer = newInstance("Frame", {
		Name = "SidebarContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, self.SideBarWidth, 1, -52),
		Position = UDim2.new(0, 0, 0, 52),
		ZIndex = 10,
		Parent = self.Panel,
	})

	self.Sidebar = newInstance("ScrollingFrame", {
		Name = "Sidebar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -14, 1, -14),
		Position = UDim2.fromOffset(14, 0),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		ZIndex = 10,
		Parent = self.SidebarContainer,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Sidebar,
	})

	self.ContentContainer = newInstance("Frame", {
		Name = "ContentContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -self.SideBarWidth, 1, -52),
		Position = UDim2.new(1, 0, 0, 52),
		AnchorPoint = Vector2.new(1, 0),
		ZIndex = 10,
		Parent = self.Panel,
	})

	self.PanelBackground = newInstance("Frame", {
		Name = "PanelBg",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -14, 1, -14),
		Position = UDim2.fromOffset(7, 7),
		ZIndex = 10,
		Parent = self.ContentContainer,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius - 6),
		Parent = self.PanelBackground,
	})
	newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.8,
		Parent = self.PanelBackground,
	})

	self.Content = newInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -28, 1, -14),
		Position = UDim2.fromOffset(14, 7),
		ZIndex = 11,
		Parent = self.ContentContainer,
	})
end

function LiquidGlass:_buildMobileButton()
	local btn = newInstance("TextButton", {
		Name = "MobileToggle",
		BackgroundColor3 = CONFIG.ElementBackground,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.fromOffset(50, 50),
		Position = self.MobileButtonPosition,
		AutoButtonColor = false,
		ZIndex = 99,
		Parent = self.Gui,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
	newInstance("UIStroke", {
		Color = CONFIG.Outline,
		Thickness = 1,
		Transparency = 0.75,
		Parent = btn,
	})

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = "☰",
		Font = CONFIG.FontBold,
		TextSize = 22,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 100,
		Parent = btn,
	})

	local scale = newInstance("UIScale", { Scale = 1, Parent = btn })

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
			TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 0.92 }):Play()
		end
	end)

	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then moved = true end
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

		self.Shell.Size = UDim2.new(
			self.Size.X.Scale * s,
			self.Size.X.Offset * s,
			self.Size.Y.Scale * s,
			self.Size.Y.Offset * s
		)

		self.Panel.BackgroundTransparency = 1 - 0.45 * a
		self.GlassLayer.BackgroundTransparency = 1 - 0.97 * a
		self.Noise.ImageTransparency = 1 - 0.04 * a
		self.Edge.Transparency = 1 - 0.7 * a
		self.Shadow.ImageTransparency = 1 - 0.5 * a
		self.Backdrop.BackgroundTransparency = 1 - 0.4 * a

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

	local tabBtn = newInstance("TextButton", {
		BackgroundColor3 = CONFIG.TabBackgroundActive,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = name,
		Font = CONFIG.Font,
		TextSize = 14,
		TextColor3 = CONFIG.TabText,
		TextTransparency = CONFIG.TabTextTransparency,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false,
		ZIndex = 11,
		Parent = self.Sidebar,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = tabBtn,
	})
	newInstance("UIStroke", {
		Color = CONFIG.Outline,
		Thickness = 1,
		Transparency = 1,
		Parent = tabBtn,
	})
	newInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		Parent = tabBtn,
	})

	local list = newInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = CONFIG.Accent,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Visible = false,
		ZIndex = 11,
		Parent = self.Content,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})
	newInstance("UIPadding", {
		PaddingRight = UDim.new(0, 6),
		Parent = list,
	})

	tab._scroll = list
	tab._btn = tabBtn

	table.insert(self._tabs, tab)

	local function selectThis()
		for _, t in ipairs(self._tabs) do
			t._scroll.Visible = false
			TweenService:Create(t._btn, TweenInfo.new(0.2), {
				BackgroundTransparency = 1,
				TextTransparency = CONFIG.TabTextTransparency,
			}):Play()
		end
		list.Visible = true
		TweenService:Create(tabBtn, TweenInfo.new(0.2), {
			BackgroundTransparency = 0.15,
			TextTransparency = CONFIG.TabTextTransparencyActive,
		}):Play()
	end

	if #self._tabs == 1 then
		selectThis()
	end

	tabBtn.MouseButton1Click:Connect(selectThis)

	local function createRow(height)
		local row = newInstance("Frame", {
			BackgroundColor3 = CONFIG.ElementBackground,
			BackgroundTransparency = CONFIG.ElementBackgroundTransparency,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height),
			ZIndex = 11,
			Parent = list,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, CONFIG.ElementRadius),
			Parent = row,
		})
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.85,
			Parent = row,
		})
		return row
	end

	tab.Label = function(opts)
		return newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "",
			Font = CONFIG.FontBold,
			TextSize = 13,
			TextColor3 = CONFIG.ElementDesc,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 22),
			ZIndex = 11,
			Parent = list,
		})
	end

	tab.Separator = function()
		return newInstance("Frame", {
			BackgroundColor3 = CONFIG.Outline,
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -16, 0, 1),
			Position = UDim2.fromOffset(16, 0),
			ZIndex = 11,
			Parent = list,
		})
	end

	tab.Button = function(opts)
		local holder = createRow(42)
		local scale = newInstance("UIScale", { Scale = 1, Parent = holder })

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Button",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -50, 1, 0),
			ZIndex = 12,
			Parent = holder,
		})

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = "›",
			Font = CONFIG.FontBold,
			TextSize = 20,
			TextColor3 = CONFIG.ElementDesc,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -28, 0, 0),
			Size = UDim2.fromOffset(18, 42),
			ZIndex = 12,
			Parent = holder,
		})

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 13,
			Parent = holder,
		})

		local sp = Spring.new(0, 260, 24)
		table.insert(self._springs, {
			spring = sp,
			apply = function(v)
				holder.BackgroundTransparency = v * 0.15
			end,
		})
		holder.MouseEnter:Connect(function() sp.target = 1 end)
		holder.MouseLeave:Connect(function() sp.target = 0 end)

		btn.MouseButton1Down:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 0.97 }):Play()
		end)
		btn.MouseButton1Up:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
			if opts.Callback then pcall(opts.Callback) end
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(scale, TweenInfo.new(0.2), { Scale = 1 }):Play()
		end)
		return holder
	end

	tab.Toggle = function(opts)
		local holder = createRow(42)
		local state = opts.Default or false

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Toggle",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -80, 1, 0),
			ZIndex = 12,
			Parent = holder,
		})

		local pill = newInstance("Frame", {
			BackgroundColor3 = state and CONFIG.Toggle or Color3.fromRGB(60, 60, 65),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(38, 22),
			Position = UDim2.new(1, -52, 0.5, -11),
			ZIndex = 12,
			Parent = holder,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })

		local knob = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(18, 18),
			Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.fromOffset(2, 2),
			ZIndex = 13,
			Parent = pill,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 14,
			Parent = holder,
		})

		local function setState(newState, animate)
			state = newState
			local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.fromOffset(2, 2)
			if animate then
				TweenService:Create(pill, TweenInfo.new(0.25), {
					BackgroundColor3 = state and CONFIG.Toggle or Color3.fromRGB(60, 60, 65),
				}):Play()
				TweenService:Create(knob, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = targetPos,
				}):Play()
			else
				pill.BackgroundColor3 = state and CONFIG.Toggle or Color3.fromRGB(60, 60, 65)
				knob.Position = targetPos
			end
			if opts.Callback then pcall(opts.Callback, state) end
		end

		btn.MouseButton1Click:Connect(function()
			setState(not state, true)
		end)
		return holder
	end

	tab.Slider = function(opts)
		local min = opts.Min or 0
		local max = opts.Max or 100
		local value = opts.Default or min

		local holder = createRow(52)
		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Slider",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 6),
			Size = UDim2.new(1, -70, 0, 16),
			ZIndex = 12,
			Parent = holder,
		})
		local valueLbl = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = tostring(value),
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.ElementDesc,
			TextTransparency = 0.2,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -60, 0, 6),
			Size = UDim2.fromOffset(46, 16),
			ZIndex = 12,
			Parent = holder,
		})

		local track = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(60, 60, 65),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -28, 0, 4),
			Position = UDim2.new(0, 14, 1, -16),
			ZIndex = 12,
			Parent = holder,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

		local fill = newInstance("Frame", {
			BackgroundColor3 = CONFIG.Slider,
			BorderSizePixel = 0,
			Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			ZIndex = 13,
			Parent = track,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })

		local knob = newInstance("Frame", {
			BackgroundColor3 = CONFIG.SliderThumb,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
			ZIndex = 14,
			Parent = track,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

		local dragging = false
		local function update(input)
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			value = min + (max - min) * rel
			value = math.floor(value * 100 + 0.5) / 100
			fill.Size = UDim2.new(rel, 0, 1, 0)
			knob.Position = UDim2.new(rel, 0, 0.5, 0)
			valueLbl.Text = tostring(value)
			if opts.Callback then pcall(opts.Callback, value) end
		end

		local hit = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 1, -32),
			ZIndex = 15,
			Parent = holder,
		})

		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(input)
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
				dragging = false
			end
		end))

		return holder
	end

	tab.Input = function(opts)
		local holder = createRow(42)
		local box = newInstance("TextBox", {
			BackgroundTransparency = 1,
			Text = opts.Default or "",
			PlaceholderText = opts.Placeholder or "Enter text",
			PlaceholderColor3 = CONFIG.ElementDesc,
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -28, 1, 0),
			ZIndex = 12,
			Parent = holder,
		})
		box.FocusLost:Connect(function()
			if opts.Callback then pcall(opts.Callback, box.Text) end
		end)
		return holder
	end

	tab.Keybind = function(opts)
		local holder = createRow(42)
		local current = opts.Default or Enum.KeyCode.F
		local picking = false

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Keybind",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -110, 1, 0),
			ZIndex = 12,
			Parent = holder,
		})

		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Text = current.Name,
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.ElementTitle,
			Size = UDim2.fromOffset(80, 28),
			Position = UDim2.new(1, -94, 0.5, -14),
			ZIndex = 12,
			Parent = holder,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = valueLbl })

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
					if opts.Callback then pcall(opts.Callback, current) end
				end
				return
			end
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current then
				if opts.Callback then pcall(opts.Callback, current) end
			end
		end))

		return holder
	end

	tab.Dropdown = function(opts)
		local values = opts.Values or {}
		local holder = createRow(42)

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Dropdown",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -110, 1, 0),
			ZIndex = 12,
			Parent = holder,
		})

		local current = opts.Default
		if not current and values[1] then
			current = type(values[1]) == "table" and (values[1].Title or tostring(values[1])) or tostring(values[1])
		end

		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Text = tostring(current or "--"),
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromOffset(110, 28),
			Position = UDim2.new(1, -124, 0.5, -14),
			ZIndex = 12,
			Parent = holder,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = valueLbl })
		newInstance("UIPadding", { PaddingRight = UDim.new(0, 10), Parent = valueLbl })

		local itemHeight = 34
		local contentHeight = #values * itemHeight + 12
		local maxHeight = 240
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
			BackgroundColor3 = CONFIG.Dialog,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, finalHeight + 40),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 201,
			Parent = sheetGui,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = sheet })
		newInstance("UIStroke", {
			Color = CONFIG.Outline,
			Thickness = 1,
			Transparency = 0.85,
			Parent = sheet,
		})

		local handle = newInstance("Frame", {
			BackgroundColor3 = CONFIG.Outline,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(36, 4),
			Position = UDim2.new(0.5, -18, 0, 8),
			ZIndex = 202,
			Parent = sheet,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = handle })

		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Select",
			Font = CONFIG.FontBold,
			TextSize = 16,
			TextColor3 = CONFIG.ElementTitle,
			TextXAlignment = Enum.TextXAlignment.Center,
			Position = UDim2.new(0, 0, 0, 18),
			Size = UDim2.new(1, 0, 0, 22),
			ZIndex = 202,
			Parent = sheet,
		})

		local scroll = newInstance("ScrollingFrame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -20, 1, -60),
			Position = UDim2.new(0, 10, 0, 48),
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = CONFIG.Accent,
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
			PaddingBottom = UDim.new(0, 10),
			Parent = scroll,
		})

		local open = false

		local function closeSheet()
			open = false
			TweenService:Create(sheet, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.new(0, 0, 1, 0),
			}):Play()
			TweenService:Create(sheetBackdrop, TweenInfo.new(0.25), {
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
			TweenService:Create(sheet, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 1, -10),
			}):Play()
			TweenService:Create(sheetBackdrop, TweenInfo.new(0.3), {
				BackgroundTransparency = 0.5,
			}):Play()
		end

		for _, v in ipairs(values) do
			local title = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
			local opt = newInstance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = title,
				Font = CONFIG.Font,
				TextSize = 14,
				TextColor3 = CONFIG.ElementTitle,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, itemHeight),
				AutoButtonColor = false,
				ZIndex = 203,
				Parent = scroll,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = opt })
			newInstance("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = opt })
			opt.MouseEnter:Connect(function()
				TweenService:Create(opt, TweenInfo.new(0.15), { BackgroundTransparency = 0.9 }):Play()
			end)
			opt.MouseLeave:Connect(function()
				TweenService:Create(opt, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
			end)
			opt.MouseButton1Click:Connect(function()
				current = title
				valueLbl.Text = title
				if opts.Callback then pcall(opts.Callback, v) end
				closeSheet()
			end)
		end

		valueLbl.MouseButton1Click:Connect(function()
			if open then closeSheet() else openSheet() end
		end)

		sheetBackdrop.MouseButton1Click:Connect(function()
			if open then closeSheet() end
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
	self._scaleSpring.value = 0.95
	self._scaleSpring.target = 1
	self._alphaSpring.value = 0
	self._alphaSpring.target = 1
end

function LiquidGlass:Close()
	self._open = false
	self._scaleSpring.target = 0.95
	self._alphaSpring.target = 0
	task.delay(0.4, function()
		if not self._open then
			self.Shell.Visible = false
		end
	end)
end

function LiquidGlass:Toggle()
	if self._open then self:Close() else self:Open() end
end

function LiquidGlass:Destroy()
	self._alive = false
	for _, c in ipairs(self._connections) do
		if c then c:Disconnect() end
	end
	self._connections = {}
	if self.Gui then self.Gui:Destroy() end
end

return LiquidGlass
