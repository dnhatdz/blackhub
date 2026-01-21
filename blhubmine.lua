-- ================= SERVICES =================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local teleTween = nil

-- Farm
local fastMine = false
local autoMine = false
local autoEquip = false
local equipMode = true
local selectedPickaxe = nil

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

-- ================= TITLE =================
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.new(0, 10, 0, 5)
title.Text = "BLACK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

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

-- ================= LEFT MENU BUTTONS =================
local btnTeleport = makeBtn(left, "Teleport")
local btnFarm = makeBtn(left, "Farm")

-- ================= TELEPORT TAB =================
local function buildTeleport()
	clearRight()

	-- AUTO TELE FARM
	local btnAutoFarm = makeBtn(right, "Auto Teleport Farm : OFF")
	btnAutoFarm.MouseButton1Click:Connect(function()
		autoTeleFarm = not autoTeleFarm
		btnAutoFarm.Text = "Auto Teleport Farm : " .. (autoTeleFarm and "ON" or "OFF")

		if autoTeleFarm then
			savedPos = hrp.Position
			-- TODO: ku nhập tọa độ B ở đây
			local posB = Vector3.new(700,20,-350)

			hrp.CFrame = CFrame.new(posB)

			task.spawn(function()
				while autoTeleFarm do
					task.wait(1)
					hrp.CFrame = CFrame.new(savedPos)
					task.wait(1)
					hrp.CFrame = CFrame.new(posB)
				end
			end)
		end
	end)

	-- TELE PLAYER
	local btnTelePlayer = makeBtn(right, "Teleport Player : OFF")
	local playerListFrame

	btnTelePlayer.MouseButton1Click:Connect(function()
		autoTelePlayer = not autoTelePlayer
		btnTelePlayer.Text = "Teleport Player : " .. (autoTelePlayer and "ON" or "OFF")

		if autoTelePlayer then
			playerListFrame = Instance.new("Frame", right)
			playerListFrame.Size = UDim2.new(1,-10,0,120)
			playerListFrame.BackgroundTransparency = 1
			local ul = Instance.new("UIListLayout", playerListFrame)
			ul.Padding = UDim.new(0,4)

			for _,plr in ipairs(Players:GetPlayers()) do
				if plr ~= player then
					local pBtn = makeBtn(playerListFrame, plr.Name, 26)
					pBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
					pBtn.TextColor3 = Color3.fromRGB(0,0,0)

					pBtn.MouseButton1Click:Connect(function()
						followPlayer = plr
						pBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
						pBtn.TextColor3 = Color3.new(1,1,1)
					end)
				end
			end
		else
			if playerListFrame then playerListFrame:Destroy() end
		end
	end)

	-- FOLLOW LOOP
	task.spawn(function()
		while true do
			if autoTelePlayer and followPlayer then
				local c = followPlayer.Character
				local t = c and c:FindFirstChild("HumanoidRootPart")
				if t then
					hrp.CFrame = t.CFrame
				end
			end
			task.wait(0.2)
		end
	end)
end

-- ================= FARM TAB =================
local function buildFarm()
	clearRight()

	-- FAST MINE
	local btnFast = makeBtn(right, "Fast Mine : OFF")
	btnFast.MouseButton1Click:Connect(function()
		fastMine = not fastMine
		btnFast.Text = "Fast Mine : " .. (fastMine and "ON" or "OFF")
	end)

	task.spawn(function()
		while true do
			if fastMine then
				ReplicatedStorage.Remotes.FinishMine:FireServer()
			end
			task.wait(0.2)
		end
	end)

	-- AUTO MINE
	local btnAutoMine = makeBtn(right, "Auto Mine : OFF")
	btnAutoMine.MouseButton1Click:Connect(function()
		autoMine = not autoMine
		btnAutoMine.Text = "Auto Mine : " .. (autoMine and "ON" or "OFF")
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

	-- AUTO EQUIP
	local btnEquip = makeBtn(right, "Auto Equip")
	local subFrame

	btnEquip.MouseButton1Click:Connect(function()
		autoEquip = not autoEquip

		if autoEquip then
			subFrame = Instance.new("Frame", right)
			subFrame.Size = UDim2.new(1,-10,0,120)
			subFrame.BackgroundTransparency = 1
			local ul = Instance.new("UIListLayout", subFrame)
			ul.Padding = UDim.new(0,4)

			local pickaxes = {
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

			for _,name in ipairs(pickaxes) do
				local p = makeBtn(subFrame, name, 26)
				p.MouseButton1Click:Connect(function()
					selectedPickaxe = name
					p.BackgroundColor3 = Color3.fromRGB(0,120,255)
				end)
			end

			local modeBtn = makeBtn(subFrame, "Mode : ON", 26)
			modeBtn.MouseButton1Click:Connect(function()
				equipMode = not equipMode
				modeBtn.Text = "Mode : " .. (equipMode and "ON" or "OFF")
			end)
		else
			if subFrame then subFrame:Destroy() end
		end
	end)

	-- EQUIP LOOP
	task.spawn(function()
		while true do
			if autoEquip and equipMode and selectedPickaxe then
				ReplicatedStorage.Remotes.PickaxeEquipRequest:FireServer(selectedPickaxe)
			end
			task.wait(2)
		end
	end)
end

-- ================= TAB SWITCH =================
btnTeleport.MouseButton1Click:Connect(buildTeleport)
btnFarm.MouseButton1Click:Connect(buildFarm)

buildTeleport() -- mặc định
