--// BLACK HUB UI CORE (UI ONLY)
--// No logic attached – dùng làm UI nền cho loadstring

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

--// BLUR
local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 12

--// GUI ROOT
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "BlackHub_UI"
gui.ResetOnSpawn = false

--// MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,650,0,380)
main.Position = UDim2.new(0.5,-325,0.5,-190)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

--// TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,40)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Text = "BLACK HUB"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,200,60)
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.TextXAlignment = Left

--// CONTENT
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,40)
content.Size = UDim2.new(1,0,1,-40)
content.BackgroundTransparency = 1

--// SIDEBAR
local sidebar = Instance.new("Frame", content)
sidebar.Size = UDim2.new(0,200,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(22,22,22)
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0,14)

--// SEARCH
local search = Instance.new("TextBox", sidebar)
search.PlaceholderText = "Search function..."
search.Size = UDim2.new(1,-20,0,32)
search.Position = UDim2.new(0,10,0,12)
search.TextColor3 = Color3.new(1,1,1)
search.BackgroundColor3 = Color3.fromRGB(35,35,35)
search.Font = Enum.Font.Gotham
search.TextSize = 13
Instance.new("UICorner", search).CornerRadius = UDim.new(0,10)

--// MENU LIST
local menu = Instance.new("Frame", sidebar)
menu.Position = UDim2.new(0,0,0,56)
menu.Size = UDim2.new(1,0,1,-56)
menu.BackgroundTransparency = 1

local menuList = Instance.new("UIListLayout", menu)
menuList.Padding = UDim.new(0,6)
menuList.HorizontalAlignment = Center

--// RIGHT PANEL
local panel = Instance.new("Frame", content)
panel.Position = UDim2.new(0,210,0,0)
panel.Size = UDim2.new(1,-220,1,0)
panel.BackgroundColor3 = Color3.fromRGB(24,24,24)
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)

--// TAB SYSTEM
local Tabs = {}

local function showTab(name)
	for k,v in pairs(Tabs) do
		v.Visible = (k == name)
	end
end

local function createTab(name)
	local frame = Instance.new("Frame", panel)
	frame.Size = UDim2.new(1,0,1,0)
	frame.BackgroundTransparency = 1
	frame.Visible = false

	local list = Instance.new("UIListLayout", frame)
	list.Padding = UDim.new(0,10)
	list.HorizontalAlignment = Center

	Tabs[name] = frame
	return frame
end

--// BUTTON COMPONENT
local function ProButton(parent,text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,-20,0,36)
	b.Text = text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(240,240,240)
	b.BackgroundColor3 = Color3.fromRGB(38,38,38)
	b.AutoButtonColor = false
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)

	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{
			BackgroundColor3 = Color3.fromRGB(60,60,60)
		}):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{
			BackgroundColor3 = Color3.fromRGB(38,38,38)
		}):Play()
	end)

	return b
end

--// MENU BUTTON
local function MenuButton(text,tabName)
	local b = ProButton(menu,text)
	b.Size = UDim2.new(1,-20,0,34)

	b.MouseButton1Click:Connect(function()
		showTab(tabName)
	end)

	return b
end

--// CREATE TABS
local tabTeleport = createTab("Teleport")
local tabFarm = createTab("Farm")
local tabAutoPlace = createTab("AutoPlace")

--// MENU ITEMS
MenuButton("Teleport","Teleport")
MenuButton("Farm","Farm")
MenuButton("Auto Place","AutoPlace")

--// SAMPLE CONTENT (PLACEHOLDER)
ProButton(tabTeleport,"Teleport x10 Map")
ProButton(tabTeleport,"Teleport Player")

ProButton(tabFarm,"Fast Mine")
ProButton(tabFarm,"Auto Mine")
ProButton(tabFarm,"Auto Equip")

ProButton(tabAutoPlace,"Rainbow Lucky Block")
ProButton(tabAutoPlace,"Secret Lucky Block")
ProButton(tabAutoPlace,"Radioactive Lucky Block")
ProButton(tabAutoPlace,"Magma Lucky Block")

--// DEFAULT TAB
showTab("Teleport")
