local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ====== STATE ======
local AutoTween = false
local ExtraMine = false
local currentTween

-- ====== UI ======
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BrainrotHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 120)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- ====== TITLE ======
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -10, 0, 22)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "BRAINROT HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Left

-- ====== AUTO TWEEN BUTTON ======
local btnTween = Instance.new("TextButton", frame)
btnTween.Size = UDim2.new(1, -10, 0, 30)
btnTween.Position = UDim2.new(0, 5, 0, 25)
btnTween.Text = "Auto Tween: OFF"
btnTween.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnTween.TextColor3 = Color3.new(1,1,1)
btnTween.BorderSizePixel = 0
Instance.new("UICorner", btnTween).CornerRadius = UDim.new(0,8)

-- ====== TELEPORT LIST ======
local list = Instance.new("Frame", frame)
list.Size = UDim2.new(1, -10, 0, 0)
list.Position = UDim2.new(0, 5, 0, 60)
list.BackgroundTransparency = 1
list.ClipsDescendants = true

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,5)

-- ====== TELEPORT POINTS ======
local points = {
    {name = "Point A", pos = Vector3.new(632, 4, -350)},
    {name = "Point B", pos = Vector3.new(722, 29, -353)}
}

local function tweenTo(pos)
    if currentTween then
        currentTween:Cancel()
    end
    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        {CFrame = CFrame.new(pos)}
    )
    currentTween:Play()
end

-- ====== CREATE BUTTONS ======
for _, p in ipairs(points) do
    local b = Instance.new("TextButton", list)
    b.Size = UDim2.new(1, 0, 0, 28)
    b.Text = p.name
    b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.TextColor3 = Color3.new(1,1,1)
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)

    b.MouseButton1Click:Connect(function()
        tweenTo(p.pos)
    end)
end

-- ====== TOGGLE AUTO TWEEN ======
btnTween.MouseButton1Click:Connect(function()
    AutoTween = not AutoTween
    btnTween.Text = "Auto Tween: " .. (AutoTween and "ON" or "OFF")

    if AutoTween then
        list:TweenSize(UDim2.new(1, -10, 0, #points * 33), "Out", "Quad", 0.25)
        frame:TweenSize(UDim2.new(0, 170, 0, 120 + #points * 33), "Out", "Quad", 0.25)
    else
        list:TweenSize(UDim2.new(1, -10, 0, 0), "Out", "Quad", 0.25)
        frame:TweenSize(UDim2.new(0, 170, 0, 120), "Out", "Quad", 0.25)
        if currentTween then currentTween:Cancel() end
    end
end)

-- ====== M TO HIDE UI ======
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)
