local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Support semua executor (Delta aman)
local hiddenUI = game:GetService("CoreGui")
pcall(function() hiddenUI = gethui() end)

-- GODMODE
local function enableGodMode()
    humanoid.MaxHealth = 9e9
    humanoid.Health = 9e9
    humanoid.HealthChanged:Connect(function() if humanoid.Health < 9e9 then humanoid.Health = 9e9 end end)
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

-- Variable
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

-- RAYFIELD TERBARU (April 2026)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🌸 CekayCantik V3 🌸",
    LoadingTitle = "CekayCantik",
    LoadingSubtitle = "Rayfield Build 1.72 • April 2026",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 4483362458)

local FlyToggle = MainTab:CreateToggle({
    Name = "Fly (F)",
    CurrentValue = false,
    Callback = function(Value) if Value then startFly() else stopFly() end end
})

local AuraToggle = MainTab:CreateToggle({
    Name = "Aura Kill (V)",
    CurrentValue = false,
    Callback = function(Value) if Value then startAuraKill() else stopAuraKill() end end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {50, 300},
    Increment = 10,
    CurrentValue = 130,
    Callback = function(Value) flySpeed = Value end
})

MainTab:CreateSlider({
    Name = "Aura Range",
    Range = {20, 100},
    Increment = 5,
    CurrentValue = 55,
    Callback = function(Value) auraRange = Value end
})

-- Joystick (mobile) - sekarang pake hiddenUI biar aman
local JoystickFrame = Instance.new("Frame")
JoystickFrame.Size = UDim2.new(0, 190, 0, 190)
JoystickFrame.Position = UDim2.new(0, 30, 1, -220)
JoystickFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
JoystickFrame.BackgroundTransparency = 0.3
JoystickFrame.Visible = false
JoystickFrame.Parent = hiddenUI

local JoyCorner = Instance.new("UICorner")
JoyCorner.CornerRadius = UDim.new(1, 0)
JoyCorner.Parent = JoystickFrame

local JoystickKnob = Instance.new("Frame")
JoystickKnob.Size = UDim2.new(0, 70, 0, 70)
JoystickKnob.Position = UDim2.new(0.5, -35, 0.5, -35)
JoystickKnob.BackgroundColor3 = Color3.fromRGB(255, 90, 190)
JoystickKnob.BackgroundTransparency = 0.2
JoystickKnob.Parent = JoystickFrame

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = JoystickKnob

-- Joystick logic
local function updateJoystick(input)
    if not flying then return end
    local absPos = JoystickFrame.AbsolutePosition
    local absSize = JoystickFrame.AbsoluteSize
    local center = absSize / 2
    local relative = input.Position - absPos
    local offset = relative - center
    local radius = absSize.X / 2 * 0.82
    if offset.Magnitude > radius then offset = offset.Unit * radius end
    JoystickKnob.Position = UDim2.new(0, center.X + offset.X - 35, 0, center.Y + offset.Y - 35)
    local dir2D = offset / radius
    local forward = -dir2D.Y
    local right = dir2D.X
    local cam = workspace.CurrentCamera
    moveVector = (cam.CFrame.LookVector * forward) + (cam.CFrame.RightVector * right)
end

JoystickFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not currentTouch then
        currentTouch = input
        joystickActive = true
        updateJoystick(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == currentTouch then updateJoystick(input) end
end)

JoystickFrame.InputEnded:Connect(function(input)
    if input == currentTouch then
        currentTouch = nil
        joystickActive = false
        moveVector = Vector3.new(0,0,0)
        JoystickKnob.Position = UDim2.new(0.5, -35, 0.5, -35)
    end
end)

-- Fly & Aura Functions
local function startFly()
    if flying then return end
    flying = true
    humanoid.PlatformStand = true
    JoystickFrame.Visible = true
    bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(1e6,1e6,1e6); bv.Velocity = Vector3.new(); bv.Parent = rootPart
    bg = Instance.new("BodyGyro"); bg.MaxTorque = Vector3.new(1e6,1e6,1e6); bg.P = 12000; bg.Parent = rootPart
    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying then return end
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new()
        if keys.W then moveDir += cam.CFrame.LookVector end
        if keys.S then moveDir -= cam.CFrame.LookVector end
        if keys.A then moveDir -= cam.CFrame.RightVector end
        if keys.D then moveDir += cam.CFrame.RightVector end
        if keys.Space then moveDir += Vector3.new(0,1,0) end
        if keys.LeftControl then moveDir -= Vector3.new(0,1,0) end
        if joystickActive then moveDir += moveVector end
        bv.Velocity = moveDir.Magnitude > 0 and moveDir.Unit * flySpeed or Vector3.new()
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    humanoid.PlatformStand = false
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    JoystickFrame.Visible = false
    joystickActive = false
    moveVector = Vector3.new(0,0,0)
    FlyToggle:Set(false)
end

local function startAuraKill()
    if auraEnabled then return end
    auraEnabled = true
    auraConn = RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr \~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
                local hum = plr.Character.Humanoid
                if hum.Health > 0 then
                    local dist = (plr.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                    if dist <= auraRange then
                        hum.Health = 0
                        plr.Character:BreakJoints()
                    end
                end
            end
        end
    end)
end

local function stopAuraKill()
    auraEnabled = false
    if auraConn then auraConn:Disconnect() auraConn = nil end
    AuraToggle:Set(false)
end

-- Keybind
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.F then FlyToggle:Set(not flying)
    elseif kc == Enum.KeyCode.V then AuraToggle:Set(not auraEnabled)
    elseif kc == Enum.KeyCode.W then keys.W = true
    elseif kc == Enum.KeyCode.A then keys.A = true
    elseif kc == Enum.KeyCode.S then keys.S = true
    elseif kc == Enum.KeyCode.D then keys.D = true
    elseif kc == Enum.KeyCode.Space then keys.Space = true
    elseif kc == Enum.KeyCode.LeftControl then keys.LeftControl = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.W then keys.W = false
    elseif kc == Enum.KeyCode.A then keys.A = false
    elseif kc == Enum.KeyCode.S then keys.S = false
    elseif kc == Enum.KeyCode.D then keys.D = false
    elseif kc == Enum.KeyCode.Space then keys.Space = false
    elseif kc == Enum.KeyCode.LeftControl then keys.LeftControl = false
    end
end)

Rayfield:Notify({Title = "✅ CekayCantik V3 Loaded!", Content = "Rayfield Build 1.72 • F = Fly • V = Aura", Duration = 5, Image = 4483362458})

print("🌸 CekayCantik V3 (Rayfield 2026) Ready!")
