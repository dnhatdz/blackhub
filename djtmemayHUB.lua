--[[
    DJTMEMAYHUB - SKIBIDI TOWER DEFENSE SCRIPT
    Tông chủ đạo: Hồng & Trắng
    Tính năng: Auto Record Macro (Spawn Unit), Auto Upgrade, Auto Ability, Auto Rejoin (7m), Save/Load Settings
--]]

local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- File cấu hình
local FILE_NAME = "Skibidi_Master.json"
local macroData = {
    spawnCommands = {}, -- Lưu danh sách {unitId, cframeTable}
    autoUpgrade = false,
    autoAbility = false
}

-- Hàm lưu/tải file
local function saveSettings()
    if writefile then
        writefile(FILE_NAME, HttpService:JSONEncode(macroData))
    end
end

local function loadSettings()
    if isfile and isfile(FILE_NAME) then
        local success, content = pcall(readfile, FILE_NAME)
        if success then
            local decoded = HttpService:JSONDecode(content)
            if decoded then macroData = decoded end
        end
    end
end

loadSettings()

-- Khởi tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DjtmestayHub_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==========================================
-- 1. LOADING SCREEN (Bảng Loading Hồng Giữa Màn Hình)
-- ==========================================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UUDim2.new(0, 300, 0, 300)
LoadingFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(255, 182, 193) -- Hồng nhạt
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = ScreenGui

local LoadingBorder = Instance.new("UIStroke")
LoadingBorder.Color = Color3.fromRGB(255, 20, 147) -- Hồng đậm
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

task.wait(3) -- Giả lập thời gian load script

-- ==========================================
-- 2. MAIN INTERFACE (UI Chính - Hồng & Trắng)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 0, 0, 0) -- Bắt đầu từ kích thước 0 để làm hiệu ứng bung ra
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Trắng nền chính
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainBorder = Instance.new("UIStroke")
MainBorder.Color = Color3.fromRGB(255, 105, 180) -- Viền hồng
MainBorder.Thickness = 2
MainBorder.Parent = MainFrame

-- Thu nhỏ bảng loading và mở bảng chính
local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(LoadingFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
task.wait(0.4)
LoadingFrame:Destroy()

MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 550, 0, 350)}):Play()

-- Cột Trái (Thanh Menu nhỏ)
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 130, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(255, 192, 203) -- Hồng phấn nhạt
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 12)
LeftCorner.Parent = LeftPanel

-- Cột Phải (Nội dung hiển thị - Có Scrolling siêu mượt)
local RightPanel = Instance.new("ScrollingFrame")
RightPanel.Size = UDim2.new(1, -140, 1, -20)
RightPanel.Position = UDim2.new(0, 140, 0, 10)
RightPanel.BackgroundTransparency = 1
RightPanel.BorderSizePixel = 0
RightPanel.CanvasSize = UDim2.new(0, 0, 0, 500) -- Độ dài cuộn
RightPanel.ScrollBarThickness = 4
RightPanel.ScrollBarImageColor3 = Color3.fromRGB(255, 105, 180)
RightPanel.ElasticBehavior = Enum.ElasticBehavior.Always -- Cuộn siêu mượt mượt đàn hồi
RightPanel.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = RightPanel

-- Các Container để đổi Tab
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

-- ==========================================
-- TẠO NÚT CHUYỂN TAB (Bên cột trái)
-- ==========================================
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

    btn.MouseButton1Click:Connect(frame)
        FarmContainer.Visible = false
        AutoContainer.Visible = false
        targetContainer.Visible = true
    end)
    return btn
end

local FarmTabBtn = createMenuButton("Farm", 0, FarmContainer)
local AutoTabBtn = createMenuButton("Auto", 1, AutoContainer)

-- ==========================================
-- HÀM TẠO NÚT BẬT/TẮT TÍNH NĂNG (Toggle UI)
-- ==========================================
local function createToggle(parent, text, defaultState, callback)
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

    local state = defaultState
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(255, 105, 180) or Color3.fromRGB(200, 200, 200)}):Play()
        callback(state)
    end)
end
local isRecording = false
local isPlaying = false
local function cframeToTable(cf)
    return {cf:GetComponents()}
end
local function tableToCFrame(tbl)
    return CFrame.new(unpack(tbl))
end
local rawmetatable = getrawmetatable(game)
local oldInvokeServer = rawmetatable.__index
if setreadonly then setreadonly(rawmetatable, false) end
rawmetatable.__index = newcclosure(function(self, key)
    if isRecording and key == "InvokeServer" and self.Name == "unit_spawn" then
        return function(rem, ...)
            local args = {...}
            -- args[1] là ID unit, args[2] là CFrame vị trí đặt
            if args[1] and typeof(args[2]) == "CFrame" then
                table.insert(macroData.spawnCommands, {
                    unitId = args[1],
                    cframe = cframeToTable(args[2])
                })
                saveSettings() -- Lưu ngay lập tức vào file
            end
            return oldInvokeServer(self, key)(rem, ...)
        end
    end
    return oldInvokeServer(self, key)
end)
if setreadonly then setreadonly(rawmetatable, true) end
createToggle(FarmContainer, "Ghi lại hành động (Record)", false, function(state)
    isRecording = state
    if state then
        macroData.spawnCommands = {} -- Xóa dữ liệu cũ khi bấm ghi mới
        saveSettings()
    end
end)
createToggle(FarmContainer, "Bắt đầu phát Macro (Play)", false, function(state)
    isPlaying = state
end)
task.spawn(function()
    while true do
        task.wait(2)
        if isPlaying and #macroData.spawnCommands > 0 then
            for _, command in ipairs(macroData.spawnCommands) do
                pcall(function()
                    local args = {
                        [1] = command.unitId,
                        [2] = tableToCFrame(command.cframe)
                    }
                    ReplicatedStorage.Remotes.client_server.unit_spawn:InvokeServer(unpack(args))
                end)
            end
        end
    end
end)
createToggle(AutoContainer, "Auto Nâng Cấp (Upgrade 1-8)", macroData.autoUpgrade, function(state)
    macroData.autoUpgrade = state
    saveSettings()
end)
createToggle(AutoContainer, "Auto Kỹ Năng (Ability 1-8)", macroData.autoAbility, function(state)
    macroData.autoAbility = state
    saveSettings()
end)
task.spawn(function()
    while true do
        task.wait(1)
        if macroData.autoUpgrade then
            for i = 1, 8 do
                pcall(function()
                    local args = { [1] = tostring(i) }
                    ReplicatedStorage.Remotes.client_server.unit_upgrade_auto:InvokeServer(unpack(args))
                end)
            end
        end
        
        if macroData.autoAbility then
            for i = 1, 8 do
                pcall(function()
                    local args = { [1] = tostring(i) }
                    ReplicatedStorage.Remotes.client_server.unit_ability_auto:InvokeServer(unpack(args))
                end)
            end
        end
    end
end)

-- ==========================================
-- 4. AUTO REJOIN SERVER (Sau 7 phút)
-- ==========================================
task.delay(420, function() -- 7 phút = 420 giây
    if #Players:GetPlayers() <= 1 then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    else
        pcall(function()
            local tps = TeleportService:GetTeleportSetting("Rejoin")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
end)
