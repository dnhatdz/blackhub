-- ================= SERVICES =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local PICKAXE_LIST = {
	"Iron Pickaxe",
	"Golden Pickaxe",
	"Diamond Pickaxe",
    "Drill Pickaxe",
    "Lava Pickaxe",
    "Royal Pickaxe",
    "Fairy Pickaxe",
    "Mythril Pickaxe",
    "Frost Pickaxe"
}

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
local AutoTween = false
local currentMode = nil
local followTarget = nil
local activeTween = nil
local ExtraMine = false

-- ================= UI =================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BlackHub"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 190, 0, 340)
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local mainList = Instance.new("UIListLayout", frame)
mainList.Padding = UDim.new(0,6)
mainList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- ================= TITLE =================
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-10,0,22)
title.BackgroundTransparency = 1
title.Text = "BLACK HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left

-- ================= AUTO TWEEN =================
local btnTween = Instance.new("TextButton", frame)
btnTween.Size = UDim2.new(1,-10,0,30)
btnTween.Text = "Auto Tween: OFF"
btnTween.BackgroundColor3 = Color3.fromRGB(40,40,40)
btnTween.TextColor3 = Color3.new(1,1,1)
btnTween.BorderSizePixel = 0
Instance.new("UICorner", btnTween).CornerRadius = UDim.new(0,8)

-- ================= MODE FRAME =================
local modeFrame = Instance.new("Frame", frame)
modeFrame.Size = UDim2.new(1,-10,0,0)
modeFrame.BackgroundTransparency = 1
modeFrame.ClipsDescendants = true

local modeList = Instance.new("UIListLayout", modeFrame)
modeList.Padding = UDim.new(0,5)

local function baseBtn(parent, text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,0,28)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	b.Parent = parent
	return b
end

-- ===== V1 + STOP X =====
local v1Holder = Instance.new("Frame", modeFrame)
v1Holder.Size = UDim2.new(1,0,0,28)
v1Holder.BackgroundTransparency = 1

local btnV1 = baseBtn(v1Holder, "Auto Tween V1")
btnV1.Size = UDim2.new(1,-32,1,0)

local stopV1 = Instance.new("TextButton", v1Holder)
stopV1.Size = UDim2.new(0,28,1,0)
stopV1.Position = UDim2.new(1,-28,0,0)
stopV1.Text = "X"
stopV1.BackgroundColor3 = Color3.fromRGB(120,0,0)
stopV1.TextColor3 = Color3.new(1,1,1)
stopV1.BorderSizePixel = 0
Instance.new("UICorner", stopV1).CornerRadius = UDim.new(0,8)

local btnV3 = baseBtn(modeFrame, "Auto Tween V3 (Follow)")

-- ================= PLAYER LIST =================
local playerFrame = Instance.new("Frame", frame)
playerFrame.Size = UDim2.new(1,-10,0,0)
playerFrame.BackgroundTransparency = 1
playerFrame.ClipsDescendants = true

local playerList = Instance.new("UIListLayout", playerFrame)
playerList.Padding = UDim.new(0,4)

-- ================= UTILS =================
local function stopTween()
	if activeTween then
		activeTween:Cancel()
		activeTween = nil
	end
end

-- ================= RUN MODE =================
local function runMode()
	stopTween()
	if not AutoTween then return end

	-- V1
	if currentMode == 1 then
		local A = Vector3.new(720,4,-350)
		local B = Vector3.new(632,4,-350)
		hrp.CFrame = CFrame.new(A)
		activeTween = TweenService:Create(
			hrp,
			TweenInfo.new(2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
			{CFrame = CFrame.new(B)}
		)
		activeTween:Play()
	end

	-- V3 FOLLOW
	if currentMode == 3 and followTarget then
		task.spawn(function()
			while AutoTween and currentMode == 3 and followTarget do
				local c = followTarget.Character
				local tHRP = c and c:FindFirstChild("HumanoidRootPart")
				if tHRP then
					activeTween = TweenService:Create(
						hrp,
						TweenInfo.new(0.25,Enum.EasingStyle.Linear),
						{CFrame = tHRP.CFrame}
					)
					activeTween:Play()
					activeTween.Completed:Wait()
				end
				task.wait(0.05)
			end
		end)
	end
end

-- ================= REFRESH PLAYER LIST =================
local function refreshPlayerList()
	for _,v in ipairs(playerFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local b = baseBtn(playerFrame, plr.Name)
			b.BackgroundColor3 = Color3.fromRGB(255,255,255)
			b.TextColor3 = Color3.fromRGB(0,0,0)

			b.MouseButton1Click:Connect(function()
				-- bấm lần 2 => dừng
				if followTarget == plr then
					followTarget = nil
					stopTween()
					b.BackgroundColor3 = Color3.fromRGB(170,0,0) -- đỏ
					return
				end

				-- reset các nút khác
				for _,btn in ipairs(playerFrame:GetChildren()) do
					if btn:IsA("TextButton") then
						btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
						btn.TextColor3 = Color3.fromRGB(0,0,0)
					end
				end

				-- follow
				followTarget = plr
				currentMode = 3
				b.BackgroundColor3 = Color3.fromRGB(0,120,255) -- xanh
				b.TextColor3 = Color3.new(1,1,1)
				runMode()
			end)
		end
	end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(function(plr)
	if followTarget == plr then followTarget = nil end
	refreshPlayerList()
end)

-- ================= BUTTON EVENTS =================
btnV1.MouseButton1Click:Connect(function()
	currentMode = 1
	runMode()
end)

stopV1.MouseButton1Click:Connect(function()
	if currentMode == 1 then
		stopTween()
		currentMode = nil
	end
end)

btnV3.MouseButton1Click:Connect(function()
	currentMode = 3
	refreshPlayerList()
	playerFrame:TweenSize(UDim2.new(1,-10,0,140),"Out","Quad",0.25,true)
end)

btnTween.MouseButton1Click:Connect(function()
	AutoTween = not AutoTween
	btnTween.Text = "Auto Tween: " .. (AutoTween and "ON" or "OFF")

	if AutoTween then
		modeFrame:TweenSize(UDim2.new(1,-10,0,70),"Out","Quad",0.25,true)
		runMode()
	else
		stopTween()
		playerFrame:TweenSize(UDim2.new(1,-10,0,0),"Out","Quad",0.25,true)
	end
end)

-- ================= EXTRA MINE =================
local Remotes = game:GetService("ReplicatedStorage").Remotes

local SelectedPickaxe = nil
local AutoMine = false

-- ===== NÚT EXTRA MINE (MENU) =====
local btnMineMenu = baseBtn(frame,"Extra Mine")

-- ===== FRAME CHỨC NĂNG =====
local mineFrame = Instance.new("Frame", frame)
mineFrame.Size = UDim2.new(1,-10,0,0)
mineFrame.BackgroundTransparency = 1
mineFrame.ClipsDescendants = true

local mineList = Instance.new("UIListLayout", mineFrame)
mineList.Padding = UDim.new(0,5)

-- ===== AUTO MINE TOGGLE =====
local btnAutoMine = baseBtn(mineFrame,"Auto Mine: OFF")

btnAutoMine.MouseButton1Click:Connect(function()
	AutoMine = not AutoMine
	btnAutoMine.Text = "Auto Mine: " .. (AutoMine and "ON" or "OFF")
end)

-- ===== PICKAXE LIST FRAME =====
local pickaxeFrame = Instance.new("ScrollingFrame", mineFrame)
pickaxeFrame.Size = UDim2.new(1,0,0,0)
pickaxeFrame.CanvasSize = UDim2.new(0,0,0,0)
pickaxeFrame.ScrollBarImageTransparency = 0
pickaxeFrame.ScrollBarThickness = 4
pickaxeFrame.BackgroundTransparency = 1
pickaxeFrame.ClipsDescendants = true

local pickaxeList = Instance.new("UIListLayout", pickaxeFrame)
pickaxeList.Padding = UDim.new(0,4)

-- ===== TẠO DANH SÁCH CÚP =====
local function refreshPickaxeList()
	for _,v in ipairs(pickaxeFrame:GetChildren()) do
		if v:IsA("TextButton") then v:Destroy() end
	end

	for _,name in ipairs(PICKAXE_LIST) do
		local b = baseBtn(pickaxeFrame,name)
		b.BackgroundColor3 = Color3.fromRGB(255,255,255)
		b.TextColor3 = Color3.fromRGB(0,0,0)

		b.MouseButton1Click:Connect(function()
			SelectedPickaxe = name
			for _,btn in ipairs(pickaxeFrame:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
					btn.TextColor3 = Color3.fromRGB(0,0,0)
				end
			end
			b.BackgroundColor3 = Color3.fromRGB(0,120,255)
			b.TextColor3 = Color3.new(1,1,1)
		end)
	end

	local itemHeight = 32
    local maxHeight = 120
    local totalHeight = #PICKAXE_LIST * itemHeight

    pickaxeFrame.CanvasSize = UDim2.new(0,0,0,totalHeight)
    pickaxeFrame:TweenSize(
       UDim2.new(1,0,0, math.min(totalHeight, maxHeight)),
       "Out","Quad",0.25,true
    )

end

-- ===== NÚT CHOOSE PICKAXE =====
local btnChoose = baseBtn(mineFrame,"Choose Pickaxe")

btnChoose.MouseButton1Click:Connect(function()
	refreshPickaxeList()
end)

-- ===== MỞ / ĐÓNG EXTRA MINE MENU =====
local mineOpen = false
btnMineMenu.MouseButton1Click:Connect(function()
	mineOpen = not mineOpen
	mineFrame:TweenSize(
		UDim2.new(1,-10,0,mineOpen and 120 or 0),
		"Out","Quad",0.25,true
	)
	if not mineOpen then
		pickaxeFrame:TweenSize(UDim2.new(1,0,0,0),"Out","Quad",0.2,true)
	end
end)

-- ===== AUTO EQUIP PICKAXE =====
local function equipPickaxe()
	if not SelectedPickaxe then return end
	local char = player.Character
	if not char then return end
	if char:FindFirstChild(SelectedPickaxe) then return end

	local bp = player:FindFirstChild("Backpack")
	if bp then
		local tool = bp:FindFirstChild(SelectedPickaxe)
		if tool and tool:IsA("Tool") then
			tool.Parent = char
		end
	end
end

-- ===== AUTO MINE LOOP =====
task.spawn(function()
	while true do
		if AutoMine and SelectedPickaxe then
			equipPickaxe()
			Remotes.FinishMine:FireServer()

			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			task.wait(0.05)
			VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
		end
		task.wait(0.4)
	end
end)

-- ================= TOGGLE UI =================
UserInputService.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.M then
		gui.Enabled = not gui.Enabled
	end
end)
