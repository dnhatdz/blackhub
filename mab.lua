-- ================= SERVICES =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
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
local autoTeleFarm = false
local autoTelePlayer = false
local followPlayer

local fastMine = false
local autoMine = false

local autoEquip = false
local selectedPickaxe

local teleportFarm = false
local farmPos = Vector3.new(10, 5, -350)
local savedPos
local farmSwitch = false

local autoPlace = {
	["Rainbow Lucky Block"] = false,
	["Secret Lucky Block"] = false,
	["Radioactive Lucky Block"] = false,
	["Magma Lucky Block"] = false
}

-- ================= COLORS =================
local RED = Color3.fromRGB(170,0,0)
local GREEN = Color3.fromRGB(0,170,0)
local BLUE = Color3.fromRGB(0,120,255)
local YELLOW = Color3.fromRGB(255,200,0)
local GRAY = Color3.fromRGB(35,35,35)

-- ================= BLUR =================
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
local function setBlur(on)
	TweenService:Create(blur, TweenInfo.new(0.25), {Size = on and 12 or 0}):Play()
end

-- ================= UI ROOT =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BlackHubV3"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,520,0,340)
main.Position = UDim2.new(0.25,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- ================= TITLE =================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,-60,0,30)
title.Position = UDim2.new(0,10,0,5)
title.Text = "BLACK HUB (FREEMIUM)"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- ================= TOGGLE =================
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0,30,0,30)
toggle.Position = UDim2.new(1,-40,0,5)
toggle.Text = "-"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
toggle.BorderSizePixel = 0
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1,0)

-- ================= CONTENT =================
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,40)
content.Size = UDim2.new(1,0,1,-40)
content.BackgroundTransparency = 1

-- ================= LEFT =================
local left = Instance.new("Frame", content)
left.Size = UDim2.new(0,120,1,0)
left.Position = UDim2.new(0,10,0,0)
left.BackgroundColor3 = Color3.fromRGB(25,25,25)
Instance.new("UICorner", left).CornerRadius = UDim.new(0,8)

local leftList = Instance.new("UIListLayout", left)
leftList.Padding = UDim.new(0,6)
leftList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================= RIGHT =================
local right = Instance.new("Frame", content)
right.Size = UDim2.new(1,-150,1,0)
right.Position = UDim2.new(0,140,0,0)
right.BackgroundColor3 = Color3.fromRGB(22,22,22)
Instance.new("UICorner", right).CornerRadius = UDim.new(0,8)

local rightList = Instance.new("UIListLayout", right)
rightList.Padding = UDim.new(0,6)
rightList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================= HELPERS =================
local function makeBtn(parent,text,h)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,-10,0,h or 30)
	b.Text = text
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = RED
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

local function setToggle(btn,state,label)
	btn.BackgroundColor3 = state and GREEN or RED
	btn.Text = label..": "..(state and "ON" or "OFF")
end

local function clearRight()
	for _,v in ipairs(right:GetChildren()) do
		if not v:IsA("UIListLayout") then v:Destroy() end
	end
end

-- ================= LEFT BUTTONS =================
local btnTeleport = makeBtn(left,"Teleport")
local btnFarm = makeBtn(left,"Farm")
local btnAutoPlace = makeBtn(left,"Auto Place")

-- ================= TELEPORT TAB =================
local function buildTeleport()
	clearRight()

	-- ===== TELE X10 MAP (ONE CLICK) =====
	local btnX10 = makeBtn(right,"Teleport x10 Map")
	btnX10.BackgroundColor3 = BLUE

	btnX10.MouseButton1Click:Connect(function()
		local pos = Vector3.new(630, 6, -350) -- 🔧 ĐỔI TỌA ĐỘ TẠI ĐÂY
		hrp.CFrame = CFrame.new(pos)
	end)

	-- ===== TELEPORT PLAYER =====
	local panelOpen = false
	local panel

	local btnTele = makeBtn(right,"Teleport Player")
	setToggle(btnTele,autoTelePlayer,"Teleport Player")

	btnTele.MouseButton1Click:Connect(function()
		panelOpen = not panelOpen

		if panelOpen then
			panel = Instance.new("Frame", right)
			panel.Size = UDim2.new(1,-10,0,200)
			panel.BackgroundTransparency = 1

			local toggleTele = makeBtn(panel,"Teleport")
			setToggle(toggleTele,autoTelePlayer,"Teleport")

			toggleTele.MouseButton1Click:Connect(function()
				autoTelePlayer = not autoTelePlayer
				setToggle(toggleTele,autoTelePlayer,"Teleport")
				setToggle(btnTele,autoTelePlayer,"Teleport Player")
			end)

			local scroll = Instance.new("ScrollingFrame", panel)
			scroll.Position = UDim2.new(0,0,0,40)
			scroll.Size = UDim2.new(1,0,0,150)
			scroll.ScrollBarThickness = 5
			scroll.BackgroundTransparency = 1

			local ul = Instance.new("UIListLayout", scroll)
			ul.Padding = UDim.new(0,4)

			ul:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				scroll.CanvasSize = UDim2.new(0,0,0,ul.AbsoluteContentSize.Y+5)
			end)

			for _,plr in ipairs(Players:GetPlayers()) do
				if plr ~= player then
					local b = makeBtn(scroll,plr.Name,26)
					b.BackgroundColor3 = GRAY
					b.MouseButton1Click:Connect(function()
						followPlayer = plr
						for _,v in ipairs(scroll:GetChildren()) do
							if v:IsA("TextButton") then v.BackgroundColor3 = GRAY end
						end
						b.BackgroundColor3 = BLUE
					end)
				end
			end
		else
			if panel then panel:Destroy() end
		end
	end)
end

-- ================= FARM TAB =================
local function buildFarm()
	clearRight()

	-- TELEPORT FARM (LUÂN PHIÊN)
    local btnTeleFarm = makeBtn(right,"Teleport Farm")
    setToggle(btnTeleFarm,teleportFarm,"Teleport Farm")
	btnTeleFarm.MouseButton1Click:Connect(function()
	    teleportFarm = not teleportFarm
	    setToggle(btnTeleFarm,teleportFarm,"Teleport Farm")

	    if teleportFarm then
		    savedPos = hrp.Position
		    farmSwitch = false
	    end
    end)


	-- FAST MINE
	local btnFast = makeBtn(right,"Fast Mine")
	setToggle(btnFast,fastMine,"Fast Mine")
	btnFast.MouseButton1Click:Connect(function()
		fastMine = not fastMine
		setToggle(btnFast,fastMine,"Fast Mine")
	end)

	-- AUTO MINE
	local btnAutoMine = makeBtn(right,"Auto Mine")
	setToggle(btnAutoMine,autoMine,"Auto Mine")
	btnAutoMine.MouseButton1Click:Connect(function()
		autoMine = not autoMine
		setToggle(btnAutoMine,autoMine,"Auto Mine")
	end)

	-- AUTO EQUIP
	local btnEquip = makeBtn(right,"Auto Equip")
	setToggle(btnEquip,autoEquip,"Auto Equip")
	btnEquip.MouseButton1Click:Connect(function()
		autoEquip = not autoEquip
		setToggle(btnEquip,autoEquip,"Auto Equip")
	end)

	-- PICKAXE LIST
	local pickFrame = Instance.new("ScrollingFrame", right)
	pickFrame.Size = UDim2.new(1,-10,0,4*30)
	pickFrame.ScrollBarThickness = 5
	pickFrame.BackgroundTransparency = 1

	local ul = Instance.new("UIListLayout", pickFrame)
	ul.Padding = UDim.new(0,4)

	ul:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		pickFrame.CanvasSize = UDim2.new(0,0,0,ul.AbsoluteContentSize.Y+5)
	end)

	local pickaxes = {
		"Iron Pickaxe","Golden Pickaxe","Diamond Pickaxe",
		"Drill Pickaxe","Lava Pickaxe","Royal Pickaxe",
		"Fairy Pickaxe","Mythril Pickaxe","Frost Pickaxe"
	}

	for _,name in ipairs(pickaxes) do
		local b = makeBtn(pickFrame,name,28)
		b.BackgroundColor3 = GRAY
		b.MouseButton1Click:Connect(function()
			selectedPickaxe = name
			for _,v in ipairs(pickFrame:GetChildren()) do
				if v:IsA("TextButton") then v.BackgroundColor3 = GRAY end
			end
			b.BackgroundColor3 = YELLOW
		end)
	end
end

-- ================= LOOPS =================
-- MINE LOOP (FAST + AUTO SONG SONG)
task.spawn(function()
	while true do
		if fastMine then
			pcall(function()
				ReplicatedStorage.Remotes.FinishMine:FireServer()
			end)
		end
		if autoMine then
			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.03)
			VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
		end
		task.wait(0.12)
	end
end)

-- AUTO EQUIP (EQUIP TOOL THẬT)
task.spawn(function()
	while true do
		if autoEquip and selectedPickaxe then
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local bp = player:FindFirstChild("Backpack")
			if hum and bp then
				local tool = bp:FindFirstChild(selectedPickaxe) or char:FindFirstChild(selectedPickaxe)
				if tool and tool:IsA("Tool") then
					pcall(function()
						hum:EquipTool(tool)
					end)
				end
			end
		end
		task.wait(1)
	end
end)

-- TELE PLAYER LOOP
task.spawn(function()
	while true do
		if autoTelePlayer and followPlayer then
			local t = followPlayer.Character and followPlayer.Character:FindFirstChild("HumanoidRootPart")
			if t then hrp.CFrame = t.CFrame end
		end
		task.wait(0.2)
	end
end)
-- ================= AUTO PLACE TAB =================
local function buildAutoPlace()
	clearRight()

	local function makeToggle(name)
		local btn = makeBtn(right,name)
		setToggle(btn,autoPlace[name],name)

		btn.MouseButton1Click:Connect(function()
			autoPlace[name] = not autoPlace[name]
			setToggle(btn,autoPlace[name],name)
		end)
	end

	makeToggle("Rainbow Lucky Block")
	makeToggle("Secret Lucky Block")
	makeToggle("Radioactive Lucky Block")
	makeToggle("Magma Lucky Block")
end

-- ================= TAB SWITCH =================
btnTeleport.MouseButton1Click:Connect(buildTeleport)
btnFarm.MouseButton1Click:Connect(buildFarm)
btnAutoPlace.MouseButton1Click:Connect(buildAutoPlace)

buildTeleport()
setBlur(true)

-- ================= TOGGLE UI =================
local opened = true
local fullSize = main.Size
local smallSize = UDim2.new(0,140,0,36)

toggle.MouseButton1Click:Connect(function()
	opened = not opened
	if opened then
		content.Visible = true
		toggle.Text = "-"
		TweenService:Create(main,TweenInfo.new(0.25),{Size = fullSize}):Play()
		setBlur(true)
	else
		toggle.Text = "+"
		TweenService:Create(main,TweenInfo.new(0.25),{Size = smallSize}):Play()
		setBlur(false)
		task.delay(0.25,function()
			if not opened then content.Visible = false end
		end)
	end
end)
-- TELEPORT FARM LOOP (QUA LẠI LIÊN TỤC)
task.spawn(function()
	while true do
		if teleportFarm and savedPos then
			if farmSwitch then
				hrp.CFrame = CFrame.new(savedPos)
			else
				hrp.CFrame = CFrame.new(farmPos)
			end
			farmSwitch = not farmSwitch
			task.wait(0.6) -- tốc độ teleport (chỉnh được)
		else
			task.wait(0.2)
		end
	end
end)
-- ================= AUTO PLACE LOOP =================
task.spawn(function()
	while true do
		for itemName,enabled in pairs(autoPlace) do
			if enabled then
				pcall(function()
					local char = player.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					local bp = player:FindFirstChild("Backpack")
					if not (char and hrp and bp) then return end

					local tool = bp:FindFirstChild(itemName)
					if tool and tool:IsA("Tool") then
						tool.Parent = char
						task.wait(0.05)
						local cf = hrp.CFrame * CFrame.new(0,0,-6)
						ReplicatedStorage.Remotes.PlacingRequest:FireServer(cf)
					end
				end)
				break
			end
		end
		task.wait(0.3) -- delay đặt
	end
end)
