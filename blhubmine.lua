-- ====== TITLE ======
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -10, 0, 22)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.Text = "BLACK HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ====== TRẠNG THÁI ======
local AutoTween = false
local ExtraMine = false

-- ====== NHÂN VẬT ======
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- ====== UI ======
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AutoMenu"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 105)
frame.Position = UDim2.new(0.05, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- ====== NÚT AUTO TWEEN ======
local btnTween = Instance.new("TextButton", frame)
btnTween.Size = UDim2.new(1, -10, 0, 35)
btnTween.Position = UDim2.new(0, 5, 0, 25)
btnTween.Text = "Auto Tween: OFF"
btnTween.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnTween.TextColor3 = Color3.new(1,1,1)
btnTween.BorderSizePixel = 0
Instance.new("UICorner", btnTween).CornerRadius = UDim.new(0, 8)

-- ====== NÚT EXTRA MINE ======
local btnMine = Instance.new("TextButton", frame)
btnMine.Size = UDim2.new(1, -10, 0, 35)
btnMine.Position  = UDim2.new(0, 5, 0, 65)
btnMine.Text = "Extra Mine: OFF"
btnMine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
btnMine.TextColor3 = Color3.new(1,1,1)
btnMine.BorderSizePixel = 0
Instance.new("UICorner", btnMine).CornerRadius = UDim.new(0, 8)

-- ====== AUTO TWEEN ======
local posA = Vector3.new(632, 4, -350)
local posB = Vector3.new(722, 29, -353)

local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(posA)})

btnTween.MouseButton1Click:Connect(function()
    AutoTween = not AutoTween
    btnTween.Text = "Auto Tween: " .. (AutoTween and "ON" or "OFF")

    if AutoTween then
        tween:Play()
    else
        tween:Cancel()
    end
end)

-- ====== EXTRA MINE ======
local mineRemote = game:GetService("ReplicatedStorage").Remotes.FinishMine

task.spawn(function()
    while true do
        if ExtraMine then
            mineRemote:FireServer()
        end
        task.wait(1) -- chỉnh tốc độ mine tại đây
    end
end)

btnMine.MouseButton1Click:Connect(function()
    ExtraMine = not ExtraMine
    btnMine.Text = "Extra Mine: " .. (ExtraMine and "ON" or "OFF")
end)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.M then
        gui.Enabled = not gui.Enabled
    end
end)