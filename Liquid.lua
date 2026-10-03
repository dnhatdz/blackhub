-- LiquidGlass - WindUI-compatible glass UI
-- API: WindUI:CreateWindow, Window:Tab, Tab:Section, Section:Toggle/Slider/Button/Input/Dropdown/Keybind/Paragraph/Colorpicker
-- Render: LiquidGlass (frosted glass panel, iOS-style components)

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local cloneref = cloneref or clonereference or function(x) return x end

LiquidGlass.Version = "1.0.0-glass"
LiquidGlass.TransparencyValue = 0.15
LiquidGlass.Transparent = false
LiquidGlass.UIScale = 1
LiquidGlass.CurrentInput = nil

local Font = {
	Regular = "rbxasset://fonts/families/GothamSSm.json",
	Medium = "rbxasset://fonts/families/GothamSSm.json",
	Bold = "rbxasset://fonts/families/GothamSSm.json",
}

local THEMES = {
	Dark = {
		Name = "Dark",
		Accent = Color3.fromHex("#18181b"),
		Dialog = Color3.fromHex("#1a1a1a"),
		Outline = Color3.fromHex("#FFFFFF"),
		Text = Color3.fromHex("#FFFFFF"),
		Placeholder = Color3.fromHex("#a1a1a1"),
		Background = Color3.fromHex("#101010"),
		Button = Color3.fromHex("#52525b"),
		Icon = Color3.fromHex("#a1a1aa"),
		Toggle = Color3.fromHex("#33C759"),
		Slider = Color3.fromHex("#0091FF"),
		Checkbox = Color3.fromHex("#0091FF"),
		Primary = Color3.fromHex("#0091FF"),
		ElementBackground = Color3.fromHex("#2A2A2C"),
		ElementBackgroundTransparency = 0,
		PanelBackground = Color3.fromHex("#FFFFFF"),
		PanelBackgroundTransparency = 0.95,
		GlassTint = Color3.fromHex("#FFFFFF"),
		GlassTransparency = 0.95,
	},
	Light = {
		Name = "Light",
		Accent = Color3.fromHex("#efefef"),
		Dialog = Color3.fromHex("#f4f4f5"),
		Outline = Color3.fromHex("#ffffff"),
		Text = Color3.fromHex("#000000"),
		Placeholder = Color3.fromHex("#555555"),
		Background = Color3.fromHex("#FFFFFF"),
		Button = Color3.fromHex("#18181b"),
		Icon = Color3.fromHex("#52525b"),
		Toggle = Color3.fromHex("#33C759"),
		Slider = Color3.fromHex("#0091FF"),
		Checkbox = Color3.fromHex("#0091FF"),
		Primary = Color3.fromHex("#0091FF"),
		ElementBackground = Color3.fromHex("#ffffff"),
		ElementBackgroundTransparency = 0,
		PanelBackground = Color3.fromHex("#efefef"),
		PanelBackgroundTransparency = 0,
		GlassTint = Color3.fromHex("#FFFFFF"),
		GlassTransparency = 0.6,
	},
	Rose = {
		Name = "Rose",
		Accent = Color3.fromHex("#be185d"),
		Dialog = Color3.fromHex("#4c0519"),
		Outline = Color3.fromHex("#FFFFFF"),
		Text = Color3.fromHex("#fdf2f8"),
		Placeholder = Color3.fromHex("#d67aa6"),
		Background = Color3.fromHex("#1f0308"),
		Button = Color3.fromHex("#e95f74"),
		Icon = Color3.fromHex("#fb7185"),
		Toggle = Color3.fromHex("#e95f74"),
		Slider = Color3.fromHex("#be185d"),
		Checkbox = Color3.fromHex("#be185d"),
		Primary = Color3.fromHex("#be185d"),
		ElementBackground = Color3.fromHex("#381E23"),
		ElementBackgroundTransparency = 0,
		PanelBackground = Color3.fromHex("#381E23"),
		PanelBackgroundTransparency = 0.85,
		GlassTint = Color3.fromHex("#fb7185"),
		GlassTransparency = 0.95,
	},
	Emerald = {
		Name = "Emerald",
		Accent = Color3.fromHex("#047857"),
		Dialog = Color3.fromHex("#022c22"),
		Outline = Color3.fromHex("#FFFFFF"),
		Text = Color3.fromHex("#ecfdf5"),
		Placeholder = Color3.fromHex("#3fbf8f"),
		Background = Color3.fromHex("#011411"),
		Button = Color3.fromHex("#059669"),
		Icon = Color3.fromHex("#10b981"),
		Toggle = Color3.fromHex("#10b981"),
		Slider = Color3.fromHex("#047857"),
		Checkbox = Color3.fromHex("#047857"),
		Primary = Color3.fromHex("#047857"),
		ElementBackground = Color3.fromHex("#202E2A"),
		ElementBackgroundTransparency = 0,
		PanelBackground = Color3.fromHex("#202E2A"),
		PanelBackgroundTransparency = 0.85,
		GlassTint = Color3.fromHex("#10b981"),
		GlassTransparency = 0.95,
	},
}

LiquidGlass.Themes = THEMES
LiquidGlass.Theme = THEMES.Dark
LiquidGlass.Objects = {}
LiquidGlass.Signals = {}
LiquidGlass.ThemeChangeCallbacks = {}

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
		value = value, target = value, velocity = 0,
		stiffness = stiffness or 220, damping = damping or 26, mass = mass or 1,
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
		local HS = game:GetService("HapticService")
		if HS:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small) then
			HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.25)
			task.wait(0.05)
			HS:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
		end
	end)
end

LiquidGlass.hapticSmall = hapticSmall

function LiquidGlass.AddSignal(sig, fn)
	local conn = sig:Connect(fn)
	table.insert(LiquidGlass.Signals, conn)
	return conn
end

function LiquidGlass.DisconnectAll()
	for _, c in pairs(LiquidGlass.Signals) do
		pcall(function() c:Disconnect() end)
	end
	LiquidGlass.Signals = {}
end

function LiquidGlass.SafeCallback(fn, ...)
	if type(fn) ~= "function" then return end
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[ LiquidGlass ] " .. tostring(err))
	end
end

function LiquidGlass.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

function LiquidGlass.GenerateUniqueID()
	return HttpService:GenerateGUID(false)
end

function LiquidGlass.Gradient(tbl, extra)
	local colors, trans = {}, {}
	for k, v in pairs(tbl) do
		local t = tonumber(k)
		if t then
			t = math.clamp(t / 100, 0, 1)
			table.insert(colors, ColorSequenceKeypoint.new(t, v.Color))
			table.insert(trans, NumberSequenceKeypoint.new(t, v.Transparency or 0))
		end
	end
	table.sort(colors, function(a, b) return a.Time < b.Time end)
	table.sort(trans, function(a, b) return a.Time < b.Time end)
	if #colors < 2 then error("Gradient needs 2+ keypoints") end
	local res = {
		Color = ColorSequence.new(colors),
		Transparency = NumberSequence.new(trans),
	}
	if extra then
		for k, v in pairs(extra) do res[k] = v end
	end
	return res
end

function LiquidGlass.Tween(obj, dur, props, style, dir)
	return TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
end

function LiquidGlass.AddColor(name, hex, amt, mul)
	mul = math.clamp(mul or 1, 0, 1)
	local base = typeof(hex) == "string" and Color3.fromHex(hex) or hex
	return function(theme)
		theme = theme or LiquidGlass.Theme
		local c = theme[name] or base
		return Color3.new(
			math.clamp(c.R + base.R * mul, 0, 1),
			math.clamp(c.G + base.G * mul, 0, 1),
			math.clamp(c.B + base.B * mul, 0, 1)
		)
	end
end

function LiquidGlass:GetThemeProperty(key)
	local t = LiquidGlass.Theme or THEMES.Dark
	local v = t[key]
	if v == nil then v = THEMES.Dark[key] end
	if typeof(v) == "string" and string.sub(v, 1, 1) == "#" then
		return Color3.fromHex(v)
	end
	return v
end

function LiquidGlass:SetTheme(name)
	if type(name) == "table" then
		LiquidGlass.Theme = name
	elseif THEMES[name] then
		LiquidGlass.Theme = THEMES[name]
	end
	for _, win in ipairs(LiquidGlass.Windows or {}) do
		pcall(function() win:_retheme() end)
	end
	for _, cb in pairs(LiquidGlass.ThemeChangeCallbacks) do
		pcall(cb, LiquidGlass.Theme)
	end
end

function LiquidGlass:GetThemes()
	return THEMES
end

function LiquidGlass:AddTheme(t)
	if type(t) == "table" and t.Name then
		THEMES[t.Name] = t
	end
	return t
end

function LiquidGlass:OnThemeChange(fn)
	if type(fn) ~= "function" then return end
	local id = HttpService:GenerateGUID(false)
	LiquidGlass.ThemeChangeCallbacks[id] = fn
	return {
		Disconnect = function()
			LiquidGlass.ThemeChangeCallbacks[id] = nil
		end
	}
end

function LiquidGlass:Notify(o)
	o = o or {}
	local title = o.Title or "Notification"
	local content = o.Content or ""
	local duration = o.Duration or 4
	local theme = LiquidGlass.Theme

	local holder = LiquidGlass.NotificationHolder
	if not holder or not holder.Parent then
		local sg = newInstance("ScreenGui", {
			Name = "LiquidNotifications",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 200,
			Parent = PG,
		})
		holder = newInstance("Frame", {
			Name = "Holder",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 320, 1, -40),
			Position = UDim2.new(1, -20, 0, 20),
			AnchorPoint = Vector2.new(1, 0),
			Parent = sg,
		})
		newInstance("UIListLayout", {
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Parent = holder,
		})
		LiquidGlass.NotificationHolder = holder
	end

	local card = newInstance("Frame", {
		BackgroundColor3 = theme.ElementBackground or theme.Background,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 64),
		ClipsDescendants = true,
		Parent = holder,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 12), Parent = card })
	newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.85, Parent = card })
	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
		TextSize = 14,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -28, 0, 18),
		Parent = card,
	})
	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = content,
		FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
		TextSize = 13,
		TextColor3 = theme.Text,
		TextTransparency = 0.15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Position = UDim2.fromOffset(14, 28),
		Size = UDim2.new(1, -28, 0, 30),
		Parent = card,
	})

	card.Position = UDim2.new(1, 340, 0, 0)
	LiquidGlass.Tween(card, 0.35, { Position = UDim2.new(0, 0, 0, 0) }):Play()
	task.delay(duration, function()
		if card and card.Parent then
			LiquidGlass.Tween(card, 0.3, {
				Position = UDim2.new(1, 340, 0, 0),
				BackgroundTransparency = 1,
			}):Play()
			task.delay(0.3, function()
				if card then card:Destroy() end
			end)
		end
	end)
end

function LiquidGlass:Dialog(o)
	o = o or {}
	local title = o.Title or "Dialog"
	local content = o.Content or ""
	local buttons = o.Buttons or {}
	local theme = LiquidGlass.Theme

	local dg = newInstance("ScreenGui", {
		Name = "LiquidDialog",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 200,
		Parent = PG,
	})
	local backdrop = newInstance("TextButton", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		Parent = dg,
	})
	local box = newInstance("Frame", {
		BackgroundColor3 = theme.Dialog,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(320, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = dg,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 14), Parent = box })
	newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.8, Parent = box })

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
		TextSize = 17,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 18),
		Size = UDim2.new(1, -40, 0, 22),
		Parent = box,
	})
	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = content,
		FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
		TextSize = 14,
		TextColor3 = theme.Text,
		TextTransparency = 0.15,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 44),
		Size = UDim2.new(1, -40, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = box,
	})
	local btnHolder = newInstance("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(20, 0),
		Size = UDim2.new(1, -40, 0, 40),
		Parent = box,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = btnHolder,
	})

	local function close()
		pcall(function() dg:Destroy() end)
	end

	for _, b in ipairs(buttons) do
		local btn = newInstance("TextButton", {
			BackgroundColor3 = b.Variant == "Primary" and theme.Accent or theme.ElementBackground,
			BackgroundTransparency = 0.05,
			BorderSizePixel = 0,
			Text = b.Title or "Button",
			FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
			TextSize = 14,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromOffset(120, 34),
			AutoButtonColor = false,
			Parent = btnHolder,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = btn })
		btn.MouseButton1Click:Connect(function()
			close()
			if b.Callback then pcall(b.Callback) end
		end)
	end

	backdrop.MouseButton1Click:Connect(close)
	return { Destroy = close }
end

-- WINDOW

LiquidGlass.Windows = {}

function LiquidGlass:CreateWindow(opts)
	opts = opts or {}
	local win = setmetatable({
		_tabs = {},
		_conns = {},
		_alive = true,
		_open = false,
		_dragging = false,
		Title = opts.Title or "LiquidGlass",
		Author = opts.Author or "",
		Size = opts.Size or UDim2.fromOffset(580, 460),
		Position = opts.Position or UDim2.fromScale(0.5, 0.5),
		ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift,
		SideBarWidth = opts.SideBarWidth or 200,
		Theme = opts.Theme or "Dark",
		Parent = opts.Parent or PG,
		Transparent = opts.Transparent or false,
		HideSearchBar = opts.HideSearchBar ~= false,
		Resizable = opts.Resizable ~= false,
		IgnoreAlerts = opts.IgnoreAlerts or false,
		Closed = false,
		Destroyed = false,
		CanDropdown = true,
		AllElements = {},
		PendingFlags = {},
		Gap = 5,
		UICorner = 16,
		UIPadding = 14,
	}, LiquidGlass)
	LiquidGlass.Theme = THEMES[win.Theme] or THEMES.Dark
	win:_buildWindow()
	win:_startLoop()
	win:_bindInput()
	table.insert(LiquidGlass.Windows, win)
	if opts.AutoOpen ~= false then
		win:Open()
	end
	return win
end

function LiquidGlass:_theme()
	return LiquidGlass.Theme or THEMES.Dark
end

function LiquidGlass:_retheme()
	local t = self:_theme()
	if self.Panel then self.Panel.BackgroundColor3 = t.Background end
	if self.PanelBackground then self.PanelBackground.BackgroundColor3 = t.ElementBackground end
	for _, tab in ipairs(self._tabs) do
		pcall(function() tab:_retheme() end)
	end
end

function LiquidGlass:_buildWindow()
	local win = self
	local theme = win:_theme()

	local gui = newInstance("ScreenGui", {
		Name = "LiquidGlassGui",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 100,
		Parent = win.Parent,
	})
	win.Gui = gui

	win.Backdrop = newInstance("Frame", {
		Name = "Backdrop",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		Parent = gui,
	})

	win.Shell = newInstance("Frame", {
		Name = "Shell",
		BackgroundTransparency = 1,
		Size = win.Size,
		Position = win.Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = gui,
	})

	win.Shadow = newInstance("ImageLabel", {
		Name = "Shadow",
		BackgroundTransparency = 1,
		Image = "rbxassetid://8992230677",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.5,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(99, 99, 99, 99),
		Size = UDim2.new(1, 80, 1, 80),
		Position = UDim2.new(0, -40, 0, -40),
		ZIndex = 0,
		Parent = win.Shell,
	})

	win.Panel = newInstance("Frame", {
		Name = "Panel",
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = win.Shell,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = win.Panel })

	win.GlassLayer = newInstance("Frame", {
		Name = "GlassLayer",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 3,
		Parent = win.Panel,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = win.GlassLayer })
	newInstance("UIGradient", {
		Rotation = 135,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.94),
			NumberSequenceKeypoint.new(0.5, 0.99),
			NumberSequenceKeypoint.new(1, 0.94),
		}),
		Parent = win.GlassLayer,
	})

	win.Noise = newInstance("ImageLabel", {
		Name = "Noise",
		BackgroundTransparency = 1,
		Image = "rbxassetid://243098098",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(128, 128),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 4,
		Parent = win.Panel,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = win.Noise })

	win.Edge = newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = win.Panel,
	})

	win.Header = newInstance("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = 10,
		Parent = win.Panel,
	})

	newInstance("TextLabel", {
		BackgroundTransparency = 1,
		Text = win.Title,
		FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
		TextSize = 16,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Position = UDim2.fromOffset(20, 14),
		Size = UDim2.new(1, -120, 0, 20),
		ZIndex = 10,
		Parent = win.Header,
	})

	if win.Author ~= "" then
		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = win.Author,
			FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
			TextSize = 13,
			TextColor3 = theme.Text,
			TextTransparency = 0.4,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(20, 30),
			Size = UDim2.new(1, -120, 0, 14),
			ZIndex = 10,
			Parent = win.Header,
		})
	end

	local function topDot(color, xOff, cb)
		local b = newInstance("TextButton", {
			BackgroundColor3 = color,
			BackgroundTransparency = 0.15,
			BorderSizePixel = 0,
			Text = "",
			Size = UDim2.fromOffset(13, 13),
			Position = UDim2.new(1, xOff, 0, 19),
			ZIndex = 10,
			Parent = win.Header,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = b })
		b.MouseButton1Click:Connect(cb)
		return b
	end

	topDot(Color3.fromRGB(255, 200, 80), -52, function() win:Toggle() end)
	topDot(Color3.fromRGB(255, 90, 95), -30, function() win:Close() end)

	win.SidebarBackground = newInstance("Frame", {
		Name = "SidebarBg",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(0, win.SideBarWidth, 1, -52),
		Position = UDim2.new(0, 0, 0, 52),
		ZIndex = 9,
		Parent = win.Panel,
	})

	win.SidebarContainer = newInstance("Frame", {
		Name = "SidebarContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, win.SideBarWidth, 1, -52),
		Position = UDim2.new(0, 0, 0, 52),
		ZIndex = 10,
		Parent = win.Panel,
	})

	win.Sidebar = newInstance("ScrollingFrame", {
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
		Parent = win.SidebarContainer,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = win.Sidebar,
	})

	win.ContentContainer = newInstance("Frame", {
		Name = "ContentContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -win.SideBarWidth, 1, -52),
		Position = UDim2.new(1, 0, 0, 52),
		AnchorPoint = Vector2.new(1, 0),
		ZIndex = 10,
		Parent = win.Panel,
	})

	win.PanelBackground = newInstance("Frame", {
		Name = "PanelBg",
		BackgroundColor3 = theme.ElementBackground,
		BackgroundTransparency = 0.75,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -14, 1, -14),
		Position = UDim2.fromOffset(7, 7),
		ZIndex = 10,
		Parent = win.ContentContainer,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = win.PanelBackground })
	newInstance("UIStroke", {
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1,
		Transparency = 0.8,
		Parent = win.PanelBackground,
	})

	win.Content = newInstance("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -28, 1, -14),
		Position = UDim2.fromOffset(14, 7),
		ZIndex = 11,
		Parent = win.ContentContainer,
	})
end

function LiquidGlass:_startLoop()
	local win = self
	local last = tick()
	local conn = RunService.RenderStepped:Connect(function()
		if not win._alive then return end
		local now = tick()
		local dt = math.min(now - last, 0.05)
		last = now
		win.Panel.BackgroundTransparency = 1 - 0.55
		win.GlassLayer.BackgroundTransparency = 1 - 0.97
		win.Noise.ImageTransparency = 1 - 0.04
		win.Edge.Transparency = 1 - 0.7
		win.Shadow.ImageTransparency = 1 - 0.5
		win.Backdrop.BackgroundTransparency = 1 - 0.4
		for _, e in ipairs(win._springs or {}) do
			local v = e.spring:Update(dt)
			e.apply(v)
		end
	end)
	table.insert(self._conns, conn)
end

function LiquidGlass:_bindInput()
	local win = self
	local startPos, startMouse

	win.Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			win._dragging = true
			startMouse = input.Position
			startPos = win.Shell.Position
		end
	end)

	table.insert(win._conns, UserInputService.InputChanged:Connect(function(input)
		if not win._dragging then return end
		local d = input.Position - startMouse
		win.Shell.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
	end))

	table.insert(win._conns, UserInputService.InputEnded:Connect(function(input)
		if not win._dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			win._dragging = false
			win.Position = win.Shell.Position
		end
	end))

	table.insert(win._conns, UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == win.ToggleKey then
			win:Toggle()
		end
	end))
end

function LiquidGlass:Open()
	self._open = true
	self.Shell.Visible = true
	self.Closed = false
end

function LiquidGlass:Close()
	self._open = false
	self.Shell.Visible = false
	self.Closed = true
end

function LiquidGlass:Toggle()
	if self._open then self:Close() else self:Open() end
end

function LiquidGlass:Destroy()
	self._alive = false
	self.Destroyed = true
	for _, c in ipairs(self._conns) do
		pcall(function() c:Disconnect() end)
	end
	self._conns = {}
	if self.Gui then self.Gui:Destroy() end
	for i, w in ipairs(LiquidGlass.Windows) do
		if w == self then
			table.remove(LiquidGlass.Windows, i)
			break
		end
	end
end

function LiquidGlass:SetTitle(s)
	self.Title = s
end

function LiquidGlass:SetTheme(name)
	LiquidGlass:SetTheme(name)
end

function LiquidGlass:ToggleTransparency(state)
	self.Transparent = state
	LiquidGlass.Transparent = state
end

function LiquidGlass:SetUIScale(s)
	LiquidGlass.UIScale = s
end

function LiquidGlass:GetUIScale()
	return LiquidGlass.UIScale
end

-- TAB

function LiquidGlass:Tab(opts)
	opts = opts or {}
	local tab = {
		__type = "Tab",
		Title = opts.Title or "Tab",
		Desc = opts.Desc,
		Icon = opts.Icon,
		IconColor = opts.IconColor,
		Locked = opts.Locked or false,
		Selected = false,
		Elements = {},
		Widgets = {},
		Window = self,
	}
	local win = self
	local theme = win:_theme()

	local tabBtn = newInstance("TextButton", {
		BackgroundColor3 = theme.ElementBackground,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = tab.Title,
		FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
		TextSize = 14,
		TextColor3 = theme.Text,
		TextTransparency = 0.45,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false,
		ZIndex = 11,
		Parent = win.Sidebar,
	})
	newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = tabBtn })
	newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 1, Parent = tabBtn })
	newInstance("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = tabBtn })

	local list = newInstance("ScrollingFrame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.Accent,
		ScrollBarImageTransparency = 0.5,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
		Visible = false,
		ZIndex = 11,
		Parent = win.Content,
	})
	newInstance("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = list,
	})
	newInstance("UIPadding", { PaddingRight = UDim.new(0, 6), Parent = list })

	tab._scroll = list
	tab._btn = tabBtn

	table.insert(win._tabs, tab)

	local function selectThis()
		for _, t in ipairs(win._tabs) do
			t.Selected = false
			t._scroll.Visible = false
			LiquidGlass.Tween(t._btn, 0.2, {
				BackgroundTransparency = 1,
				TextTransparency = 0.45,
			}):Play()
		end
		tab.Selected = true
		list.Visible = true
		LiquidGlass.Tween(tabBtn, 0.2, {
			BackgroundTransparency = 0.15,
			TextTransparency = 0,
		}):Play()
	end

	if #win._tabs == 1 then
		selectThis()
	end

	tabBtn.MouseButton1Click:Connect(selectThis)

	tab._retheme = function()
		for _, w in ipairs(tab.Widgets) do
			if w._retheme then w._retheme() end
		end
	end

	function tab:Select()
		selectThis()
	end

	local function makeRow(height)
		local row = newInstance("Frame", {
			BackgroundColor3 = theme.ElementBackground,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height),
			ZIndex = 12,
			Parent = list,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
		newInstance("UIStroke", {
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 1,
			Transparency = 0.88,
			Parent = row,
		})
		return row
	end

	function tab:Section(opts)
		opts = opts or {}
		local section = {}
		section.Title = opts.Title or "Section"
		section.Opened = opts.Opened ~= false
		section.Elements = {}
		section._widgets = {}

		local holder = newInstance("Frame", {
			BackgroundColor3 = theme.ElementBackground,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 38),
			ZIndex = 11,
			Parent = list,
		})
		newInstance("UICorner", { CornerRadius = UDim.new(0, 12), Parent = holder })
		newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.85, Parent = holder })

		local header = newInstance("TextButton", {
			BackgroundTransparency = 1,
			Text = "",
			Size = UDim2.new(1, 0, 0, 38),
			AutoButtonColor = false,
			ZIndex = 12,
			Parent = holder,
		})
		newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = section.Title,
			FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
			TextSize = 14,
			TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.fromOffset(14, 0),
			Size = UDim2.new(1, -50, 1, 0),
			ZIndex = 12,
			Parent = header,
		})
		local arrow = newInstance("TextLabel", {
			BackgroundTransparency = 1,
			Text = "▾",
			FontFace = Font.new(Font.Bold, Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = theme.Text,
			TextTransparency = 0.3,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -30, 0, 0),
			Size = UDim2.fromOffset(20, 38),
			ZIndex = 12,
			Parent = header,
		})

		local content = newInstance("Frame", {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 38),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
			ZIndex = 11,
			Parent = holder,
		})
		newInstance("UIListLayout", {
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = content,
		})
		newInstance("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			Parent = content,
		})

		local function refreshSize()
			local contentH = content.UIListLayout.AbsoluteContentSize.Y
			holder.Size = UDim2.new(1, 0, 0, 38 + (section.Opened and contentH or 0))
		end
		content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refreshSize)

		header.MouseButton1Click:Connect(function()
			section.Opened = not section.Opened
			LiquidGlass.Tween(arrow, 0.2, {
				Rotation = section.Opened and 0 or -90,
			}):Play()
			local target = 38 + (section.Opened and content.UIListLayout.AbsoluteContentSize.Y or 0)
			LiquidGlass.Tween(holder, 0.3, {
				Size = UDim2.new(1, 0, 0, target),
			}, Enum.EasingStyle.Quart):Play()
		end)

		function section:_retheme()
			for _, el in ipairs(section.Elements) do
				if el._retheme then el._retheme() end
			end
		end

		local function makeSectionRow(height)
			local row = newInstance("Frame", {
				BackgroundColor3 = theme.ElementBackground,
				BackgroundTransparency = 0,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, height),
				ZIndex = 12,
				Parent = content,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = row })
			newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.88, Parent = row })
			return row
		end

		function section:Toggle(o)
			o = o or {}
			local state = o.Default or false
			local row = makeSectionRow(42)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Toggle",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -80, 1, 0),
				ZIndex = 13,
				Parent = row,
			})

			local pill = newInstance("Frame", {
				BackgroundColor3 = state and theme.Toggle or Color3.fromRGB(60, 60, 65),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(38, 22),
				Position = UDim2.new(1, -52, 0.5, -11),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = pill })

			local knob = newInstance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(18, 18),
				Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.fromOffset(2, 2),
				ZIndex = 14,
				Parent = pill,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

			local btn = newInstance("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.fromScale(1, 1),
				ZIndex = 15,
				Parent = row,
			})

			local function set(newState, animate)
				state = newState
				local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.fromOffset(2, 2)
				if animate then
					LiquidGlass.Tween(pill, 0.25, {
						BackgroundColor3 = state and theme.Toggle or Color3.fromRGB(60, 60, 65),
					}):Play()
					LiquidGlass.Tween(knob, 0.32, {
						Position = targetPos,
					}, Enum.EasingStyle.Back):Play()
				else
					pill.BackgroundColor3 = state and theme.Toggle or Color3.fromRGB(60, 60, 65)
					knob.Position = targetPos
				end
				if o.Callback then pcall(o.Callback, state) end
			end

			btn.MouseButton1Click:Connect(function()
				set(not state, true)
				hapticSmall()
			end)

			function el:Set(v) set(v, true) end
			function el:Get() return state end

			if o.Default then
				task.defer(function()
					if o.Callback then pcall(o.Callback, true) end
				end)
			end
			return el
		end

		function section:Slider(o)
			o = o or {}
			local minV = (o.Value and o.Value.Min) or o.Min or 0
			local maxV = (o.Value and o.Value.Max) or o.Max or 100
			local defV = (o.Value and o.Value.Default) or o.Default or minV
			local step = o.Step or 1
			local value = defV
			local row = makeSectionRow(52)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Slider",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 6),
				Size = UDim2.new(1, -70, 0, 16),
				ZIndex = 13,
				Parent = row,
			})
			local valueLbl = newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = tostring(value),
				FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
				TextSize = 13,
				TextColor3 = theme.Text,
				TextTransparency = 0.2,
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.new(1, -60, 0, 6),
				Size = UDim2.fromOffset(46, 16),
				ZIndex = 13,
				Parent = row,
			})
			local track = newInstance("Frame", {
				BackgroundColor3 = Color3.fromRGB(60, 60, 65),
				BorderSizePixel = 0,
				Size = UDim2.new(1, -28, 0, 4),
				Position = UDim2.new(0, 14, 1, -16),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })
			local fill = newInstance("Frame", {
				BackgroundColor3 = theme.Slider,
				BorderSizePixel = 0,
				Size = UDim2.new((value - minV) / (maxV - minV), 0, 1, 0),
				ZIndex = 14,
				Parent = track,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
			local knob = newInstance("Frame", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(14, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new((value - minV) / (maxV - minV), 0, 0.5, 0),
				ZIndex = 15,
				Parent = track,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

			local dragging = false
			local function update(input)
				local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				value = minV + (maxV - minV) * rel
				if step >= 1 then
					value = math.floor(value / step + 0.5) * step
				else
					value = math.floor(value * 100 + 0.5) / 100
				end
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, 0, 0.5, 0)
				valueLbl.Text = tostring(value)
				if o.Callback then pcall(o.Callback, value) end
			end

			local hit = newInstance("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.new(1, 0, 0, 28),
				Position = UDim2.new(0, 0, 1, -32),
				ZIndex = 16,
				Parent = row,
			})
			hit.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					update(input)
				end
			end)
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch) then
					update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)

			function el:Set(v)
				v = tonumber(v) or value
				value = math.clamp(v, minV, maxV)
				local rel = (value - minV) / (maxV - minV)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				knob.Position = UDim2.new(rel, 0, 0.5, 0)
				valueLbl.Text = tostring(value)
				if o.Callback then pcall(o.Callback, value) end
			end
			function el:Get() return value end
			return el
		end

		function section:Button(o)
			o = o or {}
			local row = makeSectionRow(42)
			local scale = newInstance("UIScale", { Scale = 1, Parent = row })
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Button",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -50, 1, 0),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = "›",
				FontFace = Font.new(Font.Bold, Enum.FontWeight.Bold),
				TextSize = 20,
				TextColor3 = theme.Text,
				TextTransparency = 0.2,
				TextXAlignment = Enum.TextXAlignment.Right,
				Position = UDim2.new(1, -28, 0, 0),
				Size = UDim2.fromOffset(18, 42),
				ZIndex = 13,
				Parent = row,
			})
			local btn = newInstance("TextButton", {
				BackgroundTransparency = 1,
				Text = "",
				Size = UDim2.fromScale(1, 1),
				ZIndex = 14,
				Parent = row,
			})
			btn.MouseButton1Down:Connect(function()
				LiquidGlass.Tween(scale, 0.15, { Scale = 0.97 }):Play()
			end)
			btn.MouseButton1Up:Connect(function()
				LiquidGlass.Tween(scale, 0.25, { Scale = 1 }, Enum.EasingStyle.Back):Play()
				if o.Callback then pcall(o.Callback) end
				hapticSmall()
			end)
			btn.MouseLeave:Connect(function()
				LiquidGlass.Tween(scale, 0.2, { Scale = 1 }):Play()
			end)
			return el
		end

		function section:Input(o)
			o = o or {}
			local row = makeSectionRow(42)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			local box = newInstance("TextBox", {
				BackgroundTransparency = 1,
				Text = o.Value or o.Default or "",
				PlaceholderText = o.Placeholder or "Enter text",
				PlaceholderColor3 = theme.Placeholder,
				FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -28, 1, 0),
				ZIndex = 13,
				Parent = row,
			})
			box.FocusLost:Connect(function()
				if o.Callback then pcall(o.Callback, box.Text) end
			end)
			function el:Set(v) box.Text = tostring(v) end
			function el:Get() return box.Text end
			return el
		end

		function section:Dropdown(o)
			o = o or {}
			local values = o.Values or {}
			local multi = o.Multi == true
			local row = makeSectionRow(42)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Dropdown",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -110, 1, 0),
				ZIndex = 13,
				Parent = row,
			})

			local current = o.Value
			if not current and values[1] then
				current = type(values[1]) == "table" and (values[1].Title or tostring(values[1])) or tostring(values[1])
			end

			local displayText
			if multi and type(current) == "table" then
				local arr = {}
				for _, v in ipairs(current) do
					table.insert(arr, type(v) == "table" and (v.Title or tostring(v)) or tostring(v))
				end
				displayText = #arr > 0 and table.concat(arr, ", ") or "--"
			else
				displayText = tostring(current or "--")
			end

			local valueLbl = newInstance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Text = displayText,
				FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
				TextSize = 13,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Right,
				Size = UDim2.fromOffset(110, 28),
				Position = UDim2.new(1, -124, 0.5, -14),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = valueLbl })
			newInstance("UIPadding", { PaddingRight = UDim.new(0, 10), Parent = valueLbl })

			local itemHeight = 32
			local maxHeight = 220
			local finalHeight = math.min(#values * itemHeight + 12, maxHeight)

			local sheetGui = newInstance("ScreenGui", {
				Name = "LiquidSheet",
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = 150,
				Parent = PG,
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
				BackgroundColor3 = theme.Dialog,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 320, 0, finalHeight + 40),
				Position = UDim2.new(0.5, 0, 1, 0),
				AnchorPoint = Vector2.new(0.5, 1),
				ClipsDescendants = true,
				Visible = false,
				ZIndex = 201,
				Parent = sheetGui,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 16), Parent = sheet })
			newInstance("UIStroke", { Color = theme.Outline, Thickness = 1, Transparency = 0.85, Parent = sheet })

			local handle = newInstance("Frame", {
				BackgroundColor3 = theme.Outline,
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
				Text = o.Title or "Select",
				FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
				TextSize = 16,
				TextColor3 = theme.Text,
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
				ScrollBarImageColor3 = theme.Accent,
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
			newInstance("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = scroll })

			local open = false
			local function closeSheet()
				open = false
				LiquidGlass.Tween(sheet, 0.28, {
					Position = UDim2.new(0.5, 0, 1, 0),
				}, Enum.EasingStyle.Quart, Enum.EasingDirection.In):Play()
				LiquidGlass.Tween(sheetBackdrop, 0.25, { BackgroundTransparency = 1 }):Play()
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
				sheet.Position = UDim2.new(0.5, 0, 1, 0)
				LiquidGlass.Tween(sheet, 0.35, {
					Position = UDim2.new(0.5, 0, 1, -10),
				}, Enum.EasingStyle.Quart):Play()
				LiquidGlass.Tween(sheetBackdrop, 0.3, { BackgroundTransparency = 0.5 }):Play()
			end

			local selectedSet = {}
			if multi and type(current) == "table" then
				for _, v in ipairs(current) do
					local key = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
					selectedSet[key] = true
				end
			end

			local function refreshDisplay()
				if multi then
					local arr = {}
					for _, v in ipairs(values) do
						local title = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
						if selectedSet[title] then table.insert(arr, title) end
					end
					displayText = #arr > 0 and table.concat(arr, ", ") or "--"
				else
					displayText = tostring(current or "--")
				end
				valueLbl.Text = displayText
			end

			for _, v in ipairs(values) do
				local title = type(v) == "table" and (v.Title or tostring(v)) or tostring(v)
				local opt = newInstance("TextButton", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = title,
					FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
					TextSize = 14,
					TextColor3 = theme.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, 0, 0, itemHeight),
					AutoButtonColor = false,
					ZIndex = 203,
					Parent = scroll,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = opt })
				newInstance("UIPadding", { PaddingLeft = UDim.new(0, 14), Parent = opt })

				local check = newInstance("TextLabel", {
					BackgroundTransparency = 1,
					Text = "✓",
					FontFace = Font.new(Font.Bold, Enum.FontWeight.Bold),
					TextSize = 14,
					TextColor3 = theme.Accent,
					TextXAlignment = Enum.TextXAlignment.Right,
					Position = UDim2.new(1, -30, 0, 0),
					Size = UDim2.fromOffset(20, itemHeight),
					TextTransparency = (multi and selectedSet[title]) and 0 or 1,
					ZIndex = 204,
					Parent = opt,
				})

				opt.MouseEnter:Connect(function()
					LiquidGlass.Tween(opt, 0.15, { BackgroundTransparency = 0.9 }):Play()
				end)
				opt.MouseLeave:Connect(function()
					LiquidGlass.Tween(opt, 0.15, { BackgroundTransparency = 1 }):Play()
				end)
				opt.MouseButton1Click:Connect(function()
					if multi then
						selectedSet[title] = not selectedSet[title]
						check.TextTransparency = selectedSet[title] and 0 or 1
						local arr = {}
						for _, vb in ipairs(values) do
							local t = type(vb) == "table" and (vb.Title or tostring(vb)) or tostring(vb)
							if selectedSet[t] then table.insert(arr, vb) end
						end
						current = arr
						refreshDisplay()
						if o.Callback then pcall(o.Callback, arr) end
					else
						current = v
						refreshDisplay()
						if o.Callback then pcall(o.Callback, v) end
						closeSheet()
					end
				end)
			end

			valueLbl.MouseButton1Click:Connect(function()
				if open then closeSheet() else openSheet() end
			end)
			sheetBackdrop.MouseButton1Click:Connect(function()
				if open then closeSheet() end
			end)

			function el:Set(v)
				current = v
				refreshDisplay()
			end
			function el:Get() return current end
			function el:Select(v) el:Set(v) end
			return el
		end

		function section:Paragraph(o)
			o = o or {}
			local el = { _retheme = function() end }
			local lbl = newInstance("TextLabel", {
				BackgroundColor3 = theme.ElementBackground,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				Text = o.Title or "",
				FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
				TextSize = 13,
				TextColor3 = theme.Text,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ZIndex = 13,
				Parent = content,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = lbl })
			newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.88, Parent = lbl })
			newInstance("UIPadding", {
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
				Parent = lbl,
			})

			function el:SetTitle(text)
				lbl.Text = tostring(text)
			end
			el.Set = el.SetTitle
			return el
		end

		function section:Label(o)
			o = o or {}
			local lbl = newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or o.Text or "",
				FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
				TextSize = 13,
				TextColor3 = theme.Text,
				TextTransparency = 0.2,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, 0, 0, 22),
				ZIndex = 13,
				Parent = content,
			})
			return { Set = function(_, v) lbl.Text = tostring(v) end }
		end

		function section:Divider()
			return newInstance("Frame", {
				BackgroundColor3 = theme.Outline,
				BackgroundTransparency = 0.85,
				BorderSizePixel = 0,
				Size = UDim2.new(1, -16, 0, 1),
				Position = UDim2.fromOffset(8, 0),
				ZIndex = 13,
				Parent = content,
			})
		end

		function section:Keybind(o)
			o = o or {}
			local row = makeSectionRow(42)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			local current = o.Default or Enum.KeyCode.F
			local picking = false

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Keybind",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -110, 1, 0),
				ZIndex = 13,
				Parent = row,
			})
			local valueLbl = newInstance("TextButton", {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Text = current.Name,
				FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
				TextSize = 13,
				TextColor3 = theme.Text,
				Size = UDim2.fromOffset(80, 28),
				Position = UDim2.new(1, -94, 0.5, -14),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = valueLbl })

			valueLbl.MouseButton1Click:Connect(function()
				picking = true
				valueLbl.Text = "..."
			end)

			local conn = UserInputService.InputBegan:Connect(function(input, gpe)
				if picking then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						current = input.KeyCode
						valueLbl.Text = current.Name
						picking = false
						if o.Callback then pcall(o.Callback, current) end
					end
					return
				end
				if gpe then return end
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == current then
					if o.Callback then pcall(o.Callback, current) end
				end
			end)

			function el:Set(k)
				current = k
				valueLbl.Text = k.Name
			end
			function el:Get() return current end
			return el
		end

		function section:Colorpicker(o)
			o = o or {}
			local row = makeSectionRow(42)
			local el = { _retheme = function() end }
			table.insert(section.Elements, el)

			local current = o.Default or Color3.fromRGB(255, 255, 255)

			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				Text = o.Title or "Color",
				FontFace = Font.new(Font.Medium, Enum.FontWeight.Medium),
				TextSize = 14,
				TextColor3 = theme.Text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Position = UDim2.fromOffset(14, 0),
				Size = UDim2.new(1, -80, 1, 0),
				ZIndex = 13,
				Parent = row,
			})
			local swatch = newInstance("TextButton", {
				BackgroundColor3 = current,
				BorderSizePixel = 0,
				Text = "",
				Size = UDim2.fromOffset(28, 28),
				Position = UDim2.new(1, -42, 0.5, -14),
				ZIndex = 13,
				Parent = row,
			})
			newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = swatch })
			newInstance("UIStroke", { Color = Color3.fromRGB(255, 255, 255), Thickness = 1, Transparency = 0.4, Parent = swatch })

			swatch.MouseButton1Click:Connect(function()
				local pickerGui = newInstance("ScreenGui", {
					Name = "LiquidColorPicker",
					ResetOnSpawn = false,
					IgnoreGuiInset = true,
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					DisplayOrder = 210,
					Parent = PG,
				})
				local backdrop = newInstance("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
					Text = "",
					Size = UDim2.fromScale(1, 1),
					Parent = pickerGui,
				})
				local box = newInstance("Frame", {
					BackgroundColor3 = theme.Dialog,
					BackgroundTransparency = 0.05,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(280, 300),
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Parent = pickerGui,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 14), Parent = box })
				newInstance("UIStroke", { Color = theme.Outline, Thickness = 1, Transparency = 0.8, Parent = box })

				local hue = select(1, Color3.toHSV(current))
				local hueFrame = newInstance("ImageLabel", {
					BackgroundTransparency = 1,
					Image = "rbxassetid://4155801252",
					Size = UDim2.new(1, -40, 0, 40),
					Position = UDim2.fromOffset(20, 20),
					ImageColor3 = Color3.fromHSV(hue, 1, 1),
					Parent = box,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hueFrame })

				local sliderTrack = newInstance("Frame", {
					BackgroundColor3 = Color3.fromRGB(60, 60, 65),
					BorderSizePixel = 0,
					Size = UDim2.new(1, -40, 0, 6),
					Position = UDim2.fromOffset(20, 76),
					Parent = box,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderTrack })
				local sliderFill = newInstance("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.new(hue, 0, 1, 0),
					Parent = sliderTrack,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderFill })
				local sliderKnob = newInstance("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(14, 14),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(hue, 0, 0.5, 0),
					Parent = sliderTrack,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(1, 0), Parent = sliderKnob })

				local preview = newInstance("Frame", {
					BackgroundColor3 = current,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -40, 0, 60),
					Position = UDim2.fromOffset(20, 100),
					Parent = box,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 10), Parent = preview })

				local hexInput = newInstance("TextBox", {
					BackgroundColor3 = theme.ElementBackground,
					BorderSizePixel = 0,
					Text = "#" .. current:ToHex(),
					FontFace = Font.new(Font.Regular, Enum.FontWeight.Regular),
					TextSize = 14,
					TextColor3 = theme.Text,
					TextXAlignment = Enum.TextXAlignment.Center,
					Size = UDim2.new(1, -40, 0, 36),
					Position = UDim2.fromOffset(20, 170),
					Parent = box,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = hexInput })

				local applyBtn = newInstance("TextButton", {
					BackgroundColor3 = theme.Accent,
					BorderSizePixel = 0,
					Text = "Apply",
					FontFace = Font.new(Font.Bold, Enum.FontWeight.SemiBold),
					TextSize = 14,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Size = UDim2.new(1, -40, 0, 36),
					Position = UDim2.fromOffset(20, 220),
					Parent = box,
				})
				newInstance("UICorner", { CornerRadius = UDim.new(0, 8), Parent = applyBtn })

				local hueDragging = false
				local sliderHit = newInstance("TextButton", {
					BackgroundTransparency = 1,
					Text = "",
					Size = UDim2.new(1, 0, 0, 28),
					Position = UDim2.new(0, 0, 0.5, -14),
					Parent = sliderTrack,
				})
				sliderHit.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						hueDragging = true
						hue = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
						sliderFill.Size = UDim2.new(hue, 0, 1, 0)
						sliderKnob.Position = UDim2.new(hue, 0, 0.5, 0)
						hueFrame.ImageColor3 = Color3.fromHSV(hue, 1, 1)
						preview.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
						hexInput.Text = "#" .. Color3.fromHSV(hue, 1, 1):ToHex()
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch) then
						hue = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
						sliderFill.Size = UDim2.new(hue, 0, 1, 0)
						sliderKnob.Position = UDim2.new(hue, 0, 0.5, 0)
						hueFrame.ImageColor3 = Color3.fromHSV(hue, 1, 1)
						preview.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
						hexInput.Text = "#" .. Color3.fromHSV(hue, 1, 1):ToHex()
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						hueDragging = false
					end
				end)

				hexInput.FocusLost:Connect(function()
					local hex = hexInput.Text:gsub("#", "")
					local ok, c = pcall(Color3.fromHex, hex)
					if ok then
						hue = select(1, Color3.toHSV(c))
						preview.BackgroundColor3 = c
						hueFrame.ImageColor3 = Color3.fromHSV(hue, 1, 1)
						sliderFill.Size = UDim2.new(hue, 0, 1, 0)
						sliderKnob.Position = UDim2.new(hue, 0, 0.5, 0)
					end
				end)

				applyBtn.MouseButton1Click:Connect(function()
					local ok, c = pcall(Color3.fromHex, hexInput.Text:gsub("#", ""))
					if ok then
						current = c
						swatch.BackgroundColor3 = c
						if o.Callback then pcall(o.Callback, c) end
					end
					pickerGui:Destroy()
				end)

				backdrop.MouseButton1Click:Connect(function() pickerGui:Destroy() end)
			end)

			function el:Set(c)
				current = c
				swatch.BackgroundColor3 = c
			end
			function el:Get() return current end
			function el:Update(c) el:Set(c) end
			return el
		end

		table.insert(tab.Widgets, section)
		return section
	end

	table.insert(tab.Widgets, {
		_retheme = function()
			tabBtn.BackgroundColor3 = theme.TabBackgroundActive or theme.ElementBackground
		end
	})

	return tab
end

return LiquidGlass
