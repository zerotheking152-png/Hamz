local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local CoreGui = game:GetService("CoreGui")
local hiddenUI = CoreGui
pcall(function() hiddenUI = gethui() end)

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

local flying = false
local flySpeed = 120
local keys = {W = false, A = false, S = false, D = false, Space = false, LeftControl = false}
local bv, bg
local moveVector = Vector3.new(0,0,0)
local joystickActive = false
local currentTouch = nil

local auraEnabled = false
local auraRange = 50
local auraConn

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CekayCantikV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = hiddenUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 18, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 15, 65))
}
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 3
MainStroke.Color = Color3.fromRGB(255, 80, 200)
MainStroke.Transparency = 0.1
MainStroke.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "🌸 CekayCantik V2 🌸"
Title.TextColor3 = Color3.fromRGB(255, 110, 220)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 26
Title.Parent = MainFrame

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Thickness = 2
TitleStroke.Color = Color3.fromRGB(255, 200, 240)
TitleStroke.Parent = Title

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -45, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.new(1,1,1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 22
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Thickness = 2
CloseStroke.Color = Color3.fromRGB(255, 100, 120)
CloseStroke.Parent = CloseButton

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(0.85, 0, 0, 58)
FlyButton.Position = UDim2.new(0.075, 0, 0, 75)
FlyButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.new(1, 1, 1)
FlyButton.Font = Enum.Font.GothamSemibold
FlyButton.TextSize = 21
FlyButton.Parent = MainFrame

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 14)
FlyCorner.Parent = FlyButton

local FlyStroke = Instance.new("UIStroke")
FlyStroke.Thickness = 2
FlyStroke.Color = Color3.fromRGB(255, 255, 255)
FlyStroke.Parent = FlyButton

local AuraButton = Instance.new("TextButton")
AuraButton.Size = UDim2.new(0.85, 0, 0, 58)
AuraButton.Position = UDim2.new(0.075, 0, 0, 145)
AuraButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
AuraButton.Text = "Aura Kill: OFF"
AuraButton.TextColor3 = Color3.new(1, 1, 1)
AuraButton.Font = Enum.Font.GothamSemibold
AuraButton.TextSize = 21
AuraButton.Parent = MainFrame

local AuraCorner = Instance.new("UICorner")
AuraCorner.CornerRadius = UDim.new(0, 14)
AuraCorner.Parent = AuraButton

local AuraStroke = Instance.new("UIStroke")
AuraStroke.Thickness = 2
AuraStroke.Color = Color3.fromRGB(255, 255, 255)
AuraStroke.Parent = AuraButton

local JoystickFrame = Instance.new("Frame")
JoystickFrame.Size = UDim2.new(0, 180, 0, 180)
JoystickFrame.Position = UDim2.new(0, 25, 1, -210)
JoystickFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
JoystickFrame.BackgroundTransparency = 0.2
JoystickFrame.Visible = false
JoystickFrame.Parent = ScreenGui

local JoyCorner = Instance.new("UICorner")
JoyCorner.CornerRadius = UDim.new(1, 0)
JoyCorner.Parent = JoystickFrame

local JoystickKnob = Instance.new("Frame")
JoystickKnob.Size = UDim2.new(0, 65, 0, 65)
JoystickKnob.Position = UDim2.new(0.5, -32.5, 0.5, -32.5)
JoystickKnob.BackgroundColor3 = Color3.fromRGB(255, 110, 200)
JoystickKnob.BackgroundTransparency = 0.25
JoystickKnob.Parent = JoystickFrame

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = JoystickKnob

local function updateJoystick(input)
    if not flying then return end
    local absPos = JoystickFrame.AbsolutePosition
    local absSize = JoystickFrame.AbsoluteSize
    local center = absSize / 2
    local relative = input.Position - absPos
    local offset = relative - center
    local radius = absSize.X / 2 * 0.8
    if offset.Magnitude > radius then offset = offset.Unit * radius end
    JoystickKnob.Position = UDim2.new(0, center.X + offset.X - 32.5, 0, center.Y + offset.Y - 32.5)
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
        JoystickKnob.Position = UDim2.new(0.5, -32.5, 0.5, -32.5)
    end
end)

local flyConnection
local function startFly()
    if flying then return end
    flying = true
    humanoid.PlatformStand = true
    JoystickFrame.Visible = true
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e6,1e6,1e6)
    bv.Velocity = Vector3.new()
    bv.Parent = rootPart
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
    bg.P = 12000
    bg.Parent = rootPart
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
    if flyConnection then flyConnection:Disconnect() end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    JoystickFrame.Visible = false
    joystickActive = false
    moveVector = Vector3.new(0,0,0)
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
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.F then
        if flying then stopFly() else startFly() end
    elseif kc == Enum.KeyCode.V then
        if auraEnabled then stopAuraKill() else startAuraKill() end
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

FlyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        FlyButton.Text = "Fly: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    else
        startFly()
        FlyButton.Text = "Fly: ON"
        FlyButton.BackgroundColor3 = Color3.fromRGB(40, 220, 80)
    end
end)

AuraButton.MouseButton1Click:Connect(function()
    if auraEnabled then
        stopAuraKill()
        AuraButton.Text = "Aura Kill: OFF"
        AuraButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    else
        startAuraKill()
        AuraButton.Text = "Aura Kill: ON"
        AuraButton.BackgroundColor3 = Color3.fromRGB(40, 220, 80)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
