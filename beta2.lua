-- ================= SERVICES =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- ================= CHARACTER =================
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end
local hrp = getHRP()
player.CharacterAdded:Connect(function()
	hrp = getHRP()
end)

-- ================= STATES =================
local currentTab = "Teleport"

-- Teleport
local autoTeleFarm = false
local autoTelePlayer = false
local followPlayer = nil
local savedPos = nil

-- Farm
local fastMine = false
local autoMine = false
local autoEquip = false
local equipMode = true
local selectedPickaxe = nil

-- ================= BLUR =================
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local function setBlur(on)
	TweenService:Create(
		blur,
		TweenInfo.new(0.25),
		{Size = on and 12 or 0}
	):Play()
end

-- ================= UI ROOT =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BlackHubV3"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 320)
main.Position = UDim2.new(0.25, 0, 0.25, 0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- Shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10,10,118,118)
shadow.BackgroundTransparency = 1
shadow.ZIndex = -1

-- ================= TITLE =================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "BLACK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

-- ================= TOGGLE BUTTON =================
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0, 30, 0, 30)
toggle.Position = UDim2.new(1, -40, 0, 5)
toggle.Text = "-"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.BorderSizePixel = 0
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

-- ================= LEFT MENU =================
local left = Instance.new("Frame", main)
left.Size = UDim2.new(0, 120, 1, -45)
left.Position = UDim2.new(0, 10, 0, 40)
left.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", left).CornerRadius = UDim.new(0,8)

local leftList = Instance.new("UIListLayout", left)
leftList.Padding = UDim.new(0,6)
leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================= RIGHT CONTENT =================
local right = Instance.new("Frame", main)
right.Size = UDim2.new(1, -150, 1, -45)
right.Position = UDim2.new(0, 140, 0, 40)
right.BackgroundColor3 = Color3.fromRGB(22,22,22)
Instance.new("UICorner", right).CornerRadius = UDim.new(0,8)

local rightList = Instance.new("UIListLayout", right)
rightList.Padding = UDim.new(0,6)
rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================= UI HELPERS =================
local function makeBtn(parent, text, h)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, -10, 0, h or 30)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(35,35,35)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local function clearRight()
	for _,v in ipairs(right:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
end

local function slideDown(frame, height)
	frame.ClipsDescendants = true
	frame.Size = UDim2.new(1,-10,0,0)
	TweenService:Create(frame,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{
		Size = UDim2.new(1,-10,0,height)
	}):Play()
end

local function slideUp(frame)
	TweenService:Create(frame,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{
		Size = UDim2.new(1,-10,0,0)
	}):Play()
	task.delay(0.3,function()
		if frame then frame:Destroy() end
	end)
end

-- ================= LEFT BUTTONS =================
local btnTeleport = makeBtn(left,"Teleport")
local btnFarm = makeBtn(left,"Farm")

-- ================= TELEPORT TAB =================
local function buildTeleport()
	clearRight()

	local btnAutoFarm = makeBtn(right,"Auto Teleport Farm : OFF")
	btnAutoFarm.MouseButton1Click:Connect(function()
		autoTeleFarm = not autoTeleFarm
		btnAutoFarm.Text = "Auto Teleport Farm : "..(autoTeleFarm and "ON" or "OFF")

		if autoTeleFarm then
			savedPos = hrp.Position
			local posB = Vector3.new(700,20,-350)

			task.spawn(function()
				while autoTeleFarm do
					hrp.CFrame = CFrame.new(posB)
					task.wait(1)
					hrp.CFrame = CFrame.new(savedPos)
					task.wait(1)
				end
			end)
		end
	end)

	local btnTelePlayer = makeBtn(right,"Teleport Player : OFF")
	local listFrame

	btnTelePlayer.MouseButton1Click:Connect(function()
		autoTelePlayer = not autoTelePlayer
		btnTelePlayer.Text = "Teleport Player : "..(autoTelePlayer and "ON" or "OFF")

		if autoTelePlayer then
			listFrame = Instance.new("Frame", right)
			listFrame.BackgroundTransparency = 1
			slideDown(listFrame,150)

			local scroll = Instance.new("ScrollingFrame", listFrame)
			scroll.Size = UDim2.new(1,0,1,0)
			scroll.CanvasSize = UDim2.new(0,0,0,0)
			scroll.ScrollBarThickness = 4
			scroll.BackgroundTransparency = 1

			local ul = Instance.new("UIListLayout", scroll)
			ul.Padding = UDim.new(0,4)

			ul:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll.CanvasSize = UDim2.new(0,0,0,ul.AbsoluteContentSize.Y+6)
			end)

			for _,plr in ipairs(Players:GetPlayers()) do
				if plr ~= player then
					local b = makeBtn(scroll,plr.Name,26)
					b.MouseButton1Click:Connect(function()
						followPlayer = plr
						for _,v in ipairs(scroll:GetChildren()) do
							if v:IsA("TextButton") then
								v.BackgroundColor3 = Color3.fromRGB(35,35,35)
							end
						end
						b.BackgroundColor3 = Color3.fromRGB(0,120,255)
					end)
				end
			end
		else
			if listFrame then slideUp(listFrame) end
		end
	end)

	task.spawn(function()
		while true do
			if autoTelePlayer and followPlayer then
				local c = followPlayer.Character
				local t = c and c:FindFirstChild("HumanoidRootPart")
				if t then hrp.CFrame = t.CFrame end
			end
			task.wait(0.2)
		end
	end)
end

-- ================= FARM TAB =================
local function buildFarm()
	clearRight()

	local btnFast = makeBtn(right,"Fast Mine : OFF")
	btnFast.MouseButton1Click:Connect(function()
		fastMine = not fastMine
		btnFast.Text = "Fast Mine : "..(fastMine and "ON" or "OFF")
	end)

	task.spawn(function()
		while true do
			if fastMine then
				ReplicatedStorage.Remotes.FinishMine:FireServer()
			end
			task.wait(0.2)
		end
	end)

	local btnAutoMine = makeBtn(right,"Auto Mine : OFF")
	btnAutoMine.MouseButton1Click:Connect(function()
		autoMine = not autoMine
		btnAutoMine.Text = "Auto Mine : "..(autoMine and "ON" or "OFF")
	end)

	task.spawn(function()
		while true do
			if autoMine then
				VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
				task.wait(0.05)
				VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
			end
			task.wait(1)
		end
	end)

	local btnEquip = makeBtn(right,"Auto Equip")
	local sub

	btnEquip.MouseButton1Click:Connect(function()
		autoEquip = not autoEquip
		if autoEquip then
			sub = Instance.new("Frame", right)
			sub.BackgroundTransparency = 1
			slideDown(sub,180)

			local scroll = Instance.new("ScrollingFrame", sub)
			scroll.Size = UDim2.new(1,0,1,0)
			scroll.ScrollBarThickness = 4
			scroll.BackgroundTransparency = 1

			local ul = Instance.new("UIListLayout", scroll)
			ul.Padding = UDim.new(0,4)

			ul:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll.CanvasSize = UDim2.new(0,0,0,ul.AbsoluteContentSize.Y+6)
			end)

			local pickaxes = {
				"Iron Pickaxe","Golden Pickaxe","Diamond Pickaxe",
				"Drill Pickaxe","Lava Pickaxe","Royal Pickaxe",
				"Fairy Pickaxe","Mythril Pickaxe","Frost Pickaxe"
			}

			for _,name in ipairs(pickaxes) do
				local p = makeBtn(scroll,name,26)
				p.MouseButton1Click:Connect(function()
					selectedPickaxe = name
					for _,v in ipairs(scroll:GetChildren()) do
						if v:IsA("TextButton") then
							v.BackgroundColor3 = Color3.fromRGB(35,35,35)
						end
					end
					p.BackgroundColor3 = Color3.fromRGB(0,120,255)
				end)
			end
		else
			if sub then slideUp(sub) end
		end
	end)

	task.spawn(function()
		while true do
			if autoEquip and selectedPickaxe then
				ReplicatedStorage.Remotes.PickaxeEquipRequest:FireServer(selectedPickaxe)
			end
			task.wait(2)
		end
	end)
end

-- ================= TAB SWITCH =================
btnTeleport.MouseButton1Click:Connect(buildTeleport)
btnFarm.MouseButton1Click:Connect(buildFarm)

buildTeleport()
setBlur(true)

-- ================= TOGGLE =================
local opened = true
local fullSize = main.Size

toggle.MouseButton1Click:Connect(function()
	opened = not opened
	if opened then
		TweenService:Create(main,TweenInfo.new(0.25),{Size = fullSize}):Play()
		setBlur(true)
	else
		TweenService:Create(main,TweenInfo.new(0.25),{Size = UDim2.new(0,120,0,30)}):Play()
		setBlur(false)
	end
end)
