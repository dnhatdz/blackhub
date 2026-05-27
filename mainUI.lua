local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkibidiMaster_PremiumHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local FILE_NAME = "Skibidi_Master_V3.json"
local macroData = {
    spawnCommands = {},
    autoUpgrade = false,
    autoAbility = false,
    autoGacha = false,
    blackScreen = false,
    isRecording = false,
    isPlaying = false
}

local function saveSettings()
    if writefile then
        pcall(function()
            writefile(FILE_NAME, HttpService:JSONEncode(macroData))
        end)
    end
end

local function loadSettings()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(readfile, FILE_NAME)
        if success then
            local decoded = HttpService:JSONDecode(content)
            if decoded then
                macroData = decoded
            end
        end
    end
end
loadSettings()

local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Size = UDim2.new(1, 0, 1, 0)
BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreenFrame.BorderSizePixel = 0
BlackScreenFrame.ZIndex = 999990
BlackScreenFrame.Visible = macroData.blackScreen
BlackScreenFrame.Parent = ScreenGui

local BlackScreenText = Instance.new("TextLabel")
BlackScreenText.Size = UDim2.new(1, 0, 0, 60)
BlackScreenText.Position = UDim2.new(0, 0, 0.5, -30)
BlackScreenText.BackgroundTransparency = 1
BlackScreenText.Text = "CHẾ ĐỘ MÀN HÌNH ĐEN ĐANG BẬT\nBấm nút HUB để tắt cấu hình"
BlackScreenText.TextColor3 = Color3.fromRGB(255, 20, 147)
BlackScreenText.Font = Enum.Font.GothamBold
BlackScreenText.TextSize = 20
BlackScreenText.Parent = BlackScreenFrame

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 999995
LoadingFrame.Parent = ScreenGui

local LoadingPattern = Instance.new("Frame")
LoadingPattern.Size = UDim2.new(2, 0, 2, 0)
LoadingPattern.Position = UDim2.new(-0.5, 0, -0.5, 0)
LoadingPattern.BackgroundTransparency = 1
LoadingPattern.Parent = LoadingFrame

local UIGridLayout = Instance.new("UIGridLayout")
UIGridLayout.CellSize = UDim2.new(0, 40, 0, 40)
UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
UIGridLayout.Parent = LoadingPattern

for i = 1, 600 do
    local tile = Instance.new("Frame")
    tile.BorderSizePixel = 0
    local row = math.floor((i - 1) / 30)
    local col = (i - 1) % 30
    if (row + col) % 2 == 0 then
        tile.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    else
        tile.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    end
    tile.Parent = LoadingPattern
end

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(0, 400, 0, 60)
LoadingText.Position = UDim2.new(0.5, -200, 0.5, -30)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "Skibidi Master TD - HUB"
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 28
LoadingText.ZIndex = 999996
LoadingText.Parent = LoadingFrame

local LoadingBarBg = Instance.new("Frame")
LoadingBarBg.Size = UDim2.new(0, 250, 0, 4)
LoadingBarBg.Position = UDim2.new(0.5, -125, 0.5, 30)
LoadingBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LoadingBarBg.BorderSizePixel = 0
LoadingBarBg.ZIndex = 999996
LoadingBarBg.Parent = LoadingFrame

local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(0, 0, 1, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
LoadingBar.BorderSizePixel = 0
LoadingBar.ZIndex = 999996
LoadingBar.Parent = LoadingBarBg

local barTween = TweenService:Create(LoadingBar, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
barTween:Play()
task.wait(2.2)

local fadeTween = TweenService:Create(LoadingFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
fadeTween:Play()
for _, v in ipairs(LoadingPattern:GetChildren()) do
    if v:IsA("Frame") then
        TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end
end
TweenService:Create(LoadingText, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
TweenService:Create(LoadingBarBg, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
TweenService:Create(LoadingBar, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
task.wait(0.5)
LoadingFrame:Destroy()

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 360)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1000
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(255, 20, 147)
MainBorder.Thickness = 1.5
MainBorder.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -30, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Skibidi Master Tower Defense v2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 140, 1, -45)
LeftPanel.Position = UDim2.new(0, 0, 0, 45)
LeftPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftLine = Instance.new("Frame")
LeftLine.Size = UDim2.new(0, 1, 1, 0)
LeftLine.Position = UDim2.new(1, -1, 0, 0)
LeftLine.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
LeftLine.BorderSizePixel = 0
LeftLine.Parent = LeftPanel

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 6)
LeftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Parent = LeftPanel

local LeftPadding = Instance.new("UIPadding")
LeftPadding.PaddingTop = UDim.new(0, 15)
LeftPadding.Parent = LeftPanel

local ContainerFrame = Instance.new("Frame")
ContainerFrame.Size = UDim2.new(1, -155, 1, -60)
ContainerFrame.Position = UDim2.new(0, 145, 0, 50)
ContainerFrame.BackgroundTransparency = 1
ContainerFrame.Parent = MainFrame

local FarmContainer = Instance.new("ScrollingFrame")
FarmContainer.Size = UDim2.new(1, 0, 1, 0)
FarmContainer.BackgroundTransparency = 1
FarmContainer.BorderSizePixel = 0
FarmContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
FarmContainer.ScrollBarThickness = 3
FarmContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 20, 147)
FarmContainer.Visible = true
FarmContainer.Parent = ContainerFrame

local FarmLayout = Instance.new("UIListLayout")
FarmLayout.Padding = UDim.new(0, 8)
FarmLayout.SortOrder = Enum.SortOrder.LayoutOrder
FarmLayout.Parent = FarmContainer

local AutoContainer = Instance.new("ScrollingFrame")
AutoContainer.Size = UDim2.new(1, 0, 1, 0)
AutoContainer.BackgroundTransparency = 1
AutoContainer.BorderSizePixel = 0
AutoContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
AutoContainer.ScrollBarThickness = 3
AutoContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 20, 147)
AutoContainer.Visible = false
AutoContainer.Parent = ContainerFrame

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Padding = UDim.new(0, 8)
AutoLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoLayout.Parent = AutoContainer

local currentTab = nil
local function createMenuButton(text, targetContainer)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = LeftPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnBorder = Instance.new("UIStroke")
    btnBorder.Color = Color3.fromRGB(35, 35, 40)
    btnBorder.Thickness = 1
    btnBorder.Parent = btn
    
    if targetContainer.Visible then
        currentTab = btn
        btn.BackgroundColor3 = Color3.fromRGB(255, 20, 147)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnBorder.Color = Color3.fromRGB(255, 20, 147)
    end

    btn.MouseButton1Click:Connect(function()
        if currentTab then
            TweenService:Create(currentTab, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 32), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            currentTab:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(35, 35, 40)
        end
        currentTab = btn
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 20, 147), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        btnBorder.Color = Color3.fromRGB(255, 20, 147)

        FarmContainer.Visible = false
        AutoContainer.Visible = false
        targetContainer.Visible = true
    end)
end

createMenuButton("Farm Mode", FarmContainer)
createMenuButton("Auto Systems", AutoContainer)

local function createToggle(parent, text, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.98, 0, 0, 46)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local tfCorner = Instance.new("UICorner")
    tfCorner.CornerRadius = UDim.new(0, 6)
    tfCorner.Parent = toggleFrame

    local tfBorder = Instance.new("UIStroke")
    tfBorder.Color = Color3.fromRGB(32, 32, 36)
    tfBorder.Thickness = 1
    tfBorder.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -56, 0.5, -11)
    switchBg.BackgroundColor3 = defaultState and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(40, 40, 45)
    switchBg.Text = ""
    switchBg.Parent = toggleFrame
    
    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(1, 0)
    sbCorner.Parent = switchBg
    
    local switchBall = Instance.new("Frame")
    switchBall.Size = UDim2.new(0, 16, 0, 16)
    switchBall.Position = defaultState and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
    switchBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchBall.BorderSizePixel = 0
    switchBall.Parent = switchBg

    local ballCorner = Instance.new("UICorner")
    ballCorner.CornerRadius = UDim.new(1, 0)
    ballCorner.Parent = switchBall
    
    local state = defaultState
    switchBg.MouseButton1Click:Connect(function()
        state = not state
        local targetPos = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
        local targetColor = state and Color3.fromRGB(255, 20, 147) or Color3.fromRGB(40, 40, 45)
        
        TweenService:Create(switchBall, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
        
        callback(state)
    end)
    
    if parent:IsA("ScrollingFrame") then
        parent.CanvasSize = UDim2.new(0, 0, 0, parent.UIListLayout.AbsoluteContentSize.Y + 10)
    end
end

local function cframeToTable(cf)
    return {cf:GetComponents()}
end

local function tableToCFrame(tbl)
    return CFrame.new(unpack(tbl))
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if macroData.isRecording and method == "InvokeServer" and self.Name == "unit_spawn" then
        if args[1] and typeof(args[2]) == "CFrame" then
            table.insert(macroData.spawnCommands, {unitId = args[1], cframe = cframeToTable(args[2])})
            saveSettings()
        end
    end
    return oldNamecall(self, ...)
end)

createToggle(FarmContainer, "Ghi lại hành động (Record)", macroData.isRecording, function(state)
    macroData.isRecording = state
    if state then
        macroData.spawnCommands = {}
    end
    saveSettings()
end)

createToggle(FarmContainer, "Bắt đầu phát Macro (Play)", macroData.isPlaying, function(state)
    macroData.isPlaying = state
    saveSettings()
end)

task.spawn(function()
    local clientServer = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("client_server", 5)
    while true do
        task.wait(2)
        if macroData.isPlaying and #macroData.spawnCommands > 0 and clientServer then
            for _, command in ipairs(macroData.spawnCommands) do
                pcall(function()
                    clientServer.unit_spawn:InvokeServer(command.unitId, tableToCFrame(command.cframe))
                end)
            end
        end
    end
end)

createToggle(AutoContainer, "Tự Động Nâng Cấp (Auto Upgrade)", macroData.autoUpgrade, function(state)
    macroData.autoUpgrade = state
    saveSettings()
end)

createToggle(AutoContainer, "Tự Động Kích Hoạt Kỹ Năng (Auto Ability)", macroData.autoAbility, function(state)
    macroData.autoAbility = state
    saveSettings()
end)

createToggle(AutoContainer, "Tự Động Gacha (Auto Banner Open)", macroData.autoGacha, function(state)
    macroData.autoGacha = state
    saveSettings()
end)

createToggle(AutoContainer, "Chế Độ Màn Hình Đen (Black Screen)", macroData.blackScreen, function(state)
    macroData.blackScreen = state
    BlackScreenFrame.Visible = state
    saveSettings()
end)

task.spawn(function()
    local clientServer = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("client_server", 5)
    while true do
        task.wait(1)
        if clientServer then
            if macroData.autoUpgrade then
                for i = 1, 100 do
                    pcall(function()
                        clientServer.unit_upgrade_auto:InvokeServer(tostring(i))
                    end)
                end
            end
            if macroData.autoAbility then
                for i = 1, 100 do
                    pcall(function()
                        clientServer.unit_ability_auto:InvokeServer(tostring(i))
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    local clientServer = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("client_server", 5)
    while true do
        task.wait(2)
        if clientServer and macroData.autoGacha then
            pcall(function()
                clientServer.banner_open:InvokeServer()
            end)
        end
    end
end)

repeat task.wait() until game:IsLoaded()

local REJOIN_INTERVAL = 3600
local REJOIN_DELAY = 5

local function doTeleport()
    task.wait(REJOIN_DELAY)
    if game.JobId ~= "" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    else
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
end

task.spawn(function()
    task.wait(REJOIN_INTERVAL)
    doTeleport()
end)

GuiService.ErrorMessageChanged:Connect(function()
    doTeleport()
end)

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.client_server.teleport_replay:InvokeServer()
        end)
    end
end)

local menuVisible = true
local function toggleMenu()
    menuVisible = not menuVisible
    local targetSize = menuVisible and UDim2.new(0, 560, 0, 360) or UDim2.new(0, 0, 0, 0)
    local targetPos = menuVisible and UDim2.new(0.5, -280, 0.5, -180) or UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize, Position = targetPos}):Play()
end

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "HubToggleButton"
ToggleButton.Size = UDim2.new(0, 46, 0, 46)
ToggleButton.Position = UDim2.new(0, 15, 0.5, -23)
ToggleButton.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ToggleButton.Text = "HUB"
ToggleButton.TextColor3 = Color3.fromRGB(255, 20, 147)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 12
ToggleButton.DisplayOrder = 999999
ToggleButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(255, 20, 147)
ButtonStroke.Thickness = 1.5
ButtonStroke.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    toggleMenu()
end)

local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
