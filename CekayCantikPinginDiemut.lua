local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- GODMODE
local function enableGodMode()
    humanoid.MaxHealth = 9e9
    humanoid.Health = 9e9
    humanoid.HealthChanged:Connect(function()
        if humanoid.Health < 9e9 then
            humanoid.Health = 9e9
        end
    end)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
end
enableGodMode()

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    humanoid = newChar:WaitForChild("Humanoid")
    enableGodMode()
end)

-- VARIABLE
local flying = false
local flySpeed = 130
local keys = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}
local bv, bg, flyConnection
local moveVector = Vector3.new(0,0,0)
local joystickActive = false
local currentTouch = nil
local auraEnabled = false
local auraRange = 55
local auraConn

-- NEW: PUSH PLAYER
local pushEnabled = false
local pushConn
local pushRange = 55
local pushStrength = 250

-- NEW: TELEPORT SYSTEM
local selectedPlayer = nil
local teleportEnabled = false
local teleportConn = nil

local function getAllPlayers()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= player then
            table.insert(list, plr.Name)
        end
    end
    table.sort(list) -- urut alfabet biar rapi
    return list
end

-- LOAD RAYFIELD
local function loadRayfield()
    local urls = {
        "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
        "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"
    }

    for _, url in ipairs(urls) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success and result then
            return result
        end
    end
    return nil
end

local Rayfield = loadRayfield()

if not Rayfield then
    warn("❌ Rayfield gagal load")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "🌸 CekayCantik V3 🌸",
    LoadingTitle = "CekayCantik",
    LoadingSubtitle = "FINAL FIX",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

-- ==================== PLAYER TAB (SEMUA FITUR + PUSH) ====================
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- JOYSTICK (FIXED MOBILE)
local JoystickFrame = Instance.new("Frame")
JoystickFrame.Size = UDim2.new(0, 190, 0, 190)
JoystickFrame.Position = UDim2.new(0, 30, 1, -220)
JoystickFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
JoystickFrame.BackgroundTransparency = 0.4
JoystickFrame.BorderSizePixel = 0
JoystickFrame.Visible = false
JoystickFrame.Parent = player:WaitForChild("PlayerGui")

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(1, 0)
outerCorner.Parent = JoystickFrame

local JoystickInner = Instance.new("Frame")
JoystickInner.Size = UDim2.new(0, 70, 0, 70)
JoystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
JoystickInner.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
JoystickInner.BackgroundTransparency = 0.1
JoystickInner.BorderSizePixel = 0
JoystickInner.Parent = JoystickFrame

local innerCorner = Instance.new("UICorner")
innerCorner.CornerRadius = UDim.new(1, 0)
innerCorner.Parent = JoystickInner

local function updateJoystick(position)
    local center = JoystickFrame.AbsolutePosition + JoystickFrame.AbsoluteSize/2
    local pos2D = Vector2.new(position.X, position.Y)
    local direction = (pos2D - center)
    local maxRadius = 80

    if direction.Magnitude > maxRadius then
        direction = direction.Unit * maxRadius
    end

    JoystickInner.Position = UDim2.new(0.5, direction.X - 35, 0.5, direction.Y - 35)

    local right = direction.X / maxRadius
    local forward = -direction.Y / maxRadius
    moveVector = Vector3.new(right, 0, forward)
end

JoystickFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        joystickActive = true
        currentTouch = input
        updateJoystick(input.Position)
    end
end)

JoystickFrame.InputChanged:Connect(function(input)
    if input == currentTouch then
        updateJoystick(input.Position)
    end
end)

JoystickFrame.InputEnded:Connect(function(input)
    if input == currentTouch then
        joystickActive = false
        currentTouch = nil
        moveVector = Vector3.new(0,0,0)
        JoystickInner.Position = UDim2.new(0.5, -35, 0.5, -35)
    end
end)

-- FLY (SUDAH FIX GERAK MOBILE + PC)
function startFly()
    if flying then return end
    flying = true
    humanoid.PlatformStand = true
    JoystickFrame.Visible = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Parent = rootPart

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P = 12000
    bg.Parent = rootPart

    flyConnection = RunService.RenderStepped:Connect(function()
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()

        if keys.W then moveDir += cam.CFrame.LookVector end
        if keys.S then moveDir -= cam.CFrame.LookVector end
        if keys.A then moveDir -= cam.CFrame.RightVector end
        if keys.D then moveDir += cam.CFrame.RightVector end
        if keys.Space then moveDir += Vector3.new(0,1,0) end
        if keys.LeftControl then moveDir -= Vector3.new(0,1,0) end

        if joystickActive then
            moveDir += cam.CFrame.RightVector * moveVector.X + cam.CFrame.LookVector * moveVector.Z
        end

        bv.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.new()
        bg.CFrame = cam.CFrame
    end)
end

function stopFly()
    flying = false
    humanoid.PlatformStand = false
    if flyConnection then flyConnection:Disconnect() end
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    JoystickFrame.Visible = false
end

-- AURA
function startAuraKill()
    if auraEnabled then return end
    auraEnabled = true
    auraConn = RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if dist <= auraRange then
                    plr.Character:BreakJoints()
                end
            end
        end
    end)
end

function stopAuraKill()
    auraEnabled = false
    if auraConn then auraConn:Disconnect() end
end

-- PUSH PLAYER
function startPush()
    if pushEnabled then return end
    pushEnabled = true
    pushConn = RunService.Heartbeat:Connect(function()
        if not rootPart then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = plr.Character.HumanoidRootPart
                local dist = (targetRoot.Position - rootPart.Position).Magnitude
                if dist <= pushRange and dist > 1 then
                    local dir = (targetRoot.Position - rootPart.Position).Unit
                    targetRoot.AssemblyLinearVelocity += dir * pushStrength
                end
            end
        end
    end)
end

function stopPush()
    pushEnabled = false
    if pushConn then 
        pushConn:Disconnect() 
        pushConn = nil 
    end
end

-- UI PLAYER TAB
PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Callback = function(v) 
        if v then startFly() else stopFly() end 
    end
})

PlayerTab:CreateToggle({
    Name = "Aura",
    CurrentValue = false,
    Callback = function(v) 
        if v then startAuraKill() else stopAuraKill() end 
    end
})

PlayerTab:CreateToggle({
    Name = "Push Player",
    CurrentValue = false,
    Callback = function(v) 
        if v then startPush() else stopPush() end 
    end
})

PlayerTab:CreateSlider({
    Name = "Speed",
    Range = {50,300},
    CurrentValue = 130,
    Callback = function(v) flySpeed = v end
})

-- ==================== TELEPORT TAB (BARU SESUAI REQUEST) ====================
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- Dropdown Select Player (bisa di-scroll atas bawah)
local playerListOptions = getAllPlayers()
local playerDropdown = TeleportTab:CreateDropdown({
    Name = "Select Player",
    Options = playerListOptions,
    CurrentOption = {},
    MultipleOptions = false,
    Callback = function(CurrentOption)
        if CurrentOption and #CurrentOption > 0 then
            selectedPlayer = Players:FindFirstChild(CurrentOption[1])
        else
            selectedPlayer = nil
        end
    end
})

-- Refresh Button (wajib pencet dulu biar list update)
TeleportTab:CreateButton({
    Name = "🔄 Refresh Player List",
    Callback = function()
        local newOptions = getAllPlayers()
        playerDropdown:Refresh(newOptions)
        selectedPlayer = nil -- reset pilihan kalau ada player keluar
    end
})

-- Toggle Teleport to Selected Player (On/Off)
TeleportTab:CreateToggle({
    Name = "Teleport to Selected Player",
    CurrentValue = false,
    Callback = function(Value)
        teleportEnabled = Value
        if Value then
            if teleportConn then teleportConn:Disconnect() end
            teleportConn = RunService.Heartbeat:Connect(function()
                if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and rootPart then
                    rootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                end
            end)
        else
            if teleportConn then
                teleportConn:Disconnect()
                teleportConn = nil
            end
        end
    end
})

-- KEYBIND
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        if flying then stopFly() else startFly() end
    elseif input.KeyCode == Enum.KeyCode.V then
        if auraEnabled then stopAuraKill() else startAuraKill() end
    elseif keys[input.KeyCode.Name] \~= nil then
        keys[input.KeyCode.Name] = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if keys[input.KeyCode.Name] \~= nil then
        keys[input.KeyCode.Name] = false
    end
end)
