local Title = Instance.new("TextLabel")
Title.Name = "GUITitle"
Title.Parent = nil
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.5, 0, 0, 10)
Title.AnchorPoint = Vector2.new(0.5, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Skibidi Master Tower Defense v2"
Title.TextColor3 = Color3.fromRGB(255, 20, 147)
Title.TextSize = 20
Title.ZIndex = 5

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local FILE_NAME = "Skibidi_Master.json"
local macroData = {
    spawnCommands = {},
    autoUpgrade = false,
    autoAbility = false,
    isRecording = false,
    isPlaying = false,
    blackScreen = false
}

local toggleButtons = {} -- Bảng lưu trữ để đồng bộ nút bấm

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DjtmestayHub_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ========================================================
-- PHẦN CẢI TIẾN: BLACK SCREEN UI (THÊM LOADING VÀ NÚT X TẮT)
-- ========================================================
local BlackScreenFrame = Instance.new("Frame")
BlackScreenFrame.Name = "BlackScreenFrame"
BlackScreenFrame.Size = UDim2.new(1, 0, 1, 50)
BlackScreenFrame.Position = UDim2.new(0, 0, 0, -50)
BlackScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BlackScreenFrame.BorderSizePixel = 0
BlackScreenFrame.ZIndex = 999999
BlackScreenFrame.Visible = macroData.blackScreen
BlackScreenFrame.Parent = ScreenGui

local BlackScreenText = Instance.new("TextLabel")
BlackScreenText.Size = UDim2.new(1, 0, 0, 40)
BlackScreenText.Position = UDim2.new(0, 0, 0.5, -40)
BlackScreenText.BackgroundTransparency = 1
BlackScreenText.Text = "BLACK SCREEN ACTIVE\n(Đang treo máy giảm lag...)"
BlackScreenText.TextColor3 = Color3.fromRGB(255, 255, 255)
BlackScreenText.Font = Enum.Font.SourceSansBold
BlackScreenText.TextSize = 24
BlackScreenText.Parent = BlackScreenFrame

-- Chữ Loading hiệu ứng nhấp nháy dưới màn hình đen
local BlackScreenLoading = Instance.new("TextLabel")
BlackScreenLoading.Size = UDim2.new(1, 0, 0, 30)
BlackScreenLoading.Position = UDim2.new(0, 0, 0.5, 20)
BlackScreenLoading.BackgroundTransparency = 1
BlackScreenLoading.Text = "LOADING..."
BlackScreenLoading.TextColor3 = Color3.fromRGB(255, 20, 147)
BlackScreenLoading.Font = Enum.Font.SourceSansItalic
BlackScreenLoading.TextSize = 18
BlackScreenLoading.Parent = BlackScreenFrame

task.spawn(function()
    while true do
        if BlackScreenFrame.Visible then
            TweenService:Create(BlackScreenLoading, TweenInfo.new(0.6), {TextTransparency = 0.3}):Play()
            task.wait(0.6)
            TweenService:Create(BlackScreenLoading, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
            task.wait(0.6)
        else
            task.wait(1)
        end
    end
end)

-- Nút dấu X màu đỏ để tắt nhanh màn hình đen
local CloseBlackScreenBtn = Instance.new("TextButton")
CloseBlackScreenBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBlackScreenBtn.Position = UDim2.new(1, -50, 0, 60) -- Để không bị đè bởi Topbar mặc định
CloseBlackScreenBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
CloseBlackScreenBtn.Text = "X"
CloseBlackScreenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBlackScreenBtn.Font = Enum.Font.SourceSansBold
CloseBlackScreenBtn.TextSize = 22
CloseBlackScreenBtn.ZIndex = 1000000
CloseBlackScreenBtn.Parent = BlackScreenFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBlackScreenBtn

-- Khai báo hàm trước để sử dụng chéo
local toggleBlackScreen

-- Cập nhật đồng bộ giao diện nút bấm trong Hub
local function updateToggleButtonUI(configKey, state)
    local btn = toggleButtons[configKey]
    if btn then
        btn.Text = state and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(200, 200, 200)
        }):Play()
    end
end

toggleBlackScreen = function(state)
    macroData.blackScreen = state
    BlackScreenFrame.Visible = state
    
    -- Đồng bộ trạng thái với nút bấm trong menu UI
    updateToggleButtonUI("blackScreen", state)
    
    pcall(function()
        if state then
            RunService:Set3dRenderingEnabled(false) -- Tắt render 3D để giảm tải CPU/GPU
        else
            RunService:Set3dRenderingEnabled(true) -- Bật lại render 3D
        end
    end)
end

CloseBlackScreenBtn.MouseButton1Click:Connect(function()
    toggleBlackScreen(false)
    saveSettings()
end)
-- ========================================================

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(0, 300, 0, 300)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingBorder = Instance.new("UIStroke")
LoadingBorder.Color = Color3.fromRGB(255, 20, 147)
LoadingBorder.Thickness = 4
LoadingBorder.Parent = LoadingFrame

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0, 15)
LoadingCorner.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 1, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.Text = "DjtmemayHUB\n-\nSkibidi Tower Defense\n\nLoading..."
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Font = Enum.Font.SourceSansBold
LoadingText.TextSize = 22
LoadingText.Parent = LoadingFrame
task.wait(2)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(255, 105, 180)
MainBorder.Thickness = 2
MainBorder.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

Title.Parent = MainFrame

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(LoadingFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
task.wait(0.3)
LoadingFrame:Destroy()

MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 550, 0, 350)}):Play()

local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 130, 1, -45)
LeftPanel.Position = UDim2.new(0, 0, 0, 45)
LeftPanel.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 12)
LeftCorner.Parent = LeftPanel

local RightPanel = Instance.new("ScrollingFrame")
RightPanel.Size = UDim2.new(1, -140, 1, -55)
RightPanel.Position = UDim2.new(0, 140, 0, 45)
RightPanel.BackgroundTransparency = 1
RightPanel.BorderSizePixel = 0
RightPanel.CanvasSize = UDim2.new(0, 0, 0, 450)
RightPanel.ScrollBarThickness = 4
RightPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
RightPanel.ElasticBehavior = Enum.ElasticBehavior.Always
RightPanel.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = RightPanel

local FarmContainer = Instance.new("Frame")
FarmContainer.Size = UDim2.new(1, 0, 1, 0)
FarmContainer.BackgroundTransparency = 1
FarmContainer.Visible = true
FarmContainer.Parent = RightPanel

local FarmLayout = Instance.new("UIListLayout")
FarmLayout.Padding = UDim.new(0, 10)
FarmLayout.Parent = FarmContainer

local AutoContainer = Instance.new("Frame")
AutoContainer.Size = UDim2.new(1, 0, 1, 0)
AutoContainer.BackgroundTransparency = 1
AutoContainer.Visible = false
AutoContainer.Parent = RightPanel

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Padding = UDim.new(0, 10)
AutoLayout.Parent = AutoContainer

local function createMenuButton(text, posIndex, targetContainer)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, 15 + (posIndex * 50))
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 20, 147)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = LeftPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        FarmContainer.Visible = false
        AutoContainer.Visible = false
        targetContainer.Visible = true
    end)
    return btn
end

local FarmTabBtn = createMenuButton("Farm", 0, FarmContainer)
local AutoTabBtn = createMenuButton("Auto", 1, AutoContainer)

local function createToggle(parent, configKey, text, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0.95, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    toggleFrame.Parent = parent
    
    local tfCorner = Instance.new("UICorner")
    tfCorner.CornerRadius = UDim.new(0, 6)
    tfCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(50, 50, 50)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 26)
    btn.Position = UDim2.new(1, -70, 0.5, -13)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(200, 200, 200)
    btn.Text = defaultState and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = toggleFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 13)
    btnCorner.Parent = btn
    
    toggleButtons[configKey] = btn -- Lưu tham chiếu nút để cập nhật từ xa
    
    btn.MouseButton1Click:Connect(function()
        macroData[configKey] = not macroData[configKey]
        local state = macroData[configKey]
        btn.Text = state and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(200, 200, 200)}):Play()
        callback(state)
    end)
    return toggleFrame
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

createToggle(FarmContainer, "isRecording", "Ghi lại hành động (Record)", macroData.isRecording, function(state)
    if state then
        macroData.spawnCommands = {}
    end
    saveSettings()
end)

createToggle(FarmContainer, "isPlaying", "Bắt đầu phát Macro (Play)", macroData.isPlaying, function(state)
    saveSettings()
end)

-- SỬA VÒNG LẶP PLAY MACRO SAU REJOIN
task.spawn(function()
    while true do
        task.wait(2)
        if macroData.isPlaying and #macroData.spawnCommands > 0 then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local clientServer = remotes and remotes:FindFirstChild("client_server")
            if clientServer and clientServer:FindFirstChild("unit_spawn") then
                for _, command in ipairs(macroData.spawnCommands) do
                    pcall(function()
                        clientServer.unit_spawn:InvokeServer(command.unitId, tableToCFrame(command.cframe))
                    end)
                end
            end
        end
    end
end)

createToggle(AutoContainer, "autoUpgrade", "Auto Nâng Cấp", macroData.autoUpgrade, function(state)
    saveSettings()
end)

createToggle(AutoContainer, "autoAbility", "Auto Ability", macroData.autoAbility, function(state)
    saveSettings()
end)

createToggle(AutoContainer, "blackScreen", "Màn hình đen (Black Screen)", macroData.blackScreen, function(state)
    saveSettings()
    toggleBlackScreen(state)
end)

-- KHỞI ĐỘNG LẠI TRẠNG THÁI MÀN HÌNH ĐEN KHI LOAD XONG SCRIPT
task.spawn(function()
    task.wait(0.5)
    toggleBlackScreen(macroData.blackScreen)
end)

-- SỬA LỖI AUTO UPGRADE VÀ AUTO ABILITY KHÔNG HOẠT ĐỘNG SAU REJOIN
task.spawn(function()
    while true do
        task.wait(1)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local clientServer = remotes and remotes:FindFirstChild("client_server")
        
        if clientServer then
            if macroData.autoUpgrade and clientServer:FindFirstChild("unit_upgrade_auto") then
                for i = 1, 100 do
                    pcall(function()
                        clientServer.unit_upgrade_auto:InvokeServer(tostring(i))
                    end)
                end
            end
            if macroData.autoAbility and clientServer:FindFirstChild("unit_ability_auto") then
                for i = 1, 100 do
                    pcall(function()
                        clientServer.unit_ability_auto:InvokeServer(tostring(i))
                    end)
                end
            end
        end
    end
end)

repeat task.wait() until game:IsLoaded()

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes and remotes.client_server and remotes.client_server:FindFirstChild("teleport_replay") then
                remotes.client_server.teleport_replay:InvokeServer()
            end
        end)
    end
end)

-- Auto Rejoin mỗi 1 tiếng
task.spawn(function()
    while true do
        task.wait(3600)
        local success, err = pcall(function()
            if #Players:GetPlayers() <= 1 then
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        end)
        if not success then
            task.wait(5)
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end
    end
end)

local UserInputService = game:GetService("UserInputService")
local menuVisible = true
local function toggleMenu()
    menuVisible = not menuVisible
    local targetSize = menuVisible and UDim2.new(0, 550, 0, 350) or UDim2.new(0, 0, 0, 0)
    local targetPos = menuVisible and UDim2.new(0.5, -275, 0.5, -175) or UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize, Position = targetPos}):Play()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftControl then
        toggleMenu()
    end
end)

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "HubToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
ToggleButton.Text = "HUB"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 14
ToggleButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 25)
ButtonCorner.Parent = ToggleButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
ButtonStroke.Thickness = 2
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
