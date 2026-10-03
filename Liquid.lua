local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LOCAL_PLAYER = Players.LocalPlayer
local MOUSE = LOCAL_PLAYER:GetMouse()

local CONFIG = {
	Accent = Color3.fromRGB(120, 170, 255),
	BaseColor = Color3.fromRGB(18, 20, 28),
	GlassTint = Color3.fromRGB(255, 255, 255),
	GlassTransparency = 0.88,
	PanelTransparency = 0.82,
	CornerRadius = 22,
	MagnifierRadius = 110,
	MagnifierZoom = 1.85,
	MagnifierStrength = 1,
	MagnifierFalloff = 2.4,
	SpringStiffness = 220,
	SpringDamping = 26,
	SpringMass = 1,
	OpenDuration = 0.55,
	CloseDuration = 0.38,
	HoverScale = 1.04,
	PressScale = 0.96,
	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	Noise = "rbxassetid://243098098",
	MagnifierMask = "rbxassetid://5028857084",
	Shadow = "rbxassetid://8992230677",
	OpenButtonIcon = "rbxassetid://120997033468887",
}

local function newInstance(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, c in ipairs(children or {}) do
		c.Parent = inst
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
		stiffness = stiffness or CONFIG.SpringStiffness,
		damping = damping or CONFIG.SpringDamping,
		mass = mass or CONFIG.SpringMass,
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
	self._items = {}
	self._tabs = {}
	self._alive = true
	self._open = false
	self._dragging = false
	self._magnifierEnabled = true

	self.Title = opts.Title or "LiquidGlass"
	self.Author = opts.Author or ""
	self.Icon = opts.Icon
	self.Size = opts.Size or UDim2.fromOffset(580, 440)
	self.Position = opts.Position or UDim2.fromScale(0.5, 0.5)
	self.MinSize = opts.MinSize or Vector2.new(480, 320)
	self.MaxSize = opts.MaxSize or Vector2.new(900, 620)
	self.Resizable = opts.Resizable ~= false
	self.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self.Parent = opts.Parent or LOCAL_PLAYER:WaitForChild("PlayerGui")

	self._scaleSpring = Spring.new(0.92)
	self._alphaSpring = Spring.new(0)
	self._blurSpring = Spring.new(0)

	self:_build()
	self:_startLoop()
	self:_bindInput()
	self:_bindMagnifier()
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

	self.ShellCorner = newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.Shell,
	})

	self.Panel = newInstance("Frame", {
		Name = "Panel",
		BackgroundColor3 = CONFIG.BaseColor,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		Parent = self.Shell,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.Panel,
	})

	self.GlassLayer = newInstance("Frame", {
		Name = "GlassLayer",
		BackgroundColor3 = CONFIG.GlassTint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.GlassLayer,
	})
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(1, 0.5),
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

	self.MagnifierCopy = newInstance("Frame", {
		Name = "MagnifierCopy",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 6,
		Parent = self.Panel,
	})

	self.MagnifierContent = newInstance("Frame", {
		Name = "MagnifierContent",
		BackgroundColor3 = CONFIG.BaseColor,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 6,
		Parent = self.MagnifierCopy,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, CONFIG.CornerRadius),
		Parent = self.MagnifierContent,
	})
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(0.5, 0.9),
			NumberSequenceKeypoint.new(1, 0.5),
		}),
		Parent = self.MagnifierContent,
	})

	self.MagnifierMask = newInstance("ImageLabel", {
		Name = "MagnifierMask",
		BackgroundTransparency = 1,
		Image = CONFIG.MagnifierMask,
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0,
		Size = UDim2.fromOffset(CONFIG.MagnifierRadius * 2, CONFIG.MagnifierRadius * 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 7,
		Visible = false,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.MagnifierMask,
	})

	self.MagnifierGlow = newInstance("ImageLabel", {
		Name = "MagnifierGlow",
		BackgroundTransparency = 1,
		Image = CONFIG.MagnifierMask,
		ImageColor3 = CONFIG.Accent,
		ImageTransparency = 0.4,
		Size = UDim2.fromOffset(CONFIG.MagnifierRadius * 2 + 8, CONFIG.MagnifierRadius * 2 + 8),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ZIndex = 5,
		Visible = false,
		Parent = self.Panel,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = self.MagnifierGlow,
	})

	self.Header = newInstance("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 54),
		ZIndex = 10,
		Parent = self.Panel,
	})

	self.HeaderIcon = newInstance("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = self.Icon or CONFIG.OpenButtonIcon,
		ImageColor3 = Color3.fromRGB(235, 242, 255),
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.fromOffset(20, 16),
		ZIndex = 10,
		Parent = self.Header,
	})

	self.TitleLabel = newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = self.Title,
		Font = CONFIG.FontBold,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(240, 245, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(52, 12),
		Size = UDim2.new(1, -140, 0, 18),
		ZIndex = 10,
		Parent = self.Header,
	})

	self.AuthorLabel = newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = self.Author,
		Font = CONFIG.Font,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(180, 195, 220),
		TextTransparency = 0.35,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(52, 30),
		Size = UDim2.new(1, -140, 0, 14),
		ZIndex = 10,
		Parent = self.Header,
	})

	local function topBtn(color, xOff, cb)
		local b = newInstance("TextButton", {
			BackgroundColor3 = color,
			BackgroundTransparency = 0.25,
			BorderSizePixel = 0,
			Text = "",
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.new(1, xOff, 0, 20),
			ZIndex = 10,
			Parent = self.Header,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = b,
		})
		b.MouseButton1Click:Connect(cb)
		return b
	end

	self.CloseBtn = topBtn(Color3.fromRGB(255, 90, 95), -28, function()
		self:Close()
	end)
	self.MinBtn = topBtn(Color3.fromRGB(255, 200, 80), -50, function()
		self:Toggle()
	end)
	self.FullBtn = topBtn(Color3.fromRGB(100, 220, 120), -72, function()
		self:ToggleFullscreen()
	end)

	self.Sidebar = newInstance("ScrollingFrame", {
		Name = "Sidebar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 160, 1, -80),
		Position = UDim2.fromOffset(14, 62),
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
		Parent = self.Panel,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Sidebar,
	})

	self.Content = newInstance("ScrollingFrame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -200, 1, -80),
		Position = UDim2.fromOffset(186, 62),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = CONFIG.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ZIndex = 10,
		Parent = self.Panel,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = self.Content,
	})
	newInstance("UIPadding", {
		PaddingRight = UDim.new(0, 8),
		Parent = self.Content,
	})
end

function LiquidGlass:_bindMagnifier()
	local panel = self.Panel
	local copy = self.MagnifierCopy
	local content = self.MagnifierContent
	local mask = self.MagnifierMask
	local glow = self.MagnifierGlow
	local backdrop = self.Backdrop

	local conn = RunService.RenderStepped:Connect(function()
		if not self._alive or not self._magnifierEnabled or not self._open then
			copy.Visible = false
			mask.Visible = false
			glow.Visible = false
			return
		end

		local mouse = UserInputService:GetMouseLocation()
		local absPos = panel.AbsolutePosition
		local absSize = panel.AbsoluteSize

		local localX = mouse.X - absPos.X
		local localY = mouse.Y - absPos.Y

		if localX < 0 or localY < 0 or localX > absSize.X or localY > absSize.Y then
			copy.Visible = false
			mask.Visible = false
			glow.Visible = false
			return
		end

		local cx = absSize.X * 0.5
		local cy = absSize.Y * 0.5
		local dx = localX - cx
		local dy = localY - cy
		local dist = math.sqrt(dx * dx + dy * dy)
		local maxDist = math.max(absSize.X, absSize.Y) * 0.5
		local falloff = math.clamp(1 - dist / maxDist, 0, 1)
		falloff = falloff ^ CONFIG.MagnifierFalloff
		local strength = falloff * CONFIG.MagnifierStrength

		if strength <= 0.02 then
			copy.Visible = false
			mask.Visible = false
			glow.Visible = false
			return
		end

		copy.Visible = true
		mask.Visible = true
		glow.Visible = true

		local zoom = 1 + (CONFIG.MagnifierZoom - 1) * strength
		local tx = cx + (localX - cx) * (1 - 1 / zoom)
		local ty = cy + (localY - cy) * (1 - 1 / zoom)

		content.Size = UDim2.fromScale(zoom, zoom)
		content.Position = UDim2.fromOffset(-tx, -ty)
		content.BackgroundTransparency = 1 - (0.2 + strength * 0.6)

		local radius = CONFIG.MagnifierRadius * (0.9 + strength * 0.3)
		mask.Size = UDim2.fromOffset(radius * 2, radius * 2)
		mask.Position = UDim2.fromOffset(localX, localY)
		mask.ImageTransparency = 1 - strength

		glow.Size = UDim2.fromOffset(radius * 2 + 10, radius * 2 + 10)
		glow.Position = UDim2.fromOffset(localX, localY)
		glow.ImageTransparency = 1 - strength * 0.6
	end)
	table.insert(self._connections, conn)
end

function LiquidGlass:_startLoop()
	local last = tick()
	local conn = RunService.RenderStepped:Connect(function()
		if not self._alive then
			return
		end
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

		self.Panel.BackgroundTransparency = 1 - (1 - CONFIG.PanelTransparency) * a
		self.GlassLayer.BackgroundTransparency = 1 - (1 - CONFIG.GlassTransparency) * a
		self.Noise.ImageTransparency = 1 - 0.05 * a
		self.Edge.Transparency = 1 - 0.35 * a
		self.Backdrop.BackgroundTransparency = 1 - 0.5 * b

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

	local function begin(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			self._dragging = true
			startMouse = input.Position
			startPos = shell.Position
			self._scaleSpring.target = 1.02
		end
	end
	local function move(input)
		if not self._dragging then return end
		local delta = input.Position - startMouse
		shell.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
	local function finish()
		if not self._dragging then return end
		self._dragging = false
		self._scaleSpring.target = 1
		self.Position = shell.Position
	end

	table.insert(self._connections, header.InputBegan:Connect(begin))
	table.insert(self._connections, UserInputService.InputChanged:Connect(move))
	table.insert(self._connections, UserInputService.InputEnded:Connect(finish))

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end))
end

function LiquidGlass:_makeHoverSpring(obj, baseTransparency, hoverTransparency)
	local sp = Spring.new(0, 260, 24)
	table.insert(self._springs, {
		spring = sp,
		apply = function(v)
			obj.BackgroundTransparency = baseTransparency - (baseTransparency - hoverTransparency) * v
		end,
	})
	obj.MouseEnter:Connect(function()
		sp.target = 1
	end)
	obj.MouseLeave:Connect(function()
		sp.target = 0
	end)
	return sp
end

function LiquidGlass:Tab(name, icon)
	local tab = {}
	tab.Name = name

	local tabBtn = newInstance("TextButton", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Text = name,
		Font = CONFIG.Font,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(220, 230, 250),
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 36),
		ZIndex = 10,
		Parent = self.Sidebar,
	})
	newInstance("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = tabBtn,
	})
	newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.9,
		Parent = tabBtn,
	})
	newInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		Parent = tabBtn,
	})

	local list = newInstance("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = 10,
		Parent = self.Content,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})

	self:_makeHoverSpring(tabBtn, 0.94, 0.86)

	tabBtn.MouseButton1Click:Connect(function()
		for _, t in ipairs(self._tabs) do
			t.list.Visible = false
			TweenService:Create(t.btn, TweenInfo.new(0.2), { BackgroundTransparency = 0.94 }):Play()
			t.btn.TextColor3 = Color3.fromRGB(220, 230, 250)
		end
		list.Visible = true
		TweenService:Create(tabBtn, TweenInfo.new(0.2), { BackgroundTransparency = 0.78 }):Play()
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end)

	table.insert(self._tabs, { btn = tabBtn, list = list, name = name })

	if #self._tabs == 1 then
		list.Visible = true
		tabBtn.BackgroundTransparency = 0.78
		tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	local function createRow(height)
		local row = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.94,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height),
			ZIndex = 10,
			Parent = list,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 12),
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
		local lbl = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "",
			Font = CONFIG.FontBold,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(180, 195, 220),
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 26),
			ZIndex = 10,
			Parent = list,
		})
		return lbl
	end

	tab.Separator = function()
		local sep = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = 10,
			Parent = list,
		})
		return sep
	end

	tab.Button = function(opts)
		local holder = createRow(42)
		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Button",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -32, 1, 0),
			ZIndex = 10,
			Parent = holder,
		})

		local sp = Spring.new(0, 280, 26)
		table.insert(self._springs, {
			spring = sp,
			apply = function(v)
				holder.BackgroundTransparency = 0.94 - v * 0.08
				label.Position = UDim2.fromOffset(16 + v * 4, 0)
			end,
		})
		holder.MouseEnter:Connect(function() sp.target = 1 end)
		holder.MouseLeave:Connect(function() sp.target = 0 end)

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 11,
			Parent = holder,
		})
		btn.MouseButton1Click:Connect(function()
			if opts.Callback then
				pcall(opts.Callback)
			end
		end)
		return holder
	end

	tab.Toggle = function(opts)
		local holder = createRow(42)
		local state = opts.Default or false

		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Toggle",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -80, 1, 0),
			ZIndex = 10,
			Parent = holder,
		})

		local pill = newInstance("Frame", {
			BackgroundColor3 = state and CONFIG.Accent or Color3.fromRGB(80, 85, 100),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(38, 20),
			Position = UDim2.new(1, -54, 0.5, -10),
			ZIndex = 10,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = pill,
		})

		local knob = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(16, 16),
			Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2),
			ZIndex = 11,
			Parent = pill,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob,
		})

		local btn = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.fromScale(1, 1),
			ZIndex = 12,
			Parent = holder,
		})
		btn.MouseButton1Click:Connect(function()
			state = not state
			TweenService:Create(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
				BackgroundColor3 = state and CONFIG.Accent or Color3.fromRGB(80, 85, 100),
			}):Play()
			TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
				Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.fromOffset(2, 2),
			}):Play()
			if opts.Callback then
				pcall(opts.Callback, state)
			end
		end)
		return holder
	end

	tab.Slider = function(opts)
		local min = opts.Min or 0
		local max = opts.Max or 100
		local value = opts.Default or min

		local holder = createRow(56)
		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Slider",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 8),
			Size = UDim2.new(1, -32, 0, 16),
			ZIndex = 10,
			Parent = holder,
		})
		local valueLbl = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = tostring(value),
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(180, 195, 220),
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -60, 0, 8),
			Size = UDim2.fromOffset(44, 16),
			ZIndex = 10,
			Parent = holder,
		})

		local track = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(60, 65, 80),
			BorderSizePixel = 0,
			Size = UDim2.new(1, -32, 0, 6),
			Position = UDim2.new(0, 16, 1, -18),
			ZIndex = 10,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = track,
		})
		local fill = newInstance("Frame", {
			BackgroundColor3 = CONFIG.Accent,
			BorderSizePixel = 0,
			Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
			ZIndex = 11,
			Parent = track,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = fill,
		})
		local knob = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(14, 14),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
			ZIndex = 12,
			Parent = track,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = knob,
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
			Size = UDim2.new(1, 0, 0, 22),
			Position = UDim2.new(0, 0, 1, -24),
			ZIndex = 13,
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
			PlaceholderText = opts.Placeholder or "Nhập...",
			PlaceholderColor3 = Color3.fromRGB(150, 158, 175),
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -32, 1, 0),
			ZIndex = 10,
			Parent = holder,
		})
		box.FocusLost:Connect(function()
			if opts.Callback then
				pcall(opts.Callback, box.Text)
			end
		end)
		return holder
	end

	tab.Keybind = function(opts)
		local holder = createRow(42)
		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Keybind",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -80, 1, 0),
			ZIndex = 10,
			Parent = holder,
		})
		local current = opts.Default or Enum.KeyCode.F
		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Text = current.Name,
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			Size = UDim2.fromOffset(72, 26),
			Position = UDim2.new(1, -88, 0.5, -13),
			ZIndex = 10,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = valueLbl,
		})

		local picking = false
		valueLbl.MouseButton1Click:Connect(function()
			picking = true
			valueLbl.Text = "..."
		end)
		table.insert(self._connections, UserInputService.InputBegan:Connect(function(input)
			if not picking then return end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				current = input.KeyCode
				valueLbl.Text = current.Name
				picking = false
				if opts.Callback then
					pcall(opts.Callback, current)
				end
			end
		end))
		table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe or picking then return end
			if input.KeyCode == current and opts.Callback then
				pcall(opts.Callback, current)
			end
		end))
		return holder
	end

	tab.Dropdown = function(opts)
		local values = opts.Values or {}
		local holder = createRow(42 + (#values > 0 and 0 or 0))
		local label = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = opts.Text or "Dropdown",
			Font = CONFIG.Font,
			TextSize = 14,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -80, 1, 0),
			ZIndex = 10,
			Parent = holder,
		})
		local current = opts.Default or (values[1] and (type(values[1]) == "table" and values[1].Title or values[1]))
		local valueLbl = newInstance("TextButton", {
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0,
			Text = tostring(current or "--"),
			Font = CONFIG.Font,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(235, 242, 255),
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromOffset(120, 26),
			Position = UDim2.new(1, -136, 0.5, -13),
			ZIndex = 10,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 8),
			Parent = valueLbl,
		})
		newInstance("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			Parent = valueLbl,
		})

		local open = false
		local list = newInstance("Frame", {
			BackgroundColor3 = Color3.fromRGB(30, 33, 42),
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 1, 6),
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
			Visible = false,
			ZIndex = 20,
			Parent = holder,
		})
		newInstance("UICorner", {
			CornerRadius = UDim.new(0, 10),
			Parent = list,
		})
		newInstance("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = list,
		})
		newInstance("UIPadding", {
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
			Parent = list,
		})

		for _, v in ipairs(values) do
			local title = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
			local opt = newInstance("TextButton", {
				BackgroundTransparency = 1,
				Text = title,
				Font = CONFIG.Font,
				TextSize = 13,
				TextColor3 = Color3.fromRGB(220, 230, 250),
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 28),
				ZIndex = 21,
				Parent = list,
			})
			newInstance("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
				Parent = opt,
			})
			opt.MouseEnter:Connect(function()
				opt.BackgroundTransparency = 0.9
			end)
			opt.MouseLeave:Connect(function()
				opt.BackgroundTransparency = 1
			end)
			opt.MouseButton1Click:Connect(function()
				current = title
				valueLbl.Text = title
				list.Visible = false
				open = false
				if opts.Callback then
					pcall(opts.Callback, v)
				end
			end)
		end

		valueLbl.MouseButton1Click:Connect(function()
			open = not open
			list.Visible = open
		end)
		return holder
	end

	return tab
end

function LiquidGlass:ToggleFullscreen()
	if not self._fullscreen then
		self._savedSize = self.Size
		self._savedPos = self.Shell.Position
		self._fullscreen = true
		local vp = self.Gui.AbsoluteSize
		local newSize = UDim2.fromOffset(vp.X - 40, vp.Y - 40)
		TweenService:Create(self.Shell, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = newSize,
			Position = UDim2.fromScale(0.5, 0.5),
		}):Play()
		self.Size = newSize
	else
		self._fullscreen = false
		TweenService:Create(self.Shell, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = self._savedSize,
			Position = self._savedPos,
		}):Play()
		self.Size = self._savedSize
	end
end

function LiquidGlass:Open()
	self._open = true
	self.Shell.Visible = true
	self._scaleSpring.value = 0.92
	self._scaleSpring.target = 1
	self._alphaSpring.value = 0
	self._alphaSpring.target = 1
	self._blurSpring.value = 0
	self._blurSpring.target = 1
end

function LiquidGlass:Close()
	self._open = false
	self._scaleSpring.target = 0.94
	self._alphaSpring.target = 0
	self._blurSpring.target = 0
	task.delay(0.5, function()
		if not self._open then
			self.Shell.Visible = false
		end
	end)
end

function LiquidGlass:Toggle()
	if self._open then
		self:Close()
	else
		self:Open()
	end
end

function LiquidGlass:SetMagnifierEnabled(state)
	self._magnifierEnabled = state
	if not state then
		self.MagnifierCopy.Visible = false
		self.MagnifierMask.Visible = false
		self.MagnifierGlow.Visible = false
	end
end

function LiquidGlass:SetMagnifierZoom(z)
	CONFIG.MagnifierZoom = z
end

function LiquidGlass:SetMagnifierRadius(r)
	CONFIG.MagnifierRadius = r
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
