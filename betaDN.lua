local DNHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/dnhatdz/blackhub/refs/heads/main/DN-Lib.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Info = ReplicatedStorage:WaitForChild("Info")
local DataFolder = ReplicatedStorage:WaitForChild("Data")
local PlayerData = DataFolder:WaitForChild(LocalPlayer.UserId)

local ToggleHotbar = Events:WaitForChild("ToggleHotbar")
local FishingEvent = Events:WaitForChild("Fishing")
local UpdateFishProgression = Events:WaitForChild("UpdateFishProgression")
local UseSkill = Events:WaitForChild("UseSkill")
local SellFish = Events:WaitForChild("SellFish")
local CraftBaitEvent = Events:WaitForChild("CraftBait")
local CraftRodEvent = Events:WaitForChild("CraftRod")
local RedeemCodeEvent = Events:WaitForChild("RedeemCode")

local Config = {
    AutoCast = false, AutoReel = false, AutoMiniGame = false,
    BossMode = "Normal", AutoBoss = false, AutoSecretBoss = false,
    AutoSkill = false,
    SkillPriority = "Z,X,C,V",
    SkillEnabled = "Z,X,C,V",
    AutoSell = false, SellDelay = 1,
    SelectedBuyBait = "", BuyBaitAmount = 1, AutoBuyBait = false,
    SelectedBait = "", BaitAmount = 1, AutoCraftBait = false,
    SelectedRod = "", AutoCraftRod = false,
    SelectedIsland = "", SelectedNPC = "",
    ESPEnabled = false, FullBright = false, NoFog = false,
    LoopSpeedEnabled = false, WalkSpeed = 30,
    NoclipEnabled = false, InfJumpEnabled = false,
    FlyEnabled = false, FlySpeed = 2,
    FlyKeybind = "F", NoclipKeybind = "J", DisableAllKeybinds = false,
    AutoRedeem = false, RedeemInterval = 30,
    HideName = false, HideNameText = "DN Hub Private",
    HideLevel = false, HideLevelText = "Protected by DNHub",
    FloatSize = 46,
    NoclipFloatPos = { xs = 0.85, xo = 0, ys = 0.5, yo = -54 },
    NoclipFloatVisible = false,
    FlyFloatPos = { xs = 0.85, xo = 0, ys = 0.5, yo = -108 },
    FlyFloatVisible = false
}

local function ParseSkillString(str)
    if type(str) ~= "string" then return {} end
    local list = {}
    local seen = {}
    for token in string.gmatch(str, "[^,]+") do
        local k = string.upper(string.gsub(token, "%s", ""))
        if #k == 1 and not seen[k] then
            seen[k] = true
            table.insert(list, k)
        end
    end
    return list
end

local function SkillStringToSet(str)
    local set = {}
    for _, k in ipairs(ParseSkillString(str)) do
        set[k] = true
    end
    return set
end

local SAVE_FOLDER = "DN Hub"
local SAVE_FILE = SAVE_FOLDER .. "/hwf-config.json"

local function SaveConfig()
    pcall(function()
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
        writefile(SAVE_FILE, HttpService:JSONEncode(Config))
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile(SAVE_FILE) then
            local decoded = HttpService:JSONDecode(readfile(SAVE_FILE))
            for k, v in pairs(decoded) do
                if Config[k] ~= nil then Config[k] = v end
            end
        end
    end)
end

LoadConfig()
if type(Config.SkillPriority) ~= "string" then Config.SkillPriority = "Z,X,C,V" end
if type(Config.SkillEnabled) ~= "string" then Config.SkillEnabled = "Z,X,C,V" end
if type(Config.RedeemInterval) ~= "number" then Config.RedeemInterval = 30 end
if type(Config.HideNameText) ~= "string" then Config.HideNameText = "DN Hub Private" end
if type(Config.HideLevelText) ~= "string" then Config.HideLevelText = "Protected by DNHub" end

local ModuleCache = {}
local function GetModuleData(mod)
    if not mod or not mod:IsA("ModuleScript") then return nil end
    local cached = ModuleCache[mod]
    if cached ~= nil then return cached ~= false and cached or nil end
    local ok, data = pcall(require, mod)
    if ok and type(data) == "table" then
        ModuleCache[mod] = data
        return data
    end
    ModuleCache[mod] = false
    return nil
end

LocalPlayer.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

if getconnections then
    for _, conn in pairs(getconnections(LocalPlayer.Idled)) do
        if conn.Disable then conn:Disable()
        elseif conn.Disconnect then conn:Disconnect() end
    end
end

local cachedChar = LocalPlayer.Character
local cachedHum = cachedChar and cachedChar:FindFirstChildOfClass("Humanoid")
local cachedHrp = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
local cachedSkillsFolder = cachedChar and cachedChar:FindFirstChild("Skills")
local cachedStatsFolder = cachedChar and cachedChar:FindFirstChild("Stats")
local FishesFolder = workspace:FindFirstChild("Fishes")

local MainGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("MainGui")
local FishingGui = MainGui:WaitForChild("Fishing")
local BarFrame = FishingGui:WaitForChild("BarFrame")
local FishingBar = BarFrame:WaitForChild("Bar")
local SkillBtnFrame = FishingGui:WaitForChild("SkillButton"):WaitForChild("Frame")
local RhythmGui = FishingGui:FindFirstChild("Rhythm")
local BossFightBar = FishingGui:FindFirstChild("BossFightBar")
local MobileGui = MainGui:FindFirstChild("Mobile")
local MobileFishingBtn = MobileGui and MobileGui:FindFirstChild("Fishing")
local RhythmHitEvent = Events:FindFirstChild("RhythmHit")

local function RefreshGuiCache()
    if not MainGui or not MainGui.Parent then
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        MainGui = pg and pg:FindFirstChild("MainGui")
        FishingGui = MainGui and MainGui:FindFirstChild("Fishing")
        BarFrame = FishingGui and FishingGui:FindFirstChild("BarFrame")
        FishingBar = BarFrame and BarFrame:FindFirstChild("Bar")
        local sb = FishingGui and FishingGui:FindFirstChild("SkillButton")
        SkillBtnFrame = sb and sb:FindFirstChild("Frame")
        RhythmGui = FishingGui and FishingGui:FindFirstChild("Rhythm")
        BossFightBar = FishingGui and FishingGui:FindFirstChild("BossFightBar")
        MobileGui = MainGui and MainGui:FindFirstChild("Mobile")
        MobileFishingBtn = MobileGui and MobileGui:FindFirstChild("Fishing")
    else
        if not RhythmGui or not RhythmGui.Parent then RhythmGui = FishingGui and FishingGui:FindFirstChild("Rhythm") end
        if not BossFightBar or not BossFightBar.Parent then BossFightBar = FishingGui and FishingGui:FindFirstChild("BossFightBar") end
        if not MobileFishingBtn or not MobileFishingBtn.Parent then
            MobileGui = MainGui and MainGui:FindFirstChild("Mobile")
            MobileFishingBtn = MobileGui and MobileGui:FindFirstChild("Fishing")
        end
    end
    if not RhythmHitEvent then RhythmHitEvent = Events:FindFirstChild("RhythmHit") end
    if not FishesFolder or not FishesFolder.Parent then FishesFolder = workspace:FindFirstChild("Fishes") end
end

local _noclipThrottle = 0
RunService.Stepped:Connect(function(_, dt)
    if not Config.NoclipEnabled and not Config.LoopSpeedEnabled then return end
    _noclipThrottle = _noclipThrottle + dt
    if _noclipThrottle < 0.08 then return end
    _noclipThrottle = 0
    local char = cachedChar
    if not char or not char.Parent then return end
    if Config.NoclipEnabled then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
        end
    end
    if Config.LoopSpeedEnabled and cachedHum and cachedHum.WalkSpeed ~= Config.WalkSpeed then
        cachedHum.WalkSpeed = Config.WalkSpeed
    end
end)

local lastInfJumpTick = 0
local function IsInsideOceanWater(hrp)
    if not hrp then return false end
    local ocean = workspace:FindFirstChild("Ocean")
    if not ocean then return false end
    local pos = hrp.Position
    for _, child in ipairs(ocean:GetChildren()) do
        if child.Name == "Water" and child:IsA("BasePart") then
            local half = child.Size * 0.5
            local diff = child.Position - pos
            if math.abs(diff.X) <= half.X and math.abs(diff.Y) <= half.Y and math.abs(diff.Z) <= half.Z then
                return true
            end
        end
    end
    return false
end

UserInputService.JumpRequest:Connect(function()
    if not Config.InfJumpEnabled then return end
    local now = os.clock()
    if now - lastInfJumpTick < 0.18 then return end
    local char = cachedChar or LocalPlayer.Character
    local hum = cachedHum or (char and char:FindFirstChildOfClass("Humanoid"))
    local hrp = cachedHrp or (char and char:FindFirstChild("HumanoidRootPart"))
    if not char or not hum or not hrp or hum.Health <= 0 then return end
    if char:GetAttribute("Swimming") == true or hrp:FindFirstChildOfClass("BodyPosition") or IsInsideOceanWater(hrp) then return end
    lastInfJumpTick = now
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)

local flyConnection = nil
local jumpStateConnection = nil

local function startFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end
    humanoid.PlatformStand = true
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 1e7
    bg.D = 12000
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp
    jumpStateConnection = humanoid.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping or new == Enum.HumanoidStateType.Freefall then
            humanoid.PlatformStand = true
        end
    end)
    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        local md = humanoid.MoveDirection
        if md.Magnitude > 0 then
            local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
            local flatRight = Vector3.new(cam.CFrame.RightVector.X, 0, cam.CFrame.RightVector.Z)
            if flatLook.Magnitude > 0.01 and flatRight.Magnitude > 0.01 then
                local fwdAmt = md:Dot(flatLook.Unit)
                local rightAmt = md:Dot(flatRight.Unit)
                move += cam.CFrame.LookVector * fwdAmt
                move += cam.CFrame.RightVector * rightAmt
            end
        end
        if move.Magnitude > 0 then move = move.Unit end
        bv.Velocity = move * Config.FlySpeed * 50
        local look = cam.CFrame.LookVector
        bg.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + look, Vector3.new(0, 1, 0))
    end)
end

local function stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = false end
    if jumpStateConnection then jumpStateConnection:Disconnect() jumpStateConnection = nil end
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
        end
    end
end

local function IsAntiConfuseActive()
    return Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss
end

local function ApplyAntiConfuse(char)
    if not IsAntiConfuseActive() then return end
    if char then
        if char:GetAttribute("Confused") == true then pcall(function() char:SetAttribute("Confused", false) end) end
        if char:GetAttribute("SkillLocked") == true then pcall(function() char:SetAttribute("SkillLocked", false) end) end
    end
    if SkillBtnFrame then
        for _, btn in ipairs(SkillBtnFrame:GetChildren()) do
            if btn:IsA("TextButton") then
                local lock = btn:FindFirstChild("Lock")
                if lock and lock.Visible then lock.Visible = false end
            end
        end
    end
    if FishingGui then
        local hpPlayer = FishingGui:FindFirstChild("HPPlayer")
        local debuff = hpPlayer and hpPlayer:FindFirstChild("Debuff")
        local confusedGui = debuff and debuff:FindFirstChild("Confused")
        if confusedGui then pcall(function() confusedGui:Destroy() end) end
    end
end

local antiConfuseConns = {}
local function BindCharacterAntiConfuse(char)
    for _, c in ipairs(antiConfuseConns) do pcall(function() c:Disconnect() end) end
    table.clear(antiConfuseConns)
    if not char then return end
    table.insert(antiConfuseConns, char:GetAttributeChangedSignal("Confused"):Connect(function()
        if IsAntiConfuseActive() and char:GetAttribute("Confused") == true then ApplyAntiConfuse(char) end
    end))
    table.insert(antiConfuseConns, char:GetAttributeChangedSignal("SkillLocked"):Connect(function()
        if IsAntiConfuseActive() and char:GetAttribute("SkillLocked") == true then ApplyAntiConfuse(char) end
    end))
    if IsAntiConfuseActive() then ApplyAntiConfuse(char) end
end

if cachedChar then BindCharacterAntiConfuse(cachedChar) end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    cachedChar = newChar
    cachedHum = newChar:WaitForChild("Humanoid", 5)
    cachedHrp = newChar:WaitForChild("HumanoidRootPart", 5)
    cachedSkillsFolder = newChar:WaitForChild("Skills", 5)
    cachedStatsFolder = newChar:WaitForChild("Stats", 5)
    BindCharacterAntiConfuse(newChar)
    task.wait(0.3)
    if Config.FlyEnabled then startFly() end
end)

local minigameOpenTick = 0
local wasMinigameVisible = false

local function IsGameAllowingSkill(char)
    if not FishingGui or not FishingGui.Visible then
        wasMinigameVisible = false
        return false
    end
    if not wasMinigameVisible then
        wasMinigameVisible = true
        minigameOpenTick = os.clock()
    end
    if (RhythmGui and RhythmGui.Visible) or (BossFightBar and BossFightBar.Visible) then return false end
    if char:GetAttribute("Phase2") then return false end
    if not IsAntiConfuseActive() then
        if char:GetAttribute("SkillLocked") or char:GetAttribute("Confused") then return false end
    else
        ApplyAntiConfuse(char)
    end
    local stats = cachedStatsFolder or char:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("Stun") and stats.Stun.Value == true then return false end
    local fishId = LocalPlayer:GetAttribute("FishID")
    local fishObj = (fishId and FishesFolder) and FishesFolder:FindFirstChild(fishId) or nil
    if fishObj then
        local readyVal = fishObj:FindFirstChild("Ready")
        if readyVal then
            if readyVal.Value ~= true then return false end
        elseif os.clock() - minigameOpenTick < 3.1 then
            return false
        end
        if fishObj:GetAttribute("FinalPhase") == true or fishObj:GetAttribute("PreFinalPhase") == true then return false end
    elseif os.clock() - minigameOpenTick < 3.1 then
        return false
    end
    if SkillBtnFrame then
        for _, btn in ipairs(SkillBtnFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn.Visible then
                local cd = btn:FindFirstChild("CD")
                if cd and cd.Visible and cd.Text == "" then return false end
            end
        end
    end
    local skillsFolder = cachedSkillsFolder or char:FindFirstChild("Skills")
    if skillsFolder then
        for _, s in ipairs(skillsFolder:GetChildren()) do
            if s:IsA("NumberValue") and (s:GetAttribute("UsingSkill") or 0) > 0 then return false end
        end
    end
    return true
end

local function IsSkillKeyReady(char, key)
    if not SkillBtnFrame then return false end
    local btn = SkillBtnFrame:FindFirstChild(key)
    if not btn or not btn.Visible then return false end
    local lock = btn:FindFirstChild("Lock")
    if lock and lock.Visible then
        if IsAntiConfuseActive() then lock.Visible = false
        else return false end
    end
    local cd = btn:FindFirstChild("CD")
    if cd and cd.Visible then return false end
    local skillsFolder = cachedSkillsFolder or char:FindFirstChild("Skills")
    if skillsFolder then
        for _, s in ipairs(skillsFolder:GetChildren()) do
            if s:IsA("NumberValue") and s:GetAttribute("Key") == key then
                if s.Value > 0 or (s:GetAttribute("UsingSkill") or 0) > 0 then return false end
            end
        end
    end
    return true
end

local rhythmLanes = {"A", "S", "D"}
local rhythmKeyMap = { A = Enum.KeyCode.A, S = Enum.KeyCode.S, D = Enum.KeyCode.D }
local lastRhythmLaneHit = { A = 0, S = 0, D = 0 }
local lastRhythmScan = 0
local lastPhase2HitTick = 0
local phase2BarHistory = {}
local CENTER_BAR_POS = UDim2.new(0.5, 0, 0.5, 0)
local isLockingBar = false
local barPosConn = nil
local boundBar = nil

local function LockFishingBar()
    if isLockingBar then return end
    if not FishingGui or not FishingGui.Visible or not FishingBar then return end
    if not (Config.AutoReel or Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss) then return end
    isLockingBar = true
    local char = cachedChar
    if char and (tonumber(char:GetAttribute("GuildPower")) or 0) < 99999999 then
        pcall(function()
            char:SetAttribute("GuildPower", 99999999)
            local stats = cachedStatsFolder or char:FindFirstChild("Stats")
            local rp = stats and stats:FindFirstChild("RodPower")
            if rp then
                local orig = rp.Value
                rp.Value = orig + 1
                rp.Value = orig
            end
        end)
    end
    pcall(function()
        FishingBar:TweenPosition(CENTER_BAR_POS, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0, true)
        FishingBar.Position = CENTER_BAR_POS
    end)
    isLockingBar = false
end

local function BindFishingBarLock()
    if FishingBar and FishingBar ~= boundBar then
        if barPosConn then pcall(function() barPosConn:Disconnect() end) barPosConn = nil end
        boundBar = FishingBar
        barPosConn = FishingBar:GetPropertyChangedSignal("Position"):Connect(function()
            if not isLockingBar and FishingBar.Position.X.Scale ~= 0.5 then LockFishingBar() end
        end)
    end
end

BindFishingBarLock()

local function TriggerGuiButton(btn)
    if not btn then return false end
    local triggered = false
    if getconnections then
        for _, sig in ipairs({btn.MouseButton1Click, btn.Activated}) do
            if sig then
                pcall(function()
                    for _, conn in pairs(getconnections(sig)) do
                        if conn.Function then task.spawn(conn.Function) triggered = true
                        elseif conn.Fire then conn:Fire() triggered = true end
                    end
                end)
            end
        end
    end
    if firesignal then
        pcall(function() firesignal(btn.MouseButton1Click) triggered = true end)
        pcall(function() firesignal(btn.Activated) triggered = true end)
    end
    return triggered
end

local getupval = (debug and debug.getupvalue) or getupvalue

local function StepPhase2MiniGame()
    if not BossFightBar or not BossFightBar.Visible then
        if #phase2BarHistory > 0 then table.clear(phase2BarHistory) end
        return
    end
    local bar = BossFightBar:FindFirstChild("Bar")
    local hitbox = BossFightBar:FindFirstChild("Hitbox")
    if not bar or not hitbox then return end
    local barW = bar.Size.X.Scale
    local barCenter = bar.Position.X.Scale + barW * (0.5 - bar.AnchorPoint.X)
    local hbW = hitbox.Size.X.Scale
    local hbLeft = hitbox.Position.X.Scale - hbW * hitbox.AnchorPoint.X
    local now = os.clock()
    table.insert(phase2BarHistory, { t = now, x = barCenter })
    while #phase2BarHistory > 1 and (now - phase2BarHistory[1].t) > 0.15 do
        table.remove(phase2BarHistory, 1)
    end
    local handledViaUpval = false
    local onClickFn = nil
    if getconnections and getupval and MobileFishingBtn then
        pcall(function()
            for _, conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down)) do
                local fn = conn.Function and getupval(conn.Function, 1)
                if type(fn) == "function" then
                    onClickFn = fn
                    local u12 = getupval(fn, 1)
                    local u14 = getupval(fn, 2)
                    local u27 = getupval(fn, 3)
                    local u26 = getupval(fn, 4)
                    local u1 = getupval(fn, 5)
                    local u25 = getupval(fn, 6)
                    local u23 = getupval(fn, 7)
                    local u2 = getupval(fn, 8)
                    local u15 = getupval(fn, 9)
                    if u12 == true and type(u14) == "number" and type(u27) == "number" and type(u26) == "number" and type(u1) == "number" and type(u25) == "number" and type(u23) == "number" and type(u2) == "number" and type(u15) == "number" then
                        if math.abs(u2 - hbW) < 0.005 and math.abs(u15 - hbLeft) < 0.005 then
                            handledViaUpval = true
                            if now - u14 >= 0.035 and now - lastPhase2HitTick >= 0.035 then
                                local v91 = (now - 0.025 - u27) % u26 * u1
                                if u25 < v91 then v91 = u25 * 2 - v91 end
                                local v92 = u23 + v91
                                local v93 = u2 * 0.3
                                if v92 >= (u15 - v93 * 0.8) and v92 <= (u15 + u2 + v93 * 0.8) then
                                    lastPhase2HitTick = now
                                    fn(false)
                                end
                            end
                        end
                        break
                    end
                end
            end
        end)
    end
    if handledViaUpval then return end
    if now - lastPhase2HitTick < 0.04 then return end
    local evalX = barCenter
    local targetTime = now - 0.041
    for i = #phase2BarHistory, 1, -1 do
        if phase2BarHistory[i].t <= targetTime then
            evalX = phase2BarHistory[i].x
            break
        end
    end
    local pad = hbW * 0.2
    local badBox = BossFightBar:FindFirstChild("HitboxBad")
    if badBox and badBox.Visible then
        local badW = badBox.Size.X.Scale
        local badLeft = badBox.Position.X.Scale - badW * badBox.AnchorPoint.X
        if evalX >= (badLeft - 0.01) and evalX <= (badLeft + badW + 0.01) then return end
    end
    if evalX >= (hbLeft - pad) and evalX <= (hbLeft + hbW + pad) then
        lastPhase2HitTick = now
        local clicked = false
        if onClickFn then
            pcall(function() onClickFn(false) clicked = true end)
        end
        if not clicked and MobileFishingBtn then
            if getconnections then
                pcall(function()
                    for _, conn in pairs(getconnections(MobileFishingBtn.MouseButton1Down)) do
                        if conn.Function then task.spawn(conn.Function) clicked = true
                        elseif conn.Fire then conn:Fire() clicked = true end
                    end
                end)
            end
            if not clicked and firesignal then
                pcall(function() firesignal(MobileFishingBtn.MouseButton1Down) clicked = true end)
            end
        end
        if not clicked then
            pcall(function()
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.delay(0.01, function()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end)
            end)
        end
    end
end

local function StepRhythmMiniGame()
    if not RhythmGui or not RhythmGui.Visible then return end
    local now = os.clock()
    if now - lastRhythmScan < 0.025 then return end
    lastRhythmScan = now
    for _, lane in ipairs(rhythmLanes) do
        if now - (lastRhythmLaneHit[lane] or 0) >= 0.05 then
            local laneFrame = RhythmGui:FindFirstChild("Progression" .. lane)
            if laneFrame then
                local barFrame = laneFrame:FindFirstChild("BarFrame")
                local targetY = barFrame and barFrame.Position.Y.Scale or 0.85
                local targetNote = nil
                local bestDist = 0.18
                for _, child in ipairs(laneFrame:GetChildren()) do
                    if child.Name == "Note_FX" and child:IsA("GuiObject") and child.Visible then
                        local dist = math.abs(child.Position.Y.Scale - targetY)
                        if dist <= bestDist then
                            bestDist = dist
                            targetNote = child
                        end
                    end
                end
                if targetNote then
                    lastRhythmLaneHit[lane] = now
                    local btn = laneFrame:FindFirstChild("Button")
                    if btn then TriggerGuiButton(btn) end
                    if targetNote.Parent ~= nil then
                        local kc = rhythmKeyMap[lane]
                        if kc then
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, kc, false, game)
                                task.delay(0.02, function()
                                    VirtualInputManager:SendKeyEvent(false, kc, false, game)
                                end)
                            end)
                        end
                    end
                    if targetNote.Parent ~= nil and bestDist <= 0.1 and RhythmHitEvent then
                        pcall(function()
                            targetNote:Destroy()
                            RhythmHitEvent:FireServer("hit")
                        end)
                    end
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not FishingGui or not FishingGui.Visible then return end
    BindFishingBarLock()
    LockFishingBar()
    if Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss then StepPhase2MiniGame() end
end)

RunService.Stepped:Connect(function()
    if not FishingGui or not FishingGui.Visible then return end
    BindFishingBarLock()
    LockFishingBar()
end)

RunService.Heartbeat:Connect(function()
    if not FishingGui or not FishingGui.Visible then return end
    BindFishingBarLock()
    LockFishingBar()
    if Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss then
        StepPhase2MiniGame()
        StepRhythmMiniGame()
    end
end)

local function GetModelPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

local function IsSecretBossEntity(obj)
    if not obj then return false end
    if obj:GetAttribute("Secret") == true or obj:GetAttribute("Rarity") == "Secret" then return true end
    local rawName = tostring(obj:GetAttribute("Name") or obj:GetAttribute("FishName") or obj.Name)
    local lowerName = string.lower(rawName)
    if string.find(lowerName, "secret") or string.find(lowerName, "long diaohai") or string.find(lowerName, "wuzhi") then return true end
    local inv = Info:FindFirstChild("Inventory")
    local mod = inv and inv:FindFirstChild(rawName)
    local data = GetModuleData(mod)
    if data and (data.Secret == true or data.Rarity == "Secret" or (data.Boss == true and (tonumber(data.Chance) or 100) <= 1)) then return true end
    return false
end

local function FindBossTarget(wantSecret)
    local npcFolder = workspace:FindFirstChild("NPC")
    local bossFolder = npcFolder and npcFolder:FindFirstChild("Boss")
    if bossFolder then
        for _, boss in ipairs(bossFolder:GetChildren()) do
            local part = GetModelPart(boss)
            if part then
                local isSec = IsSecretBossEntity(boss)
                if wantSecret and isSec then return boss, part
                elseif not wantSecret and not isSec then return boss, part end
            end
        end
    end
    if not wantSecret then
        local wsBoss = workspace:FindFirstChild("Boss") or workspace:FindFirstChild("BossZone")
        if wsBoss then
            local part = GetModelPart(wsBoss)
            if part then return wsBoss, part end
        end
    end
    return nil, nil
end

local lastBossActionTick = 0
local lastBossNotifyKey = ""
local lastBossNotifyTick = 0

local function NotifyBoss(title, content, key, cooldown)
    local now = os.clock()
    local cd = cooldown or 8
    local k = key or (title .. "|" .. content)
    if k == lastBossNotifyKey and (now - lastBossNotifyTick) < cd then return end
    lastBossNotifyKey = k
    lastBossNotifyTick = now
    pcall(function()
        if _G.DN_Notify then _G.DN_Notify(title, content, nil, 4) end
    end)
end

local function GetButtonLabelText(obj)
    if not obj then return "" end
    if obj:IsA("TextButton") or obj:IsA("TextLabel") then
        if obj.Text and obj.Text ~= "" then return obj.Text end
    end
    local lbl = obj:FindFirstChild("Title") or obj:FindFirstChild("TextLabel") or obj:FindFirstChildWhichIsA("TextLabel", true)
    if lbl and lbl.Text then return lbl.Text end
    return ""
end

local function FindBossMenuFrame()
    if not MainGui then return nil end
    local menu = MainGui:FindFirstChild("Menu")
    if not menu then return nil end
    for _, name in ipairs({"BossFight", "Boss", "BossMenu", "Raid", "SecretBoss"}) do
        local f = menu:FindFirstChild(name)
        if f and f:IsA("GuiObject") then return f end
    end
    for _, child in ipairs(menu:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "Info" and child.Name ~= "Black" and child.Name ~= "Dialogue" then
            local title = child:FindFirstChild("Title")
            if title and title:IsA("TextLabel") and string.find(string.lower(title.Text), "boss") then return child end
            if child:FindFirstChild("Normal", true) and child:FindFirstChild("Hard", true) and child:FindFirstChild("Nightmare", true) then return child end
        end
    end
    return nil
end

local function GetBossRequirementSummary(bossFrame, bossName)
    local missing = {}
    local rodVal = PlayerData and PlayerData:FindFirstChild("FishingRod")
    local curRodName = rodVal and rodVal.Value or ""
    if curRodName == "" then table.insert(missing, "No Fishing Rod equipped") end
    local char = LocalPlayer.Character
    local stats = char and char:FindFirstChild("Stats")
    local inv = Info:FindFirstChild("Inventory")
    if inv and bossName then
        local bossMod = inv:FindFirstChild(bossName)
        local bossData = GetModuleData(bossMod)
        local rodMod = curRodName ~= "" and inv:FindFirstChild(curRodName) or nil
        local rodData = GetModuleData(rodMod)
        if bossData and tonumber(bossData.Power) and rodData and tonumber(rodData.Power) then
            local rodBonus = stats and stats:FindFirstChild("RodPower") and tonumber(stats.RodPower.Value) or 0
            local fishBonus = stats and stats:FindFirstChild("FishPower") and tonumber(stats.FishPower.Value) or 0
            local playerPower = tonumber(rodData.Power) + rodBonus
            local bossEffPower = math.max(1, tonumber(bossData.Power) - fishBonus + 4)
            if (playerPower / bossEffPower) <= 0.5 then
                table.insert(missing, string.format("Low Power (%d/%d)", math.floor(playerPower), math.floor(bossEffPower)))
            end
        end
    end
    if bossFrame then
        for _, desc in ipairs(bossFrame:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local txt = desc.Text or ""
                local cur, req = string.match(txt, "^%s*(%d+)%s*/%s*(%d+)%s*$")
                if cur and req then
                    local nCur = tonumber(cur)
                    local nReq = tonumber(req)
                    if nCur and nReq and nCur < nReq then table.insert(missing, cur .. "/" .. req) end
                end
            end
        end
    end
    return missing
end

local bossSummoned = false
local bossSummonTick = 0

local function CloseBossMenuFrame(bossFrame)
    if not bossFrame or not bossFrame.Visible then return end
    local closed = false
    for _, desc in ipairs(bossFrame:GetDescendants()) do
        if desc:IsA("GuiButton") and desc.Visible then
            local bName = string.lower(desc.Name)
            local bTxt = string.lower(GetButtonLabelText(desc))
            local pName = desc.Parent and string.lower(desc.Parent.Name) or ""
            if bName == "close" or bTxt == "x" or pName == "close" then
                if TriggerGuiButton(desc) then closed = true break end
            end
        end
    end
    if not closed then pcall(function() bossFrame.Visible = false end) end
end

local function CheckBossStatusOnToggle(wantSecret)
    bossSummoned = false
    bossSummonTick = 0
    local title = wantSecret and "Auto Long DiaoHai" or "Auto Enzo"
    local rodVal = PlayerData and PlayerData:FindFirstChild("FishingRod")
    if not rodVal or rodVal.Value == "" then
        NotifyBoss(title, "Failed: Requirements not met (No Fishing Rod equipped)!", "toggle_norod_" .. tostring(wantSecret), 2)
        return
    end
    local bossObj = FindBossTarget(wantSecret)
    if not bossObj then
        NotifyBoss(title, "Failed: " .. (wantSecret and "Secret Boss" or "Boss") .. " not found on map!", "toggle_noboss_" .. tostring(wantSecret), 2)
        return
    end
    local bossName = tostring(bossObj:GetAttribute("Name") or bossObj.Name)
    local missing = GetBossRequirementSummary(FindBossMenuFrame(), bossName)
    if #missing > 0 then
        NotifyBoss(title, "Requirement Warning (" .. bossName .. "): " .. table.concat(missing, ", "), "toggle_warn_" .. bossName, 2)
    else
        NotifyBoss(title, "Requirements met! Hunting " .. bossName .. " [" .. tostring(Config.BossMode) .. "]", "toggle_ok_" .. bossName, 2)
    end
end

local function ClickBossModeAndStart(bossFrame, bossName, mode, wantSecret)
    if not bossFrame then return false end
    local notifyTitle = wantSecret and "Auto Long DiaoHai" or "Auto Enzo"
    local targetMode = mode or "Normal"
    local targetLower = string.lower(targetMode)
    local modeMatched = false
    for _, desc in ipairs(bossFrame:GetDescendants()) do
        if desc:IsA("TextLabel") then
            local txt = string.lower(desc.Text or "")
            if string.find(txt, "mode:") and string.find(txt, targetLower) then modeMatched = true break end
        end
    end
    if not modeMatched then
        for _, desc in ipairs(bossFrame:GetDescendants()) do
            if desc:IsA("GuiButton") and desc.Visible then
                local bName = string.lower(desc.Name)
                local bTxt = string.lower(GetButtonLabelText(desc))
                local pName = desc.Parent and string.lower(desc.Parent.Name) or ""
                if bName == targetLower or bTxt == targetLower or pName == targetLower then
                    TriggerGuiButton(desc)
                    task.wait(0.1)
                    break
                end
            end
        end
    end
    local inProgress = false
    local startBtn = nil
    local startBtnText = ""
    local function scanStartButton()
        inProgress = false
        startBtn = nil
        startBtnText = ""
        for _, desc in ipairs(bossFrame:GetDescendants()) do
            if desc:IsA("GuiButton") and desc.Visible and desc.Name ~= "Close" then
                local bName = string.lower(desc.Name)
                local rawTxt = GetButtonLabelText(desc)
                local bTxt = string.lower(rawTxt)
                local pName = desc.Parent and string.lower(desc.Parent.Name) or ""
                local isModeBtn = (bName == "normal" or bName == "hard" or bName == "nightmare"
                    or bTxt == "normal" or bTxt == "hard" or bTxt == "nightmare"
                    or pName == "normal" or pName == "hard" or pName == "nightmare"
                    or bTxt == "x" or pName == "close")
                if not isModeBtn then
                    if string.find(bTxt, "in progress") then
                        inProgress = true
                        startBtnText = rawTxt
                    elseif bTxt ~= "" or bName == "start" or bName == "fight" or bName == "play" or bName == "enter" or bName == "button" then
                        startBtn = desc
                        startBtnText = rawTxt
                    end
                end
            end
        end
    end
    scanStartButton()
    if inProgress then
        bossSummoned = true
        bossSummonTick = os.clock()
        CloseBossMenuFrame(bossFrame)
        NotifyBoss(notifyTitle, "Requirements met! Boss " .. tostring(bossName or "Boss") .. " [" .. targetMode .. "] is In Progress!", "inprog_" .. tostring(bossName) .. "_" .. targetMode, 15)
        return true
    end
    if startBtn then TriggerGuiButton(startBtn) end
    for _, rName in ipairs({"BossFight", "StartBossFight", "StartBoss", "Boss", "ChallengeBoss", "FightBoss"}) do
        local ev = Events:FindFirstChild(rName)
        if ev then
            pcall(function()
                if ev:IsA("RemoteEvent") then
                    ev:FireServer(targetMode)
                    if bossName then ev:FireServer(bossName, targetMode) end
                elseif ev:IsA("RemoteFunction") then
                    ev:InvokeServer(targetMode)
                end
            end)
        end
    end
    task.wait(0.25)
    scanStartButton()
    if inProgress or (FishingGui and FishingGui.Visible) then
        bossSummoned = true
        bossSummonTick = os.clock()
        CloseBossMenuFrame(bossFrame)
        NotifyBoss(notifyTitle, "Success! Started Boss " .. tostring(bossName or "Boss") .. " [" .. targetMode .. "]!", "start_ok_" .. tostring(bossName) .. "_" .. targetMode, 12)
        return true
    else
        local missing = GetBossRequirementSummary(bossFrame, bossName)
        local reason = #missing > 0 and table.concat(missing, ", ") or (startBtnText ~= "" and startBtnText or "Missing Tickets/Crystals or on Cooldown")
        NotifyBoss(notifyTitle, "Failed (Requirements not met): " .. tostring(bossName or "Boss") .. " [" .. targetMode .. "] - " .. reason, "start_fail_" .. tostring(bossName) .. "_" .. targetMode, 10)
        return false
    end
end

local lastCaughtBossTick = 0
local lastCaughtFishName = ""

do
    local repEv = Events:FindFirstChild("ReplicateFishCaught")
    if repEv and repEv:IsA("RemoteEvent") then
        repEv.OnClientEvent:Connect(function(charModel, fishName)
            if charModel == LocalPlayer.Character then
                lastCaughtBossTick = os.clock()
                lastCaughtFishName = tostring(fishName or "")
                bossSummoned = false
                bossSummonTick = 0
                if Config.AutoBoss or Config.AutoSecretBoss then
                    local notifyTitle = Config.AutoSecretBoss and "Auto Long DiaoHai" or "Auto Enzo"
                    NotifyBoss(notifyTitle, "Success! Caught Boss: " .. lastCaughtFishName .. "!", "caught_" .. lastCaughtFishName .. "_" .. tostring(math.floor(lastCaughtBossTick)), 1)
                end
            end
        end)
    end
end

local trackingBossFight = false
local function MonitorBossMinigame()
    if trackingBossFight then return end
    local fishId = LocalPlayer:GetAttribute("FishID")
    local fishesFolder = workspace:FindFirstChild("Fishes")
    local fishObj = (fishId and fishesFolder) and fishesFolder:FindFirstChild(tostring(fishId)) or nil
    if not fishObj then return end
    trackingBossFight = true
    task.spawn(function()
        local notifyTitle = Config.AutoSecretBoss and "Auto Long DiaoHai" or "Auto Enzo"
        local progBar = FishingGui and FishingGui:FindFirstChild("ProgressionBar")
        local fNameLbl = progBar and progBar:FindFirstChild("FishName")
        local fName = (fNameLbl and fNameLbl.Text ~= "" and fNameLbl.Text) or "Boss"
        local hpObj = fishObj:FindFirstChild(LocalPlayer.UserId .. "_PlayerHealth")
        local maxFishHp = tonumber(fishObj:GetAttribute("MaxHealth")) or 100
        NotifyBoss(notifyTitle, "Fighting " .. fName .. " [" .. tostring(Config.BossMode) .. "]!", "pull_" .. tostring(fishId), 5)
        local lastScale = 0.5
        local lastHp = hpObj and hpObj.Value or 100
        local lastFishVal = fishObj:IsA("ValueBase") and fishObj.Value or 0
        local hadFinalPhase = false
        local lastFinalHp = 1
        while fishObj.Parent and (FishingGui and FishingGui.Visible) do
            bossSummonTick = os.clock()
            if hpObj then lastHp = hpObj.Value end
            if fishObj:IsA("ValueBase") then lastFishVal = fishObj.Value end
            if fishObj:GetAttribute("FinalPhase") == true then hadFinalPhase = true end
            if fishObj:GetAttribute("FinalPhaseHP") ~= nil then lastFinalHp = tonumber(fishObj:GetAttribute("FinalPhaseHP")) or lastFinalHp end
            if FishingBar then lastScale = FishingBar.Position.X.Scale end
            task.wait(0.1)
        end
        task.wait(0.35)
        bossSummoned = false
        bossSummonTick = 0
        if os.clock() - lastCaughtBossTick < 2.5 then
            trackingBossFight = false
            return
        end
        local won = (hadFinalPhase and lastFinalHp <= 0) or (not hadFinalPhase and lastFishVal >= maxFishHp * 0.98 and lastHp > 0 and lastScale > 0.02 and lastScale < 0.98)
        if won then
            NotifyBoss(notifyTitle, "Success! Defeated Boss " .. fName .. "!", "win_" .. tostring(fishId), 2)
        else
            local failReason = "Line broke / Cancelled"
            if lastHp <= 0 then failReason = "Died (0 HP)"
            elseif lastScale <= 0.02 or lastScale >= 0.98 then failReason = "Out of bar"
            elseif LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Type") ~= "Fishing Rod" then failReason = "Rod unequipped" end
            NotifyBoss(notifyTitle, "Failed fighting " .. fName .. ": " .. failReason .. "!", "lose_" .. tostring(fishId), 2)
        end
        trackingBossFight = false
    end)
end

local function StepAutoBoss(char, isMinigame)
    if isMinigame then
        bossSummoned = true
        bossSummonTick = os.clock()
        MonitorBossMinigame()
        return
    end
    local now = os.clock()
    if now - lastBossActionTick < 0.8 then return end
    lastBossActionTick = now
    if bossSummoned and (now - bossSummonTick > 45) then bossSummoned = false end
    local wantSecret = Config.AutoSecretBoss
    local notifyTitle = wantSecret and "Auto Long DiaoHai" or "Auto Enzo"
    local rodVal = PlayerData and PlayerData:FindFirstChild("FishingRod")
    if not rodVal or rodVal.Value == "" then
        NotifyBoss(notifyTitle, "Failed: Requirements not met (No Fishing Rod equipped)!", "step_norod", 10)
        return
    end
    local bossObj, bossPart = FindBossTarget(wantSecret)
    if not bossObj or not bossPart then
        NotifyBoss(notifyTitle, "Failed: " .. (wantSecret and "Secret Boss" or "Boss") .. " not found on map!", "step_noboss_" .. tostring(wantSecret), 10)
        return
    end
    local hrp = cachedHrp or (char and char:FindFirstChild("HumanoidRootPart"))
    local bossName = bossObj and (bossObj:GetAttribute("Name") or bossObj.Name) or nil
    if bossPart and hrp then
        local dist = (hrp.Position - bossPart.Position).Magnitude
        if dist > 12 then hrp.CFrame = bossPart.CFrame * CFrame.new(0, 3, -5) end
    end
    local bossFrame = FindBossMenuFrame()
    if not bossSummoned then
        if bossPart and hrp then
            local prompt = bossObj and bossObj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt and fireproximityprompt then
                pcall(function() fireproximityprompt(prompt) end)
            end
        end
        if bossFrame and bossFrame.Visible then
            ClickBossModeAndStart(bossFrame, bossName, Config.BossMode, wantSecret)
        end
        if MainGui and not bossSummoned then
            local menu = MainGui:FindFirstChild("Menu")
            local dialogue = menu and menu:FindFirstChild("Dialogue")
            if dialogue and dialogue.Visible then
                local btnFrame = dialogue:FindFirstChild("ButtonFrame")
                if btnFrame then
                    local chosenBtn = nil
                    local modeLower = string.lower(Config.BossMode or "Normal")
                    for _, btn in ipairs(btnFrame:GetChildren()) do
                        if btn:IsA("TextButton") and btn.Name ~= "Template" and btn.Visible then
                            local title = btn:FindFirstChild("Title")
                            local txt = title and string.lower(title.Text) or ""
                            if string.find(txt, modeLower) then
                                chosenBtn = btn
                                break
                            elseif not chosenBtn and not string.find(txt, "close") and not string.find(txt, "cancel") and not string.find(txt, "nevermind") and not string.find(txt, "leave") then
                                chosenBtn = btn
                            end
                        end
                    end
                    if chosenBtn then TriggerGuiButton(chosenBtn) end
                end
            end
        end
    else
        if bossFrame and bossFrame.Visible then CloseBossMenuFrame(bossFrame) end
        if char then
            if char:GetAttribute("Type") ~= "Fishing Rod" then
                pcall(function() ToggleHotbar:InvokeServer("1") end)
            elseif not char:GetAttribute("Fishing") and hrp then
                pcall(function() FishingEvent:FireServer(hrp.CFrame) end)
            end
        end
    end
end

task.spawn(function()
    local lastCastTry = 0
    local lastSkillTry = 0
    while task.wait(0.12) do
        local now = os.clock()
        RefreshGuiCache()
        local isMinigame = FishingGui and FishingGui.Visible or false
        local activeReel = Config.AutoReel or Config.AutoMiniGame or Config.AutoBoss or Config.AutoSecretBoss
        local activeCast = Config.AutoCast or Config.AutoBoss or Config.AutoSecretBoss
        local activeSkill = Config.AutoSkill or Config.AutoBoss or Config.AutoSecretBoss
        if activeReel and isMinigame then
            pcall(function() UpdateFishProgression:FireServer() end)
        end
        if activeSkill and isMinigame and (now - lastSkillTry >= 0.45) then
            local char = cachedChar
            if char and IsGameAllowingSkill(char) then
                local priorityList = ParseSkillString(Config.SkillPriority)
                local enabledSet = SkillStringToSet(Config.SkillEnabled)
                for _, key in ipairs(priorityList) do
                    if enabledSet[key] and IsSkillKeyReady(char, key) then
                        lastSkillTry = os.clock()
                        pcall(function() UseSkill:FireServer(key) end)
                        break
                    end
                end
            end
        end
        if Config.AutoBoss or Config.AutoSecretBoss then
            StepAutoBoss(cachedChar, isMinigame)
        elseif activeCast and not isMinigame and (now - lastCastTry >= 0.6) then
            local char = cachedChar
            if char then
                if char:GetAttribute("Type") ~= "Fishing Rod" then
                    lastCastTry = now
                    pcall(function() ToggleHotbar:InvokeServer("1") end)
                elseif not char:GetAttribute("Fishing") then
                    local hrp = cachedHrp or char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        lastCastTry = now + 0.9
                        pcall(function() FishingEvent:FireServer(hrp.CFrame) end)
                    end
                end
            end
        end
    end
end)

Events:WaitForChild("Slam").OnClientEvent:Connect(function(remote)
    if (Config.AutoMiniGame or Config.AutoReel or Config.AutoBoss or Config.AutoSecretBoss) and remote then
        task.wait(0.05)
        local handled = false
        pcall(function()
            local tc = FishingGui and FishingGui:FindFirstChild("TrashCan")
            local slamGui = tc and tc:FindFirstChild("Slam")
            local btn = slamGui and slamGui:FindFirstChild("Button")
            local line = btn and btn:FindFirstChild("Line")
            if line then line.Size = UDim2.new(1, 0, 1, 0) end
            if btn then
                TriggerGuiButton(btn)
                if not slamGui.Parent then handled = true end
            end
            if not handled then
                remote:FireServer("Perfect")
                if slamGui and slamGui.Parent then slamGui:Destroy() end
            end
        end)
    end
end)

Events:WaitForChild("Charge").OnClientEvent:Connect(function(remote)
    if (Config.AutoMiniGame or Config.AutoReel or Config.AutoBoss or Config.AutoSecretBoss) and remote then
        task.wait(1.05)
        pcall(function()
            local tc = FishingGui and FishingGui:FindFirstChild("TrashCan")
            local chargeGui = tc and tc:FindFirstChild("Charge")
            local btn = chargeGui and chargeGui:FindFirstChild("Button")
            if btn and chargeGui.Parent then TriggerGuiButton(btn) end
            if chargeGui and chargeGui.Parent then
                remote:FireServer()
                chargeGui:Destroy()
            end
        end)
    end
end)

local function clearPlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local esp = head:FindFirstChild("DNEsp")
                if esp then esp:Destroy() end
            end
        end
    end
end

local function updateESP()
    if not Config.ESPEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if head and hum then
                    local esp = head:FindFirstChild("DNEsp")
                    if hum.Health > 0 then
                        if not esp then
                            esp = Instance.new("BillboardGui")
                            esp.Name = "DNEsp"
                            esp.Adornee = head
                            esp.Size = UDim2.new(0, 200, 0, 25)
                            esp.StudsOffset = Vector3.new(0, 2.5, 0)
                            esp.AlwaysOnTop = true
                            esp.MaxDistance = math.huge
                            local text = Instance.new("TextLabel")
                            text.Name = "NameText"
                            text.Parent = esp
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextScaled = false
                            text.TextSize = 13
                            text.Font = Enum.Font.GothamBold
                            text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            text.TextStrokeTransparency = 0
                            text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                            text.TextXAlignment = Enum.TextXAlignment.Center
                            esp.Parent = head
                        end
                        esp.NameText.Text = player.DisplayName
                    else
                        if esp then esp:Destroy() end
                    end
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.4) do
        if Config.ESPEnabled then updateESP() end
    end
end)

local lastSellTime = 0
local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

local function FindRemote(name)
    return Events:FindFirstChild(name) or (RemotesFolder and RemotesFolder:FindFirstChild(name))
end

local function FireOrInvokeEvent(ev, ...)
    if not ev then return false end
    local args = {...}
    local ok = pcall(function()
        if ev:IsA("RemoteEvent") then ev:FireServer(unpack(args))
        elseif ev:IsA("RemoteFunction") then ev:InvokeServer(unpack(args)) end
    end)
    return ok
end

local function DoBuyBait(baitName, amount)
    if not baitName or baitName == "" then return end
    local amt = math.max(1, math.floor(tonumber(amount) or 1))
    local buyEvent = FindRemote("BuyBait") or FindRemote("Bait") or FindRemote("PurchaseBait") or FindRemote("BaitShop") or FindRemote("BuyItem")
    if buyEvent then
        FireOrInvokeEvent(buyEvent, baitName, amt)
    else
        pcall(function() CraftBaitEvent:FireServer(baitName, amt) end)
    end
end

task.spawn(function()
    while task.wait(0.8) do
        if Config.AutoSell then
            local delaySec = math.clamp(tonumber(Config.SellDelay) or 1, 1, 10) * 60
            local now = os.clock()
            if now - lastSellTime >= delaySec then
                lastSellTime = now
                pcall(function() SellFish:FireServer("All") end)
            end
        end
        if Config.AutoBuyBait and Config.SelectedBuyBait ~= "" then
            DoBuyBait(Config.SelectedBuyBait, Config.BuyBaitAmount)
        end
        if Config.AutoCraftBait and Config.SelectedBait ~= "" then
            pcall(function() CraftBaitEvent:FireServer(Config.SelectedBait, math.max(1, math.floor(tonumber(Config.BaitAmount) or 1))) end)
        end
        if Config.AutoCraftRod and Config.SelectedRod ~= "" then
            pcall(function() CraftRodEvent:FireServer(Config.SelectedRod) end)
        end
    end
end)

local function GetBuyableBaits()
    local list = {}
    local seen = {}
    local baitFolder = Info:FindFirstChild("Bait")
    if baitFolder then
        for _, child in ipairs(baitFolder:GetChildren()) do
            local data = GetModuleData(child)
            if data and not data.Ingredient then
                seen[child.Name] = true
                table.insert(list, child.Name)
            end
        end
    end
    local itemFolder = Info:FindFirstChild("Item")
    if itemFolder then
        for _, child in ipairs(itemFolder:GetChildren()) do
            if not seen[child.Name] then
                local data = GetModuleData(child)
                if data and data.Type == "Bait" and not data.Ingredient then
                    seen[child.Name] = true
                    table.insert(list, child.Name)
                end
            end
        end
    end
    table.sort(list)
    return list
end

local function GetCraftableBaits()
    local list = {}
    local baitFolder = Info:FindFirstChild("Bait")
    if baitFolder then
        for _, child in ipairs(baitFolder:GetChildren()) do
            local data = GetModuleData(child)
            if data and data.Ingredient then table.insert(list, child.Name) end
        end
    end
    table.sort(list)
    return list
end

local function GetCraftableRods()
    local list = {}
    local invFolder = Info:FindFirstChild("Inventory")
    if invFolder then
        for _, child in ipairs(invFolder:GetChildren()) do
            local data = GetModuleData(child)
            if data and data.Ingredient and data.Type == "Fishing Rod" then table.insert(list, child.Name) end
        end
    end
    table.sort(list)
    return list
end

local IslandTargets = {}
local CanonicalIslandOrder = {
    ["Beginning Isle"] = 1, ["Bamboo Isle"] = 2, ["Fallout Isle"] = 3, ["Sovereign Isle"] = 4,
    ["Perch Isle"] = 5, ["Frost Isle"] = 6, ["Coconut Isle"] = 7, ["Amber Isle"] = 8,
    ["Battlefield Isle"] = 9, ["Mistpeak Isle"] = 10, ["World Angler Isle"] = 11,
    ["Weather Isle"] = 12, ["Mystic Reef Isle"] = 13
}
local CanonicalIslandPower = {
    ["Beginning Isle"] = 1, ["Bamboo Isle"] = 19, ["Fallout Isle"] = 32, ["Sovereign Isle"] = 39,
    ["Perch Isle"] = 48, ["Frost Isle"] = 55, ["Coconut Isle"] = 65, ["Amber Isle"] = 75,
    ["Battlefield Isle"] = 90, ["Mistpeak Isle"] = 100, ["World Angler Isle"] = 100,
    ["Weather Isle"] = 100, ["Mystic Reef Isle"] = 100
}

local function GetCanonicalIslandRank(name)
    if CanonicalIslandOrder[name] then return CanonicalIslandOrder[name] end
    local lowerName = string.lower(name)
    for k, rank in pairs(CanonicalIslandOrder) do
        local lk = string.lower(k)
        if lowerName == lk or string.find(lowerName, lk, 1, true) or string.find(lk, lowerName, 1, true) then return rank end
    end
    return nil
end

local function GetCanonicalIslandPower(name)
    if CanonicalIslandPower[name] then return CanonicalIslandPower[name] end
    local lowerName = string.lower(name)
    for k, pwr in pairs(CanonicalIslandPower) do
        local lk = string.lower(k)
        if lowerName == lk or string.find(lowerName, lk, 1, true) or string.find(lk, lowerName, 1, true) then return pwr end
    end
    return nil
end

local function GetIslandList()
    local rawIslands = {}
    local seen = {}
    table.clear(IslandTargets)
    local sp = workspace:FindFirstChild("Spawnpoint")
    if not sp then return {} end
    local startPart = sp:FindFirstChild("Beginning Isle")
    local startPos = startPart and GetModelPart(startPart) and GetModelPart(startPart).Position or Vector3.zero
    local compassOrder = {}
    local compassPower = {}
    if MainGui then
        local menu = MainGui:FindFirstChild("Menu")
        local compass = menu and menu:FindFirstChild("Compass")
        local areaList = compass and compass:FindFirstChild("AreaList")
        if areaList then
            for _, item in ipairs(areaList:GetChildren()) do
                if item:IsA("GuiObject") and item:FindFirstChild("Track") then
                    local powerVal = nil
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("TextLabel") and desc.Text then
                            local m = string.match(desc.Text, "Power:%s*(%d+)")
                            if m then powerVal = tonumber(m) break end
                        end
                    end
                    if powerVal then compassPower[item.Name] = powerVal end
                    local orderScore = (powerVal or 999) * 1000 + (item.LayoutOrder or 0)
                    compassOrder[item.Name] = orderScore
                end
            end
        end
    end
    for _, child in ipairs(sp:GetChildren()) do
        local part = GetModelPart(child)
        if part and not seen[child.Name] then
            seen[child.Name] = true
            local rank = GetCanonicalIslandRank(child.Name)
            local weight
            if rank then weight = rank
            elseif compassOrder[child.Name] then weight = 1000 + compassOrder[child.Name]
            else weight = 1e7 + (part.Position - startPos).Magnitude end
            local pwr = compassPower[child.Name] or GetCanonicalIslandPower(child.Name)
            table.insert(rawIslands, { name = child.Name, part = part, weight = weight, power = pwr })
        end
    end
    table.sort(rawIslands, function(a, b)
        if a.weight ~= b.weight then return a.weight < b.weight end
        return a.name < b.name
    end)
    local list = {}
    for _, entry in ipairs(rawIslands) do
        local label = entry.power and (entry.name .. " | " .. tostring(entry.power)) or entry.name
        IslandTargets[label] = entry.part
        IslandTargets[entry.name] = entry.part
        table.insert(list, label)
    end
    return list
end

local function TeleportToIsland(islandName)
    if not islandName or islandName == "" then return end
    if not IslandTargets[islandName] then GetIslandList() end
    local targetPart = IslandTargets[islandName]
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and targetPart then hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0) end
end

local NPCTargets = {}
local function GetNPCList()
    local list = {}
    local seen = {}
    table.clear(NPCTargets)
    local function addNPCModel(obj)
        if not obj then return end
        local part = GetModelPart(obj)
        if not part then return end
        local rawName = tostring(obj:GetAttribute("Name") or obj.Name)
        if rawName == "" then return end
        NPCTargets[rawName] = part
        if not seen[rawName] then
            seen[rawName] = true
            table.insert(list, rawName)
        end
    end
    local npcFolder = workspace:FindFirstChild("NPC")
    if npcFolder then
        for _, child in ipairs(npcFolder:GetChildren()) do
            if child:IsA("Folder") then
                if child.Name ~= "Boss" then
                    for _, sub in ipairs(child:GetChildren()) do addNPCModel(sub) end
                end
            elseif child.Name ~= "Boss" then
                addNPCModel(child)
            end
        end
    end
    for _, folderName in ipairs({"NPCPVP", "Merchant", "God"}) do
        local f = workspace:FindFirstChild(folderName)
        if f then
            if f:IsA("Model") or f:IsA("BasePart") then addNPCModel(f)
            else for _, child in ipairs(f:GetChildren()) do addNPCModel(child) end end
        end
    end
    table.sort(list)
    return list
end

local function TeleportToNPC(npcName)
    if not npcName or npcName == "" then return end
    local targetPart = NPCTargets[npcName]
    if not targetPart or not targetPart.Parent then
        GetNPCList()
        targetPart = NPCTargets[npcName]
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and targetPart and targetPart.Parent then hrp.CFrame = targetPart.CFrame * CFrame.new(0, 3, -4) end
end

local function GetHumanoid()
    local Character = LocalPlayer.Character
    local RG = Character and Character:FindFirstChildOfClass("Humanoid")
    return RG
end

local function RedeemAllCodes()
    local adq = GetHumanoid()
    if not adq then
        return
    end
    local Code = adq:FindFirstChild("Code")
    if not Code then
        return
    end
    for i, child in ipairs(Code:GetChildren()) do
        local adq_1 = child:IsA("BoolValue") and child.Value == false
        if adq_1 then
            RedeemCodeEvent:FireServer(child.Name)
            task.wait(0.2)
        end
    end
end

local OGBNameLabel = nil
local OGBNameConn = nil
local OGLevelLabels = {}
local OGLevelConns = {}

local function GetNameLabel(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local eqTitle = hrp:FindFirstChild("EquippedTitle")
    if not eqTitle then return nil end
    local plrName = eqTitle:FindFirstChild("PlayerName")
    if plrName and plrName:IsA("TextLabel") then return plrName end
    return nil
end

local function RestoreHideName()
    if OGBNameConn then
        pcall(function() OGBNameConn:Disconnect() end)
        OGBNameConn = nil
    end
    if OGBNameLabel and OGBNameLabel.Parent and OGBNameLabel.Text ~= Config.HideNameText then
        pcall(function() OGBNameLabel.Text = LocalPlayer.DisplayName end)
    end
    OGBNameLabel = nil
end

local function ApplyHideName(char)
    RestoreHideName()
    if not Config.HideName then return end
    local label = GetNameLabel(char)
    if not label then return end
    OGBNameLabel = label
    pcall(function() label.Text = Config.HideNameText end)
    OGBNameConn = label:GetPropertyChangedSignal("Text"):Connect(function()
        if not Config.HideName then return end
        if label.Text ~= Config.HideNameText then
            pcall(function() label.Text = Config.HideNameText end)
        end
    end)
end

local function GetLevelLabels()
    local labels = {}
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return labels end
    for _, desc in ipairs(pg:GetDescendants()) do
        if desc:IsA("TextLabel") and desc.Parent and desc.Parent.Name == "Level" then
            table.insert(labels, desc)
        end
    end
    return labels
end

local function RestoreHideLevel()
    for _, conn in ipairs(OGLevelConns) do
        pcall(function() conn:Disconnect() end)
    end
    table.clear(OGLevelConns)
    for label, origText in pairs(OGLevelLabels) do
        if label and label.Parent then
            pcall(function() label.Text = origText end)
        end
    end
    table.clear(OGLevelLabels)
end

local function ApplyHideLevel()
    RestoreHideLevel()
    if not Config.HideLevel then return end
    local labels = GetLevelLabels()
    for _, label in ipairs(labels) do
        if not OGLevelLabels[label] then
            OGLevelLabels[label] = label.Text
        end
        pcall(function() label.Text = Config.HideLevelText end)
        local conn = label:GetPropertyChangedSignal("Text"):Connect(function()
            if not Config.HideLevel then return end
            if label.Text ~= Config.HideLevelText then
                pcall(function() label.Text = Config.HideLevelText end)
            end
        end)
        table.insert(OGLevelConns, conn)
    end
end

local function RefreshHideLevelWatcher()
    if not Config.HideLevel then return end
    task.spawn(function()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        pg.DescendantAdded:Connect(function(desc)
            if not Config.HideLevel then return end
            if desc:IsA("TextLabel") and desc.Parent and desc.Parent.Name == "Level" then
                task.wait(0.05)
                if OGLevelLabels[desc] == nil then
                    OGLevelLabels[desc] = desc.Text
                end
                pcall(function() desc.Text = Config.HideLevelText end)
                local conn = desc:GetPropertyChangedSignal("Text"):Connect(function()
                    if not Config.HideLevel then return end
                    if desc.Text ~= Config.HideLevelText then
                        pcall(function() desc.Text = Config.HideLevelText end)
                    end
                end)
                table.insert(OGLevelConns, conn)
            end
        end)
    end)
end

pcall(function()
    ApplyHideName(LocalPlayer.Character)
    ApplyHideLevel()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Config.HideName then ApplyHideName(char) end
    if Config.HideLevel then ApplyHideLevel() end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.HideName then
            local char = LocalPlayer.Character
            if char then
                local label = GetNameLabel(char)
                if label and label ~= OGBNameLabel then
                    ApplyHideName(char)
                end
            end
        end
        if Config.HideLevel then
            local labels = GetLevelLabels()
            local missing = false
            for _, label in ipairs(labels) do
                if not OGLevelLabels[label] then
                    missing = true
                    break
                end
            end
            if missing then ApplyHideLevel() end
        end
    end
end)

local OriginalLighting = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local OriginalAtmosphere = {}
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("Atmosphere") then
        OriginalAtmosphere[child] = { Density = child.Density, Haze = child.Haze, Glare = child.Glare }
    end
end

local applyingLighting = false
local function ApplyLightingSettings()
    if applyingLighting then return end
    applyingLighting = true
    pcall(function()
        if Config.FullBright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        end
        if Config.NoFog then
            Lighting.FogStart = 100000
            Lighting.FogEnd = 100000
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") then
                    if not OriginalAtmosphere[child] then
                        OriginalAtmosphere[child] = { Density = child.Density, Haze = child.Haze, Glare = child.Glare }
                    end
                    child.Density = 0
                    child.Haze = 0
                    child.Glare = 0
                end
            end
        end
    end)
    applyingLighting = false
end

local function RestoreFullBright()
    applyingLighting = true
    pcall(function()
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end)
    applyingLighting = false
end

local function RestoreNoFog()
    applyingLighting = true
    pcall(function()
        Lighting.FogStart = OriginalLighting.FogStart
        Lighting.FogEnd = OriginalLighting.FogEnd
        for atm, orig in pairs(OriginalAtmosphere) do
            if atm and atm.Parent then
                atm.Density = orig.Density
                atm.Haze = orig.Haze
                atm.Glare = orig.Glare
            end
        end
    end)
    applyingLighting = false
end

Lighting.Changed:Connect(function()
    if Config.FullBright or Config.NoFog then ApplyLightingSettings() end
end)

ApplyLightingSettings()

local Window = DNHub:CreateWindow({
    Title = "DN Hub Private",
    SubTitle = "Heavyweight Fishing",
    Size = UDim2.new(0, 750, 0, 500),
    Parent = game:GetService("CoreGui"),
    MinimizeKey = Enum.KeyCode.RightControl,
    Game = "Heavyweight Fishing",
    Version = "v1.0"
})

_G.DN_Notify = function(title, content, status, duration)
    Window:Notify({ Title = title, Description = content, Status = status, Duration = duration or 4 })
end

local MainTab = Window:AddTab({ Title = "Main", Icon = "rbxassetid://10709797111" })
local PlayerTab = Window:AddTab({ Title = "Player", Icon = "rbxassetid://10709797111" })
local TeleportTab = Window:AddTab({ Title = "Teleport", Icon = "rbxassetid://10709797111" })
local ShopTab = Window:AddTab({ Title = "Shop", Icon = "rbxassetid://10709797111" })
local ESPTab = Window:AddTab({ Title = "ESP", Icon = "rbxassetid://10709797111" })
local MiscTab = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://10709797111" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "rbxassetid://10709797111" })

MainTab:AddSeparator({ Title = "FISHING" })

MainTab:AddToggle({
    Title = "Auto Cast",
    Description = "Tự động quăng cần",
    Default = Config.AutoCast,
    Callback = function(v) Config.AutoCast = v SaveConfig() end
})

MainTab:AddToggle({
    Title = "Auto Reel",
    Description = "Tự động kéo cá",
    Default = Config.AutoReel,
    Callback = function(v) Config.AutoReel = v SaveConfig() end
})

MainTab:AddSeparator({ Title = "SKILL" })

MainTab:AddToggle({
    Title = "Auto Skill",
    Description = "Tự động dùng skill",
    Default = Config.AutoSkill,
    Callback = function(v) Config.AutoSkill = v SaveConfig() end
})

MainTab:AddTextbox({
    Title = "Skill Priority",
    Description = "Thứ tự ưu tiên (VD: Z,X,C,V)",
    Placeholder = "Z,X,C,V",
    Default = Config.SkillPriority or "Z,X,C,V",
    Callback = function(v)
        Config.SkillPriority = tostring(v or "Z,X,C,V")
        SaveConfig()
    end
})

MainTab:AddTextbox({
    Title = "Skill Enabled",
    Description = "Skill được phép dùng (VD: Z,X,C)",
    Placeholder = "Z,X,C,V",
    Default = Config.SkillEnabled or "Z,X,C,V",
    Callback = function(v)
        Config.SkillEnabled = tostring(v or "Z,X,C,V")
        SaveConfig()
    end
})

MainTab:AddSeparator({ Title = "BOSS" })

MainTab:AddDropdown({
    Title = "Boss Mode",
    Description = "Chế độ boss",
    Options = {"Normal", "Hard", "Nightmare"},
    Default = Config.BossMode,
    Multi = false,
    Callback = function(v) Config.BossMode = v or "Normal" SaveConfig() end
})

MainTab:AddToggle({
    Title = "Auto Enzo",
    Description = "Tự động đánh boss Enzo",
    Default = Config.AutoBoss,
    Callback = function(v)
        Config.AutoBoss = v
        SaveConfig()
        if v then task.spawn(function() CheckBossStatusOnToggle(false) end) end
    end
})

MainTab:AddToggle({
    Title = "Auto Long DiaoHai",
    Description = "Tự động đánh Secret Boss",
    Default = Config.AutoSecretBoss,
    Callback = function(v)
        Config.AutoSecretBoss = v
        SaveConfig()
        if v then task.spawn(function() CheckBossStatusOnToggle(true) end) end
    end
})

MainTab:AddToggle({
    Title = "Auto Mini Game",
    Description = "Tự động minigame",
    Default = Config.AutoMiniGame,
    Callback = function(v)
        Config.AutoMiniGame = v
        if v and LocalPlayer.Character then ApplyAntiConfuse(LocalPlayer.Character) end
        SaveConfig()
    end
})

PlayerTab:AddSeparator({ Title = "MOVEMENT" })

PlayerTab:AddToggle({
    Title = "Walk Speed",
    Description = "Bật chỉnh tốc độ chạy",
    Default = Config.LoopSpeedEnabled,
    Callback = function(v) Config.LoopSpeedEnabled = v SaveConfig() end
})

PlayerTab:AddSlider({
    Title = "Speed",
    Description = "Tốc độ chạy",
    Min = 16, Max = 250, Default = Config.WalkSpeed, Suffix = "",
    Callback = function(v) Config.WalkSpeed = v SaveConfig() end
})

PlayerTab:AddToggle({
    Title = "Fly",
    Description = "Bay",
    Default = Config.FlyEnabled,
    Callback = function(v)
        Config.FlyEnabled = v
        SaveConfig()
        if v then startFly() else stopFly() end
    end
})

PlayerTab:AddSlider({
    Title = "Fly Speed",
    Description = "Tốc độ bay",
    Min = 1, Max = 20, Default = Config.FlySpeed, Suffix = "",
    Callback = function(v) Config.FlySpeed = v SaveConfig() end
})

PlayerTab:AddToggle({
    Title = "Noclip",
    Description = "Xuyên vật thể",
    Default = Config.NoclipEnabled,
    Callback = function(v) Config.NoclipEnabled = v SaveConfig() end
})

PlayerTab:AddToggle({
    Title = "Infinite Jump",
    Description = "Nhảy vô hạn",
    Default = Config.InfJumpEnabled,
    Callback = function(v) Config.InfJumpEnabled = v SaveConfig() end
})

TeleportTab:AddSeparator({ Title = "ISLAND" })

local islandList = GetIslandList()
if (Config.SelectedIsland == "" or not table.find(islandList, Config.SelectedIsland)) and #islandList > 0 then
    Config.SelectedIsland = islandList[1]
end

TeleportTab:AddDropdown({
    Title = "Select Island",
    Description = "Chọn đảo",
    Options = islandList,
    Default = Config.SelectedIsland ~= "" and Config.SelectedIsland or (islandList[1] or ""),
    Multi = false,
    Callback = function(v) Config.SelectedIsland = v or "" SaveConfig() end
})

TeleportTab:AddButton({
    Title = "Teleport To Island",
    Callback = function() TeleportToIsland(Config.SelectedIsland) end
})

TeleportTab:AddSeparator({ Title = "NPC" })

local npcList = GetNPCList()
if (Config.SelectedNPC == "" or not table.find(npcList, Config.SelectedNPC)) and #npcList > 0 then
    Config.SelectedNPC = npcList[1]
end

TeleportTab:AddDropdown({
    Title = "Select NPC",
    Description = "Chọn NPC",
    Options = npcList,
    Default = Config.SelectedNPC ~= "" and Config.SelectedNPC or (npcList[1] or ""),
    Multi = false,
    Callback = function(v) Config.SelectedNPC = v or "" SaveConfig() end
})

TeleportTab:AddButton({
    Title = "Teleport To NPC",
    Callback = function() TeleportToNPC(Config.SelectedNPC) end
})

ShopTab:AddSeparator({ Title = "SELLING" })

ShopTab:AddToggle({
    Title = "Auto Sell All",
    Description = "Tự động bán cá",
    Default = Config.AutoSell,
    Callback = function(v)
        Config.AutoSell = v
        if not v then lastSellTime = 0 end
        SaveConfig()
    end
})

ShopTab:AddSlider({
    Title = "Sell Delay (min)",
    Description = "Thời gian chờ bán (phút)",
    Min = 1, Max = 10, Default = math.clamp(tonumber(Config.SellDelay) or 1, 1, 10), Suffix = "m",
    Callback = function(v) Config.SellDelay = v SaveConfig() end
})

ShopTab:AddButton({ Title = "Sell All Fish", Callback = function() SellFish:FireServer("All") end })
ShopTab:AddButton({ Title = "Sell One Fish", Callback = function() SellFish:FireServer("One") end })

ShopTab:AddSeparator({ Title = "BUY BAIT" })

local buyBaitList = GetBuyableBaits()
if Config.SelectedBuyBait == "" and #buyBaitList > 0 then Config.SelectedBuyBait = buyBaitList[1] end

ShopTab:AddDropdown({
    Title = "Select Bait",
    Description = "Chọn mồi để mua",
    Options = buyBaitList,
    Default = Config.SelectedBuyBait ~= "" and Config.SelectedBuyBait or (buyBaitList[1] or ""),
    Multi = false,
    Callback = function(v) Config.SelectedBuyBait = v or "" SaveConfig() end
})

ShopTab:AddTextbox({
    Title = "Buy Amount",
    Description = "Số lượng mua",
    Placeholder = "1",
    Default = tostring(Config.BuyBaitAmount or 1),
    Callback = function(v) Config.BuyBaitAmount = math.max(1, math.floor(tonumber(v) or 1)) SaveConfig() end
})

ShopTab:AddToggle({
    Title = "Auto Buy Bait",
    Description = "Tự động mua mồi",
    Default = Config.AutoBuyBait,
    Callback = function(v) Config.AutoBuyBait = v SaveConfig() end
})

ShopTab:AddButton({ Title = "Buy Bait", Callback = function() DoBuyBait(Config.SelectedBuyBait, Config.BuyBaitAmount) end })

ShopTab:AddSeparator({ Title = "CRAFT BAIT" })

local baitList = GetCraftableBaits()
if Config.SelectedBait == "" and #baitList > 0 then Config.SelectedBait = baitList[1] end

ShopTab:AddDropdown({
    Title = "Select Bait",
    Description = "Chọn mồi để chế",
    Options = baitList,
    Default = Config.SelectedBait ~= "" and Config.SelectedBait or (baitList[1] or ""),
    Multi = false,
    Callback = function(v) Config.SelectedBait = v or "" SaveConfig() end
})

ShopTab:AddTextbox({
    Title = "Craft Amount",
    Description = "Số lượng chế",
    Placeholder = "1",
    Default = tostring(Config.BaitAmount or 1),
    Callback = function(v) Config.BaitAmount = math.max(1, math.floor(tonumber(v) or 1)) SaveConfig() end
})

ShopTab:AddToggle({
    Title = "Auto Craft Bait",
    Description = "Tự động chế mồi",
    Default = Config.AutoCraftBait,
    Callback = function(v) Config.AutoCraftBait = v SaveConfig() end
})

ShopTab:AddButton({
    Title = "Craft Bait",
    Callback = function()
        if Config.SelectedBait ~= "" then
            CraftBaitEvent:FireServer(Config.SelectedBait, math.max(1, math.floor(tonumber(Config.BaitAmount) or 1)))
        end
    end
})

ShopTab:AddSeparator({ Title = "CRAFT ROD" })

local rodList = GetCraftableRods()
if Config.SelectedRod == "" and #rodList > 0 then Config.SelectedRod = rodList[1] end

ShopTab:AddDropdown({
    Title = "Select Rod",
    Description = "Chọn cần để chế",
    Options = rodList,
    Default = Config.SelectedRod ~= "" and Config.SelectedRod or (rodList[1] or ""),
    Multi = false,
    Callback = function(v) Config.SelectedRod = v or "" SaveConfig() end
})

ShopTab:AddToggle({
    Title = "Auto Craft Rod",
    Description = "Tự động chế cần",
    Default = Config.AutoCraftRod,
    Callback = function(v) Config.AutoCraftRod = v SaveConfig() end
})

ShopTab:AddButton({
    Title = "Craft Rod",
    Callback = function()
        if Config.SelectedRod ~= "" then CraftRodEvent:FireServer(Config.SelectedRod) end
    end
})

ESPTab:AddSeparator({ Title = "PLAYER ESP" })

ESPTab:AddToggle({
    Title = "ESP Players",
    Description = "Hiện tên người chơi",
    Default = Config.ESPEnabled,
    Callback = function(v)
        Config.ESPEnabled = v
        SaveConfig()
        if not v then clearPlayerESP() end
    end
})

MiscTab:AddSeparator({ Title = "VISUAL" })

MiscTab:AddToggle({
    Title = "FullBright",
    Description = "Ánh sáng đầy đủ",
    Default = Config.FullBright,
    Callback = function(v)
        Config.FullBright = v
        SaveConfig()
        if v then ApplyLightingSettings()
        else
            RestoreFullBright()
            if Config.NoFog then ApplyLightingSettings() end
        end
    end
})

MiscTab:AddToggle({
    Title = "No Fog",
    Description = "Tắt sương mù",
    Default = Config.NoFog,
    Callback = function(v)
        Config.NoFog = v
        SaveConfig()
        if v then ApplyLightingSettings()
        else
            RestoreNoFog()
            if Config.FullBright then ApplyLightingSettings() end
        end
    end
})

MiscTab:AddSeparator({ Title = "HIDE INFO" })

MiscTab:AddToggle({
    Title = "Hide Name",
    Description = "Đổi tên hiển thị trên đầu thành tên tùy chỉnh",
    Default = Config.HideName,
    Callback = function(v)
        Config.HideName = v
        SaveConfig()
        if v then ApplyHideName(LocalPlayer.Character)
        else RestoreHideName() end
    end
})

MiscTab:AddTextbox({
    Title = "Custom Name",
    Description = "Tên hiển thị khi bật Hide Name",
    Placeholder = "DN Hub Private",
    Default = Config.HideNameText or "DN Hub Private",
    Callback = function(v)
        Config.HideNameText = tostring(v ~= "" and v or "DN Hub Private")
        SaveConfig()
        if Config.HideName then
            ApplyHideName(LocalPlayer.Character)
        end
    end
})

MiscTab:AddToggle({
    Title = "Hide Level",
    Description = "Đổi text Level trong PlayerGui thành nội dung tùy chỉnh",
    Default = Config.HideLevel,
    Callback = function(v)
        Config.HideLevel = v
        SaveConfig()
        if v then
            ApplyHideLevel()
            RefreshHideLevelWatcher()
        else
            RestoreHideLevel()
        end
    end
})

MiscTab:AddTextbox({
    Title = "Custom Level Text",
    Description = "Nội dung thay thế cho Level",
    Placeholder = "Protected by DNHub",
    Default = Config.HideLevelText or "Protected by DNHub",
    Callback = function(v)
        Config.HideLevelText = tostring(v ~= "" and v or "Protected by DNHub")
        SaveConfig()
        if Config.HideLevel then
            ApplyHideLevel()
        end
    end
})

MiscTab:AddSeparator({ Title = "CODES" })

MiscTab:AddToggle({
    Title = "Auto Redeem Codes",
    Description = "Tự động redeem code mỗi chu kỳ",
    Default = Config.AutoRedeem,
    Callback = function(v) Config.AutoRedeem = v SaveConfig() end
})

MiscTab:AddSlider({
    Title = "Redeem Interval",
    Description = "Chu kỳ kiểm tra (giây)",
    Min = 10, Max = 120, Default = Config.RedeemInterval, Suffix = "s",
    Callback = function(v) Config.RedeemInterval = v SaveConfig() end
})

MiscTab:AddButton({ Title = "Redeem All Codes", Callback = function() RedeemAllCodes() end })

SettingsTab:AddSeparator({ Title = "KEYBINDS" })

SettingsTab:AddToggle({
    Title = "Disable Keybinds",
    Description = "Tắt toàn bộ phím tắt",
    Default = Config.DisableAllKeybinds or false,
    Callback = function(v) Config.DisableAllKeybinds = v SaveConfig() end
})

SettingsTab:AddKeybind({
    Title = "Fly Keybind",
    Description = "Phím bật/tắt Fly",
    Default = Config.FlyKeybind or "F",
    Callback = function(Key)
        if not Config.DisableAllKeybinds and Config.FlyKeybindEnabled ~= false then
            if Config.FlyEnabled then stopFly() else startFly() end
            Config.FlyEnabled = not Config.FlyEnabled
            SaveConfig()
        end
    end
})

SettingsTab:AddKeybind({
    Title = "Noclip Keybind",
    Description = "Phím bật/tắt Noclip",
    Default = Config.NoclipKeybind or "J",
    Callback = function(Key)
        if not Config.DisableAllKeybinds and Config.NoclipKeybindEnabled ~= false then
            Config.NoclipEnabled = not Config.NoclipEnabled
            SaveConfig()
        end
    end
})

UserInputService.InputBegan:Connect(function(input, gpe)
    if Config.DisableAllKeybinds then return end
    if UserInputService:GetFocusedTextBox() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local flyKey = Enum.KeyCode[Config.FlyKeybind] or Enum.KeyCode.F
        local noclipKey = Enum.KeyCode[Config.NoclipKeybind] or Enum.KeyCode.J
        if Config.FlyKeybindEnabled ~= false and input.KeyCode == flyKey then
            if Config.FlyEnabled then stopFly() else startFly() end
            Config.FlyEnabled = not Config.FlyEnabled
            SaveConfig()
        elseif Config.NoclipKeybindEnabled ~= false and input.KeyCode == noclipKey then
            Config.NoclipEnabled = not Config.NoclipEnabled
            SaveConfig()
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if Config.AutoRedeem then
            RedeemAllCodes()
            task.wait(Config.RedeemInterval)
        end
    end
end)

Window:Notify({
    Title = "DN Hub Private",
    Description = "Loaded successfully! Heavyweight Fishing",
    Status = "ON",
    Duration = 5
})
