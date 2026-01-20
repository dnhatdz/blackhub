-- ===== SERVICES =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ===== PLAYER =====
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ===== STATE =====
local AutoTween = false
local Fly = false
local FlySpeed = 5
local currentTween
local bv, bg

-- ===== UI ROOT =====
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BrainrotHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 190, 0, 0)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- ===== LIST LAYOUT =====
local list = Instance.new("UIListLayout", frame)
list.Padding = UDim.new(0,6)
list.HorizontalAlignment = Center

local function autoSize()
	task.wait()
	frame.Size = UDim2.new(0, 190, 0, list.AbsoluteContentSize.Y + 8)
end
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(autoSize)

-- ===== TITLE =====
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -12, 0, 24)
title.Text = "BRAINROT HUB"
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- ===== BUTTON MAKER =====
local function makeButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -12, 0, 30)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(40,40,40)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	b.Parent = frame
	return b
end

-- ===== AUTO TWEEN =====
local btnTween = makeButton("Auto Tween: OFF")

local tpHolder = Instance.new("Frame", frame)
tpHolder.Size = UDim2.new(1, -12, 0, 0)
tpHolder.BackgroundTransparency = 1
tpHolder.ClipsDescendants = true

local tpLayout = Instance.new("UIListLayout", tpHolder)
tpLayout.Padding = UDim.new(0,5)

local points = {
	{name="Point A", pos=Vector3.new(632,4,-350)},
	{name="Point B", pos=Vector3.new(722,29,-353)},
}

local function tweenTo(pos)
	if currentTween then currentTween:Cancel() end
	currentTween = TweenService:Create(
		hrp,
		TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{CFrame = CFrame.new(pos)}
	)
	currentTween:Play()
end

for _,p in ipairs(points) do
	local b = makeButton(p.name)
	b.Size = UDim2.new(1, 0, 0, 28)
	b.Parent = tpHolder
	b.MouseButton1Click:Connect(function()
		tweenTo(p.pos)
	end)
end

btnTween.MouseButton1Click:Connect(function()
	AutoTween = not AutoTween
	btnTween.Text = "Auto Tween: " .. (AutoTween and "ON" or "OFF")
	tpHolder.Size = AutoTween
		and UDim2.new(1, -12, 0, tpLayout.AbsoluteContentSize.Y)
		or UDim2.new(1, -12, 0, 0)
end)

-- ===== FLY =====
local btnFly = makeButton("Fly: OFF (F)")

-- ===== SLIDER =====
local sliderBg = Instance.new("Frame", frame)
sliderBg.Size = UDim2.new(1, -12, 0, 12)
sliderBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
sliderBg.BorderSizePixel = 0
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1,0)

local slider = Instance.new("Frame", sliderBg)
slider.Size = UDim2.new(0.1,0,1,0)
slider.BackgroundColor3 = Color3.fromRGB(90,90,90)
slider.BorderSizePixel = 0
Instance.new("UICorner", slider).CornerRadius = UDim.new(1,0)

local dragging = false
sliderBg.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

RunService.RenderStepped:Connect(function()
	if dragging then
		local x = math.clamp(
			(UIS:GetMouseLocation().X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X,
			0, 1
		)
		slider.Size = UDim2.new(x,0,1,0)
		FlySpeed = math.max(1, math.floor(x * 50))
	end
end)

-- ===== FLY LOGIC =====
local function startFly()
	bv = Instance.new("BodyVelocity", hrp)
	bv.MaxForce = Vector3.new(1e9,1e9,1e9)
	bg = Instance.new("BodyGyro", hrp)
	bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
end

local function stopFly()
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
end

RunService.RenderStepped:Connect(function()
	if not Fly or not bv then return end
	local cam = workspace.CurrentCamera
	local move = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
	bv.Velocity = move * FlySpeed
	bg.CFrame = cam.CFrame
end)

local function toggleFly()
	Fly = not Fly
	btnFly.Text = "Fly: " .. (Fly and "ON" or "OFF") .. " (F)"
	if Fly then startFly() else stopFly() end
end

btnFly.MouseButton1Click:Connect(toggleFly)

-- ===== HOTKEYS =====
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.F then toggleFly() end
	if i.KeyCode == Enum.KeyCode.RightShift then gui.Enabled = not gui.Enabled end
end)
